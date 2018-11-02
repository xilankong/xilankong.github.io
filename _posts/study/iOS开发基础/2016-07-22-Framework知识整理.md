---
layout: post
category: iOS开发基础
title:  "Framework知识整理" 
---

https://www.jianshu.com/p/71b5ecacaaac

https://www.jianshu.com/p/cbec1da24585



Could not build Objective-C module 'keyword'

framework生成问题





dyld: Library not loaded: 各种情况

    第一种情况：

    dyld: Library not loaded: @rpath/libswiftCore.dylib

    Referenced from: /var/containers/Bundle/Application/CF227EE4-F36F-4161-A8A4-BB063D74B0CF/Boss.app/Boss

    Reason: no suitable image found.  Did find:

    /private/var/containers/Bundle/Application/CF227EE4-F36F-4161-A8A4-BB063D74B0CF/Boss.app/Frameworks/libswiftCore.dylib: code signature invalid for '/private/var/containers/Bundle/Application/CF227EE4-F36F-4161-A8A4-BB063D74B0CF/Boss.app/Frameworks/libswiftCore.dylib'
    ***带有 Swift 项目 ***
    解决办法：
    
    1.rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang/ModuleCache"
    
    2.rm -rf ~/Library/Developer/Xcode/DerivedData
    
    3.rm -rf ~/Library/Caches/com.apple.dt.Xcode
    第二种情况
    dyld: Library not loaded: @rpath/Charts.framework/Charts
    
    Referenced from: /var/containers/Bundle/Application/FEFF646B-5902-4015-B159-C141EB0E8DC0/test.app/test
    
    Reason: image not found
    动态库未链接到项目内
    解决办法：
    
    在 TARGETS —> General —> Embedded Binaries 下，点击 + 按钮，选择 Charts.framework就可以解决问题
    第三种情况（一般出现在真机）
    
    dyld: Library not loaded: @rpath/Charts.framework/Charts
    
    ..........
    
    code signing blocked mmap() of
    
    ............
    ***证书有问题  ***
    解决办法：
    
    把所有证书删掉 重新安装





    合并SDK打开终端，cd 到 ‘~/Desktop/framework_sdk/’文件夹下执行命令，本例为：命令：lipo -create s_MyFramework.framework/MyFramework i_MyFramework.framework/MyFramework -output Myframework

​    
    重要一步：随便复制一个framework，比如本例：“i_MyFramework.framework” 将其改名为“MyFramework.framework”然后将“MyFramework.framework”包里的“MyFramework”替换成合并后的“Myframework”.



cocoapod + ruby 脚本配合自动制作 framework
