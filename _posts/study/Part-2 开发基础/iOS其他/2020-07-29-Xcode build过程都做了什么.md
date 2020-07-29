---
layout: post
category: iOS开发基础
title : "Xcode build过程中都做了什么"
tags: Xcode学习
---



讲build之前，我们先简单了解一下编译的过程。

## 一、编译过程简单介绍

Objective C/C/C++使用的编译器前端是[clang](https://clang.llvm.org/docs/index.html)，swift是[swiftc](https://swift.org/compiler-stdlib/#compiler-architecture)，后端都是[LLVM](https://llvm.org/)。



![编译流程](https://xilankong.github.io/resource/xcodebuild/编译流程.jpg)

### 1、LLVM

LLVM命名源自 Low Level Virtual Machine，是一个强大的编译器开发工具套件。

LLVM的核心库提供了现代化的 source-target-independent[优化器 ](https://llvm.org/docs/Passes.html)和支持诸多流行CPU架构的代码生成器，这些核心代码是围绕着LLVM IR(中间代码)建立的。

基于LLVM，又衍生出了一些强大的子项目：[Clang](http://clang.llvm.org/)和[LLDB](http://lldb.llvm.org/)。

### 2、Clang

Clang是一个C、C++、Objective-C语言的轻量级编译器。OC一般前端是Clang编译，流程大致如下

![clang](https://xilankong.github.io/resource/xcodebuild/clang.png)

##### 1、预处理(preprocessor)

预处理会替进行头文件引入，宏替换，注释处理，条件编译(#ifdef)等操作

##### 2、词法分析(lexical anaysis)

读入源文件的字符流，将他们组织成有意义的词素(lexeme)序列，对于每个词素，此法分析器产生词法单元（token）作为输出

##### 3、语法分析(semantic analysis)

词法分析的Token流会被解析成一颗抽象语法树(abstract syntax tree - AST)。AST是开发者编写clang插件主要交互的数据结构，clang也提供很多API去读取AST。更多细节：[Introduction to the Clang AST](https://clang.llvm.org/docs/IntroductionToTheClangAST.html)。

##### 4、CodeGen

CodeGen遍历语法树，生成LLVM IR代码。LLVM IR是前端的输出，后端的输入。

##### 5、生成汇编代码

LLVM对IR进行优化后，会针对不同架构生成不同的目标代码，最后以汇编代码的格式输出

##### 6、汇编器生成 .o文件

汇编器以汇编代码作为输入，将汇编代码转换为机器代码，最后输出目标文件(object file)

##### 7、连接器

把编译产生的.o文件和（dylib,a,tbd）文件，生成一个mach-o文件

### 3、swiftc

https://swift.org/swift-compiler/#compiler-architecture

![swiftc](https://xilankong.github.io/resource/xcodebuild/swiftc.png)

##### 1、解析器

解析器是一个简单的递归下降解析器(在lib/Parse中实现)，带有集成的手工编码的lexer。解析器负责生成没有任何语义或类型信息的抽象语法树(AST)，并针对输入源的语法问题发出警告或错误。

##### 2、语义分析，生成AST

语义分析(在lib/Sema中实现)负责获取已解析的AST，并将其转换为格式良好、类型完全检查的AST形式，对源代码中的语义问题发出警告或错误。语义分析包括类型推断，如果成功，则指示从结果的经过类型检查的AST生成代码是安全的。

##### 3、SIL生成与优化

SIL是一种高级的、特定于Swift的中间语言，适合进一步分析和优化Swift代码。SIL生成阶段(在lib/SILGen中实现)将类型检查的AST降低为所谓的“原始”SIL。SIL的设计在文档/SIL.rst中有描述。

SIL保证的转换(在lib/SILOptimizer/Mandatory中实现)执行影响程序正确性的额外数据流诊断(比如未初始化变量的使用)。这些转换的最终结果是“规范的”SIL。

SIL优化(在lib/Analysis、lib/ARC、lib/LoopTransforms和lib/Transforms中实现)对程序执行额外的高级、特定于速度的优化，包括(例如)自动引用计数优化、devirtualization和泛型专门化。

##### 4、SIL降低为LLVM IR 

LLVM IR生成:IR生成(在lib/IRGen中实现)将SIL降低为LLVM IR 代码，此时LLVM可以继续优化它并生成机器码。

##### 5、生成汇编代码

##### 6、生成可执行代码



#### 4、演示一遍编译(OC语言)

接下来，从代码层面看一下具体的转化过程，新建一个main.h  和main.m

```
#main.h

#import <Foundation/Foundation.h>

//A base class for common MyDemo
@interface MyDemo : NSObject
+ (void)test;
@end

#main.m

#import "main.h"

//A base class for common MyDemo
#define DEBUG 1
@implementation MyDemo
+ (void)test {
#ifdef DEBUG
        NSLog(@"this is oc debug demo");
#else
        NSLog(@"this is oc demo");
#endif
}
@end

int main(int argc, char * argv[]) {
    [MyDemo test];
}
```

**1、预处理(preprocessor)**

```
xcrun clang -E main.m
```

预处理后的文件有400多行，在文件的末尾，可以找到main函数

```
@interface MyDemo : NSObject
+ (void)test;
@end

@implementation MyDemo
+ (void)test {
   NSLog(@"this is oc debug demo");
}
@end

int main(int argc, char * argv[]) {
    [MyDemo test];
}
```

可以看到，在预处理的时候，注释被删除，条件编译被处理。

**2、词法分析(lexical anaysis)**

```
$ xcrun clang -fmodules -fsyntax-only -Xclang -dump-tokens main.m
```

输出一堆这种内容：

```
l_brace '{'	 [LeadingSpace]	Loc=<main.m:20:35>
l_square '['	 [StartOfLine] [LeadingSpace]	Loc=<main.m:21:5>
identifier 'MyDemo'		Loc=<main.m:21:6>
identifier 'test'	 [LeadingSpace]	Loc=<main.m:21:13>
r_square ']'		Loc=<main.m:21:17>
semi ';'		Loc=<main.m:21:18>
r_brace '}'	 [StartOfLine]	Loc=<main.m:22:1>
eof ''		Loc=<main.m:22:2>
```

`Loc=<main.m:20:31>`标示这个token位于源文件main.m的第1行，从第1个字符开始。保存token在源文件中的位置是方便后续clang分析的时候能够找到出错的原始位置。

l_brace、identifier、semi 就如字面意思，释义具体符号或者标识 或者标点

**3、语法分析(semantic analysis)**

词法分析的Token流会被解析成一颗抽象语法树(abstract syntax tree - AST)。

```
$ xcrun clang -fsyntax-only -Xclang -ast-dump main.m | open -f
```

AST的结构如下样式：

```
[0;34m|-[0m[0;1;32mObjCInterfaceDecl[0m[0;33m 0x7f8e4fad8208[0m <[0;33m./main.h:5:1[0m, [0;33mline:10:2[0m> [0;33mline:5:12[0m[0;1;36m MyDemo[0m
[0;34m| |-[0msuper [0;1;32mObjCInterface[0m[0;33m 0x7f8e492bc7a8[0m[0;1;36m 'NSObject'[0m
[0;34m| |-[0m[0;1;32mObjCImplementation[0m[0;33m 0x7f8e4fad83a0[0m[0;1;36m 'MyDemo'[0m
[0;34m| `-[0m[0;1;32mObjCMethodDecl[0m[0;33m 0x7f8e4fad8320[0m <[0;33mline:8:1[0m, [0;33mcol:13[0m> [0;33mcol:1[0m +[0;1;36m test[0m [0;32m'void'[0m
[0;34m|-[0m[0;1;32mObjCImplementationDecl[0m[0;33m 0x7f8e4fad83a0[0m <[0;33mmain.m:6:1[0m, [0;33mline:17:1[0m> [0;33mline:6:17[0m[0;1;36m MyDemo[0m
[0;34m| |-[0m[0;1;32mObjCInterface[0m[0;33m 0x7f8e4fad8208[0m[0;1;36m 'MyDemo'[0m
[0;34m| `-[0m[0;1;32mObjCMethodDecl[0m[0;33m 0x7f8e4fad8430[0m <[0;33mline:8:1[0m, [0;33mline:15:1[0m> [0;33mline:8:1[0m +[0;1;36m test[0m [0;32m'void'[0m
[0;34m|   |-[0m[0;1;32mImplicitParamDecl[0m[0;33m 0x7f8e4fad84b8[0m <[0;33m<invalid sloc>[0m> [0;33m<invalid sloc>[0m implicit[0;1;36m self[0m [0;32m'Class':'Class'[0m
[0;34m|   |-[0m[0;1;32mImplicitParamDecl[0m[0;33m 0x7f8e4fad8518[0m <[0;33m<invalid sloc>[0m> [0;33m<invalid sloc>[0m implicit[0;1;36m _cmd[0m [0;32m'SEL':'SEL *'[0m
[0;34m|   `-[0m[0;1;35mCompoundStmt[0m[0;33m 0x7f8e4fad86a0[0m <[0;33mcol:14[0m, [0;33mline:15:1[0m>
```

**4、CodeGen**

生成LLVM IR代码。LLVM IR是前端的输出，后端的输入。

```
xcrun clang -S -emit-llvm main.m -o main.ll
```

main.ll文件内容样式：

```
define internal void @"\01+[MyDemo test]"(i8*, i8*) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i8*, align 8
  store i8* %0, i8** %3, align 8
  store i8* %1, i8** %4, align 8
  notail call void (i8*, ...) @NSLog(i8* bitcast (%struct.__NSConstantString_tag* @_unnamed_cfstring_ to i8*))
  ret void
}
```

Objective C代码在这一步会进行runtime的桥接：property合成，ARC处理等。

LLVM会对生成的IR进行优化，优化会调用相应的Pass进行处理。Pass由多个节点组成，都是[Pass](http://llvm.org/doxygen/classllvm_1_1Pass.html)类的子类，每个节点负责做特定的优化，更多细节：[Writing an LLVM Pass](https://llvm.org/docs/WritingAnLLVMPass.html)。

**5、生成汇编代码**

LLVM对IR进行优化后，会针对不同架构生成不同的目标代码，最后以汇编代码的格式输出：

生成arm 64汇编：

```
$ xcrun clang -S main.m -o main.s
```

查看生成的main.s文件，样式大致如下

```
 .section	__TEXT,__objc_classname,cstring_literals
L_OBJC_CLASS_NAME_:                     ## @OBJC_CLASS_NAME_
	.asciz	"MyDemo"
	.section	__TEXT,__objc_methname,cstring_literals
L_OBJC_METH_VAR_NAME_:                  ## @OBJC_METH_VAR_NAME_
	.asciz	"test"
	.section	__TEXT,__objc_methtype,cstring_literals
L_OBJC_METH_VAR_TYPE_:                  ## @OBJC_METH_VAR_TYPE_
	.asciz	"v16@0:8"
	.section	__DATA,__objc_const
	.p2align	3               ## @"\01l_OBJC_$_CLASS_METHODS_MyDemo"
l_OBJC_$_CLASS_METHODS_MyDemo:
	.long	24                      ## 0x18
	.long	1                       ## 0x1
	.quad	L_OBJC_METH_VAR_NAME_
	.quad	L_OBJC_METH_VAR_TYPE_
	.quad	"+[MyDemo test]"
```

**6、汇编器**

汇编器以汇编代码作为输入，将汇编代码转换为机器代码，最后输出目标文件(object file)。

```
$ xcrun clang -fmodules -c main.m -o main.o
```

通过nm命令，查看下main.o中的符号

```
$ xcrun nm -nm main.o

                 (undefined) external _NSLog
                 (undefined) external _OBJC_CLASS_$_NSObject
                 (undefined) external _OBJC_METACLASS_$_NSObject
                 (undefined) external ___CFConstantStringClassReference
                 (undefined) external __objc_empty_cache
                 (undefined) external _objc_msgSend
0000000000000000 (__TEXT,__text) non-external +[MyDemo test]
0000000000000030 (__TEXT,__text) external _main
00000000000000b0 (__DATA,__objc_const) non-external l_OBJC_$_CLASS_METHODS_MyDemo
00000000000000d0 (__DATA,__objc_const) non-external l_OBJC_METACLASS_RO_$_MyDemo
0000000000000118 (__DATA,__objc_const) non-external l_OBJC_CLASS_RO_$_MyDemo
0000000000000160 (__DATA,__objc_data) external _OBJC_METACLASS_$_MyDemo
0000000000000188 (__DATA,__objc_data) external _OBJC_CLASS_$_MyDemo
```

`_NSLog`是一个是undefined external的。undefined表示在当前文件暂时找不到符号`_NSLog`，而external表示这个符号是外部可以访问的，对应表示文件私有的符号是`non-external`。

**7、链接**

连接器把编译产生的.o文件和（dylib,a,tbd）文件，生成一个mach-o文件

```
$ xcrun clang main.o -o main
```

我们就得到了一个mach o格式的可执行文件

```
$  demo ./main
2020-07-22 17:02:56.829 main[51123:1397953] this is oc debug demo
```

在用nm命令，查看可执行文件的符号表：

```
$ nm -nm main
                 (undefined) external _NSLog (from Foundation)
                 (undefined) external _OBJC_CLASS_$_NSObject (from libobjc)
                 (undefined) external _OBJC_METACLASS_$_NSObject (from libobjc)
                 (undefined) external ___CFConstantStringClassReference (from CoreFoundation)
                 (undefined) external __objc_empty_cache (from libobjc)
                 (undefined) external _objc_msgSend (from libobjc)
                 (undefined) external dyld_stub_binder (from libSystem)
0000000100000000 (__TEXT,__text) [referenced dynamically] external __mh_execute_header
0000000100000f00 (__TEXT,__text) non-external +[MyDemo test]
0000000100000f30 (__TEXT,__text) external _main
00000001000020c8 (__DATA,__objc_data) external _OBJC_METACLASS_$_MyDemo
00000001000020f0 (__DATA,__objc_data) external _OBJC_CLASS_$_MyDemo
0000000100002118 (__DATA,__data) non-external __dyld_private
```

可以看到，_NSLog后面多了 from Foundation。表示这个符号来自于 Foundation ，会在运行时动态绑定。

#### 5、再看一下Swift语言编译过程

先写个demo.swift

```
import Foundation

class MyClass {
    
    func doSth() {
        print("do sth")
    }
}
MyClass().doSth()
```

**1、生成语法树**

```
$ swiftc -dump-ast demo.swift
```

生成的AST 样式大概如下

```swift
(source_file "demo.swift"
  (import_decl range=[demo.swift:1:1 - line:1:8] 'Foundation')
  (class_decl range=[demo.swift:3:1 - line:8:1] "MyClass" interface type='MyClass.Type' access=internal non-resilient
    (func_decl range=[demo.swift:5:5 - line:7:5] "doSth()" interface type='(MyClass) -> () -> ()' access=internal
      (parameter "self" interface type='MyClass')
      (parameter_list range=[demo.swift:5:15 - line:5:16])
      (call_expr type='()' location=demo.swift:6:9 range=[demo.swift:6:9 - line:6:23] nothrow arg_labels=_:
        (declref_expr type='(Any..., String, String) -> ()' location=demo.swift:6:9 range=[demo.swift:6:9 - line:6:9] decl=Swift.(file).print(_:separator:terminator:) function_ref=single)
```

**2、生成最简洁的SIL代码**

```
swiftc -emit-sil demo.swift 
```

输出

```
sil_stage canonical

// MyClass.deinit
sil hidden @$s4demo7MyClassCfd : $@convention(method) (@guaranteed MyClass) -> @owned Builtin.NativeObject {
// %0                                             // users: %2, %1
bb0(%0 : $MyClass):
  debug_value %0 : $MyClass, let, name "self", argno 1 // id: %1
  %2 = unchecked_ref_cast %0 : $MyClass to $Builtin.NativeObject // user: %3
  return %2 : $Builtin.NativeObject               // id: %3
} // end sil function '$s4demo7MyClassCfd'

sil_vtable MyClass {
  #MyClass.doSth!1: (MyClass) -> () -> () : @$s4demo7MyClassC5doSthyyF	// MyClass.doSth()
  #MyClass.init!allocator.1: (MyClass.Type) -> () -> MyClass : @$s4demo7MyClassCACycfC	// MyClass.__allocating_init()
  #MyClass.deinit!deallocator.1: @$s4demo7MyClassCfD	// MyClass.__deallocating_deinit
}
```

**3、生成LLVM IR代码**

```
swiftc -emit-ir demo.swift -o demo.ll 
```

输出

```
; ModuleID = 'demo.ll'
source_filename = "demo.ll"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

%swift.full_type = type { i8**, %swift.type }
%swift.type = type { i64 }
%objc_class = type { %objc_class*, %objc_class*, %swift.opaque*, %swift.opaque*, i64 }
%swift.opaque = type opaque
%swift.method_descriptor = type { i32, i32 }
%T4demo7MyClassC = type <{ %swift.refcounted }>
%swift.refcounted = type { %swift.type*, i64 }
%swift.type_metadata_record = type { i32 }
%swift.metadata_response = type { %swift.type*, i64 }
%swift.bridge = type opaque
%Any = type { [24 x i8], %swift.type* }
%TSS = type <{ %Ts11_StringGutsV }>
%Ts11_StringGutsV = type <{ %Ts13_StringObjectV }>
%Ts13_StringObjectV = type <{ %Ts6UInt64V, %swift.bridge* }>
%Ts6UInt64V = type <{ i64 }>
```

**4、生成汇编代码**

```
 swiftc -emit-assembly demo.swift -o demo.s
```

**5、汇编器**

汇编器以汇编代码作为输入，将汇编代码转换为机器代码，最后输出目标文件(object file)。

```
$ xcrun clang -fmodules -c demo.s -o demo.o
```

通过nm命令，查看下 demo.o 中的符号

```
xcrun nm -nm demo.o
                 (undefined) external _$sBoWV
                 (undefined) external _$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC
                 (undefined) external _$sSSN
                 (undefined) external _$ss27_allocateUninitializedArrayySayxG_BptBwlF
                 (undefined) external _$ss5print_9separator10terminatoryypd_S2StF
                 (undefined) external _$sypN
                 (undefined) external _OBJC_CLASS_$__TtCs12_SwiftObject
                 (undefined) external _OBJC_METACLASS_$__TtCs12_SwiftObject
                 (undefined) external __objc_empty_cache
                 (undefined) external _swift_allocObject
                 (undefined) external _swift_bridgeObjectRelease
                 (undefined) external _swift_deallocClassInstance
                 (undefined) external _swift_getInitializedObjCClass
                 (undefined) external _swift_release
0000000000000000 (__TEXT,__text) external _main
0000000000000050 (__TEXT,__text) private external _$s4demo7MyClassCMa
00000000000000a0 (__TEXT,__text) private external _$s4demo7MyClassC5doSthyyF
0000000000000160 (__TEXT,__text) weak private external _$ss5print_9separator10terminatoryypd_S2StFfA0_
0000000000000180 (__TEXT,__text) weak private external _$ss5print_9separator10terminatoryypd_S2StFfA1_
00000000000001a0 (__TEXT,__text) private external _$s4demo7MyClassCACycfC
00000000000001f0 (__TEXT,__text) private external _$s4demo7MyClassCACycfc
0000000000000210 (__TEXT,__text) private external _$s4demo7MyClassCfd
0000000000000230 (__TEXT,__text) private external _$s4demo7MyClassCfD
0000000000000298 (__DATA,__data) private external _$s4demo7MyClassCMm
00000000000002c0 (__DATA,__data) non-external _$s4demo7MyClassCMf
00000000000002d0 (__DATA,__data) private external [no dead strip] [alt entry] _$s4demo7MyClassCN
0000000000000330 (__DATA,__objc_const) non-external l__METACLASS_DATA__TtC4demo7MyClass
0000000000000378 (__DATA,__objc_const) non-external l__DATA__TtC4demo7MyClass
00000000000003c0 (__TEXT,__const) non-external l___unnamed_5
00000000000003c8 (__TEXT,__const) weak private external _$s4demoMXM
00000000000003d4 (__TEXT,__const) non-external l___unnamed_6
00000000000003dc (__TEXT,__const) private external _$s4demo7MyClassCMn
0000000000000410 (__TEXT,__const) private external [no dead strip] [alt entry] _$s4demo7MyClassC5doSthyyFTq
0000000000000418 (__TEXT,__const) private external [no dead strip] [alt entry] _$s4demo7MyClassCACycfCTq
0000000000000420 (__TEXT,__const) weak private external [no dead strip] ___swift_reflection_version
0000000000000422 (__TEXT,__swift5_typeref) weak private external _symbolic _____ 4demo7MyClassC
0000000000000428 (__TEXT,__swift5_fieldmd) non-external [no dead strip] _$s4demo7MyClassCMF
0000000000000438 (__TEXT,__swift5_types) non-external [no dead strip] l_type_metadata_table
0000000000000440 (__DATA,__objc_classlist) non-external [no dead strip] _objc_classes
00000000000006a8 (__DATA,__bss) non-external _$s4demo7MyClassCML
```

**6、转成可执行文件**

汇编按前面的方式转成

把.o文件转成可执行文件

```
swiftc demo.o -o demo
```

```
运行成功

$ demo ./demo
do sth
```



## 二、Xcode build过程都做了什么



#### 1、Xcode 索引构建期间做的事情

在DerivedData目录 构建工程目录 - 中间内容目录、构建Products目录

![build目录构建](https://xilankong.github.io/resource/xcodebuild/build目录构建.png)



主要了解一下 各个target的build目录，我们看一下Develop target的build目录：

![build目录](https://xilankong.github.io/resource/xcodebuild/build目录.png)

- **DerivedSources / Develop-Swift.h文件，pod校验结果文件**

- **一堆hmap文件  主要是帮助编译器找到头文件的辅助文件：存储头文件到其物理路径的映射关系。**

可以通过一个辅助的小工具[hmap](https://github.com/milend/hmap)查看hmap中的内容：

> AppDelegate.h -> /Users/xxx/Desktop/Demo/Demo/AppDelegate.h 
>
> Demo-Bridging-Header.h -> /Users/xxx/Desktop/Demo/Demo/Demo-Bridging-Header.h
>
> Dummy.h -> /Users/xxx/Desktop/Demo/Framework/Dummy.h 

Clang 发现  import 的时候，先在headermap(Develop-generated-files.hmap  、Develop-project-headers.hmap) 里查找，headermap找不到接着在 own target 的 framework里面找

如果再找不到然后SDK里找 （先找到framework 然后 查找头文件是否存在）

- **Objects-normal 目录（存放每个类的编译文件，每一个类都三个文件 `.d`、`.dia`、`.o`  ）**

> .d: 表示这个类所依赖的其他类，即使用import导入的头文件，会自动寻找所有的依赖头文件，包含多级依赖 (a依赖b，b又依赖c，那么最终a也会依赖c)
> .dia: 是diagnose的简写，就是诊断的意思，我们在Xcode写的源代码，经过编译的时候有时候会生成一些警告信息，都是放到这里面的
> .o: 对象文件，.m经过编译生成.o文件，用来链接到可执行文件中
>
> Develop.LinkFileList (链接的所有对象文件 .o 列表)

- **script文件配置的各种执行脚本，最终都是在这里**

- **InputFileList 和 OutputList 分别是拷贝资源 和 framework的目录地址列表**

- **xcent文件  entitlements中的内容**

  

#### 2、单个Target的编译过程

1、准备工作 ：

- 在DerivedData目录 构建工程目录 - 中间内容目录等

2、Write auxiliary files  写辅助文件

- all-product-headers.yaml，   头文件地址汇总列表

- .hmap 相关 （主要是帮助编译器找到头文件的辅助文件：存储这头文件到其物理路径的映射关系。）

- Develop.LinkFileList (链接的所有对象文件 .o 列表)  在Objects-normal 目录里

3、编译源文件

4、生成.framework(.a)



#### 3、Pod编译

先了解一下cocoapods的原理：[pod的原理]([https://xilankong.github.io/ios%E6%9B%B4%E5%A4%9A%E7%9F%A5%E8%AF%86/2016/06/24/CocoaPods%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E%E4%B9%A6.html](https://xilankong.github.io/ios更多知识/2016/06/24/CocoaPods使用说明书.html))

就在 cocoapods原理中提及的一样，最终是通过依赖一个pod构建的framework来关联起主工程和pod工程

在  Pods-Develop-frameworks.sh 脚本帮助下，所有的pod库都会打成 framework（或者.a），具体的流程就和签名提及的编译单个Target的流程类似

pod framework 目录结构：

![企业微信截图_08f5449b-09d6-4d9c-8749-64d49b321a28](https://xilankong.github.io/resource/xcodebuild/framework-folder.png)

![企业微信20200721054104](https://xilankong.github.io/resource/xcodebuild/framework.png)



1、解析info.plist文件

2、Cp AKBuy-umbrella.h   Framework的 master 头文件  将那些想暴露的头文件汇总，OC的库很明显看到很多.h文件公布  到framework

3、编译swift 源文件

4、cp AKBuy-swift.h文件 （oc中使用swift的类，swift的类会映射在这个文件）

5、编译AKBuy-dummy.m文件，CocoaPods 使用的用于区分不同 pod 的编译文件，每个第三方库有不同的 target，所以每次编译第三方库时，都会新增几个文件：包含编译选项的.xcconfig文件，同时拥有编译设置和 CocoaPods 配置的私有 .xcconfig 文件，编译所必须的prefix.pch文件以及编译必须的文件 dummy.m

6、编译AKBuy_vers.c 文件

7、copy x86_64.swiftmodule ， swift模块文件

8、copy x86_64.swiftdoc， 保存了从源码获得的文档注释

9、链接依赖库

10、拷贝bundle文件 （会提前构建签名好）

11、拷贝module.mudulemap，  这个文件标识对一个框架，一个库的所有头文件的结构化描述。通过这个描述，桥接了新语言特性和老的头文件，会指定 AKBuy-umbrella.h ,  AKBuy-Swift.h

12、生成AKBuy.framework

13、签名



#### 4、编译Target依赖（serviceExtension）



#### 5、编译主Target

准备：确认编译方式，schecme、依赖关系

1、创建  .app目录  和  /.app/PlugIns 目录

2、配置 Entitlements、证书等，像我们工程没有aps证书 就没有这一块的工作

3、构建辅助文件，和前面的单个Target的类似

4、脚本文件运行（build phase 里的）

5、编译主工程源文件

6、copy  Develop-swift.h、copy x86_64.swiftmodule、copy x86_64.swiftdoc

7、动态库、静态库处理，链接到.app下的可执行文件

8、拷贝处理资源文件 （CompileStoryboard 编译 `.storyboard` 为 `.storyboardc` 文件，拷贝其他资源文件）

9、CopyPlistFile 处理自定义的 plist 文件、CopyPNGFile 拷贝png图片文件、CompileAssetCatalog (编译 .xcassets 文件 为 Assets.car)

10、CopyPNGFile 拷贝png图片文件、CompileAssetCatalog (编译 .xcassets 文件 为 Assets.car)

10、ProcessInfoPlistFile (处理 `info.plsit` 信息)

11、LinkStoryboards 链接前面生成的 storyboradc

12、脚本文件 

run custom shell script '[CP] Copy Pods Resources'

run custom shell script '[CP] Embed Pods Frameworks'

run custom shell script '[CP] Copy Pods Resources'

run custom shell script 'Crashlytics'

run custom shell script 'Bugly'

13、Copy AkulakuServiceExtension.appex、Validate  AkulakuServiceExtension.appex

Validate  AkulakuServiceExtension.appex

14、CodeSign 签名、校验.app文件  _CodeSignature
