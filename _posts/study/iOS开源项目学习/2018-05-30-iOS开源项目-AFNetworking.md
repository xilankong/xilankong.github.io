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







### 1、实现一个最简单的请求

#### AFURLSessionManager

简单介绍：

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



#### AFHTTPSessionManager

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



简单请求知道如何构建了，我们看一看底层具体的实现原理

### 2、请求的底层原理

AFNetworking的操作都是基于NSURLSession的



2、任务进度设置和通知监听、代理转发



2、请求的底层原理，NSOperationQueue的使用



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

