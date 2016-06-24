---
title: "CocoaPods 介绍"
layout: post
date: 2016-06-17 22:48
---



------

## 1.什么是CocoaPods

CocoaPods 是开发 OS X 和 iOS 应用程序的一个第三方库的依赖管理工具。利用它可以定义自己的依赖关系 (称作 `pods`)，并且随着时间的变化，以及在整个开发环境中对第三方库的版本管理非常方便。这里整理了从基本安装到使用的操作流程和期间容易出现的问题以及解决办法。

## 2.CocoaPods的安装

### 1.安装过程

安装方式异常简单 , Mac 下都自带 ruby，使用 ruby 的 gem 命令即可下载安装：

```
$ sudo gem install cocoa pods

$ pod setup
```

### 2.安装过程可能出现的错误

1.gem版本需要更新

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

2.pod setup 卡住在 Setting up CocoaPods master repo

这步其实是 Cocoapods 在将它的信息下载到 `~/.cocoapods`目录下，如果你等太久，可以试着 cd 到那个目录，用 `du -sh *`来查看下载进度。

如果还是慢，更新一下软件源：

ruby 的软件源 `https://rubygems.org` 因为使用的是亚马逊的云服务，所以被墙了，需要更新一下 ruby 的源。并且由于淘宝源已经不再进行更新维护，改成由 ruby-china 管理维护 所以源改成 `https://gems.ruby-china.org/`。

```
gem sources –remove https://rubygems.org // 移除默认源

gem sources -a https://gems.ruby-china.org // 添加新的源

gem sources -l //查看sources源 看是否已经更换
```

## 3.CocoaPods的使用

### 1.项目中的使用方法

使用时需要新建一个名为 `Podfile` 的文件，以如下格式，将依赖的库名字依次列在文件中即可:

```
source 'https://github.com/CocoaPods/Specs.git' //可以在这里按这种格式配置其他仓库
target 'MyApp' do 
platform :ios, '6.0' //IOS 系统、版本要求
pod 'MJExtension', '~> 2.5.12' //引入的pod项目对应的项目名称 和版本号
platform :ios,'7.0' 
pod 'FMDB','~> 2.6.0'//~>符号指的是 2.6 级别版本获取最新的版本'
end
```

然后你将编辑好的 `Podfile` 文件放到你的项目根目录中，执行如下命令即可：

```
cd “你的podfile所在目录”

pod install
```

现在，你的所有第三方库都已经下载完成并且设置好了编译参数和依赖，你只需要记住如下：

> 使用 CocoaPods 生成的 `.xcworkspace` 文件来打开工程，而不是以前的 `.xcodeproj` 文件。
>
> 每次更改了 Podfile 文件，你需要重新执行一次 `pod update` 命令。

当不知道某款第三方库的引入方法时可以直接在终端查找第三方库 或者 你如果不知道 CocoaPods 管理的库中，是否有你想要的库，那么你可以通过  `pod search xxx` 命令进行查找

### 2.CocoaPods使用中的tips

1.关于 Podfile.lock

当你执行 pod install 之后，除了 Podfile 外，CocoaPods 还会生成一个名为 `Podfile.lock` 的文件，`Podfile.lock` 应该加入到版本控制里面，不应该把这个文件加入到 `.gitignore` 中。

因为 `Podfile.lock` 会锁定当前各依赖库的版本，之后如果多次执行 pod install  不会更改版本，要pod update 才会改 Podfile.lock 了。

这样多人协作的时候，可以防止第三方库升级时造成大家各自的第三方库版本不一致。

> 后面的CocoaPods私人仓库创建会讲到 podspec 文件的问题

2.–no-repo-update

CocoaPods 在执行 pod install 和 pod update 时，会默认先更新一次 podspec 索引,会去更新 repo。使用 `--no-repo-update` 参数可以禁止其做索引更新操作。如下所示：

> pod install –no-repo-update
>
> pod update –no-repo-update

3.CocoaPods原理

大概研究了一下 CocoaPods 的原理，它是将所有的依赖库都放到另一个名为 Pods 项目中，然后让主项目依赖 Pods 项目，这样，源码管理工作都从主项目移到了 Pods 项目中。发现的一些技术细节有：

> 1.Pods 项目最终会编译成一个名为 `libPods.a` 的文件，主项目只需要依赖这个 `.a` 文件即可。
>
> 2.对于资源文件，CocoaPods 提供了一个名为 `Pods-resources.sh` 的 `bash` 脚本，该脚本在每次项目编译的时候都会执行，将第三方库的各种资源文件复制到目标目录中。
>
> 3.CocoaPods 通过一个名为 `Pods.xcconfig` 的文件来在编译时设置所有的依赖和参数。

## 3.创建私有仓库

使用pod的时候 我们会遇到需要将自己的代码封装出去 单独管理的情况，这种情况下 我们就需要一个私有的仓库来管理这些单独的部件。

### 1.创建一个支持pod引入的项目

cocoapods提供了一个快捷的项目模板创建命令：

```
$ pod lib create 你要创建的项目的项目名称
```

执行命令会有如下选择过程：

```
//pod lib create 你要创建的项目的项目名称  命令执行后会询问基本信息

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

生成项目分为 `Example` 和 `Pods` 两个主要的目录。

```
Pods 
|- Assets 文件夹，//用来存放本地资源，比如图片、Assets.xcassets等
|- Classes 文件夹，//存放pod的.m.h.swift.xib文件等
| 
Example 文件夹，//就是一个demo项目方便pod代码开发
| 
LICENSE //授权文件
| 
demoProject.podspec  //这个pod文件的说明书，下面会详细说
```

项目在xcode中的结构如下：

![png](https://xilankong.github.io/resource/pod_dir.png)

其中重要的两个部分是 `*.podspec` 文件 和 pods下面的 `Development Pods` 目录其实就是上面提到的Pod目录

`*.podspec` 就像一个说明书，描述当前这份pod项目 需要提交到私有库中，才能让其他项目通过私有库引用到当前这份pod项目。

`*.podspec`内容格式基本如下：

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
s.requires_arc = true 
s.source_files = ‘Pod/Classes/*/.{h,m}’ //项目核心部分的文件 class下面的所有.h/.m文件

# s.public_header_files = ‘Pod/Classes/*/.h’ 
# s.frameworks = ‘UIKit’, ‘MapKit’ //此pod项目使用到得框架 
# s.dependency ‘AFNetworking’, ‘~> 2.3’ //此pod项目依赖的其他pod项目

end
```

修改pod项目并提交到指定地址 给项目打上tag 这里的tag需要和podspec中配置的tag一样。

```
$ git tag 1.0.0

$ git push origin v1.0.0
```

**特别注意** :

> 每次往Pod里面添加文件、图片、等任何非代码级别的改动的时候，都需要在Example目录下面进行一次pod install 或者 pod update一次。

### 2.创建私有仓库

首先创建放私有库(repo) git地址 ：

```
git@gitlab.xxx.net:xxxxx/demoRepo.git
```

然后在添加一个叫 demoRepo 的本地repo,并指向之前创建好的git地址，控制台命令:

```
$ pod repo add demoRepo git@gitlab.xxx.net:xxxxx/demoRepo.git
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

### 3.获取私有仓库中的pod项目

上面已经将我们自己创建的项目注册到了我们自己的私有repo中，在我们的主项目中需要引入这些pod部件的时候。首先在项目的 `.xcodeproj` 文件同级 创建一个 podfile 文件 文件内容如下：

```
source ‘https://github.com/CocoaPods/Specs.git’ 引用的源 cocoapods的公用源 
source ‘git@gitlab.jfz.net:huangyang/demoRepo.git’ 我们自己的私有源

platform :ios, ‘6.0’ 
target ‘demoWebView’ do 
pod ‘JFZPodsDemo’, ‘~> 1.0.1’ //我们需要引入的pod项目 ~> 表示是 1.0.X 版本级别的更新 前两位不改变

end
```

这里面的 `platform` 版本要和 podspec 里面设置的不能冲突,否则无法引用pod项目

然后重新 `pod install` 一下就好了

### 4.可能遇见的问题

1.spec文件无法校验通过



### 5.开发pod项目的其他问题

1.怎么在开发中调试程序

开发过程中，可以修改Podfile文件的，将pod版本指向本地。对应pod的代码会被引入Development Pods中：

```
#pod 'Stock', :path => '/Users/xxxx/desktop/workplace/Stock'
```

2.模块之间的命名问题，最好以模块为单位添加不同的前缀。

3.Pod之间的引用

4.添加pod的某个tag如0.0.1 到repo后，需要修改代码但又不想提升tag版本时，注意修改完后清理CocoaPods的本地缓存

```
$ rm -rf “${HOME}/Library/Caches/CocoaPods”
```

5.第三方库的修改，尽量fork再通过pod引用

6.有时候突然想要忽略某个文件，但是跟新`.gitignore`以后，remote端并没有马上删除这个文件，原因是ignore文件只能忽略没有加入版本管理的文件，已经被纳入了版本管理的文件是无效的。

7.使用ssh协议(见git使用中得ssh描述)

8.解决ArgumentError - invalid byte sequence in US-ASCII错误
修改终端语言、地区等国际化环境变量

```
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

9.CI ssh 问题

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
