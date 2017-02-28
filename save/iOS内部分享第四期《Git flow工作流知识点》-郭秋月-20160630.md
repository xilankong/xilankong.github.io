#Git版本控制系统工作流介绍  
********

##索引
1. [背景](#1)
2. [Git flow](#2) 
3. [Github flow](#3)  
4. [Gitlab flow](#4) 
5. [补充说明](#5)
6. [参考资料](#6)

<h2 id='1'>1.背景</h2>
Git 作为一个源码管理系统，不可避免涉及到多人协作。
协作必须有一个规范的工作流程，让大家有效地合作，使得项目井井有条地发展下去。"工作流程"在英语里，叫做"workflow"或者"flow"，原意是水流，比喻项目像水流那样，顺畅、自然地向前流动，不会发生冲击、对撞、甚至漩涡。下面对常用工作流进行对比说明：Git flow、Github flow和Gitlab flow。

<h2 id='2'>2.Git flow</h2>
![](http://static.codeceo.com/images/2015/12/4d5880f92476701b7c63992a7457b90d.png)  
###主要特点  
1.存在两个长期分支  

```
主分支master
开发分支develop
```  
master用于存放对外发布的版本，任何时候在这个分支拿到的，都是稳定的分布版；Git创建时，默认为master。<br />

develop用于日常开发，存放最新的开发版，功能都在这个分支完成，操作如下：

```  
#创建develop分支
git checkout -b develop master
#开发完成后，把develop分支合并到master
git checkout master
git merge develop --no-ff 
``` 

<font color=red>注意：合并（merge）分支时必须加上--no-ff参数，将快速合并（fast forward）变为普通合并，合并后的历史有分支，能看出来曾经做过合并。</font>

2.存在三种短期分支  

```  
功能分支(feature branch)   
补丁分支(hotfix branch)  
预发分支(release branch)  
```  
1) 功能分支(feature branch)

为了开发某个特定的功能，从develop分支分出来，开发完成后，合并到develop。
操作如下：

```  
#创建feature-A分支
git checkout -b feature-A develop
#开发完成后，把feature-A分支合并到develop
git checkout develop
git merge feature-A --no-diff 
``` 

2) 发版分支(release branch)

从develop分支上面分出来的，预发布结束以后，必须合并进Develop和Master分支。它的命名采用release-3.4的形式，其中3.4为当前版本。
操作如下：

```  
#创建release-3.4分支
git checkout -b release-3.4 develop
#发版完成后，把release-3.4分支合并到master
git checkout master
git merge release-3.4 --no-diff 
#同时3.4版本打tag
git tag -a 'release_3.4' -m "release_3.4"
git push --tags
#发版完成后，把release-3.4分支合并到develop
git checkout develop
git merge release-3.4 --no-diff
```

3) 修复bug分支(hotfix branch)

从master分支上面分出来的。修补结束以后，再合并进master和develop分支。它的命名，可以采用hotfix-3.4.1的形式，其中3.4.1为版本号。
操作如下：

```  
#创建hotfix-3.4.1分支
git checkout -b hotfix-3.4.1 master
#发版完成后，把hotfix-3.4.1分支合并到master
git checkout master
git merge hotfix-3.4.1 --no-diff 
#同时3.4.1版本打tag
git tag -a 'release_3.4.1' -m "release_3.4.1"
git push --tags
#发版完成后，把hotfix-3.4.1分支合并到develop
git checkout develop
git merge hotfix-3.4.1 --no-diff
```

###评价  
Git flow的特点是清晰可控，缺点是相对复杂，需要同时维护两个长期分支。大多数工具都将master当做默认分支，可以开发是在develop分支进行的，这导致经常要切换分支。  
这个模式是基于“版本发布”的，目标是一段时间以后产出一个新版本。但是很多网站项目是“持续发布”，代码一有变动，就部署一次，这时，master和develop分支的差别不大，没必要维护两个长期分支。  

<h2 id='2'>2.Github flow</h2>
Github flow是Git flow的简化版，专门配合“持续发布”。  
 
###主要特点   
Github flow只要一个长期分支，就是master，因此用起来比较简单。 
![](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015122305.png)  
1）根据需求，从master拉出新分支，不区分功能分支或补丁分支。  
2）新分支开发完成后，或者需要讨论的时候，就向master发起一个pull request   
3）pull request的过程中，你可以不断提交代码。  
4）你的pull request被接受，合并进master，重新部署后，原来拉出来的分支就被删除。 
 
###评价  
Github flow的最大优点就是简单，对于“持续发布”的产品，可以说是最合适的流程。  
问题在于它认为master分支的更新与产品的发布是一致的。master分支的最新代码，默认就是当前线上的代码。  
可是，有时候并非如此，代码合并进入master分支，并不代表它就能立刻发布。比如，提交Apple的APP，审核需要一段时间才能上架，这时，如果还有新的代码提交，master分支就会与刚发布的版本不一致。   


<h2 id='3'>3.Gitlab flow</h2> 
Gitlab flow是Git flow与Github flow的综合。它吸取了两者的优点，既有适应不同开发环境的弹性，又有单一主分支的简单和便利。它是 Gitlab.com 推荐的做法。
分为如下分支：

```
主分支（master branch）
发布分支（production branch）
功能分支（feature branch）
修复bug分支（hotfix branch）
```

移除Git flow的develop分支。

###主要特点  
Gitlab flow的最大原则叫做“上游优先”，即只存在一个主分支master，它是所有其他分支的上游，只有上游分支采纳的代码变化，才能应用到其他的分支。 

1) 主分支(master branch)

项目创建，Git初始化产生主分支，所有功能开发都在这个分支，操作如下：

```  
#创建master分支
git checkout master
#开发完成后，把feature-A分支合并到develop
git checkout develop
git merge feature-A --no-diff 
```

2) 功能分支(feature branch)

项目组员中各自成员维护分支，从master分支分出来，开发完成后，合并到master。
操作如下：

```  
#创建feature-A分支
git checkout -b feature-A master
#开发完成后，把feature-A分支合并到master
git checkout master
git merge feature-A --no-diff 
``` 

3) 发版分支(release branch)

从master分支上面分出来的，用于版本发布和tag存放。tag命名采用release-3.4的形式，其中3.4为当前版本。
操作如下：

```  
#切换到release分支
git checkout release
git merge master --no-diff 
#同时3.4版本打tag
git tag -a 'release_3.4' -m "release_3.4"
git push --tags
```

4) 修复bug分支(hotfix branch)

从release分支上面分出来的。修补结束以后，再合并进master和release分支。它的命名，可以采用hotfix-3.4.1的形式，其中3.4.1为版本号。
操作如下：

```  
#创建hotfix-3.4.1分支
git checkout -b hotfix-3.4.1 release
#发版完成后，把hotfix-3.4.1分支合并到master
git checkout master
git merge hotfix-3.4.1 --no-diff 
#同时3.4.1版本打tag
git tag -a 'release_3.4.1' -m "release_3.4.1"
git push --tags
#发版完成后，把hotfix-3.4.1分支合并到develop
git checkout release
git merge hotfix-3.4.1 --no-diff
```

<h2 id='5'>5.补充说明</h2>   

### 金斧子移动端版本控制
金斧子版本控制统一使用Git控制，采用Gitlab工作流管理，参考[Gitlab flow](#4)章节，如下图：
![](http://gitlab.jfz.net/iOS/iOSStudy/raw/master/training/iOS内部分享第四期《Git%20flow工作流知识点》-郭秋月-20160630/img/Gitlab.png)

<font color=red> 
特别说明：<br/>
1）首先，release分支应该是稳定的，仅用来发布新版本，平时不能在上面开发；

2）开发都在dev分支上，也就是说，dev分支是不稳定的，到某个时候，比如3.4.0版本发布时，再把master分支合并到release上，在release分支发布3.4.0版本；

3）项目成员，都从master分支拉取自己独立分支开发（feature-A），每完成一个功能点，往master分支上合并。
</font>

本地开发时，Gitlab工作流可以用Sourcetree维护。

### Pull Request&Merge Request
当要发起一个Pull Request,需要请求(Request)另一个开发者，来pull你仓库中的一个分支到他的仓库中。这需要提供4个信息（源仓库、源分支、目的仓库、目的分支），以发起Pull Request。

<h2 id='6'>6.参考资料</h2>
1. [Git 分支管理策略](http://www.ruanyifeng.com/blog/2012/07/git.html)
2. [Git 工作流程](http://www.ruanyifeng.com/blog/2015/12/git-workflow.html)