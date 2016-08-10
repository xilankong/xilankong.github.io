#iOS移动端组件管理规范
----

##索引 
1. [创建单个组件](#1) 
2. [Spec配置说明](#2)
3. [组件源码注释](#3) 
4. [组件说明文档](#4)
5. [组件单元测试](#5)
6. [组件上传](#6) 
7. [组件维护](#7)

项目所有的组件，通过CocoaPods工具进行依赖管理，安装说明参考[CocoaPods官网](https://cocoapods.org)

<h4 id="1">1. 创建单个组件</h4>
在“终端（terminal）”，通过"pod lib"命令创建组件，如下所示：

```ruby
pod lib create JFZAnalytics
```

之后，根据提示操作，即可

```
//语言选择
What language do you want to use?? [ Swift / ObjC ]
 > objc

//演示程序
Would you like to include a demo application with your library? [ Yes / No ]
 > no

//测试框架
Which testing frameworks will you use? [ Specta / Kiwi / None ]
 > none

//演示程序是否测试
Would you like to do view based testing? [ Yes / No ]
 > no

//App前缀
What is your class prefix?
 > JFZ
```

进入JFZAnalytics文件夹，层次结构如下：

```
├── Example
│   ├── JFZAnalytics.xcodeproj
│   ├── JFZAnalytics.xcworkspace
│   ├── Podfile
│   ├── Podfile.lock
│   ├── Pods
│   └── Tests
├── JFZAnalytics
│   ├── Assets
│   └── Classes
├── JFZAnalytics.podspec
├── LICENSE
├── README.md
└── _Pods.xcodeproj -> Example/Pods/Pods.xcodeproj
```
<font color=red>
Example:演示测试文件夹<br />
JFZAnalytics：组件资源(Assets)和源文件(Classes)存放目录<br />
LICENSE：组件许可说明<br />
README.md：组件说明文档<br />
JFZAnalytics.podspec：组件配置文件<br />
</font>
****

<h4 id="2">2 Spec配置说明</h4>
通过步骤[1.1创建单个组件](#1.1)生成组件，查看.podspec配置文件，如下所示：

```
Pod::Spec.new do |s|
  s.name             = 'JFZAnalytics'
  s.version          = '0.1.0'
  s.summary          = 'A short description of JFZAnalytics.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/JFZAnalytics'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huangzhenzeng' => 'huangzhenzeng@126.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/JFZAnalytics.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'JFZAnalytics/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JFZAnalytics' => ['JFZAnalytics/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
```

<font color=red>
配置文件，必须填写条目：<br />
s.summary：组件功能摘要，Gitlab管理组件列表会显示这个描述<br />
s.description：组件功能描述<br />
s.source：组件下载地址<br />
s.ios.deployment_target：最低部署目标<br />
</font>
****

<h4 id="3">3 组件源码注释</h4>  

##### 3.1 暴漏外部公开头文件，函数需要注释，列出：函数的目的/功能、输入参数、输出参数、返回值、调用关系（函数、表）等。
```
/**
*  encryption string using DES argorithm
*
*  @param plainText encryption string
*  @param key       secret key
*  @param iv        index array
*
*  @return encrypted string
*/
+ (NSString *)jfz_encryptUseDES:(NSString *)plainText withKey:(NSString *)key withIV:(NSString *)iv;
```

##### 3.2 暴漏外部公开头文件，属性需要注释。
```
///navigation bar 背景图片
@property (copy, nonatomic) NSString* imgNaviBK;
```

##### 3.3 边写代码边注释，修改代码同时修改相应的注释，以保证注释与代码的一致性。不再有用的注释要删除。
```
+ (JFZAnalyticalProvider *)providerInstanceOfClass:(Class)ProviderClass
{
    // Check whether the ProviderClass is subclass of JFZAnalyticalProvider or not
    if (![ProviderClass isSubclassOfClass:JFZAnalyticalProvider.class]) {
        return nil;
    }
    
    ......
}
```

##### 3.4 注释的内容要清楚、明了，含义准确，防止注释二义性。

##### 3.5 避免在注释中使用缩写，特别是不常用缩写（在使用缩写时或之前，应对缩写进行必要的说明）。
```
///navigation bar 背景图片
@property (copy, nonatomic) NSString* imgNaviBK;
```

##### 3.6 注释应与其描述的代码相近，对代码的注释应放在其上方或右方（对单条语句的注释）相邻位置，不可放在下面，如放于上方则需与其上面的代码用空行隔开。
```
+ (JFZAnalyticalProvider *)providerInstanceOfClass:(Class)ProviderClass
{
    // Check whether the ProviderClass is subclass of JFZAnalyticalProvider or not
    if (![ProviderClass isSubclassOfClass:JFZAnalyticalProvider.class]) {
        return nil;
    }

    // Find the instance by enumerating the providers set
    JFZAnalyticalProvider *__block providerInstance = nil;
    [_sharedAnalytics.providers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        // Get the proivder and return it
        if ((*stop = [obj isKindOfClass:ProviderClass])) {
            providerInstance = obj;
        }
    }];
    
    return providerInstance;
}
```

##### 3.7 对于所有有物理含义的变量、常量，如果其命名不是充分自注释的，在声明时都必须加以注释，说明其物理含义。变量、常量、宏的注释应放在其上方相邻位置或右方。
```
/*
1.需要切换到外网域名
0:线上，隐藏环境 1:预发，显示环境 2:内网，显示环境
*/
#define GXQ_NETWORK_STATUS (0)
```

##### 3.8 数据结构声明(包括数组、结构、类、枚举等)，如果其命名不是充分自注释的，必须加以注释。对数据结构的注释应放在其上方相邻位置，不可放在下面；对结构中的每个域的注释放在此域的右方。
```
@interface JFZPushNotificationModel : NSObject

/* 推送显示的内容 */
@property (nonatomic, strong) NSString* content;

/* badge数 */
@property (nonatomic, assign) NSInteger badge;

/* 播放的声音 */
@property (nonatomic, strong) NSString* sound;

/* 消息Id */
@property (nonatomic, strong) NSString* msgId;

@end
```

##### 3.9 将注释与其上面的代码用空行隔开。
```
/* badge数 */
@property (nonatomic, assign) NSInteger badge;

/* 播放的声音 */
@property (nonatomic, strong) NSString* sound;
```

##### 3.10 对变量的定义和分支语句（条件分支、循环语句等）必须编写注释。
<font color=red>说明：这些语句往往是程序实现某一特定功能的关键，对于维护人员来说，良好的注释帮助更好的理解程序，有时甚至优于看设计文档。</font>

##### 3.11 避免在一行代码或表达式的中间插入注释。
<font color=red>除非必要，不应在代码或表达中间插入注释，否则容易使代码可理解性变差。</font>

##### 3.12 在代码的功能、意图层次上进行注释，提供有用、额外的信息。
```
/*
1.需要切换到外网域名
0:线上，隐藏环境 1:预发，显示环境 2:内网，显示环境
*/
#define GXQ_NETWORK_STATUS (0)
```

##### 3.13 注释应考虑程序易读及外观排版的因素，使用的语言若是中、英兼有的，建议多使用中文，除非能用非常流利准确的英文表达。
<font color=red>说明：注释语言不统一，影响程序易读性和外观排版，出于对维护人员的考虑，建议使用中文。</font>

##### 3.14 在程序块的结束行右方加注释标记，以表明某程序块的结束。
```
if (...)
{
    // program code

    while (index < MAX_INDEX)
    {
        // program code

    } /* end of while (index < MAX_INDEX) */ // 指明该条while语句结束

} /* end of  if (...)*/ // 指明是哪条if语句结束
```

**** 

<h4 id="4">4 组件说明文档</h4>
通过步骤[1.1创建单个组件](#1.1)生成组件，查看README.md文件，定义如下规范：

- 功能说明（description）<br/>
<font color=red>说明组件做了什么，包含哪些特点</font>
- 使用示例（How To Use）<br/>
<font color=red>项目使用组件步骤流程</font>
- 安装说明（How To Install）<br/>
<font color=red>怎么集成到项目和版本要求</font>
- 常见问题（Common Problems）<br/>
<font color=red>组件发布后，修复哪些问题、扩展新功能、第三方使用问题解答和对比等</font>
- 将来还需完善点（Future Enhancements）<br/>
<font color=red>说明组件存在缺陷，将来完善计划</font>
- 使用许可（Licenses）<br />
<font color=red>常用许可有：BSD、MIT、GPL、LGPL等，金斧子组件采用MIT</font>

<font color=red>
注意：以上【1-7】如果没有的，可以写无；具体规范，可以参考附件文件，文档采用MarkDown语言
</font>

参看文档如下：
[JFZAnalytics](#JFZAnalytics-README.md)

****

<h4 id="5">5 组件单元测试</h4> 
<font color=red>后续完善</font>

**** 

<h4 id="6">6 组件上传</h4>
##### 6.1 组件开发完成，本地进行编译和联调。
<font color=red>说明：每次修改组件代码，进行测试后才能提交到Gitlab</font>

##### 6.2 组件提交到Gitlab，需要进行pod spec lint libName验证。
<font color=red>说明：验证组件时，第一次不带--allow-warnings参数，查看警告重要程度，酌情解决；对于错误，必须解决才能提交。</font>

##### 6.3 组件开发完成，Demo验证基本功能。
<font color=red>说明：UI相关组件，看法完成后，需要在Demo中进行测试，验证是否缺少相关资源或流程问题。</font>

如

##### 6.4 组件开发完成，本地进行单元测试。
<font color=red>说明：理论上，每次修改组件都需要进行单元测试，看修改是否影响其他逻辑。</font>

<h4 id="7">7 组件维护</h4>
组件一般分为公共组件、独立业务组件和非独立业务组件等维护。

##### 7.1 公共组件维护
公共组件涉及多个App共用，组件命名为：JFZ+模块名，如下所示

```
JFZAnalytics /*统计库*/
JFZPush /*推送库*/
```
- 公共组件应该包含演示Demo、单元测试用例和使用文档。演示Demo提供组件简单使用，方便用户集成；单元测试提供组件覆盖测试，验证修改是否影响其他功能；使用文档提供安装和使用规范。
- 当修改Bug或新需求时，需要新增测试用例覆盖；所用测试用例覆盖通过后，方可提交。
- 组件修改后，提交到Gitlab时，提交信息格式为：

```
[Component] Action: (Issue #Id) + Message (Issue Status)
```
1）Component指任务所属模块，如iOS，Android，WPhone，Web等。<br/>
2）Action指操作是什么，如Add, Mod(ify), Ref(actoring), Fix, Rem(ove) and Rea(dability)，用来让代码提交信息的目的看起来比较清晰。<br />
3）Issue #Id指JIRA中bug id。<br />
4）Message指本次提交描述或影响范围。

如：

```
[iOS] Mod: #1586 Updated image downloader with a single session that manages all tasks
```

- 组件多个App使用，谁发现bug，谁修复；比如GXQ、JFZ等，GXQ项目组发现Bug，GXQ负责修复并内部测试，修复后提交各测试集成测试，验证通过后，在GXQ下个迭代发布；当GXQ使用稳定后，知会其他App更新（除非其它App也急于修复这个bug）。
- 公共组件修复Bug后，邮件知会其它项目组，说明修复问题和影响范围。

##### 7.2 独立业务组件维护
独立业务组件维护和公共组件相似，现在或将来会被其它App使用，故规则同“公共组件”。

##### 7.3 非独立业务组件维护
非独立业务组件不用考虑其他人或项目组重用的问题，所以对于修改操作会自由得多。但不要忘记，虽然非独立业务组件不会被他人重用，但仍然可能会被他人维护，所以必要的注释还是需要的。

****