---
layout: post
title: "CocoaPods使用说明书" 
category: iOS开发进阶
tags: 开发工具
---



## 1、什么是CocoaPods

CocoaPods 是开发 OS X 和 iOS 应用程序的一个第三方库的依赖管理工具。利用它可以定义自己的依赖关系 (称作 pods)，并且随着时间的变化，以及在整个开发环境中对第三方库的版本管理非常方便。这里整理了从基本安装到使用的操作流程和期间容易出现的问题以及解决办法。



## 2、CocoaPods都做了什么

简单查看一下[cocoapods源代码](https://github.com/CocoaPods/CocoaPods)（[ruby语言](https://xilankong.github.io/2016年/2016/07/01/Ruby使用说明书.html)），了解一下install和update过程都干了什么。 参考：[cocoapods都做了什么](https://www.jianshu.com/p/84936d9344ff)

#### CocoaPods/lib/cocoapods/command/install.rb

```
def run
    verify_podfile_exists!
    installer = installer_for_config //Podfile的内容解析
    installer.repo_update = repo_update?(:default => false)
    installer.update = false //和update的区别
    installer.install!
 end
```

#### CocoaPods/lib/cocoapods/command/update.rb

```
def run
    verify_podfile_exists!

    installer = installer_for_config
    installer.repo_update = repo_update?(:default => true)
    if @pods
      verify_lockfile_exists!
      verify_pods_are_installed!
      installer.update = { :pods => @pods }
    else
      UI.puts 'Update all pods'.yellow
      installer.update = true
    end
    installer.install!
end
```



####  CocoaPods/lib/cocoapods/installer.rb

```
def install!
  prepare
  resolve_dependencies //处理依赖关系、比如是根据本地specs文件呢还是远端git地址等
  download_dependencies//跟进依赖关系下载对应依赖包
  validate_targets
  generate_pods_project //生成pods.xcodeproj工程，将依赖中的文件、Library加入工程，设置target dependencies、生成workspace//
  if installation_options.integrate_targets?
    integrate_user_project
  else
    UI.section 'Skipping User Project Integration'
  end
  perform_post_install_actions
end
```

### 总结

Podfile的内容解析

repo的更新检查

处理Podfile中的依赖关系

下载依赖资源

生成pods.xcodeproj工程

将依赖中的文件、Library加入工程

设置target dependencies

生成workspace



## 3、CocoaPods的安装

### 1.安装过程

安装方式异常简单 , Mac 下都自带 ruby，使用 ruby 的 gem 命令即可下载安装：

```
$ sudo gem install cocoa pods

$ pod setup
```

### 2.安装过程可能出现的错误

#### gem版本需要更新

首先确认软件源地址是正确的，然后如果你的 gem 太老，可能也会有问题，可以尝试用如下命令升级 gem。

```
$ sudo gem update –system  //sudo 执行 不然会报无权限错误
```

更新完成 gem 后 ：

```
$ gem update cocoapod //更新cocoapod

$ pod setup pod //更新完成后初始化

$ pod repo update —verbose //更新repo
```

如果报错，先移除原来的缓存文件:

```
$ rm -rf ~/.cocoapods/repos/master //然后再 pod setup。
```

#### pod setup 卡住在 Setting up CocoaPods master repo

这步其实是 Cocoapods 在将它的信息下载到  ~/.cocoapods 目录下，如果你等太久，可以试着 cd 到那个目录，用  du -sh * 来查看下载进度。

如果还是慢，更新一下软件源：

ruby 的软件源 `https://rubygems.org` 因为使用的是亚马逊的云服务，所以被墙了，需要更新一下 ruby 的源。并且由于淘宝源已经不再进行更新维护，改成由 ruby-china 管理维护 所以源改成 `https://gems.ruby-china.org/`。

```
gem sources –remove https://rubygems.org // 移除默认源

gem sources -a https://gems.ruby-china.org // 添加新的源

gem sources -l //查看sources源 看是否已经更换
```

## 4、CocoaPods基础应用

### 1.项目中的使用方法

使用时需要新建一个名为 Podfile 的文件，以如下格式，将依赖的库名字依次列在文件中即可:

```
source 'https://github.com/CocoaPods/Specs.git' //可以在这里按这种格式配置其他仓库
target 'MyApp' do 
platform :ios, '6.0' //IOS 系统、版本要求
pod 'MJExtension', '~> 2.5.12' //引入的pod项目对应的项目名称 和版本号
platform :ios,'7.0' 
pod 'FMDB','~> 2.6.0'//~>符号指的是 2.6 级别版本获取最新的版本'
end
```

然后你将编辑好的  Podfile 文件放到你的项目根目录中，执行如下命令即可：

```
cd “你的podfile所在目录”

pod install
```

现在，你的所有第三方库都已经下载完成并且设置好了编译参数和依赖，你只需要记住如下：

> 使用 CocoaPods 生成的 .xcworkspace 文件来打开工程，而不是以前的 .xcodeproj 文件。
>
> 每次更改了 Podfile 文件，你需要重新执行一次 pod update 命令。

当不知道某款第三方库的引入方法时可以直接在终端查找第三方库 或者 你如果不知道 CocoaPods 管理的库中，是否有你想要的库，那么你可以通过  pod search xxx 命令进行查找

### 2.CocoaPods使用中的tips

#### 1.关于 Podfile.lock

当你执行 pod install 之后，除了 Podfile 外，CocoaPods 还会生成一个名为 Podfile.lock 的文件，Podfile.lock 应该加入到版本控制里面，不应该把这个文件加入到 .gitignore 中。

因为 Podfile.lock 会锁定当前各依赖库的版本，之后如果多次执行 pod install  不会更改版本，要pod update 才会改 Podfile.lock 了。

这样多人协作的时候，可以防止第三方库升级时造成大家各自的第三方库版本不一致。

> 后面的CocoaPods私人仓库创建会讲到 podspec 文件的问题

#### 2.–-no-repo-update

CocoaPods 在执行 pod install 和 pod update 时，会默认先更新一次 podspec 索引,会去更新 repo。

使用 --no-repo-update 参数可以禁止其做索引更新操作。如下所示：

> pod install –-no-repo-update
>
> pod update –-no-repo-update

#### 3.移除tag0.0.1，再重现提交新的tag0.0.1

```
git add . 
git commit -m"cover tag 0.0.1" 
git push 
git tag -d 0.0.1 
git push origin :refs/tags/0.0.1 
git tag 0.0.1 
git push origin 0.0.1
```

#### 4.CocoaPods原理

大概研究了一下 CocoaPods 的原理，它是将所有的依赖库都放到另一个名为 Pods 项目中，然后让主项目依赖 Pods 项目，这样，源码管理工作都从主项目移到了 Pods 项目中。发现的一些技术细节有：

> 1.Pods 项目最终会编译成一个名为 libPods.a 的文件，主项目只需要依赖这个 .a 文件即可。
>
> 2.对于资源文件，CocoaPods 提供了一个名为 Pods-resources.sh 的  bash  脚本，该脚本在每次项目编译的时候都会执行，将第三方库的各种资源文件复制到目标目录中。
>
> 3.CocoaPods 通过一个名为 Pods.xcconfig 的文件来在编译时设置所有的依赖和参数。

### 3.创建私有仓库

使用pod的时候 我们会遇到需要将自己的代码封装出去 单独管理的情况，这种情况下 我们就需要一个私有的仓库来管理这些单独的部件。

#### 1.创建一个支持pod引入的项目

cocoapods提供了一个快捷的项目模板创建命令：

```
$ pod lib create 你要创建的项目的项目名称
```

执行命令会有如下选择过程：

```
//pod lib create 你要创建的项目的项目名称  命令执行后会询问基本信息
//1.是否需要一个例子工程；2.选择一个测试框架；3.是否基于View测试；4.类的前缀；

What language do you want to use?? [ Swift / ObjC ]
 > ObjC

Would you like to include a demo application with your library? [ Yes / No ]
 > yes

Which testing frameworks will you use? [ Specta / Kiwi / None ]
 > none

Would you like to do view based testing? [ Yes / No ]
 > no

What is your class prefix?
 > YG
```

依次按需要执行完成就会生成一个有格式的项目。

生成项目分为 Example 和 Pods 两个主要的目录。

```
Pods 
|- Assets 文件夹，//用来存放本地资源，比如图片、Assets.xcassets等
|- Classes 文件夹，//存放pod的.m.h.swift.xib文件等
| 
Example 文件夹，//就是一个demo项目方便pod代码开发
|   |- demoProject.xcodeproj
|   |- demoProject.xcworkspace
|   |- Podfile   //就是一个demoPod项目的 第三方库依赖描述文件
|   |- Podfile.lock
|   |- demoProject
|   |- Pods      //其他第三方库依赖描述文件存放文件夹
|   |- Tests
LICENSE //开源协议文件
| 
demoProject.podspec  //这个pod文件的说明书，下面会详细说
```

项目在xcode中的结构如下：

![png](https://xilankong.github.io/resource/pod_dir.png)

其中重要的两个部分是 *.podspec 文件 和 pods下面的 Development Pods 目录其实就是上面提到的Pod目录。.podspec 就像一个说明书，描述当前这份pod项目 需要提交到私有库中，才能让其他项目通过私有库引用到当前这份pod项目。

*.podspec 内容格式基本如下：

```
Pod::Spec.new do |s| 
s.name = “demoProject” //项目名 
s.version = “1.0.2” //版本号 要和在git上的tag对应 
s.summary = “demo” 
s.description = <<-DESC 
this is a demo 
DESC 
s.homepage = “git@gitlab.jfz.net:xxxx/demoProject” //项目主页 
s.license = ‘MIT’ 
s.author = { “young” => “young.huang@jfz.com” } //用户信息 
s.source = { :git => “git@gitlab.jfz.net:xxx/demoProject.git”, :tag => s.version.to_s }//git地址 
s.platform = :ios, ‘6.0’ //支持系统、最低版本 
s.requires_arc = true  //是否使用ARC，如果指定具体文件，则具体的问题使用ARC
s.source_files = ‘Pod/Classes/*/.{h,m}’ //项目核心部分的文件 class下面的所有.h/.m文件

#s.source_files = 'Pod/Classes/**/*'//代码源文件地址，**/* 表示Classes目录及其子目录下所有文件，如果有多个目录下则用逗号分开，如果需要在项目中分组显示，这里也要做相应的设置

# s.public_header_files = ‘Pod/Classes/*/.h’ //公开头文件地址
# s.frameworks = ‘UIKit’, ‘MapKit’ //此pod项目使用到得框架 
# s.dependency ‘AFNetworking’, ‘~> 2.3’ //此pod项目依赖的其他pod项目

end
```

[subspec语法参考](https://guides.cocoapods.org/syntax/podspec.html)

修改pod项目并提交到指定地址 给项目打上tag 这里的tag需要和podspec中配置的tag一样。

```
$ git tag 1.0.0

$ git push origin v1.0.0
```

**特别注意** :

> 1.每次往Pod里面添加文件、图片、等任何非代码级别的改动的时候，都需要在Example目录下面进行一次pod install 或者 pod update一次。
>
> 2.版本管理忽略掉pods文件夹 保留 podfile podfile.lock 跟着版本同步

#### 2.创建私有仓库

首先创建放私有库(repo) git地址 ：

```
git@gitlab.xxx.net:xxxxx/demoRepo.git
```

然后在添加一个叫 demoRepo 的本地repo,并指向之前创建好的git地址，控制台命令:

```
$ pod repo add demoRepo git@gitlab.xxx.net:xxxxx/demoRepo.git
$ pod repo //查看本地所有repo
```

私有库创建好了后，回到之前创建的pod项目下，一般修改好podspec后会进行校验必须是无错误、无警告才能提交。校验命令：

```
pod lib lint //只是本地格式校验

pod spec lint YoungEwm.podspec //这个命令除开校验格式  还需要校验远程地址，链接的项目地址等
```

将修改好的podspec文件push到我们刚刚创建的demoRepo上。加上 –-verbose命令会打印操作日志

```
$ pod repo push demoRepo demoProject.podspec –-verbose
```

到最后如果是因为警告原因（warn）无法通过则在push命令后如上 `--allow-warnings` 即可。成功提交后在我们的demoRepo对应的git remote端就可以看到一个对应版本的 pod spec 文件。

```
├─ LICENSE
├─ demoProject
│   └─ 1.0.2
│       └─ demoProject.podspec
└─ README.md
```

#### 3.获取私有仓库中的pod项目

上面已经将我们自己创建的项目注册到了我们自己的私有repo中，在我们的主项目中需要引入这些pod部件的时候。首先在项目的 `.xcodeproj` 文件同级 创建一个 podfile 文件 文件内容如下：

```
source ‘https://github.com/CocoaPods/Specs.git’ 引用的源 cocoapods的公用源 
source ‘git@gitlab.jfz.net:huangyang/demoRepo.git’ 我们自己的私有源

platform :ios, ‘6.0’ 
target ‘demoWebView’ do 
pod ‘JFZPodsDemo’, ‘~> 1.0.1’ //我们需要引入的pod项目 ~> 表示是 1.0.X 版本级别的更新 前两位不改变

end
```

这里面的 platform 版本要和 podspec 里面设置的不能冲突,否则无法引用pod项目

然后重新 pod install 一下就好了

#### 4.删除repo

如何删除一个私有Spec Repo，只需要执行一条命令即可：

```
pod repo remove demoRepo
```

这样这个Spec Repo就在本地删除了，我们还可以通过

```
pod repo add demoRepo git@coding.net:wtlucky/WTSpecs.git
```

再把它给加回来。

如果我们要删除私有Spec Repo下的某一个podspec怎么操作呢，此时无需借助Cocoapods，只需要cd到~/.cocoapods/repos/demoRepo 目录下，删掉库目录。

```
~/.cocoapods/repos/demoRepo$ rm -Rf demoRepoXXX
```

然后在将Git的变动push到远端仓库即可。

#### 5.可能遇见的问题

**spec文件无法校验通过**

发生原因：

当spec本身格式有错误的时候

当引用多个私有repo中得pod项目，直接指向cocoapods查询不到对应的pod所属的私有repo

解决办法 ：

在pod repo push 后跟上对repo的地址指向 -- source=。已经添加到本地的repo 可以直接用repo名称，没有的使用git地址。

```
--sources=https://github.com/artsy/Specs,master  
```

#### 6.开发pod项目的其他问题

**1.怎么在开发中调试程序**

开发过程中，可以修改Podfile文件的，将pod版本指向本地。对应pod的代码会被引入Development Pods中：

```
#pod 'Stock', :path => '/Users/xxxx/desktop/workplace/Stock'
```

**2.模块之间的命名问题**

最好以模块为单位添加不同的前缀。

**3.Pod之间的引用**

**4.tag缓存问题**

添加pod的某个tag如0.0.1 到repo后，需要修改代码但又不想提升tag版本时，注意修改完后清理CocoaPods的本地缓存

```
$ rm -rf “${HOME}/Library/Caches/CocoaPods”
```

**5.第三方库的修改，尽量fork再通过pod引用**

**6.ignore 文件忽略问题**

有时候突然想要忽略某个文件，但是跟新 .gitignore 以后，remote 端并没有马上删除这个文件，原因是ignore文件只能忽略没有加入版本管理的文件，已经被纳入了版本管理的文件是无效的

```
git rm -r --cached .
git add .
git commit -m 'update .gitignore'
```

**7.使用ssh协议(见git使用中得ssh描述)**

**8.解决ArgumentError - invalid byte sequence in US-ASCII错误**
修改终端语言、地区等国际化环境变量

```
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

**9.CI-SSH 问题**

```
#解决ci远程slave访问git时，要求验证私钥密码问题
#即，pod install 时，跟新pod的访问权限问题
#$SSH_PARIVATE_KEY_PASS变量为私钥密码
#为了安全在jenkins的环境变量里面设置这个常量
eval $(ssh-agent)
expect << EOF
spawn ssh-add $1
expect "Enter passphrase"
send "$SSH_PRIVATE_KEY_PASS\r"
expect eof
EOF
```

**10.其他知识点**

pod 在多人协作的时候 如何保证 发布版本不会跟着开发走动  ：

我们从开发过程可以看到 当我们pod install的时候 会出现下面代码：

```
Pre-downloading: `Category` from `git@gitlab.xxx.net:xxx_iOS/Category.git`, commit `e244ac83e027b8f6247e702603ecf0209c9d4878`
```

这里说明 Category这个库 更新了 pod去拉取Category库最新的代码

cocoapods是根据 podfile文件中得 配置去指向指定库 同时 也有一个pod.lock文件 这个文件用于锁定 pod拉取代码的 commit 节点。如下是Category在pod.lock文件中生成的，commit 就是指向对应commit节点。

```
Category:
:commit: 03c7a540b5c24eda6cea048048adef887cbbc77a
:git: git@gitlab.jfz.net:gxq_iOS/JFZReportModule.git
```

当然  如果是已经打了tag的不存在这个问题 因为它是按tag去拉取，这里针对的时尚未打tag的库。



## 5、CocoaPods高级应用



### podfile文件的更多应用



#### 1、pod引用参数

1、Build configurations（编译配置）

```
pod 'PonyDebugger', :configurations => ['Debug', 'Beta']
```

2、Subspecs（子模块）

```
pod 'QueryKit', :subspecs => ['Attribute', 'QuerySet']
pod 'QueryKit/Attribute'
```

3、branch、tag、commit

```
pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :branch => 'dev'
pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :tag => '0.7.0'
pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :commit => '082f8319af'
```

4、指定podspec

```
pod 'JSONKit', :podspec => 'https://example.com/JSONKit.podspec'
```

#### 2、target

一个工程多个taget需要不同pod配置项的时候

```
workspace 'xxx.xcworkspace' 指定对应xcworkspace
target :ZipApp do
  project 'FastGPS' 指定对应project

  pod 'SSZipArchive'
end

使用自定义构建配置
project 'TestProject', 'Mac App Store' => :release, 'Test' => :debug

```

#### 3、inhibit_all_warnings!

屏蔽cocoapods库里面的所有警告

```
inhibit_all_warnings!
or
pod 'SSZipArchive', :inhibit_warnings => true
```

#### 4、pre_install

这个钩子允许你在Pods被下载后但是还未安装前对Pods做一些改变

```
pre_install do |installer|
  # Do something fancy!
end
```

#### 5、post_install

这个钩子允许你在生成的Xcode project写入硬盘或者其他你想执行的操作前做最后的改动

```
给所有target自定义编译配置

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_ENABLE_OBJC_GC'] = 'supported' //配置环境变量等
    end
  end
end
```

#### 6、abstract_target

```
抽象target、当多个target的工程并且工程中各个target之间有很大一部分依赖是相同的时候，我们可以抽象出一个抽象target

抽象target中的所有target都自动继承抽象target定义的所有依赖

abstract_target 'Shows' do
  pod 'ShowsKit'

  # The target ShowsiOS has its own copy of ShowsKit (inherited) + ShowWebAuth (added here)
  target 'ShowsiOS' do
    pod 'ShowWebAuth'
  end

  # The target ShowsTV has its own copy of ShowsKit (inherited) + ShowTVAuth (added here)
  target 'ShowsTV' do
    pod 'ShowTVAuth'
  end

  # Our tests target has its own copy of
  # our testing frameworks, and has access
  # to ShowsKit as well because it is
  # a child of the abstract target 'Shows'

  target 'ShowsTests' do
    inherit! :search_paths
    pod 'Specta'
    pod 'Expecta'
  end
end
```

#### 7、其他参数 swift_version、platform、use_frameworks、inherit

```
swift_version：指定swift版本号
swift_version = '4.0'

platform：指定系统、版本 

platform :ios, '4.0'
platform :ios

use_frameworks：使用动态库
use_frameworks!

inherit! :search_paths
明确指定继承于父层的所有pod，默认就是继承的
```

8、Jenkins 和cocoapods 和打包机的问题

升级打包机cocoapods 发现没有用 ，识别到的jenkins打包环境对应的RVM版本完全不对，根本和slave不一样。为什么：：

jenkins执行shell命令 记得加上

```
#!/bin/bash -l

没有这一句执行到的jenkins环境很奇怪 我也不知道指向了哪里的环境
```





## 6、参考文献

[cocoapods官网](https://cocoapods.org)

[cocoapods都做了什么](https://www.jianshu.com/p/84936d9344ff)

[cocoapods——dqk](https://blog.dianqk.org/2017/05/01/dev-on-pod/)





# Cocoapods原理



## 一、Xcode工程结构

#### 1、scheme

![scheme](https://xilankong.github.io/resource/xcodebuild/scheme.png)

日常开发中我们常常点击 Xcode 左上角的 Run 箭头来运行调试代码，这其实就是执行了 Scheme 定义的一个任务。**针对一个指定的 target，scheme 定义了 build 这个 target 时使用的配置选项，执行的任务，环境参数等等**。Scheme 可以理解为一个工作计划，Xcode 会按照 scheme 中的定义去执行，Scheme 中预设了六个主要的工作流： Build、 Run、Test、Profile、 Analyze、Archive。包括了我们对某个 target 的所有操作，每一个工作流都可以单独配置。

常见的就是我们切换Build Configuration  --  Debug和Release。

每个 configuration 对应了 build target 时不同的参数集，比如宏，编译器选项，bundle name 等等。我们可以在 target 的配置页中更改这些选择项，也可以自己创建新的 build configuration，比如为 App 创建不同版本的配置。

除了 build configuration 外，scheme 还可以配置：

- 运行时的环境变量（Environment Variables）
- 启动时设置给 运行时的参数，比如本地化语言选择（Arguments Passed on Launch）
- App 执行时的系统语言、模拟的定位坐标、国家等环境参数
- runtime，内存管理，日志，帧率检测等调试选项

一个 scheme 对应一个 target，同一个 target 可以有多个 scheme，通过灵活地配置 scheme，我们可以方便地管理不同环境下 App 的测试，调试，打包流程。



下表列举了我们在 Scheme 中的常见配置选项：

| 配置选项                       | 选项内容                                                     |
| ------------------------------ | ------------------------------------------------------------ |
| Launch                         | 编译完成后是否立即运行                                       |
| Arguments Passed On Launch     | 指定一些运行时的参数，比如本地化语言的选项，Core Data 调试选项等 |
| Environment Variables          | 指定环境变量，比如开启僵尸内存、Malloc选项、I/O buffer大小等 |
| Application Language/RegionApp | 运行使用的语言和国家                                         |
| XPC Services                   | 打开调试 XPC (应用间通信)                                    |
| Queue Debugging                | 打开线程调试，会自动记录运行时的线程信息                     |
| Runtime Sanitization           | 是否打开运行时的一些调试选项，包括内存检测、多线程检测等等，在 debug 一些棘手的异常时十分有用 |
| Memory Management              | 开启一些内存管理相关的服务，包括内存涂抹，边缘保护，动态内存分配保护，僵尸对象等等 |
| Logging                        | 配置调试过程中终端输出的日志                                 |



#### 2、Target

Target 是我们工程中的**最小可编译单元**，我们在scheme那边可以切换我们的编译target。每一个 target 对应一个编译输出，这个输出可以是一个链接库，一个可执行文件或者一个资源包。**它定义了这个输出怎样被 build 的所有细节**，包括：

- 编译选项，比如使用的编译器，目标平台，flag，头文件搜索路径等等。
- 哪些源码或者资源文件会被编译打包，哪些静态库、动态库会被链接。
- build 时的前置依赖、执行的脚本文件。
- build 生成目标的签名、Capabilities 等属性。

我们平时在 Build Settings，Build Phases 中配置的各种选项，大部分都是对应到指定的 target 的。

每次我们在 Xcode 中 run/test/profile/analyze/archive 时，都必须指定一个 target。

工程中的 targets 有时候会共享很多代码、资源，这些相似的 targets 可能对应同一个应用的不同版本，比如 iPad 版和 iPhone 版，或者针对不同市场的版本。



#### 3、Project

Project 很好理解，就是一个 Xcode 工程，它管理这个工程下的 targets 集合以及它们的源码，引用的资源，framework 等等。

Project 是管理资源的容器，本身是无法被编译的，所以每个 project 至少应该有一个可编译的 target，否则就是一个空壳。一个 target 编译时引用的资源是它所在 project 所有管理资源的子集。

我们也可以对 project 进行配置，包括基本信息和编译选项（Build Settings）等，这些配置会应用到它管理的所有 targets 中，但是如果 target 有自己的配置，则会覆盖 project 中对应的配置。

在很多情况下，我们的工程中只有一个 project。可以在 finder 中双击后缀名为`.xcodeproj` 的文件，就可以直接打开单个 project 了。

如果我们需要从源码编译一个依赖库，可以把这些源码所在的工程作为主工程的`subProject` 添加到目录结构中去，然后将这个子工程的某个 target 作为主工程 target 的依赖，从而在 build 主工程 target 的时候，顺便也会编译子工程对应的 target。

然后将这个子工程的某个 target 作为主工程 target 的依赖，从而在 build 主工程 target 的时候，顺便也会编译子工程对应的 target。

这样做的好处是你可以在一个窗口中同时修改主工程和子工程的源码，并且一起进行编译。

#### 4、Workspace

上面所说的添加子工程的方法，已经很好的解决了不同项目中 target 依赖的问题了，那么什么时候需要用到 Workspace 呢？

当一个 target 被多个不同的项目依赖，或者 project 之间互相引用，那么我们就需要把这些 projects 放到相同的层级上来。**管理相同层级 projects 的容器就是 Workspace**。

和 project，target 不同，workspace 是纯粹的**容器**，不参与任何编译链接过程，它主要管理：

- Xcode 中的 projects，记录它们在 Finder 中的引用位置。
- 一些用户界面的自定义信息（窗口的位置，顺序，偏好等等）。

注意到，当你把不同的 projects 放到一个 workspace 中管理后，你仍然可以用 Xcode 单独打开其中的某一个 project，但是如果它涉及到对其它 project target 的依赖，这时候你无法在这个单独的窗口中编译成功。

在 iOS 开发中，我们常常使用 Cocoapods 来管理三方库，它会把这些三方库的源码组装成一个 project，和主工程一起放入到 workspace 中，自动配置好主工程与 pods 库之间的依赖。所以如果引入了 Cocoapods，我们必须打开这个新的 workspace 才能正常 build 原来的项目。关于 Cocoapods，我们在后面的文章中再详细介绍



## 二、cocoapods的原理是什么



Cocoapods 核心原理

workspace 是xcode提供的用于多个子工程管理，和 projects，target 不同，workspace 是纯粹的**容器**，不参与任何编译链接过程

pod lib create PodDemo

我们构建一个pod的样本工程我们可以看到和我们自己构建workspace是一样的

在CocoaPods中，会存在以下几种文件：

- podspec  Pod的描述文件，一般来说表征你的项目地址，项目使用的平台和版本等信息
- podfile  用户编写的对于期望加载的pod信息
- podfile.lock  记录了之前pod加载时的一些信息，包括版本、依赖、CocoaPods版本等
- mainfest.lock  记录了本地pod的基本信息，实际上是podfile.lock的拷贝 大部分开发者最熟悉的cocoaPods指令就是`pod install`，那具体在执行`pod install`时发生了什么呢？

#### pod install 运行原理分析

当我们运行 `pod install` 时，会发生：

- 分析Dependency。 对比本地pod的version和podfile.lock中的pod version，如果不一致会提示存在风险
- 对比podfile是否发生了变化。 如果存在问题，会生成两个列表，一个是需要Add的Pod(s)，一个是需要Remove的Pod(s)。
- (如果存在remove的)删除需要Remove的Pods
- 添加需要的Pod(s)。 此时，如果是常规的CocoaPods库（如果基于Git），会先去： 
  - Spec下查找对应的Pod文件夹
  - 找到对应的tag，不写就是最新
  - 定位其Podspec文件
  - git clone下来对应的文件
  - copy到Pod文件夹中
  - 运行pre-Install hook
- 生成Pod Project 
  - 将该Pod中对应文件添加到工程中
  - 添加对应的framework、.a库、bundle等
  - 链接头文件（link headers），生成Target
  - 运行 post-install hook
- 生成podfile.lock，之后生成此文件的副本，将其放到Pod文件夹内，命名为manifest.lock （如果出现 `The sandbox is not sync with the podfile.lock`这种错误，则表示manifest.lock和podfile.lock文件不一致），此时一般需要重新运行`pod install`命令。
- 配置原有的project文件（add build phase） 
  - 添加了 `Embed Pods Frameworks` 
  - 添加了 `Copy Pod Resources` 

其中，pre-install hook和post-install hook可以理解成回调函数，是在podfile里对于install之前或者之后（生成工程但是还没写入磁盘）可以执行的逻辑，逻辑为：

```javascript
pre_install do |installer| 
    # 做一些安装之前的hook
end

post_install do |installer| 
    # 做一些安装之后的hook
end
```

#### CocoaPods第三方库下载逻辑

- 首先，CocoaPods会根据Podfile中的描述进行依赖分析，最终得出一个扁平的依赖表。 这里，CocoaPods使用了一个叫做 [Milinillo](https://github.com/CocoaPods/Molinillo/blob/master/ARCHITECTURE.md) 的依赖关系解决算法。
- 针对列表中的每一项，回去Spec的Repo中查看其podSpec文件，找到其地址
- 通过downloader进行对应库的下载。如果地址为git+tag，则此步骤为`git clone xxxx.git` 注意，此时必须要保证需要下载的pod版本号和git仓库的tag标签号一致。

所有依赖库下载之后，便进入了和Xcode工程的融合步骤。

## 3、Xcode工程的变化

Xcode工程上有什么变化

在cocoaPods和Xcode工程进行集成的过程中，会有有以下流程

- creat workspace 创建xcworkspace文件。其实xcworkspace文件本质上只是xcodeproject的集合，数据结构如下：

```javascript
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:Demo/Demo.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:Pods/Pods.xcodeproj">
   </FileRef>
</Workspace>
```

- create group， 在工程中创建group文件夹，逻辑上隔离一些文件
- create pod project & add pod library， 创建pod.xcodeproject工程，并且将在podfile中定义的第三方库引入到这个工程之中。

-  add embed frameworks script phase， 添加了[CP] Embed Pods Frameworks

  ![embed](https://xilankong.github.io/resource/xcodebuild/embed.png)

  Pods-Develop-frameworks.sh  脚本用来完成将内部第三方库打包成.a静态库文件（在Podfile中如果选择了!use_frameworks，则此步骤会打包成.framework）     

- remove embed frameworks script phase， 如果本次podfile删除了部分第三方库，则此步骤会删除掉不需要的第三方库，将其的引用关系从Pod.xcodeproject工程中拿走。
-  add copy resource script phase， 如果第三方库存在资源bundle，则此步骤会将资源文件进行复制到集中的目录中，方便统一进行打包和封装。相应的，会添加[CP] Copy Pods Resources脚本。      ![podResource](/Users/yang/Desktop/xcode build/podResource.png)

-  add check manifest.lock script phase, 添加[CP] Check Pods Manifest.lock 脚本，前文提到过，manifest.lock其实是podfile.lock的副本。此步骤会进行diff，如果存在不一致，则会提示著名的那句`The sandbox is not sync with the podfile.lock`错误。

- add user script phase， 此步骤是对原有project工程文件进行改造。在运行过 pod install 后，再次打开原有工程会发现无法编译通过，因为已经做了改动。 

  1、 首先，添加了对Pod工程的依赖，具体为引用中多了Pods_Develop.framework文件。此文件为上述步骤中xxx.framework.sh打包出来的文件，也就是说，**cocoaPods会把所有第三方的组件封装为一个.framework文件（或者静态库的.a文件）！** 

  使用  `use_frameworks! `     

  ![pod库](https://xilankong.github.io/resource/xcodebuild/libpods-framework.png)

  不使用  `use_frameworks! ` 

  ![libpods-a](https://xilankong.github.io/resource/xcodebuild/libpods-a.png)

   2、 静态文件引入   

  -  建立了Pods的group，内含pods-xxx-debug.xconfig和pods-xxx.release.xconfig文件。这两个文件是对应工程的build phase的配置。相应的，主工程的Iinfo->Configurations的debug和release配置会对应上述两个配置文件。      

  - 上述两个配置都做了什么？包括： Header_search_path，指向了Pod/Headers/public/xxx，添加了Pods文件编译后的头文件地址 Other_LDFLAGS，添加了-ObjC等等 一些Pods变了，例如Pods_BUILD_DIR等

至此，原有xcode工程和新建的Pod工程完成了集成和融合。

