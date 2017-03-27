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





4、消息机制

## 4、第一个项目

app的适配、小demo 应用调试、页面间的传值



5、问答



6、IOS学习方向

面向对象开发？ 类的特征  编译方式，oc使用c语音 oc中还可以使用什么别的语言  IOS开发帮助工具 （git cocoapods）





7、参考资料

[官方文档](https://developer.apple.com/library/content/navigation/)