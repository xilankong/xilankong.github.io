---
layout: post
category: 2018年
title : "iOS开源项目-AFNetworking"
---



> 整理AF源码学习过程，和自己封装的基于AF的API库



## AFNetworking v3.1.0

> 从需求开始逐个分析AFNetworking v3.1.0
>

### AFNetworking的类结构图



![img](https://xilankong.github.io/resource/afnetworking.png)







### 1、NSURLSession 了解

#### 相关类

```
NSURLSession

NSURLSessionConfiguration

NSURLSessionDelegate

NSURLSessionTask

NSURLSessionTaskMetrics

NSURLSessionTaskTransactionMetrics
```

#### 关系图

![img](https://xilankong.github.io/resource/urlsession.png)



#### NSURLSessionDelegate

![img](https://xilankong.github.io/resource/sessiondelegate.png)



#### NSURLSessionTask

![img](https://xilankong.github.io/resource/datatask.png)



### 1、基本使用与实现原理

#### 通过 AFURLSessionManager 实现

```
1、继承自NSObject，以组合的方式包装NSURLSession

2、提供工厂，但是不是单例，根据 NSURLSessionConfiguration 初始化

3、多线程采用NSOperationQueue，默认最大并发数为1

4、默认JSON类型响应序列化

4、提供数据、上传、下载三种业务


```

NSURLSessionTask 包含三种不同类型任务：NSURLSessionDataTask、NSURLSessionUploadTask、NSURLSessionDownloadTask。AFURLSessionManager 也因此分为三种业务：

```
///////数据////////
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;
                            
////////上传///////                       
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler;
                                
///////下载////////                             
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;
```

#### 通过 AFHTTPSessionManager 实现

```
1、继承自AFURLSessionManager，专门用来实现HTTPS协议，提供了POST、GET、HEAD、DELETE、PUT、PATCH等方便方法。具体的实现都直接或者间接调用了父类AFURLSessionManager数据业务的方法，下载和上传业务没有涉及。

2、在父类AFURLSessionManager的基础上隐藏了NSURLRequest的概念，简化为urlString，并且是相对于baseURL的相对路径，会在内部进行拼接，形成一个完整的urlString。

3、直接根据url初始化 AFHTTPSessionManager，提供工厂，但是不是单例
```

构建网络请求的方式

```
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure DEPRECATED_ATTRIBUTE;
```



请求知道如何构建了，我们看一看底层具体的实现原理

#### 请求的底层原理

AFNetworking的操作都是基于NSURLSession， 基本逻辑：

```
let url = URL(string: "http://rap2api.taobao.org/app/mock/117041/mock")!

var request = URLRequest(url: url)
request.httpMethod = "POST"

let session = URLSession.shared
let dataTask = session.dataTask(with: request) { (data, resp, error) in
    print(data)
}

dataTask.resume()
```

我们具体分析整个逻辑上的细节：

```
AF中声明了几个静态的C语言函数

url_session_manager_creation_queue： 单例 串行队列 专用于构建操作

url_session_manager_create_task_safely：用上面构建的队列顺序构建task

url_session_manager_processing_queue：单例 并行队列 专用于 任务响应解析

url_session_manager_completion_group：单例 队列组
```



**1、AFURLSessionManager的构建**

```
1、根据 NSURLSessionConfiguration 初始化

2、配置线程队列 NSOperationQueue，默认最大并发数为 1 

3、NSURLSessionConfiguration 和 队列 构建 NSURLSession，@synchronized 锁

4、配置响应序列化，默认JSON类型

5、配置安全策略

6、锁 NSLock
```

**2、NSMutableURLRequest构建（如果是通过AFHTTPSessionManager 构建请求）**

```
URL拼接，参数配置，请求头配置等操作
```

**3、NSURLSessionDataTask的构建**

```
1、构建task的时候会使用  url_session_manager_create_task_safely 来保证安全构建任务

2、AFURLSessionManagerTaskDelegate 代理初始化
代理通过manager 弱持有sessionManager
代理完成 上传、下载的 NSProgress设置
NSProgress 取消、挂起、运行 关联task 的block设置 (weak持有 task)
NSProgress fractionCompleted(某个任务已完成单元量占总单元量的比例) 监听设置

3、mutableTaskDelegatesKeyedByTaskIdentifier 添加代理键值对 (有锁)

通过全局字典保存任务代理，task.taskIdentifier 为 key， AFURLSessionManagerTaskDelegate 代理 为 value

4、Task通知监听添加，监听 taskDidResume 和 taskDidSuspend (有锁)

```

**4、NSURLSessionTask执行**

NSURLSessionTask 不能直接初始化，它有两个子类，NSURLSessionDataTask、NSURLSessionDownloadTask，NSURLSessionDataTask 有个子类 NSURLSessionUploadTask。

任务执行：[task resume]；

```
AFURLSessionManagerTaskDelegate 处理网络请求回调

SessionManager实现了 NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate

请求结果的回调会在 SessionManager 中处理
SessionManager定义的回调block也在这处理
AFURLSessionManagerTaskDelegate 的对响应结果部分的处理也通过 SessionManager 进行代理转发
```

**5、AFURLSessionManager清理NSURLSessionDataTask**

```
请求结束后进行清理，清理操作都有加锁 removeDelegateForTask

removeNotificationObserverForTask  移除通知
mutableTaskDelegatesKeyedByTaskIdentifier  移除代理键值对
```



### 2、任务进度设置和通知监听、代理转发等请求扩展需求

上面提到的NSURLSessionDataTask执行后会回调回SessionManager

**Session 层次的回调(定义在 NSURLSessionTaskDelegate)**

```

1、URLSession:didBecomeInvalidWithError: 无效请求


2、URLSession:didReceiveChallenge:completionHandler:

当一个服务器请求身份验证或TLS握手期间需要提供证书的话

如果远程服务器返回一个状态值表明需要进行认证或者认证需要特定的环境(例如一个SSL客户端证书),NSURLSession调用会调用一个认证相关的代理方法。(Https请求都会调用)

如果没有实现该方法，URLSession就会这么做 :

使用身份认证信息作为请求URL的一部分(如果可用的话)

在用户的keychain中查找网络密码和证书(in macOS), 在app的keychain中查找(in iOS)



3、URLSessionDidFinishEventsForBackgroundURLSession:

在iOS中使用NSURLSession,当一个下载任务完成时,app将会自动重启.app代理方法application:handleEventsForBackgroundURLSession:completionHandler:负责重建合适的会话,存储完成处理块,并在会话对象调用会话代理的URLSessionDidFinishEventsForBackgroundURLSession:方法时调用完成处理块.
```

**Task 层次的回调**

**NSURLSessionTaskDelegate 协议 回调** 

```
1、URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler

HTTP 重定向

2、URLSession:task:didReceiveChallenge：completionHandler: 

Task 任务层次的授权、证书问题

如果远程服务器返回一个状态值表明需要进行认证或者认证需要特定的环境(例如一个SSL客户端证书),NSURLSession调用会调用一个认证相关的代理方法。(Https请求都会调用)

身份验证问题，处理服务器身份验证请求时需要的信息。你可以通过提供NSURLCredential对象来做身份验证工作。 AF基于 securityPolicy 做判断

3、URLSession:task:needNewBodyStream:

如果app使用流作为请求体,还必须提供一个自定义会话代理实现
当以流的形式上传，认证失败，任务将不再在重要该流进行上传。通过下面方法获取新的NSInputStream 

4、URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:

方法来获取上传进度信息

5、URLSession:task:didCompleteWithError: 

任务结束，成功或者失败都会调用

6、URLSession:task:didFinishCollectingMetrics

```

**NSURLSessionDataDelegate 协议 回调**

```

1、URLSession:dataTask:didReceiveResponse:completionHandler 

接受响应，回调响应接收block

2、URLSession:dataTask:didBecomeDownloadTask

代理调整，删除原有任务，重新添加新的下载任务

3、URLSession:dataTask:didReceiveData 

提供了任务请求返回的数据,周期性的返回数据块, 如果app需要在方法返回之后使用数据, 必须用代码实现数据存储
AF代理到 AFURLSessionManagerTaskDelegate 中 统计下载进度。

4、URLSession:dataTask:willCacheResponse:completionHandler


5、URLSessionDidFinishEventsForBackgroundURLSession


```

**NSURLSessionDownloadDelegate 协议 回调**

```
1、URLSession:downloadTask:didFinishDownloadingToURL: 

提供app下载内容的临时存储目录

2、URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite 

提供了下载进度的状态信息

3、URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes 

告诉app尝试恢复之前失败的下载
```





1、继承自NSObject，以组合的方式包装NSURLSession

2、多线程采用NSOperationQueue，使用起来更方便，而且可以方便的实现顺序以来、取消等功能

3、提供工厂，但是不是单例

4、提供数据、上传、下载三种业务

3、序列化

4、额外的功能

#### 5、Category扩展部分



### 实现一个GET请求









NSURLSession



AFURLSessionManager



AFHTTPSessionManager









AFNetworking主要是对NSURLSession和NSURLConnection(iOS9.0废弃)的封装,其中主要有以下类:

1). AFHTTPRequestOperationManager：内部封装的是 NSURLConnection, 负责发送网络请求, 使用最多的一个类。(3.0废弃)

2). AFHTTPSessionManager：内部封装是 NSURLSession, 负责发送网络请求,使用最多的一个类。

3). AFNetworkReachabilityManager：实时监测网络状态的工具类。当前的网络环境发生改变之后,这个工具类就可以检测到。

4). AFSecurityPolicy：网络安全的工具类, 主要是针对 HTTPS 服务。

5). AFURLRequestSerialization：序列化工具类,基类。上传的数据转换成JSON格式    (AFJSONRequestSerializer).使用不多。

6). AFURLResponseSerialization：反序列化工具类;基类.使用比较多:

7). AFJSONResponseSerializer; JSON解析器,默认的解析器.

8). AFHTTPResponseSerializer; 万能解析器; JSON和XML之外的数据类型,直接返回二进

制数据.对服务器返回的数据不做任何处理.

9). AFXMLParserResponseSerializer; XML解析器;





网络缓存