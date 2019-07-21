---
layout: post
title:  "GitHooks在IOS开发上的使用" 
category: iOS更多知识
tags: 开发工具
---



## 1.什么是 Git Hooks

如同其他许多的版本控制系统一样，Git 也具有在特定事件发生之前或之后执行特定脚本代码功能（从概念上类比，就与监听事件、触发器之类的东西类似）。[Git Hooks](https://git-scm.com/book/zh/v1/自定义-Git-Git挂钩) 就是那些在Git执行特定事件（如commit、push、receive等）后触发运行的脚本。

![](https://xilankong.github.io/resource/hooks_one.png)

Git钩子最常见的使用场景包括推行提交规范，根据仓库状态改变项目环境，和接入持续集成工作流。但是，因为脚本可以完全定制，你可以用Git钩子来自动化或者优化你开发工作流中任意部分。



## 2.Git Hooks 能做什么

Git Hooks是定制化的脚本程序，所以它实现的功能与相应的git动作相关,如下几个简单例子：

1.多人开发代码语法、规范强制统一

2.commit message 格式化、是否符合某种规范

3.如果有需要，测试用例的检测

4.服务器代码有新的更新的时候通知所有开发成员

5.代码提交后的项目自动打包（git receive之后） 等等...

更多的功能可以按照生产环境的需求写出来



## 3.Git Hooks 是如何工作的

每一个使用了 git 的工程下面都有一个隐藏的 .git 文件夹。

![一个工程下面的.git](https://xilankong.github.io/resource/git_dir.png)

挂钩都被存储在 `.git` 目录下的 hooks 子目录中，即大部分项目中的 .git/hooks。  如下图:

![一个工程下面的.git](https://xilankong.github.io/resource/githooks.png)

Git 默认会放置一些脚本样本在这个目录中，除了可以作为挂钩使用，这些样本本身是可以独立使用的。所有的样本都是shell脚本，其中一些还包含了Perl的脚本。不过，任何正确命名的可执行脚本都可以正常使用 ，也可以用Ruby或Python，或其他脚本语言。

上图是git 初始化的时候生成的默认钩子，已包含了大部分可以使用的钩子，但是 .sample 拓展名防止它们默认被执行。为了安装一个钩子，你只需要去掉 .sample 拓展名。或者你要写一个新的脚本，你只需添加一个文件名和上述匹配的新文件，去掉.sample拓展名。把一个正确命名且可执行的文件放入 Git 目录下的 hooks子目录中，可以激活该挂钩脚本，之后他一直会被 Git 调用。



**一个简单的 Hooks 例子**

使用shell 这里尝试写一个简单的钩子，安装一个 prepare-commit-msg 钩子。去掉脚本的 .sample 拓展名，在文件中加上下面这两行：

```
#!/bin/sh

echo "# Please include a useful commit message!" > $1
```

钩子需要能被执行，所以如果你创建了一个新的脚本文件，你需要修改它的文件权限。比如说，为了确保prepare-commit-msg可执行，运行下面这个命令：

```
chmod + x prepare-commit-msg
```

接下来你每次运行git commit时，你会看到默认的提交信息都被替换了。

内置的样例脚本是非常有用的参考资料，因为每个钩子传入的参数都有非常详细的说明（不同钩子不一样）。



**脚本语言**

git自己生成的默认钩子的脚本大多是shell和Perl语言的，但你可以使用任何脚本语言，只要它们最后能编译到可执行文件。每次脚本中的 #!/bin/sh 定义了你的文件将被如何解析。比如，使用其他语言时你只需要将path改为你的解释器的路径。

比如说，你可以在 prepare-commit-msg 中写一个可执行的Python脚本。下面这个钩子和上一节的shell脚本做的事完全一样。

```
#!/usr/bin/env python

import sys, os

commit_msg_filepath = sys.argv[1]
with open(commit_msg_filepath, 'w') as f:
    f.write("# Please include a useful commit message!")
```
注意第一行改成了python解释器的路径。此外，这里用sys.argv[1]而不是$1来获取第一个参数。这个特性非常强大，因为你可以用任何你喜欢的语言来编写Git钩子。



**钩子的作用域**

对于任何Git仓库来说钩子都是本地的，而且它不会随着git clone一起复制到新的仓库。而且，因为钩子是本地的，任何能接触得到仓库的人都可以修改。在开发团队中维护钩子是比较复杂的，因为.git/hooks目录不随你的项目一起拷贝，也不受版本控制影响。一个简单的解决办法是把你的钩子存在项目的实际目录中（在.git外）。这样你就可以像其他文件一样进行版本控制。

作为备选方案，Git同样提供了一个模板目录机制来更简单地自动安装钩子。每次你使用 git init 或 git clone 时，模板目录文件夹下的所有文件和目录都会被复制到.git文件夹。




## 4.客户端 Hooks

客户端钩子只影响它们所在的本地仓库。有许多客户端挂钩，以下把他们分为：提交工作流挂钩、电子邮件工作流挂钩及其他客户端挂钩。

#### 1.提交工作流挂钩

commit操作有 4个挂钩被用来处理提交的过程，他们的触发时间顺序如下：

pre-commit、prepare-commit-msg、commit-msg、post-commit

commit操作最前和最后的两个钩子执行时间如下图：

![](https://xilankong.github.io/resource/hooks_two.png)

##### pre-commit

pre-commit 挂钩在键入提交信息前运行，最先触发运行的脚本。被用来检查即将提交的代码快照。例如，检查是否有东西被遗漏、运行一些自动化测试、以及检查代码规范。当从该挂钩返回非零值时，Git 放弃此次提交，但可以用 git commit --no-verify 来忽略。该挂钩可以被用来检查代码错误，检查代码格式规范，检查尾部空白（默认挂钩是这么做的），检查新方法（译注：程序的函数）的说明。

pre-commit 不需要任何参数，以非零值退出时将放弃整个提交。这里，我们用 “强制代码格式校验” 来说明 (见第6点)。

##### prepare-commit-msg

prepare-commit-msg 挂钩在提交信息编辑器显示之前，默认信息被创建之后运行，它和 pre-commit 一样，以非零值退出会放弃提交。因此，可以有机会在提交作者看到默认信息前进行编辑。该挂钩接收一些选项：拥有提交信息的文件路径，提交类型。例如和提交模板配合使用，以编程的方式插入信息。提交信息模板的提示修改在上面已经看到了，现在我们来看一个更有用的脚本。在处理需要单独开来的bug时，我们通常在单独的分支上处理issue。如果你在分支名中包含了issue编号，你可以使用prepare-commit-msg钩子来自动地将它包括在那个分支的每个提交信息中。

```
#!/usr/bin/env python

import sys, os, re
from subprocess import check_output

# 收集参数
commit_msg_filepath = sys.argv[1]
if len(sys.argv) > 2:
    commit_type = sys.argv[2]
else:
    commit_type = ''
if len(sys.argv) > 3:
    commit_hash = sys.argv[3]
else:
    commit_hash = ''

print "prepare-commit-msg: File: %s\nType: %s\nHash: %s" % (commit_msg_filepath, commit_type, commit_hash)

# 检测我们所在的分支
branch = check_output(['git', 'symbolic-ref', '--short', 'HEAD']).strip()
print "prepare-commit-msg: On branch '%s'" % branch

# 用issue编号生成提交信息
if branch.startswith('issue-'):
    print "prepare-commit-msg: Oh hey, it's an issue branch."
    result = re.match('issue-(.*)', branch)
    issue_number = result.group(1)

    with open(commit_msg_filepath, 'r+') as f:
        content = f.read()
        f.seek(0, 0)
        f.write("ISSUE-%s %s" % (issue_number, content))
```

首先，上面的 prepare-commit-msg 钩子告诉你如何收集传入脚本的所有参数。接下来，它调用了git symbolic-ref --short HEAD 来获取对应HEAD的分支名。如果分支名以issue-开头，它会重写提交信息文件，在第一行加上issue编号。比如你的分支名issue-224，下面的提交信息将会生成:

```
ISSUE-224 

# Please enter the commit message for your changes. Lines starting 
# with '#' will be ignored, and an empty message aborts the commit. 
# On branch issue-224 
# Changes to be committed: 
# modified:   test.txt
```

有一点要记住的是即使用户用-m传入提交信息，prepare-commit-msg也会运行。也就是说，上面这个脚本会自动插入ISSUE-[#]字符串，而用户无法更改。你可以检查第二个参数是否是提交类型来处理这个情况。但是，如果没有-m选项，prepare-commit-msg钩子允许用户修改生成后的提交信息。所以这个脚本的目的是为了方便，而不是推行强制的提交信息规范。如果你要这么做，你需要下面所讲的 commit-msg 钩子。

##### commit-msg

commit-msg钩子和prepare-commit-msg钩子很像，但它会在用户输入提交信息之后被调用。这适合用来提醒开发者他们的提交信息不符合你团队的规范。传入这个钩子唯一的参数是包含提交信息的文件名。如果它不喜欢用户输入的提交信息，它可以在原地修改这个文件（和prepare-commit-msg一样），或者它会以非零值退出，放弃这个提交。比如说，下面这个脚本确认用户没有删除prepare-commit-msg脚本自动生成的ISSUE-[#]字符串。

```
#!/usr/bin/env python

import sys, os, re
from subprocess import check_output

# 收集参数
commit_msg_filepath = sys.argv[1]

# 检测所在的分支
branch = check_output(['git', 'symbolic-ref', '--short', 'HEAD']).strip()
print "commit-msg: On branch '%s'" % branch

# 检测提交信息，判断是否是一个issue提交
if branch.startswith('issue-'):
    print "commit-msg: Oh hey, it's an issue branch."
    result = re.match('issue-(.*)', branch)
    issue_number = result.group(1)
    required_message = "ISSUE-%s" % issue_number

    with open(commit_msg_filepath, 'r') as f:
        content = f.read()
        if not content.startswith(required_message):
            print "commit-msg: ERROR! The commit message must start with '%s'" % required_message
            sys.exit(1)
```

##### post-commit

post-commit 挂钩在整个提交过程完成后运行，他不会接收任何参数，但可以运行  git  log 来获得最后的提交信息。总之，该挂钩是作为通知之类使用的。虽然可以用post-commit来触发本地的持续集成系统，但大多数时候你想用的是post-receive这个钩子。它运行在服务端而不是用户的本地机器，它同样在任何开发者推送代码时运行。那里更适合进行持续集成。

提交工作流的客户端挂钩脚本可以在任何工作流中使用，他们经常被用来实施某些策略，但值得注意的是，这些脚本在clone期间不会被传送。可以在服务器端实施策略来拒绝不符合某些策略的推送，但这完全取决于开发者在客户端使用这些脚本的情况。所以，这些脚本对开发者是有用的，由他们自己设置和维护，而且在任何时候都可以覆盖或修改这些脚本，后面讲如何把这部分东西也集成到开发流中。

#### 2.E-mail工作流挂钩

有3个可用的客户端挂钩用于e-mail工作流。当运行 `git am` 命令时，会调用他们，因此，如果你没有在工作流中用到此命令，可以跳过本节。如果你通过e-mail接收由 git format-patch 产生的补丁，这些挂钩也许对你有用。

首先运行的是 `applypatch-msg` 挂钩，他接收一个参数：包含被建议提交信息的临时文件名。如果该脚本非零退出，Git 放弃此补丁。可以使用这个脚本确认提交信息是否被正确格式化，或让脚本编辑信息以达到标准化。

下一个在 git am 运行期间调用是 `pre-applypatch` 挂钩。该挂钩不接收参数，在补丁被运用之后运行，因此，可以被用来在提交前检查快照。你能用此脚本运行测试，检查工作树。如果有些什么遗漏，或测试没通过，脚本会以非零退出，放弃此次 git am 的运行，补丁不会被提交。

最后在 git am 运行期间调用的是 `post-applypatch` 挂钩。你可以用他来通知一个小组或获取的补丁的作者，但无法阻止打补丁的过程。

#### 3.其他客户端挂钩

##### pre-rebase

pre-rebase 挂钩在衍合前运行，脚本以非零退出可以中止衍合的过程。你可以使用这个挂钩来禁止衍合已经推送的提交对象，pre-rebase 挂钩样本就是这么做的。该样本假定next是你定义的分支名，因此，你可能要修改样本，把next改成你定义过且稳定的分支名。

比如说，如果你想彻底禁用rebase操作，你可以使用下面的pre-rebase脚本：

```
#!/bin/sh

# 禁用所有rebase
echo "pre-rebase: Rebasing is dangerous. Don't do it."
exit 1
```

每次运行git rebase，你都会看到下面的信息：

```
pre-rebase: Rebasing is dangerous. Don't do it.
The pre-rebase hook refused to rebase.
```

内置的pre-rebase.sample脚本是一个更复杂的例子。它在何时阻止rebase这方面更加智能。它会检查你当前的分支是否已经合并到了下一个分支中去（也就是主分支）。如果是的话，rebase可能会遇到问题，脚本会放弃这次rebase。

##### post-checkout

由git checkout命令调用，在完成工作区更新之后执行。该脚本由三个参数：之前HEAD指向的引用，新的HEAD指向的引用，一个用于标识此次检出是否是分支检出的值（0表示文件检出，1表示分支检出）。也可以被git clone触发调用，除非在克隆时使用参数--no-checkout。在由clone调用执行时，三个参数分别为null, 1, 1。这个脚本可以用于为自己的项目设置合适的工作区，比如自动生成文档、移动一些大型二进制文件等，也可以用于检查版本库的有效性。

最后，在 merge 命令成功执行后，`post-merge` 挂钩会被调用。他可以用来在 Git 无法跟踪的工作树中恢复数据，诸如权限数据。该挂钩同样能够验证在 Git 控制之外的文件是否存在，因此，当工作树改变时，你想这些文件可以被复制。



## 5.服务器端 Hooks

除了客户端挂钩，作为系统管理员，你还可以使用两个服务器端的挂钩对项目实施各种类型的策略。这些挂钩脚本可以在提交对象推送到服务器前被调用，也可以在推送到服务器后被调用。推送到服务器前调用的挂钩可以在任何时候以非零退出，拒绝推送，返回错误消息给客户端，还可以如你所愿设置足够复杂的推送策略。

#### pre-receive

处理来自客户端的推送（push）操作时最先执行的脚本就是 `pre-receive` 。它从标准输入（stdin）获取被推送引用的列表；如果它退出时的返回值不是0，所有推送内容都不会被接受。利用此挂钩脚本可以实现类似保证最新的索引中不包含非 fast-forward 类型的这类效果；抑或检查执行推送操作的用户拥有创建，删除或者推送的权限或者他是否对将要修改的每一个文件都有访问权限。

```
#!/usr/bin/env python

import sys
import fileinput

# 读取用户试图更新的所有引用
for line in fileinput.input():
    print "pre-receive: Trying to push ref: %s" % line

# 放弃推送
# sys.exit(1)
```

#### post-receive

post-receive 挂钩在整个过程完结以后运行，可以用来更新其他系统服务或者通知用户。它接受与 pre-receive 相同的标准输入数据。应用实例包括给某邮件列表发信，通知实时整合数据的服务器，或者更新软件项目的问题追踪系统 —— 甚至可以通过分析提交信息来决定某个问题是否应该被开启，修改或者关闭。该脚本无法组织推送进程，不过客户端在它完成运行之前将保持连接状态；所以在用它作一些消耗时间的操作之前请三思。

#### update

update 脚本和 pre-receive 脚本十分类似。不同之处在于它会为推送者更新的每一个分支运行一次。假如推送者同时向多个分支推送内容，pre-receive 只运行一次，相比之下 update 则会为每一个更新的分支运行一次。它不会从标准输入读取内容，而是接受三个参数：索引的名字（分支），推送前索引指向的内容的 SHA-1 值，以及用户试图推送内容的 SHA-1 值。如果 update 脚本以退出时返回非零值，只有相应的那一个索引会被拒绝；其余的依然会得到更新。

## 6.使用Hooks-客户端代码规范（OC）

统一的代码规范让代码更加清晰易懂。在控制代码规范方面可以执行的就是 ：

> 1.程序员自己控制（定期code review）
>
> 2.自动化检测 (多人协作代码提交的时候强制检测代码规范，不符合不让提交)

这里就依赖着 spacecommander 和 hooks 的结合 实现代码提交之前的代码格式规范检测。

#### 1.下载 spacecommander

```
git clone https://github.com/square/spacecommander.git
```

下图就是我们clone下来的 spacecommander 的文件夹内容,其中包括一些 shell 脚本文件,还有 python 脚本文件,(其中 shell 主要是来调用 python 脚本的),其中还有一个最重要的隐藏文件 `.clang-format` (这个文件是用配置代码规范的,采用 YMAL 标记语言书写).

![](https://xilankong.github.io/resource/space.png)



#### 2.在项目仓库中安装spacecommander

我们进入项目目录 运行 spacecommander 仓库中的 `setup-repo.sh` 脚本

执行过程如下图：

![](https://xilankong.github.io/resource/setup_space.png)



第一个红圈处地址为我项目工程所在目录 执行的 setup-repo.sh  需要取 spacecommander 目录地址。

第二个红圈处可以看到  setup-repo.sh  命令的执行 

在 项目目录下的 .git/hooks 目录中生成一个 `pre-commit` 文件（可执行钩子文件）

同时在项目目录下生成了一个 `.clang-format` 文件

其中 `.clang-format` 只是一个文件链接,指向了我们的 spacecommander 仓库中的这个文件,这个文件主要用来配置规范的选项。最重要的一个文件是 .git 隐藏文件夹下的 hook文件夹中的 `pre-commit` 脚本,这个脚本会在 git commit 之前执行用来检测代码是否符合规范。

```
#!/usr/bin/env bash
current_repo_path=$(git rev-parse --show-toplevel)
repo_to_format="/Users/young/Desktop/demo/demoWebView"
if [ "$current_repo_path" == "$repo_to_format" ] && 
[ -e "/Users/young/desktop/demo/spacecommander"/format-objc-hook ]; 
then "/Users/young/desktop/demo/spacecommander"/format-objc-hook; fi
```

上面的 shell 代码 大致的意思就是 对我们指定的目录 执行 format-objc-hook 脚本文件去校验，而这个format-objc-hook 脚本文件主要是用来检测这个这次提交的变化中是否有不符合代码规范的代码,如果有就 commit 失败,如果没有就 commit 成功。

#### 3.提交代码+代码检测+代码自动fix

```
🚸 Format and stage individual files:
"/Users/young/desktop/demo/spacecommander"/format-objc-file.sh 'demoWebView/ViewController.m' && git add 'demoWebView/ViewController.m';

🚀  Format and stage all affected files:
	 "/Users/young/desktop/demo/spacecommander"/format-objc-files.sh -s

🔴  There were formatting issues with this commit, run the👆 above👆 command to fix.
💔  Commit anyway and skip this check by running git commit --no-verify
yanghuangdeMac-mini:demoWebView young$ 
```

如上图结果 提交命令 `git commit -m "mod"` 之后 提交并未成功并返回了错误，错误清楚的告诉我们格式不对的提交文件，我们可以按错误提示中得操作命令去 单独格式化一个文件 或者整个项目。

#### 4.自定义代码规范文件

[clang-format](http://clang.llvm.org/doxygen/structclang_1_1format_1_1FormatStyle.html) 规范

```
IndentNestedBlocks: false
AllowNewlineBeforeBlockParameter: false

Language:        Cpp
# BasedOnStyle:  Google # 基础样式
AccessModifierOffset: -1 #类的访问修饰关键字(private,public,protected···)缩进
# private:
# int a;
# 1表示不缩进
#大于1的值表示访问修饰关键字的左侧从int a的左侧列开始往右侧移动的距离

ConstructorInitializerIndentWidth: 4
SortIncludes: false

AlignAfterOpenBracket: true #在未封闭(括号的开始和结束不在同一行)的括号中的代码是否对齐
# if(a &&
#    b)
# 

AlignEscapedNewlinesLeft: true #如果是true就是左对齐,如果是false就是右对齐 如下：
# void foo() {
#        someFunction();
#  someOtherFunction();
# }//false
# void foo() {
#    someFunction();
#    someOtherFunction();
# }//true

AlignOperands: false #水平对齐二进制和三元表达式

AlignTrailingComments: true  
#是否把注释右对齐,下面为右对齐的效果
#void someFunction() {
#    doWork();     // Does something
#    doMoreWork(); // Does something else
#}

AlignConsecutiveAssignments: false  #多行赋值语句按=号对齐
AlignConsecutiveDeclarations: false #多行声明语句按=号对齐

AllowAllParametersOfDeclarationOnNextLine: false #参数的对齐方式 如果TRUE就让参数上下对齐 否则将是默认
# someFunction(foo,
#              bar,
#              baz);//true
#
# someFunction(foo, bar, baz);//false
#

AllowShortBlocksOnASingleLine: false #是否允许短代码块在一行写完#如 if (a) { return; }
AllowShortCaseLabelsOnASingleLine: false #是否允许短switch的case 语句在一行写完
AllowShortFunctionsOnASingleLine: true #是否允许短的函数在一行写完
AllowShortIfStatementsOnASingleLine: true #是否允许短的语句在一行写完
AllowShortFunctionsOnASingleLine: All
AllowShortLoopsOnASingleLine: true #是否允许短的循环在一行写完

AlwaysBreakAfterDefinitionReturnType: false
AlwaysBreakTemplateDeclarations: false

AlwaysBreakBeforeMultilineStrings: false #在多行字符串之前总是打破 如下 true
# NSString *string = 
# @"deqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwde"                        # @"qwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeqwdeq"
# @"wdeqwdeqw";

BreakBeforeBinaryOperators: None #在二元运算符前断行
BreakBeforeTernaryOperators: false #在三元运算符前断行
BreakConstructorInitializersBeforeComma: false #在构造函数初始化时按逗号断行，并以冒号对齐

BinPackArguments: true
BinPackParameters: true
ColumnLimit: 0 #最大宽度,如果代码超过这个宽度会按语义折行 0意味着没有限制
ConstructorInitializerAllOnOneLineOrOnePerLine: true
DerivePointerAlignment: false
ExperimentalAutoDetectBinPacking: false
IndentCaseLabels: true  #case语句的位置总是在switch语句后缩进一级
IndentWrappedFunctionNames: false
IndentFunctionDeclarationAfterType: false
MaxEmptyLinesToKeep: 2 #允许最大连续空行数
KeepEmptyLinesAtTheStartOfBlocks: false #block从空行开始
NamespaceIndentation: Inner #命名空间缩进
ObjCBlockIndentWidth: 4 #block内的缩进大小
ObjCSpaceAfterProperty: true #是否需要在"@property"后加上空格
ObjCSpaceBeforeProtocolList: true #是否需要在协议名后加上空格
PenaltyBreakBeforeFirstCallParameter: 10000
PenaltyBreakComment: 300
PenaltyBreakString: 1000
PenaltyBreakFirstLessLess: 120
PenaltyExcessCharacter: 1000000 #最多能超出ColumnLimit多少个字符
PenaltyReturnTypeOnItsOwnLine: 200
PointerAlignment: Right #指针在类型那边还是在变量名那边还是在中间
SpacesBeforeTrailingComments: 1 #单行注释前的空格数
Cpp11BracedListStyle: true
Standard:        Auto
IndentWidth:     4
TabWidth:        8
UseTab:          Never #是否使用tab进行缩进
BreakBeforeBraces: Custom # 圆括号的换行方式
BraceWrapping: 
    AfterClass: true
    AfterControlStatement: false
    AfterEnum: false
    AfterFunction: true
    AfterNamespace: true
    AfterObjCDeclaration: true
    AfterStruct: false
    AfterUnion: false
    BeforeCatch: false
    BeforeElse: false
    IndentBraces: false

SpacesInParentheses: false #是否在非空的括号中插入空格
SpacesInSquareBrackets: false
SpacesInAngles:  false #是否在<>中间插入空格
SpaceInEmptyParentheses: false  #是否在空括号中加空格
SpacesInCStyleCastParentheses: false
SpaceAfterCStyleCast: false
SpacesInContainerLiterals: true #是否在容器字面量(@[@"1",@"2"])中插入空格
SpaceBeforeAssignmentOperators: true #在=号前加空格

ContinuationIndentWidth: 4 
#在续行(\  
#     下一行)时的缩进长度
CommentPragmas:  '^ IWYU pragma:'
ForEachMacros:   [ foreach, Q_FOREACH, BOOST_FOREACH ]
SpaceBeforeParens: ControlStatements   #是否在括号前加上空格
DisableFormat:   false #禁用当前format文件
```



## 7.可能出现的问题

1.`.simple` 文件后缀的移除

2.如果自己新建的钩子文件不生效，执行一遍 chmod +x 文件名

3.使用 spacecommander 去自动编译代码格式的时候 一定要用他提示的绝对地址的文件路径 



## 8.基于Clang的iOS代码校验工具

前面遗留下来的那个问题，怎么更好的去使用 spacecommander 去做事情，去优化我们的代码风格。

任务:

1.更完善的代码校验

2.更方便的集成，更简易的部署到项目中

3.更合理的代码提示和 代码不规范处提示。

4.代码静态扫描，服务器端运行脚本进行全局扫描校验



IOS 代码校验，一键部署，只需要执行一次命令文件就可以给IOS项目部署代码校验工具

依赖于Git hooks 每次代码 commit 的时候进行代码强制校验。

要求：Git工程、OC代码

实现:

### 1.减少用户使用时的步骤

工具部署只需要一个启动脚本，自动下载校验工具、部署脚本和钩子以及创建新的操作命令

```
1.提取项目中得setup.command文件放置到工程的根目录，双击执行 并根据提示操作command文件

2.如果执行提示无权限 > 终端 cd 到当前目录 执行 chmod +x setup.command

3.Would you like to use the codeChecker ? [ yes / no ]

4.选中 no 为卸载操作，当不需要代码校验的时候执行此操作 / 选择yes为安装操作。

5.Which style do you need ?  [ list / window ]

6.提供两种模式
```

### 2.提供两种代码提示

为方便不同的使用，现提供两种代码规范提示模式：list 模式 / window 模式

1.list模式

list模式每次commit会自动显示错误文档，显示代码纠正点，可以根据代码问题点自行进行代码修整 或者使用快捷命令自动修改代码格式。

![](https://xilankong.github.io/resource/list.png)

如上图部分，※号下面为原本的错误样式  — 号下面部分为校验后代码样式 数字分别表示从多少行开始到多少行。!号表示有变更的行，+号表示新增，-号表示删除   :q 退出查看，每一份代码文件都会单独展示样式修改信息。

![](https://xilankong.github.io/resource/list-tips.png)

同时终端也会提示你现在在校验的文件，自动化单个校验、多个校验的命令等 。

2.window模式

window模式开启代码对比功能，左侧为自己的代码、右侧为规范代码，提供快捷方式进行代码修正覆盖。

![](https://xilankong.github.io/resource/window.png)

如上图部分，左侧为我们的代码，右侧为format后的代码，其中有变更的地方都有颜色标明。我们可以使用快捷键来快速的在需要变更的节点跳转和节点覆盖。以及代码的还原和撤销，当处理完成后颜色光标会消失，wqa 保存退出即可。下面是常用快捷方式

```
window 模式下的操作快捷方式

Ctrl - w 切换光标位置

Ctrl-w K（把当前窗口移到最上边）

Ctrl-w H（把当前窗口移到最左边）

Ctrl-w J（把当前窗口移到最下边）

Ctrl-w L（把当前窗口移到最右边）

]c 跳向下一个编辑点

[c 跳向上一个编辑点

do 将另一个文件的编辑点覆盖到当前文件（注意光标位置）

dp 将当前文件的编辑点覆盖到另一份文件

Ctrl - u 撤销修改(保证光标在需要撤销的文件下 处于INSERT模式) 如果非INSERT模式直接 u 就是撤销

:qa 不修改退出 （编辑过后不可用 需要使用 :qa! 表示撤销修改后退出）

:wqa 保存修改退出
```

### 3.代码安全备份，代码误操作还原

由于在刚开始使用终端操作的时候经常会有误操作的可能，所以为了防止影响到自己的工作代码，执行commit的时候，会默认备份到指定目录。

当想恢复刚刚执行的format操作可以使用codelog命令查看format记录，codereset命令(参数是需要还原的文件在项目中的相对地址)还原刚刚操作过的文件。(暂时只支持单文件还原，每个文件的备份数据在本地进行迭代。如果需要某个文件的多个版本前的备份记录，需要先还原备份目录到指定节点)。

codelog

![](https://xilankong.github.io/resource/codelog.png)

codereset

![](https://xilankong.github.io/resource/codereset.png)

每次的format过程都会备份文件，并且这些文件以迭代的方式保存。目录 Document/codeCheckerCache

### 4.问题

1.更完美的备份恢复机制

2.vimdiff是否能更多自定义

3.服务器端的静态扫描

4.丰富校验规则



### 5.链接

 [setup.command](https://github.com/xilankong/IosCodeChecker)



## 9.参考、栗子

[Git Hooks 文档](https://git-scm.com/book/zh/v1/自定义-Git-Git挂钩)

[spacecommander](https://github.com/square/spacecommander/)

[clang-format](http://clang.llvm.org/doxygen/structclang_1_1format_1_1FormatStyle.html)

[clang-format-demo](http://clangformat.com)

[IOS 代码校验封装（仅限OC）](https://github.com/xilankong/IosCodeChecker)



