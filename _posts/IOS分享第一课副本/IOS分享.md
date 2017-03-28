# IOS学习入门

概述

## 1、语言基础

#### 1、C 语言

基本数据类型、判断与循环语句、函数与变量作用域、基本运算与进制、基本算法、数组与指针、枚举、宏定义

#### 2、Objective-C 语言

OC基本语法、类与对象、封装与继承、点语法、公有与私有属性、构造方法、内存管理的原则、MRC的内存管理、ARC的内存管理、野指针与僵尸对象、分类、协议、延展、block的简单使用、代理设计模式、Foundation框架、数组持久化、单例设计模式

#### 3、Swift 语言

swift 工程中得main方法入口

@UIApplicationMain

http://www.tuicool.com/articles/fAZ3yef

Swift 是 Apple 自创的一门专门为 Cocoa 和 CocoaTouch 设计的语言，意在用来替代 objc

```
所有的 Swift 代码都将被 LLVM 编译为 native code，以极高的效率运行。按照官方今天给出的 benchmark 数据，运行时比 Python 快 3.9 倍，比 objc 快 1.4 倍左右
另一方面，Swift 的代码又是可以 Interactive 来“解释”执行的。新的 Xcode 中加入了所谓的 Playground 来对开发者输入的 Swift 代码进行交互式的相应，开发者也可是使用 swift 的命令行工具来交互式地执行 swift 语句。细心的朋友可能注意到了，我在这里把“解释”两个字打上了双引号。这是因为即使在命令行中， Swift 其实也不是被解释执行的，而是在每个指令后进对从开始以来的 swift 代码行了一遍编译，然后执行的。这样的做法下依然可以让人“感到”是在做交互解释执行，这门语言的编译速度和优化水平，可见一斑。同时 Playground 还顺便记录了每条语句的执行时候的各种情况，叫做一组 timeline。可以使用 timeline 对代码的执行逐步检查，省去了断点 debug 的时间，也非常方便。
```



Swift采用了安全的编程模式和添加现代的功能来使得编程更加简单、灵活和有趣。界面则基于广受人民群众爱戴的Cocoa和Cocoa Touch框架，展示了软件开发的新方向。

```
cocoa与cocoa Touch区别之分
相同之处：两者都包含OC运行时的两个核心框架：
cocoa包含Foundation和AppKit、Core Data等框架，可用于开发Mac OS X系统的应用程序
cocoa touch包含Foundation和UIKit框架，可用于开发iPhone OS 系统的应用程序
```

```
   1.swift程序的入口是UIApplicationMain;

    2.OC的类是以.h和.m组成的;swift是一.swift结尾的;

    3.OC的类是以@interface和@end开始结尾;swift是采用{};

    4.OC里语句结束以分号(;);swift里不需要分号,添加分号也不会出错;

    5.OC中创建一个视图,采用alloc/init,swift采用();

    6.OC中创建视图采用initWithXXX;swift里变成(XXX:)

    7.swift设置属性,全面采用点语法;

    8.OC中添加视图使用self.view.addSubView;swift添加视图使用view.addSubView,不使用self,为了在闭包里和构造函数里区分会在闭包里和够构造函数里用self;

    9.OC中枚举需要写全,swift中采用type.类型的形式;

    10.OC里的方法是采用@selector;swift采用”方法名”形式;

    11.swift中的枚举可以省略前面的tyoe,直接采用点语法,只能提示不太好;

    12.OC中打印使用NSLog,swift使用print;

    13.等号左右两边最号用对等的空格;
```

```
数据类型等级  http://www.jianshu.com/p/f25b1ae07103

OC

swift 类型体系
Swift中的函数和闭包都是一等公民

```



## 2、xcode的使用

1、项目结构、常用配置

开发环境 （默认有环境变量，编译后内容在哪？app在哪），硬件软件 应用程序目录结构说明  iOS模拟器 获取更多版本的模拟器 程序的调试

新建项目流程 （每个属性的分别意义）

LaunchScreen作用 启动图storyboard

demo 目录结构，配置文件意义

资源处理 多倍图，imageAssets，国际化，常见配置文件 创建目录最好建立真实目录方便调整

```
xcode Toolbar
Xcode - OPen Developer Tool
File - 工程创建
Product -编译 run clean

window api 、devices、organizer
scheme意义
```

```
IOS 工程内容http://www.jianshu.com/p/e304247ede59

1、PROJECT 和 TARGETS
project就是一个项目，或者说工程，一个project可以对应多个target
targets之间完全没有关系。但target和project有关系，target的setting会从project settings中继承一部分
targets 一个target对应一个新的product(基于同一份代码的情况下).
虽然代码是同一份, 但编译设置(比如编译条件), 以及包含的资源文件却可以有很大的差别. 于是即使同一份代码, 产出的product也可能大不相同。例如我们一份代码需要做出不同应用环境的 app 这个时候target的作用就出来了。  每个target单独会有一份 info.plist

Manage Schemes

project 中的配置项：
Info
这个Info.plist文件内定义了一个iPhone项目的很多关键性内容, 比如程序名称, 最终生成product的全局唯一id等等.每一个Target都能设置不同的 

custom ios target properties
$(PRODUCT_BUNDLE_IDENTIFIER) 通配符
$(EXECUTABLE_NAME) 执行程序名，默认与 PRODUCT_NAME 一致。不能修改Info.plist中的该键，否则报错

Bundle Version String是正式的，跟itunes上的版本号一致，Bundle Version 可用作内部版本时使用，当Bundle Version String缺省时，Bundle Version替代Bundle Version String的功能，同时也继承他的限制(比如格式，位数等)，需与itunes上的版本号保持一致。
 


development target 最低兼容系统版本号 
configurations

target 中的配置项:

build settings

Info.plist

general

capabilities

resource Tags

info

buid settings

buid phases

target dependencies
某些Target可能依赖某个Target输出的值,这里设置依赖
compile sources
指将有哪些源代码被编译
link binary with libraries
是指编译过程中会引用哪些库文件
copy bundle resources
是指生成的product的.app内将包含哪些资源文件
build rules


edit scheme



```



```
demo
--demo
--demoTests
--demoUITests
--Products
--Frameworks
```

playground的介绍 特性



2、开发常用工具、API

```

```



3、Xib / Storyboard 的使用

4、xcode 项目调试

代码调试 LLDB调试 断点调试

IOS模拟器调试：

```
模拟器的使用：旋转、截屏、慢动作、colorlayers、window大小 scale
```



IOS真机调试 （模拟器毕竟是模拟器） http://www.runoob.com/ios/ios-first-iphone-application.html

LLDB调试 断点调试

## 3、IOS基础

runLoop

UIResponder 是干嘛的

AppDelegate 是干嘛的

IOS证书

GXQ导航条实现方式



1、UIKit框架 （视图控件、事件处理）

IOS UI  层次结构 storyboard  scene是什么 xib开发，代码开发 pods导入、自动布局

2、QuartzCore框架 （绘图 CALayer图层）

3、CoreAnimation框架 （核心动画）

IOS基础知识  UIViewController生命周期  application生命周期 线程机制  IOS动画

IOS运行时 、IOS文件

```
iphone 的 屏幕宽度 、像素比、scale

设备	尺寸	逻辑分辨率	设备分辨率	scale
4S	3.5 INCH	320*480	640*960	2
5S	4 INCH	320*568	640*1136	2
6	4.7 INCH	375*667	750*1334	2
6+	5.5 INCH	414*736	1080*1920	3
7	4.7 INCH	375*667	750*1334	2
7+	5.5 INCH	414*736	1080*1920	3
PPI = （（根号 （宽平方 + 高平方））/尺寸）
```





介绍xcode基本开发 常用的点 快捷键，操作方式





框架和API

```
UIKit (UITableView、UIButton、UINavigationController以及GestureRecognizers)
Interface Builder (Storyboards、Segues和奇怪的.xib)
基本数据类型 (NSArray、NSDictionary以及NSString)，与之对应的Swift中的类型 (Array、Dictionary 和 String)，HTTP API (NSURLSession, 基本的 REST API 概念, 用NSJSONSerialization解析处理JSON)
Grand Central Dispatch (GCD、NSOperationQueue)
持久化 (NSCoding、NSUserDefaults和CoreData)
内存管理 (什么是 循环引用 以及 ARC 基础)
```

```
开发模式

模式很重要，它能让开发更轻松，让你的代码更整洁。确保你了解最基本的模式，它们被广泛使用在iOS框架中，不了解这些你很难在开发中施展拳脚（还有很多其他的模式，但这些可以作为你刚开始学习的起点）。

代理 (这是很多iOS的API会涉及到的，你必须清楚地理解它)
Model View Controller (我不认为Apple在鼓励使用最好的MVC分离上做的足够出色，但如果你花时间正确实践它，它会是一个能帮助你提升代码质量的重要模式。同样，基本上都会出现在任何面试问题的列表里。)
Subclassing (几乎所有用户接口都是某个类的子类)
单例 (这个模式绝对被滥用了...请有节制地使用)
```

模拟使用场景去使用 协议，block，代理

控件 跳转 storyboard开发



4、消息机制

## 4、第一个项目

app的适配、小demo 应用调试、页面间的传值



5、问答



6、IOS学习方向

面向对象开发？ 类的特征  编译方式，oc使用c语音 oc中还可以使用什么别的语言  IOS开发帮助工具 （git cocoapods）

沙盒目录，IOS查看文件 日志目录



异常捕获 http://www.cocoachina.com/ios/20141229/10787.html

7、参考资料

[官方文档](https://developer.apple.com/library/content/navigation/)



1，开发用那个IDE。xcode？vs？还是什么其他的高逼格的， 需要装多少辅助插件之类的
2，有没有类似安卓的mainfest的文件。相对应的访问权限之类的是怎么设置。、、权限设置，ios文档
2，类似android的启动运行的生命周期 、、生命周期 图（http://blog.csdn.net/totogo2010/article/details/8048652/）这个链接存在过时情况，需要进一步考证
3，事件怎么绑定，可以简单的说下嵌套的层的事件触发冲突的这类是怎么搞的  、、事件响应链http://www.cocoachina.com/ios/20160113/14896.html
4，UI是怎么拖进去界面的 我就喜欢拖进去。

5，介绍一下xcode都提供哪些功能，比如说内存泄漏检测等，另外，你们会怎么做单元自测、代码扫描 静态代码扫描，swiftLint

6，IOS 像素比

7，IOS编译、页面传值

