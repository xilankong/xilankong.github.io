---
layout: post
category: 2016年
title:  "网络层(AFNetworking的使用)" 
---

AFNetworking使用细节整理

## 1.单例

AFNetworking 使用整理，基本原理，使用细则，不常用的点

```
+ (instancetype)sharedClient {
    
    static YangHttpClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[YangHttpClient alloc]init];
        
        YangHTTPSessionManager * httpClient = [[YangHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"http://baidu.com"]];
        httpClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        httpClient.requestSerializer.timeoutInterval = 300;
        httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        httpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
        _sharedClient.httpClient = httpClient;
        
    });
    
    
    
    return _sharedClient;
}
```

Q：

```
NS_ASSUME_NONNULL_BEGIN 和 NS_ASSUME_NONNULL_END

Nonnull区域设置(Audited Regions)
如果需要每个属性或每个方法都去指定nonnull和nullable，是一件非常繁琐的事。苹果为了减轻我们的工作量，专门提供了两个宏：NS_ASSUME_NONNULL_BEGIN和NS_ASSUME_NONNULL_END。
例：
NS_ASSUME_NONNULL_BEGIN

@interface TestNullabilityClass () 

@property (nonatomic, copy) NSArray * items; 

- (id)itemWithName:(nullable NSString *)name; 

@end 

NS_ASSUME_NONNULL_END

在上面的代码中，items属性默认是nonnull的，itemWithName:方法的返回值也是nonnull，而参数是指定为nullable的。

不过，为了安全起见，苹果还制定了几条规则：

typedef定义的类型的nullability特性通常依赖于上下文，即使是在Audited Regions中，也不能假定它为nonnull。

复杂的指针类型(如id *)必须显示去指定是nonnull还是nullable。例如，指定一个指向nullable对象的nonnull指针，可以使用"nullable id * nonnull"。

我们经常使用的NSError **通常是被假定为一个指向nullable NSError对象的nullable指针。

```

Q2:

```
网络请求出现Code=-1022解决办法

针对AFNETWorking 更新Xcode7.0后网络请求出现如下error

Error Domain=NSURLErrorDomain Code=-1022

在工程的 info.plist 文件中添加 

App Transport Security Settings

Allow Arbitrary Loads - YES
```

Q3:

```

当 NSURLSessionTask cancle的时候会回调失败block

```



## 2.NSURLSession

第一步 通过NSURLSession的实例创建task
第二部 执行task



NSURLSessionTask(抽象类)
​	NSURLSessionDataTask 
​	NSURLSessionUploadTask （NSURLSessionDataTask 子类）
​	NSURLSessionDownloadTask



AFN(3.1.0)中的封装：

NSURLSession 目录  

AFHTTPSessionManager（AFURLSessionManager子类）  处理  NSURLSessionDataTask

AFURLSessionManager 处理  NSURLSessionUploadTask/NSURLSessionDownloadTask

AFHTTPSessionManager 属性：

1.

@property (readonly, nonatomic, strong, nullable) NSURL *baseURL;

根URL 比如一个APP的所有请求都是指向一个根路径下面的请求，这个baseURL就是这个根路径，方便外部请求可以直接用相对URL

2.

@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;

请求解析器

```
httpClient.requestSerializer = [AFHTTPRequestSerializer serializer];
httpClient.requestSerializer.timeoutInterval = 300;
//超时时间设置
//字符串格式设置 默认 NSUTF8StringEncoding
//请求头设置 HTTPRequestHeaders
```

3.

@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

响应解析器

```
httpClient.responseSerializer = [AFJSONResponseSerializer serializer];
httpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
// responseSerializer 默认是AFJSONResponseSerializer
// acceptableContentTypes  允许接收的contentType 类型集合
```

4.

常见get post 请求方法

DEPRECATED_ATTRIBUTE 的意思是  废弃属性



AF https

http://www.jianshu.com/p/20d5fb4cd76d





https 抓包



http://www.jianshu.com/p/97745be81d64