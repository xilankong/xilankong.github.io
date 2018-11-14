---
layout: post
category: iOS开源项目

title : "iOS开源项目-原生网络请求和AFNetworking3.1学习"
---



> 学习AFNetworking之前， 整理一下iOS中的网络请求



## 1、NSURLConnection 了解

发起一个网络请求

```
NSURLConnection.sendAsynchronousRequest(URLRequest(url: URL(string: "http://rap2api.taobao.org/app/mock/117041/mock")!), queue: OperationQueue.main) { (resp, data, error) in
    print(resp)
}
```

已废弃就不再过多介绍

### NSURLSession 和  NSURLConnection 的区别

```
1、下载方式
NSURLConnection下载文件时，先是将整个文件下载到内存，然后再写入到沙盒，如果文件比较大，就会出现内存暴涨的情况。

而使用NSURLSessionDownloadTask下载文件，会默认下载到沙盒中的tem文件中，不会出现内存暴涨的情况，但是在下载完成后会把tem中的临时文件删除，需要在初始化任务方法时，在completionHandler回调中增加保存文件的代码。

2、控制方法
NSURLConnection实例化对象，实例化开始，默认请求就发送(同步发送),不需要调用start方法。而cancel可以停止请求的发送，停止后不能继续访问，需要创建新的请求。

NSURLSession有三个控制方法，取消(cancel)、暂停(suspend)、继续(resume)，暂停以后可以通过继续恢复当前的请求任务。

3、配置

NSURLSession的构造方法（sessionWithConfiguration:delegate:delegateQueue）中有一个NSURLSessionConfiguration类的参数可以设置配置信息，其决定了cookie，安全和高速缓存策略，最大主机连接数，资源管理，网络超时等配置。

NSURLConnection不能进行这个配置，NSURLConnection依赖与一个全局的配置对象

```





## 2、NSURLSession 了解

### 相关类关系图



![img](https://xilankong.github.io/resource/urlsession.png)



#### NSURLSession

```
1、sharedSession

全局共享单例session

2、+ sessionWithConfiguration:delegate:delegateQueue:
自定义session : 自定义配置文件, 设置代理, 大部分时间我们都是用这个

3、NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"xxx"];

_backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

后台session : 也是自定义session的一种, 只是他专门用于做后台上传/下载任务

session为哪一种类型完全由其内部的Configuration而定。
```



#### NSURLSessionConfiguration

```
1、defaultSessionConfiguration 

系统默认

2、ephemeralSessionConfiguration 

仅内存缓存, 不做磁盘缓存的配置

3、backgroundSessionConfiguration

这里需要指定一个identifier, identifier用来后台重连session对象 (做后台上传/下载就是这个config)

我们还可以给Configuration对象再自定义一些属性, 例如每端口的最大并发HTTP请求数目, 以及是否允许蜂窝网络, 请求缓存策略, 请求超时, cookies/证书存储策略等等
```



#### NSURLSessionDelegate

![img](https://xilankong.github.io/resource/sessiondelegate.png)



```
NSURLSessionDelegate : session-level的代理方法

NSURLSessionTaskDelegate : task-level面向all的代理方法

NSURLSessionDataDelegate : task-level面向data和upload的代理方法

NSURLSessionDownloadDelegate : task-level的面向download的代理方法

NSURLSessionStreamDelegate : task-level的面向stream的代理方法
```



#### NSURLSessionTask

![img](https://xilankong.github.io/resource/datatask.png)



```
NSURLSessionTask : Task的抽象基类

NSURLSessionDataTask : 以NSData的形式接收一个URLRequest的内容

NSURLSessionUploadTask : 上传NSData或者本地磁盘中的文件, 完成后以NSData的形式接收一个URLRequest的响应

NSURLSessionDownloadTask : 下载完成后返回临时文件在本地磁盘的URL路径

NSURLSessionStreamTask : 用于建立一个TCP/IP连接
```



#### NSURLSessionTaskMetrics 和 NSURLSessionTaskTransactionMetrics

对发送请求/DNS查询/TLS握手/请求响应等各种环节时间上的指标统计。 更易于我们检测, 分析我们App的请求缓慢到底是发生在哪个环节， 并对此进行优化提升我们APP的性能。

NSURLSessionTaskMetrics对象与NSURLSessionTask对象一一对应. 每个NSURLSessionTaskMetrics对象内有3个属性 :

- taskInterval : task从开始到结束总共用的时间
- redirectCount : task重定向的次数
- transactionMetrics : 一个task从发出请求到收到数据过程中派生出的每个子请求, 它是一个装着许多NSURLSessionTaskTransactionMetrics对象的数组，每个对象都代表下图的一个子过程。

![img](https://xilankong.github.io/resource/transactionmetrics.png)

API很简单, 就一个方法 : - (void)URLSession:task:didFinishCollectingMetrics:, 当收集完成的时候就会调用该方法。



### 身份验证和自定义TLS

1. 当一个服务器请求身份验证或TLS握手期间需要提供证书的话, URLSession会调用他的代理方法`URLSession:didReceiveChallenge:completionHandler:`去处理.

2. 如果你没有实现该代理方法, URLSession就会这么做 :

   ```
   - 使用身份认证信息作为请求URL的一部分(如果可用的话)
   
   - 在用户的keychain中查找网络密码和证书(in macOS), 在app的keychain中查找(in iOS)
   ```

3. 如果证书还是不可用或服务器拒绝该证书, 就会继续缺少身份认证的连接.

   ```
   - 对于HTTP(S)连接, 请求失败并返回一个状态码, 可能会提供一些替代的内容, 例如一个私人网站的公共网页.
   
   - 对于其他URL类型(如FTP等), 则连接请求失败, 直接返回错误信息
   ```


### App Transport Security

```
从iOS9开始支持ATS, 且默认ATS只支持发送HTTPS请求, 不允许发送不安全的HTTP请求. 如果用户需要发送HTTP请求需要在info.plist中配置 

<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```



### NSURLSession 工作流程

#### NSURLSession 发起一个网络请求

```
// 设置配置
NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
/** 设置其他配置属性 **/
 
// 代理队列
NSOperationQueue *queue = [NSOperationQueue mainQueue];
 
// 创建session
NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
 
// 利用session创建n个task
NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
// 开始
[task resume];
```

#### 身份验证或者 TLS握手

```
这是所有task都必须经历的一个过程. 当一个服务器请求身份验证或TLS握手期间需要提供证书的话, URLSession会调用他的代理方法URLSession:didReceiveChallenge:completionHandler:去处理., 另外, 如果连接途中收到服务器返回需要身份认证的response, 也会调用该代理方法。
```

#### 重定位response

```
这也是所有task都有可能经历的一个过程, 如果response是HTTP重定位, session会调用代理的

URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:方法

这里需要调用completionHandler 告诉 session 是否允许重定位, 或者重定位到另一个URL，或者传nil表示重定位的响应body有效并返回

如果代理没有实现该方法, 则允许重定位直到达到最大重定位次数。
```

#### DataTask

```
1. 对于一个data task来说, session会调用代理的URLSession:dataTask:didReceiveResponse:completionHandler:方法, 决定是否将一个data dask转换成download task, 然后调用completion回调继续接收data或下载data。

如果你的app选择转换成download task， session会调用代理的URLSession:dataTask:didBecomeDownloadTask:方法并把新的download task对象以方法参数的形式传给你。之后代理不会再收到data task的回调而是转为收到download task的回调。

2. 在服务器传输数据给客户端期间, 代理会周期性地收到URLSession:dataTask:didReceiveData:回调，如果数据需要使用，可以通过代码存储。

3. session会调用URLSession:dataTask:willCacheResponse:completionHandler:询问你的app是否允许缓存. 如果代理不实现这个方法的话, 默认使用session绑定的Configuration的缓存策略。
```

#### DownloadTask

```
1. 对于一个通过downloadTaskWithResumeData:创建的下载任务, session会调用代理的URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:方法。

2. 在服务器传输数据给客户端期间, 调用URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite: 给用户传数据

- 当用户暂停下载时, 调用cancelByProducingResumeData:给用户传已下好的数据。
       
- 如果用户想要恢复下载, 把刚刚的resumeData以参数的形式传给downloadTaskWithResumeData:方法创建新的task继续下载。
       
3. 如果download task成功完成了, 调用URLSession:downloadTask:didFinishDownloadingToURL:把临时文件的URL路径给你. 此时你应该在该代理方法返回以前读取他的数据或者把文件持久化。
```

#### UploadTask

```
上传数据去服务器期间, 代理会周期性收到

URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:

回调并获得上传进度的报告。
```

#### StreamTask

```
如果任务的数据是由一个stream发出的, session就会调用代理的URLSession:task:needNewBodyStream:方法去获取一个NSInputStream对象并提供一个新请求的body data。
```

#### Task completion

```
任何task完成的时候, 都会调用URLSession:task:didCompleteWithError:方法, error有可能为nil(请求成功), 不为nil(请求失败)

- 请求失败, 但是该任务是可恢复下载的, 那么error对象的userInfo字典里有一个NSURLSessionDownloadTaskResumeData对应的value, 你应该把这个值传给downloadTaskWithResumeData:方法重新恢复下载

- 请求失败, 但是任务无法恢复下载, 那么应该重新创建一个下载任务并从头开始下载

- 因为其他原因(如服务器错误等等), 创建并恢复请求

注意：NSURLSession不会收到服务器传来的错误, 代理只会收到客户端出现的错误, 例如无法解析主机名或无法连接上主机等等。 客户端错误定义在URL Loading System Error Codes。 服务端错误通过HTTP状态法进行传输, 详情请看NSHTTPURLResponse和NSURLResponse类
```

#### 销毁session

```
如果你不再需要一个session了， 一定要调用它的invalidateAndCancel或finishTasksAndInvalidate方法。 (前者是取消所有未完成的任务然后使session失效，后者是等待正在执行的任务完成之后再使session失效)。 否则的话, 有可能造成内存泄漏。

另外，session失效后会调用URLSession:didBecomeInvalidWithError:方法，之后session释放对代理的强引用。
```



### Background Transport

需要注意的是, 在后台session中, 一些代理方法将失效. 下面说一些使用后台session的注意点 :

- 后台session必须提供一个代理处理突发事件
- 只支持HTTP(S)协议. 其他协议都不可用.
- 只支持上传/下载任务, data任务不支持.
- 后台任务有数量限制
- 当任务数量到达系统指定的临界值的时候, 一些后台任务就会被取消. 也就是说, 一个需要长时间上传/下载的任务很可能会被系统取消然后有可能过一会再重新开始, 所以支持断点续传很重要.
- 如果一个后台传输任务是在app在后台的时候开启的, 那么这个任务很可能会出于对性能的考虑随时被系统取消掉(相当于session的Configuration对象的discretionary属性为true.)

后台session限制确实很多, 所以尽可能使用前台session做事情.

```
注意：

后台session最好用来传输一些支持断点续传大文件. 或对这个过程进行一些针对性的优化

- 最好把文件先压缩成zip/tar等压缩文件再上传/下载.
- 把大文件按数据段分别发送, 发送完之后服务端再把数据拼接起来.
- 上传的时候服务端应该返回一个标识符, 这样可以追踪传输的状态, 及时做出传输的调整
- 增加一个web代理服务器中间层, 以促进上述的优化

```

#### 如何使用

那么如何使用这个后台传输呢?

- 创建一个后台session

  ```
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"xxxx"];//identifier用来后台重连session对象 (做后台上传/下载就是这个config)
  _backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
  ```

- 创建一个upload or download task

  ```
  NSURL *URL = [NSURL URLWithString:@"http://www.bz55.com/uploads/allimg/140402/137-140402153504.jpg"];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  
  self.task = [self.session downloadTaskWithRequest:request];
  
  注意 : 后台任务不能使用带有completionHandler的方法创建 
  注意 : 如果任务只想在app进入后台后才处理, 那么可不调用[task resume]主动执行, 待程序进入后台后会自动执行 
  ```

- 我们等下载到一半后进入后台, 打开App Switcher过一会可以发现, 图片下载完之后就会显示在应用程序上. 方法调用顺序为 : 下面四个方法全部都是app在后台时调用的

![img](http://upload-images.jianshu.io/upload_images/1862021-83f89d2f08e3c874.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)





```
2017-03-24 14:17:09.458415 JRBgSessionDemo[2766:1080861] 下载中 - 58%
2017-03-24 14:17:09.567957 JRBgSessionDemo[2766:1080861] 下载中 - 59%
2017-03-24 14:17:16.916830 JRBgSessionDemo[2766:1080828] -[AppDelegate application:handleEventsForBackgroundURLSession:completionHandler:]
2017-03-24 14:17:16.951185 JRBgSessionDemo[2766:1080977] -[DownloadViewController URLSession:downloadTask:didFinishDownloadingToURL:]
2017-03-24 14:17:16.953951 JRBgSessionDemo[2766:1080977] -[DownloadViewController URLSession:task:didCompleteWithError:]
2017-03-24 14:17:16.954574 JRBgSessionDemo[2766:1080977] -[DownloadViewController URLSessionDidFinishEventsForBackgroundURLSession:]
```



#### 总结后台传输

1. 尽量用真机进行调试, 模拟器会跳过某一两个方法
2. 只能进行upload/download task, 不能进行data task
3. 不能使用带completionHandler的方法创建task, 否则程序直接挂掉
4. Applecation里的completionHandler必须存储起来, 等你处理完所有事情之后再调用告诉系统可以进行Snapshot和挂起app了
5. 后台下载最好支持断点续传, 因为任务有可能会被系统主动取消(例如系统性能下降了, 资源不够用的情况下)



### 其他重要知识

#### 1、线程安全

URLSession 的API全部都是线程安全的. 你可以在任何线程上创建session和tasks, task会自动调度到合适的代理队列中运行。

```
后台传输的代理方法URLSessionDidFinishEventsForBackgroundURLSession:可能会在其他线程中被调用

在该方法中你应该回到主线程然后调用completion handler去触发AppDelegate中的application:handleEventsForBackgroundURLSession:completionHandler:方法。
```

#### 2、NSCopying Behavior

```
session, task和configuration对象都支持copy操作 :

- session/task copy : 返回对象本身
- configuration copy : 返回一个无法修改(immutable)的对象.

```

#### 3、completionHandler

```
如果你实现了URLSession:didReceiveChallenge:completionHandler:这种带有completionHandler的方法又没有在该方法调用completionHandler, 请求就会遭到阻塞
```

#### 4、断点续传

```
下载失败/暂停/被取消, 可以通过task的- cancelByProducingResumeData:方法保存已下载的数据, 然后调用session的downloadTaskWithResumeData:方法, 触发代理的URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:方法
```



此部分知识来源网络。[源站](http://ios.jobbole.com/93098/)，[Demo下载](https://github.com/Jerry4me/JRBgSessionDemo)



## AFNetworking v3.1.0

> 从需求开始逐个分析AFNetworking v3.1.0



### AFNetworking的类结构图



![img](https://xilankong.github.io/resource/afnetworking.png)

### 1、基本使用与实现原理

#### AFURLSessionManager

```
1、继承自NSObject，以组合的方式包装NSURLSession

2、提供工厂，但是不是单例，根据 NSURLSessionConfiguration 初始化

3、多线程采用NSOperationQueue，默认最大并发数为1

4、默认JSON类型响应序列化

5、提供数据、上传、下载三种业务
```

#### AFHTTPSessionManager

```
1、继承自AFURLSessionManager，专门用来实现HTTPS协议，提供了POST、GET、HEAD、DELETE、PUT、PATCH等方便方法。具体的实现都直接或者间接调用了父类AFURLSessionManager数据业务的方法，下载和上传业务没有涉及。

2、在父类AFURLSessionManager的基础上隐藏了NSURLRequest的概念，简化为urlString，并且是相对于baseURL的相对路径，会在内部进行拼接，形成一个完整的urlString。

3、直接根据url初始化 AFHTTPSessionManager，提供工厂，但是不是单例
```

#### 通过  AFURLSessionManager 实现一个请求

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

#### 通过 AFHTTPSessionManager  实现一个请求

```
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure DEPRECATED_ATTRIBUTE;
```



请求知道如何构建了，我们看一看底层具体的实现原理

#### 请求的底层原理

AFNetworking的操作都是基于NSURLSession

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

**2、AFHTTPSessionManager的构建**

```
继承自AFURLSessionManager

直接根据url初始化 AFHTTPSessionManager，提供工厂，但是不是单例

初始化

initWithBaseURL:sessionConfiguration:

初始化 requestSerializer 为 AFHTTPRequestSerializer 用来构建 NSMutableURLRequest
 
初始化 responseSerializer 为 AFJSONResponseSerializer

```

**3、NSMutableURLRequest构建（如果是通过AFHTTPSessionManager 构建请求）**

```
URL拼接，参数配置，请求头配置等操作
```

**4、NSURLSessionDataTask的构建**

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

**5、NSURLSessionTask执行**

```
AFURLSessionManagerTaskDelegate 处理网络请求回调

SessionManager实现了 NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate

请求结果的回调会在 SessionManager 中处理
SessionManager定义的回调block也在这处理
AFURLSessionManagerTaskDelegate 的对响应结果部分的处理也通过 SessionManager 进行代理转发
```

**6、AFURLSessionManager清理NSURLSessionDataTask**

```
请求结束后进行清理，清理操作都有加锁 removeDelegateForTask

removeNotificationObserverForTask  移除通知
mutableTaskDelegatesKeyedByTaskIdentifier  移除代理键值对
```



### 2、任务进度设置和通知监听、代理转发等请求扩展需求

上面提到的NSURLSessionDataTask执行后会回调回SessionManager

#### Session 层次的回调

**NSURLSessionTaskDelegate  协议回调**

```

1、URLSession:didBecomeInvalidWithError: 无效请求

回调block: sessionDidBecomeInvalid

发出通知

2、URLSession:didReceiveChallenge:completionHandler:

回调block: sessionDidReceiveAuthenticationChallenge

否则 根据是否需要 和 securityPolicy 配置 决定 NSURLSessionAuthChallengeDisposition 和 NSURLCredential 

3、URLSessionDidFinishEventsForBackgroundURLSession:

回调block:   didFinishEventsForBackgroundURLSession

在iOS中使用NSURLSession,当一个下载任务完成时,app将会自动重启。app代理方法application:handleEventsForBackgroundURLSession:completionHandler:负责重建合适的会话,存储完成处理块,并在会话对象调用会话代理的 URLSessionDidFinishEventsForBackgroundURLSession:方法时调用完成处理块。


```

#### Task 层次的回调

**NSURLSessionTaskDelegate 协议回调** 

```
1、URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler

HTTP 重定向

回调block: taskWillPerformHTTPRedirection

AF重写的 respondsToSelector 中拦截了 willPerformHTTPRedirection 这个 selector，当 taskWillPerformHTTPRedirection存在时才执行。

2、URLSession:task:didReceiveChallenge：completionHandler: 

Task 任务层次的授权、证书问题

回调block:sessionDidReceiveAuthenticationChallenge

否则 根据是否需要 和 securityPolicy 配置 决定 NSURLSessionAuthChallengeDisposition 和 NSURLCredential 

3、URLSession:task:needNewBodyStream:

回调block: taskNeedNewBodyStream

如果app使用流作为请求体,还必须提供一个自定义会话代理实现
当以流的形式上传，认证失败，任务将不再在重要该流进行上传。通过这个方法获取新的NSInputStream 

4、URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:

代理:  AFURLSessionManagerTaskDelegate 通过这个方法来获取上传进度信息

回调block: taskDidSendBodyData

5、URLSession:task:didCompleteWithError: 

代理: AFURLSessionManagerTaskDelegate 响应解析

回调block: taskDidComplete

任务结束，成功或者失败都会调用，执行通知的移除、mutableTaskDelegatesKeyedByTaskIdentifier 的 代理键值对移除 

6、URLSession:task:didFinishCollectingMetrics

指标统计

代理: AFURLSessionManagerTaskDelegate 

回调block: taskDidFinishCollectingMetrics 
```

**NSURLSessionDataDelegate 协议回调**

```

1、URLSession:dataTask:didReceiveResponse:completionHandler 

接受响应

回调block: dataTaskDidReceiveResponse

2、URLSession:dataTask:didBecomeDownloadTask

代理: 删除原有任务对应的代理、通知、mutableTaskDelegatesKeyedByTaskIdentifier键值对，重新添加新的下载任务

3、URLSession:dataTask:didReceiveData 

代理: 转发至 AFURLSessionManagerTaskDelegate 统计下载进度

回调block: dataTaskDidReceiveData

4、URLSession:dataTask:willCacheResponse:completionHandler

回调block: dataTaskWillCacheResponse

询问你的app是否允许缓存. 如果代理不实现这个方法的话, 默认使用session绑定的Configuration的缓存策略.

5、URLSessionDidFinishEventsForBackgroundURLSession

回调block: didFinishEventsForBackgroundURLSession

```

**NSURLSessionDownloadDelegate 协议 回调**

```
1、URLSession:downloadTask:didFinishDownloadingToURL: 

提供app下载内容的临时存储目录

代理: AFURLSessionManagerTaskDelegate

回调block: downloadTaskDidFinishDownloading

2、URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite 

提供了下载进度的状态信息

代理: AFURLSessionManagerTaskDelegate 统计进度

回调block: downloadTaskDidWriteData

3、URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes 

告诉app尝试恢复之前失败的下载

代理: AFURLSessionManagerTaskDelegate 统计进度

回调block: downloadTaskDidResume
```



### 3、请求参数的序列化

#### 相关类

- AFURLRequestSerialization 协议
- AFHTTPRequestSerializer  继承自NSObject 实现 AFURLRequestSerialization 协议
- AFJSONRequestSerializer   继承自 AFHTTPRequestSerializer
- AFPropertyListRequestSerializer   继承自 AFHTTPRequestSerializer
- AFMultipartFormData 协议

```
AFHTTPRequestSerializer \ AFJSONRequestSerializer \ AFPropertyListRequestSerializer 都实现了序列化请求的方法：

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
                                        
实现该方法 请求序列化器可以将参数编码为查询字符串，HTTP主体，根据需要设置适当的HTTP头字段。

例如，JSON请求序列化器可以将请求的HTTP主体设置为JSON表示，并将Content-TypeHTTP标头字段值设置为application / json。
```

#### 特殊属性

AFHTTPRequestSerializer

```
1、mutableObservedChangedKeyPaths

来源自 AFHTTPRequestSerializerObservedKeyPaths()，存了一些系统定义的请求头部键值对信息

2、mutableHTTPRequestHeaders

自定义的部分请求头部键值对信息

3、requestHeaderModificationQueue 

dispatch_queue_create("requestHeaderModificationQueue", DISPATCH_QUEUE_CONCURRENT); 并发操作队列，用于请求变更的操作
```





### 4、响应数据的解析





NSSecureCoding



AFURLRequestSerialization

AFURLResponseSerialization



AFJSONResponseSerializer



AFHTTPResponseSerializer

AFXMLParserResponseSerializer



AFNetworking的多数类都支持序列化，但实现的是NSSecureCoding的接口，而不是NSCoding，区别在于解数据时要指定Class，用-decodeObjectOfClass:forKey:方法代替了-decodeObjectForKey:。这样做更安全，因为序列化后的数据有可能被篡改，若不指定Class，-decode出来的对象可能不是原来的对象，有潜在风险。



### 5、额外的功能



#### AFSecurityPolicy

HTTPS连接建立过程大致是，客户端和服务端建立一个连接，服务端返回一个证书，客户端里存有各个受信任的证书机构根证书（CA根证书），用这些根证书对服务端返回的证书进行验证，经验证如果证书是可信任的，就生成一个pre-master secret，用这个证书的公钥加密后发送给服务端，服务端用私钥解密后得到pre-master secret，再根据某种算法生成master secret，客户端也同样根据这种算法从pre-master secret 生成 master secret，随后双方的通信都用这个 master secret 对传输数据进行加密解密。

**1、证书是怎样验证的？怎样保证中间人不能伪造证书？**

```
建立https连接时，服务端返回证书A给客户端，客户端的系统里的CA机构根证书有这个CA机构的公钥，用这个公钥对证书A的加密内容F1解密得到F2，跟证书A里内容F对比，若相等就通过验证。

整个流程大致是：F->CA私钥加密->F1->客户端CA公钥解密->F。因为中间人不会有CA机构的私钥，客户端无法通过CA公钥解密，所以伪造的证书肯定无法通过验证。
```

**2、什么是 SSL Pinning**

可以理解为证书绑定，用来验证服务器就是我要的服务器。

```
是指客户端直接保存服务端的证书，建立https连接时直接对比服务端返回的和客户端保存的两个证书是否一样，一样就表明证书是真的，不再去系统的信任证书机构里寻找验证。这适用于非浏览器应用，因为浏览器跟很多未知服务端打交道，无法把每个服务端的证书都保存到本地，但CS架构的像手机APP事先已经知道要进行通信的服务端，可以直接在客户端保存这个服务端的证书用于校验。

为什么直接对比就能保证证书没问题？如果中间人从客户端取出证书，再伪装成服务端跟其他客户端通信，它发送给客户端的这个证书不就能通过验证吗？确实可以通过验证，但后续的流程走不下去，因为下一步客户端会用证书里的公钥加密，中间人没有这个证书的私钥就解不出内容，也就截获不到数据，这个证书的私钥只有真正的服务端有，中间人伪造证书主要伪造的是公钥。

为什么要用SSL Pinning？正常的验证方式不够吗？如果服务端的证书是从受信任的的CA机构颁发的，验证是没问题的，但CA机构颁发证书比较昂贵，小企业或个人用户可能会选择自己颁发证书，这样就无法通过系统受信任的CA机构列表验证这个证书的真伪了，所以需要SSL Pinning这样的方式去验证。

```

**AFSecurityPolicy分三种验证模式**

```
AFSSLPinningModeNone
这个模式表示不做SSL pinning，只跟浏览器一样在系统的信任机构列表里验证服务端返回的证书。若证书是信任机构签发的就会通过，若是自己服务器生成的证书，这里是不会通过的。

AFSSLPinningModePublicKey
这个模式同样是用证书绑定方式验证，客户端要有服务端的证书拷贝，只是验证时只验证证书里的公钥，不验证证书的有效期等信息。只要公钥是正确的，就能保证通信不会被窃听，因为中间人没有私钥，无法解开通过公钥加密的数据。

AFSSLPinningModeCertificate
这个模式表示用证书绑定方式验证证书，需要客户端保存有服务端的证书拷贝，这里验证分两步，第一步验证证书的域名/有效期等信息，第二步是对比服务端返回的证书跟客户端返回的是否一致。
除了公钥外，其他能容也要一致才能通过验证。
```

**AFSecurityPolicy属性分析**

```
1、pinnedCertificates

这个属性保存着所有的可用做校验的证书的集合。AFNetworking 默认会搜索工程中所有 .cer的证书文件。如果想制定某些证书，可使用certificatesInBundle在目标路径下加载证书，然后调用policyWithPinningMode:withPinnedCertificates创建一个本类对象。

注意： 只要在证书集合中任何一个校验通过，evaluateServerTrust:forDomain: 就会返回true，即通过校验。


2、allowInvalidCertificates

使用允许无效或过期的证书，默认是不允许。

3、validatesDomainName

是否验证证书中的域名domain

```

**AFSecurityPolicy方法分析**

```
1、默认的实例对象，默认的认证设置为：

不允许无效或过期的证书
验证domain名称
不对证书和公钥进行验证


2、certificatesInBundle:(NSBundle *)bundle

返回指定bundle中的证书。如果使用AFNetworking的证书验证 ，就必须实现此方法，并且使用policyWithPinningMode:withPinnedCertificates 方法来创建实例对象。


3、evaluateServerTrust:forDomain:

评估服务器是否需要证书验证


在二进制的文件中获取公钥的过程是这样

① NSData *certificate -> CFDataRef -> (SecCertificateCreateWithData) -> SecCertificateRef allowedCertificate

②判断SecCertificateRef allowedCertificate 是不是空，如果为空，直接跳转到后边的代码

③allowedCertificate 保存在allowedCertificates数组中

④allowedCertificates -> (CFArrayCreate) -> SecCertificateRef allowedCertificates[1]

⑤根据函数SecPolicyCreateBasicX509() -> SecPolicyRef policy

⑥SecTrustCreateWithCertificates(tempCertificates, policy, &allowedTrust) -> 生成SecTrustRef allowedTrust

⑦SecTrustEvaluate(allowedTrust, &result) 校验证书

⑧(__bridge_transfer id)SecTrustCopyPublicKey(allowedTrust) -> 得到公钥id allowedPublicKey
```



#### AFNetworkReachabilityManager

**网络检测**

```
// 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
[[AFNetworkReachabilityManager sharedManager] startMonitoring];
// 检测网络连接的单例,网络变化时的回调方法
[[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
    NSLog(@"%ld",(long)status);
    switch (status) {

        case AFNetworkReachabilityStatusUnknown:
            NSLog(@"网络错误");
            break;

        case AFNetworkReachabilityStatusNotReachable:
            NSLog(@"没有连接网络");
            break;

        case AFNetworkReachabilityStatusReachableViaWWAN:
            NSLog(@"蜂窝网络");
            break;

        case AFNetworkReachabilityStatusReachableViaWiFi:
            NSLog(@"wifi");
            break;

    }
}];
/*     
 AFNetworkReachabilityStatusUnknown          = -1, //未知、网络错误
 AFNetworkReachabilityStatusNotReachable     = 0,  //未连接网络
 AFNetworkReachabilityStatusReachableViaWWAN = 1,  //蜂窝网络
 AFNetworkReachabilityStatusReachableViaWiFi = 2,  //wifi
 */
```

**其他**

```
通知

网络状态变化

AFNetworkingReachabilityDidChangeNotification
```





### 6、Category扩展部分









## 参考

http://ios.jobbole.com/93098/