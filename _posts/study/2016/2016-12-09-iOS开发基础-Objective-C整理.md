---
layout: post
category: 2016年
title : "iOS开发基础-Objective-C整理"
---

## 运行时runtime

OC语言最大的特色，OC是C的升级、OC必须转为C然后再转为汇编。

OC是一门动态语言，类型的判断、类的成员变量、方法的内存地址都是在程序的运行阶段才最终确定，并且还能动态的添加成员变量和方法。也就意味着你调用一个不存在的方法时，编译也能通过，甚至一个对象它是什么类型并不是表面我们所看到的那样，只有运行之后才能决定其真正的类型

## 实例 (instance)

实例 (instance)  到底是由什么构成，我们查看一下objc.h中的源码：

```
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;
/// Represents an instance of a class.
struct objc_object {
    Class isa  OBJC_ISA_AVAILABILITY;
};
/// A pointer to an instance of a class.
typedef struct objc_object *id;
```

由此看出，我们创建的一个对象或实例其实就是一个struct objc_object结构体，而我们常用的动态类型 id 也就是这个结构体的指针。

我们创建的类的实例最终获取的都是一个结构体指针，这个结构体只有一个成员变量就是`Class`类型的`isa`指针，日常实例使用，我们调用实例的 class 方法，返回一个Class类型对象，也就是实例的类，并且可以通过这个class来初始化实例。所以我们可以知道： 这个Class就是代表这个实例的类，所以实例的isa指针指向的是这个实例的类。

```
NSString *str = [[NSString alloc] initWithString: @"Hello World"];
Class strClass = [str class];
NSString *str2 = [[strClass alloc] initWithString: @"Hello World"];

从这可以推断我们上面描述的 isa指针指向的就是这个实例的类。
```



## class object、metaclass

OC中的类本身也是一个对象：类对象（class object），上面实例中的 [str class] 方法返回的就是一个类对象。那么类对象又是什么？  `Class `是结构体指针，指向 结构体 ` objc_class` , 下面是这个结构体:

```
struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
    Class _Nullable super_class                             
    const char * _Nonnull name                              
    long version                                            
    long info                                                
    long instance_size                                       
    struct objc_ivar_list * _Nullable ivars                 
    struct objc_method_list * _Nullable * _Nullable methodLists                    
    struct objc_cache * _Nonnull cache                     
    struct objc_protocol_list * _Nullable protocols 
}
```

**这个结构体就是整个类对象，包含了实例变量和实例方法等所有信息**，我们称这个结构体包含的数据为元数据(metadata)，在metadata中我们可以看到第一个参数依然是一个Class类型的 isa指针，这个类对象的isa指针指向的对象，我们称之为 元类（metaclass），**元类中存储了类变量和类方法等所有信息**。

下面是一张网上copy的图，很详细的描述了整个闭环：



![](https://xilankong.github.io/resource/runtime-isa.png)

代码解释：

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
      Person *p = [[Person alloc] init];
        //输出1
        NSLog(@"%d", [p class] == object_getClass(p));
        //输出0
        NSLog(@"%d", class_isMetaClass(object_getClass(p)));
        //输出1
        NSLog(@"%d", class_isMetaClass(object_getClass([Person class])));
        //输出0
        NSLog(@"%d", object_getClass(p) == object_getClass([Person class]));
        //元类的isa指向哪里 输出1
        NSLog(@"%d", object_getClass([[Person class]class]) == object_getClass([Person class]));
    }
    return 0;
}
```

tips:

```
1、元类的isa指向哪里?  指向自己

2、类对象的super_class指向其父类，一直到NSObject，NSObject的super_class是 nil

3、NSObject 的元类的父类指向 NSObject 类

@interface NSObject (Sark)
+ (void)foo;
@end
@implementation NSObject (Sark)
- (void)foo {
    NSLog(@"IMP: -[NSObject (Sark) foo]");
}
@end
// 测试代码
[NSObject foo];
[[NSObject new] foo];

执行结果：编译运行正常，两行代码都执行-foo。 [NSObject foo]方法查找路线为 NSObject metaclass –super-> NSObject class，

```

## 元数据（vars、methods、protocols）

从类对象的结构体我们可以看到下面四个结构体：

类对象中包含了实例数据，元类对象中包含了类数据。

```
struct objc_ivar_list * _Nullable ivars     				  属性列表             
struct objc_method_list * _Nullable * _Nullable methodLists   方法列表                  
struct objc_cache * _Nonnull cache                    		  缓存  
struct objc_protocol_list * _Nullable protocols 			  协议列表
```

#### 1、属性列表

#### 2、方法列表

这个列表其实是一个字典，key是selector，value是IMP（imp是一个指针类型，指向方法的实现），并且selector和IMP之间的关系是在运行时才决定的，而不是编译时。如此们就可以做出一些特别事情来。

#### 3、缓存

每个类对象都有一份独立的缓存，同时包括继承的方法和在该类中定义的方法。

```
//下面来剖析一段苹果官方方法查找运行时源码:
static Method look_up_method(Class cls, SEL sel, BOOL withCache, BOOL withResolver) {
    // 1. 声明IMP
    Method meth = NULL;
    // 2. 从cache中查找
    if (withCache) {
        meth = _cache_getMethod(cls, sel,&_objc_msgForward_internal);
        if (meth == (Method)1) {
            // cache中包含了这个方法的话,就停止搜索
            // Cache contains forward:: . Stop searching.
            return NULL;
        }
	}
    // Ivar class_getInstaceMethod(Class cls, SEL name);
    // Ivar class_getClassMethod(Class cls, SEL name);
    // 3. 如果找不到从方法列表中查找(包括类方法列表和对象方法列表)
    if (!meth) meth = _class_getMethod(cls, sel);
    // 4. 将找到的方法缓存到cache中
    if (!meth  &&  withResolver) meth = _class_resolveMethod(cls, sel);
		return meth;
  }
  
1，首先去该类的方法 cache 中查找，通过SEL查找对应函数method（cache中method列表是以SEL为key通过hash表来存储的，这样能提高函数查找速度）如果找到了就返回它;

2，如果没有找到，就去该类的方法列表中查找。如果在该类的方法列表中找到了，则将 IMP 返回，并将 它加入 cache中缓存起来。根据最近使用原则，这个方法再次调用的可能性很大，缓存起来可以节省下次 调用再次查找的开销。

3，如果在该类的方法列表中没找到对应的 IMP，在通过该类结构中的 super_class指针在其父类结构的方法列表中去查找，直到在某个父类的方法列表中找到对应的 IMP，返回它，并加入 cache 中;

4，如果在自身以及所有父类的方法列表中都没有找到对应的 IMP，则看是不是可以进行动态方法解析

5，如果动态方法解析没能解决问题，进入下面要讲的消息转发流程。

```

#### 4、实例方法查找路线

```
1、根据实例对象的isa指针去该对象的类对象方法列表中查找，如果找到了就执行

2、如果没有找到，就去该类的父类类对象方法列表中查找

3、如果没有找到就一直往上找，直到根类（NSObject）

4、如果都没有就会调用NSObjec的一个方法doesNotRecognizeSelector:，这个方法就会报unrecognized selector错误（其实在调用这个方法之前还会进行消息转发，还有三次机会来处理，消息转发在后文会有介绍）。
```

#### 5、类方法查找路线

```
1、根据类对象的isa指针，去元类对象的方法列表中查找，如果找到了就执行

2、如果没有找到，就去该元类的父类类对象方法列表中查找

3、如果没有找到就一直往上找，直到根类（NSObject）

4、如果NSObject的元类对象方法列表里面也没有，则找到 NSObject类对象 的方法列表 (因为NSObject元类的父类是NSObject类)

5、如果都没有就会调用NSObjec的一个方法doesNotRecognizeSelector:，这个方法就会报unrecognized selector错误（其实在调用这个方法之前还会进行消息转发，还有三次机会来处理，消息转发在后文会有介绍）
```



## 消息传递

消息传递只要是写iOS的基本也都知道是什么个意思，这里分析一些细节点：

先了解几大内容：

#### Method

```
一个方法 Method，其包含一个方法选标 SEL – 表示该方法的名称，一个 types – 表示该方法参数的类型， 一个 IMP - 指向该方法的具体实现的函数指针。

struct objc_method {
    SEL _Nonnull method_name           //方法名称 也就是selector
    char * _Nullable method_types      //方法的参数类型
    IMP _Nonnull method_imp            //函数指针，指向方法的具体实现
}    
// IMP 和 SEL是在运行时才配对的，一对一，通过selector去查找IMP，找到执行方法的地址，才能确定具体的执行代码
```

#### SEL

```
指向objc_selector的指针，表示方法的名字

typedef struct objc_selector *SEL;

当不同类的实例对象 performSelector相同的selector的时候，会在各自的方法链表，根据SEL查找对应的IMP，然后执行，不同类可以有相同selector
```

#### IMP

```
函数指针，指向方法的实现

typedef id (*IMP)(id, SEL, ...)

IMP 函数指针，包含一个接受消息的对象id，调用方法的方法名 SEL，以及参数个数，并返回一个id
IMP 是消息最终调用的代码
```

#### objc_msgSend

```
objc_msgSend(p, sel_registerName("showMyself"));

OC的runtime通过objc_msgSend函数将一个面向对象的消息传递转为了面向过程的函数调用。

objc_msgSend函数根据消息的接受者和selector选择适当的方法来调用，那它又是如何选择的呢？

我们分析一下 一个成功执行的 objc_msgSend 

参数：消息接收者，方法名，消息参数

[person run]; --> objc_msgSend(person, @selector(run));
 
objc_msgSend消息函数做了动态绑定所需要的一切工作：

1、找到SEL对应的方法实现IMP，不同的类对同一个方法名会有不同的实现 (前面提及的方法查找)
2、将消息接收者对象(指向对象的指针) 以及方法中指定的参数传递给方法实现IMP
3、最后，将方法实现的返回值作为该函数的返回值返回
 
找到对应的方法实现时，它将直接调用该方法实现，并将消息中所有的参数都传递给方法实现，同时，他还将传递两个隐藏参数 -- 消息接受者 以及 方法名SEL，（消息接受者去调用对应的方法实现）

如果查找失败就会调用NSObjec的一个方法doesNotRecognizeSelector:，这个方法就会报unrecognized selector错误
 
```

## 消息转发

看完前面的消息发送，基本了解消息是怎么一回事了，前面提及如果查找失败会自动调用到根类 NSObject 里面的错误响应方法，但在这之前其实还有一个消息转发。

```
会调用所属类的方法

+(BOOL)resolveInstanceMethod:(SEL)name (所属类动态方法解析)

- (id)forwardingTargetForSelector:(SEL)aSelector;(备援接收者)

- (void)forwardInvocation: (NSInvocation*)invocation;(消息重定向)
```

#### 1、所属类动态方法解析

```

在接收者对象中实现 resolveInstanceMethod: 即可以捕获方法查找并处理。

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(doSth)) {
        class_addMethod(self, @selector(doSth), class_getMethodImplementation(self, @selector(doOther)), "v@:");
    }
    return [super resolveInstanceMethod:sel];
}

- (void)doOther {
    NSLog(@"doOther");
}
```

#### 2、备援接收者

```

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [Human new];
}

如果接收者没有这个方法的实现，可以选择其他接收者返回回去。在其他接收者对象当中，甚至不需要再头文件将方法名暴露出来，系统会找到要转发的类，自动查找。

如果不处理 返回 nil。
```



#### 3、消息重定向

```
forwardInvocation 方法并不会直接进，必须要 methodSignatureForSelector 能返回一个方法签名。

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    if (aSelector == @selector(doSth)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (anInvocation.selector == @selector(doSth)) {
        
        [anInvocation invokeWithTarget: [Human new]];
        return;
    }
    [super forwardInvocation:anInvocation];
}
```

methodSignatureForSelector用于描述被转发的消息，系统会调用methodSignatureForSelector:方法，尝试获得一个方法签名。如果获取不到，则直接调用doesNotRecognizeSelector抛出异常。如果能获取，则返回非nil：创建一个 NSlnvocation 并传给forwardInvocation:。 描述的格式要遵循以下规则[点击打开链接](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1).

#### 签名参数具体怎么编写？

首先，先要了解的是,每个方法都有self和_cmd两个默认的隐藏参数，self即接收消息的对象本身，_cmd即是selector选择器，所以，描述的大概格式是：返回值@:参数。@即为self,:对应_cmd(selector).返回值和参数根据不同函数定义做具体调整。

比如下面这个函数

```objc
-(void)testMethod;
```

返回值为void,没有参数，按照上面的表格中的符号说明，再结合上面提到的概念，这个函数的描述即为   v@:

v代表void,@代表self(self就是个对象，所以用@),:代表_cmd(selector)
再练一个

```html
-(NSString *)testMethod2:(NSString *)str;
```

描述为 @@:@

第一个@代表返回值NSString*,对象;第二个@代表self;:代表_cmd(selector);第三个@代表参数str,NSString对象类型。如果实在拿不准，不会写，还可以简单写段代码，借助method_getTypeEncoding方法去查看某个函数的描述,比如

```
Method method = class_getInstanceMethod(self.class, @selector(testMethod2));
const char *des = method_getTypeEncoding(method);
NSString *desStr = [NSString stringWithCString:des encoding:NSUTF8StringEncoding];
NSLog(@"%@",desStr);
return @"";
```

整体操作：

```
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([someOtherObject respondsToSelector:
            [anInvocation selector]])
        [anInvocation invokeWithTarget:someOtherObject];
    else
        [super forwardInvocation:anInvocation];
}


-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(doSth)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return nil;
}
```

https://blog.csdn.net/wangweijjj/article/details/51888750





## 动态属性

允许获取属性列表、动态添加属性，特别是在一些系统库或者三方库的基础上需要扩展一个属性，这个时候动态添加一个属性就很有意义。

**property**

```
unsigned int count = 0;
    
//添加property
objc_property_attribute_t attributes = {"T@\"NSString\",&,N,V_age"};
class_addProperty([p class], "age", &attributes, 1);

//获取property列表
objc_property_t *list = class_copyPropertyList([p class], &count);
    
    
    
```

**关联对象**

```
管理关联对象的方法：
objc_setAssociatedObject(id object, void * key, id value, <objc_AssociationPolicy policy)
以给定的key为对象设置关联对象的value

objc_getAssociatedObject(id _Nonnull object, const void * _Nonnull key)
根据key从对象中获取相应的关联对象的value

objc_removeAssociatedObjects(id _Nonnull object)
移除所有关联对象

使用时通常使用静态的全局变量做key

优点：这种方式能够使我们快速的在一个已有的class内部添加一个动态属性或block块。
缺点：不能像遍历属性一样的遍历我们所有关联对象，且不能移除制定的关联对象，只能通过removeAssociatedObjects方法移除所有关联对象。

```

对象关联类型

| 关联类型                              | 等效的@property属性   |
| --------------------------------- | ---------------- |
| OBJC_ASSOCIATION_ASSIGN           | assign           |
| OBJC_ASSOCIATION_RETAIN_NONATOMIC | nonatomic,retain |
| OBJC_ASSOCIATION_COPY_NONATOMIC   | nonatomic,copy   |
| OBJC_ASSOCIATION_RETAIN           | retain           |
| OBJC_ASSOCIATION_COPY             | copy             |

**动态添加Ivar**

```
重点: 不能在已存在的class中添加Ivar，必须通过objc_allocateClassPair动态创建一个class，才能调用class_addIvar创建Ivar，最后通过objc_registerClassPair注册class。

添加变量
class_addIvar(Class _Nullable cls, const char * _Nonnull name, size_t size, 
              uint8_t alignment, const char * _Nullable types) 
              
name : 变量名称、

size: 变量大小、

alignment: 变量对齐数
处理方式： 如果是NSString类型 alignment = log2(_Alignof(NSString *) 或者 log2(sizeOf(NSString *))
types: 变量编码类型            
              
```

## Method Swizzling

这个应该是运行时再日常开发中最常用的功能了。

```
OC中的 + load方法，用来做Method Swizzling最合适。


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSEL = @selector(doSth);
        SEL newSEL = @selector(doOther);
        
        Method originMethod = class_getInstanceMethod(self, originSEL);
        Method newMethod = class_getInstanceMethod(self, newSEL);
        BOOL result = class_addMethod(self, originSEL, class_getMethodImplementation(self, newSEL), method_getTypeEncoding(newMethod));
        if (result) {
            class_replaceMethod(self, newSEL, class_getMethodImplementation(self, originSEL), method_getTypeEncoding(originMethod));
        } else {
            method_exchangeImplementations(originMethod, newMethod);
        }
        
    });
}


- (void)doSth {
    NSLog(@"doSth");
//    [self doSth];
}

- (void)doOther {
    NSLog(@"doOther");
    [self doOther];
}


注意点：
当方法实现交换后，再次想调用原始方法 需要调用新的方法名。

```

#### iOS  + initialize 与 +load 方法

```

1.load方法的调用时机，main函数之前，先调用类中的，再调用类别中的（类别中如果有重写），依赖库类优先调用。

应用场景：runtime交换方法实现

2.initialize方法的调用时机，当向该类发送第一个消息（一般是类消息首先调用，常见的是alloc）的时候，先调用类中的，再调用类别中的（类别中如果有重写）；如果该类只是引用，没有调用，则不会执行initialize方法。

应用场景：初始化常用静态变量
```

#### performSelector 执行原理

```

```



#### 动态判断、动态检查

```
isKindOfClass

isMemberOfClass

isSubclassOfClass

instancesRespondToSelector

respondsToSelector
```



#### 动态加载：根据需求加载所需要的资源

```

```



## 题外话-

#### iOS程序启动过程

iOS开发中，main函数是我们熟知的程序启动入口，但实际上并非真正意义上的入口，因为在我们运行程序，再到main方法被调用之间，程序已经做了许许多多的事情，比如我们熟知的runtime的初始化就发生在main函数调用前，还有程序动态库的加载链接也发生在这阶段。

1、系统先读取App的可执行文件（Mach-O文件），获取到dyld的路径，并加载dyld

2、dyld去初始化运行环境、开启缓存策略、加载依赖库、我们的可执行文件、链接依赖库，并调用每个依赖库的初始化方法

3、在上一步runtime被初始化，当所有的依赖库初始化后，程序可执行文件进行初始化，这个时候runtime回对项目中的所有类进行类结构初始化，然后调用所有类的+load方法

```
1、runtime初始化方法 _objc_init 中最后注册了两个通知：
map_images 主要是在镜像加载进内容后对其二进制内容进行解析，初始化里面的类结构等
load_images主要是调用call_load_methods 按照继承层次依次调用Class的 +load方法 然后是Category的+ load方法。(call_load_methods 调用load 是通过方法地址直接调用的load方法，并不是通过消息机制，这就是为什么分类中的load方法并不会覆盖主类以及其他同主类的分类里的load 方法实现了。)

2、runtime 调用项目中所有的load方法时，所有的类的结构已经初始化了,此时在load方法中可以使用任何类创建实例并给他们发送消息。
```

4、最后dyld返回main函数地址，main函数被调用



5、通过了解程序在启动前做了什么，我们可以尝试去优化App的启动速度



main函数之前都发生了什么



## runloop







事件响应链、传递链



触摸事件等



core graphics



引用计数



深复制浅复制



app生命周期







​	http://www.cocoachina.com/ios/20170427/19145.html



foundation kit



ui kit、动画



设计模式



线程并发



网络协议



文件数据处理



https抓包  网络部分 tcp/ip http/https socket ftp



和 webView、JS的交互



AFNetwork & Alamofire

- Masonry & SnapKit
- SDWebImage
- SwiftyJSON





bug检查排除



最后处理混编的问题、UI优化、编译优化



算法



最近处理过的复杂问题



## 6、理解UIApplication

UIApplication对象是应用程序的象征。

每一个应用程序都有自己的UIApplication对象，而且是单例。

一个iOS程序启动后创建的第一个对象就是UIApplication对象。

通过 UIApplication *app = [UIApplication sharedApplication]; 可以获得这个单例对象。

利用UIApplication对象能进行一些应用级别的操作。

常用的UIApplication相关 

Event Loop

1、applicationIconBadgeNumber  程序图标小红点

2、networkActivityIndicatorVisible 联网指示器可见性

3、状态栏管理

4、openURL

5、判断程序运行状态

6、阻止屏幕变暗进入休眠状态



## 7、理解UIWindow



https://www.jianshu.com/p/cda083e44abd



ios 底层实现





https://www.jianshu.com/p/d2e0dc7bf57f



常见关键字：

atomic：atomic意为操作是原子的，意味着只有一个线程访问实例变量。atomic是线程安全的，至少在当前的存取器上是安全的。它是一个默认的特性，但是很少使用。

nonatomic：nonatomic跟atomic刚好相反。表示非原子的，可以被多个线程访问。它的效率比atomic快。但不能保证在多线程环境下的安全性，在单线程和明确只有一个线程访问的情况下广泛使用。

readwrite（默认）：readwrite是默认值，表示该属性同时拥有setter和getter。

readonly： readonly表示只有getter没有setter。

assign（默认）：assign用于值类型，如int、float、double和NSInteger，CGFloat等表示单纯的复制。还包括不存在所有权关系的对象，比如常见的delegate。

strong：strong是在IOS引入ARC的时候引入的关键字，是retain的一个可选的替代。表示实例变量对传入的对象要有所有权关系，即强引用。strong跟retain的意思相同并产生相同的代码，但是语意上更好更能体现对象的关系。

weak：在setter方法中，需要对传入的对象不进行引用计数加1的操作。简单来说，就是对传入的对象没有所有权，当该对象引用计数为0时，即该对象被释放后，用weak声明的实例变量指向nil，即实例变量的值为0。（ARC IOS 5 之后）

copy：与strong类似，但区别在于实例变量是对传入对象的副本拥有所有权，而非对象本身。

**其他



## iOS数据结构

### 链表

https://www.jianshu.com/p/12fe060811f2



### 堆和栈的区别

objective-c 对象所占内存总是分配在“堆空间”，并且堆内存是由你释放的，即release。
栈是由编译器管理自动释放的，在方法中（函数体）定义的变量通常在栈内。

1.栈区(stack):由编译器自动分配释放，存放函数的参数值，局部变量等值。其操作方式类似于数据结构中的栈。
2.堆区(heap):一般由程序员分配释放，若程序员不释放，则可能会引起内存泄漏。注 堆和数据结构中的堆栈不一样，其类似于链表。

栈是一个用来存储局部和临时变量的存储空间。在现代操作系统中,一个线程会分配一个栈. 当一个函数被调用,一个stack frame(栈帧)就会被压到stack里。里面包含这个函数涉及的参数,局部变量,返回地址等相关信息。当函数返回后,这个栈帧就会被销毁。而这一切都是自动的,由系统帮我们进行分配与销毁。对于程序员来说，我们无须自己调度。

堆从本质上来说，程序中所有的一切都在内存中（有些东西是不在堆栈中的，但在这篇文章中我们不作讨论）。在堆上，我们可以任何时候分配内存空间以及释放销毁它。你必须显示的请求在堆上分配内存空间，如果你不使用垃圾回收机制，你必须显示的去释放它。这就是在你的函数调用前需要完成的事情。简单来说，就是malloc与free。

通常以这种方式创建对象：
NSObject *obj = [[NSObject alloc] init];
系统会在栈上存储obj这个指针变量，它所指的对象在堆中。通过[NSObject alloc]系统会为其在堆中开辟一块内存空间，并为其生成NSObject所需内存结构布局。

栈对象：
     优点：1.高速，在栈上分配内存是非常快的。
                2.简单，栈对象有自己的生命周期，你永远不可能发生内存泄露。因为他总是在超出他的作用域时被自动销毁了
     缺点：栈对象严格的定义了生命周期也是其主要的缺点,栈对象的生命周期不适于Objective-C的引用计数内存管理方法。
在objective-c中只支持一个类型对象：blocks。
关于在block中的对象的生命周期问题。出现这问题的原因是，block是新的对象，当你使用block时候，如果你想对其保持引用，你需要对其进行copy操作，（从栈上copy到堆中，并返回一个指向他的指针），而不是对其进行retain操作
堆对象：
    优点：可以自己控制对象的生命周期。

    缺点：需要程序员手动释放，容易造成内存泄漏。







#### 4、获取类中所有的成员变量和属性

一些没有提供API的类，有些属性我们拿不到又需要用怎么办？

例如：UITextField的placeholder的颜色，API并没有这个属性

```
运行时获取UITextField的所有成员变量，会发现有一个_placeholderLabel成员变量，通过这个可以设置颜色

[self.textField setValue:[UIColor blueColor] forKeyPath:@"_placeholderLabel.textColor"];
```

