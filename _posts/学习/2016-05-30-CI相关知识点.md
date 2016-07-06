### 持续集成（Continuous integration）For iOS in JFZ

#### 关于持续集成
+ 概念： [百度百科](http://baike.baidu.com/link?url=p8fTx8-ccfi1L532zRI3roZzH1l_b2o9bF0EeXPZ7Dc64xee4H4ox-7WsmDd9jg4X0QMfEVzG5aPGcpgne2FBq) 上已经给出比较详细的概念说明，总结就是：需要人力去做的东西（编译，打包，发布，测试等），都可以交给持续集成来做。

#### iOS自动构建
目前金斧子理财、金斧子财富的打包方式使用的是 xctool + xcodeBuild来实现

#### 1.XCTool

xctool是facebook开源的一个命令行工具，用于取代Apple的xcodebuild，用于简化iOS和Mac平台项目的构建和测试的开源工具，xctool在持续集成方面占有优势，最大的好处是可以通过命令行构建项目和运行单元测试。

##### 安装
	命令行： sudo brew install xctool


##### 使用
+ 参数
	+ -workspace 需要打包的workspace文件
	+ -scheme 需要打包的Scheme 
	+ -configuration 打包的配置，一般来说就是环境(Debug,Release)的配置

+ 命令
	+ clean 清空编译环境
	+ archive 打包，生成一个.xcarchive的文件 archive需要接收多一个参数 -archivePath 即.xcarchive存放的目录

#### 2.xcodeBuild 
xcodebuild是安装xocde command line tools 就有的一个命令
##### 使用
+ 参数
	+ -exportArchive 让xcodebuild export archive文件

	+ -exportFormat 告诉xcodebuild需要导出的archive文件最后格式 一般接ipa，就会导出xxxx.ipa的文件

	+ -archivePath archive文件目录

	+ -exportPath 导出的ipa存放目录

	+ -exportProvisioningProfile 打包需要签名的provisioningProfile名

#### 3.一个打包的命令流程 
1. 产生一个xcarchive文件

	```sh
	xctool -workspace JFZFortune.xcworkspace -scheme JFZFortune -configuration Debug clean build archive -archivePath ./packages/JFZFortune.xcarchive
	```
	
2. 导出ipa文件

	```sh
	xcodebuild -exportArchive -archivePath ./packages/JFZFortune.xcarchive -exportPath ./packages/JFZFortune.ipa -exportFormat ipa -exportProvisioningProfile iOS Team Provisioning Profile: com.jfz.JFZFortune
	```

一个ci脚本

```sh
# ============ci.sh===========

# ================ Set ENV start ================================
# build tools chain env
XCTOOL=/usr/local/bin/xctool
XCODEBUILD=/usr/bin/xcodebuild

# Package name
IPA_NAME_PREFIX=JFZFortune_
IPA_NAME_DATESTAMP=`date +%Y%m%d_%H%M`
IPA_NAME_VERSION=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ./JFZFortune/Info.plist`
BUILD_NUMBER=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ./JFZFortune/Info.plist`
# BUILD_BUMBER 空判断

if [ "$BUILD_NUMBER"x == ""x ]; then
BUILD_NUMBER="0"
echo "BUILD_NUM is nil set build BUILD_NUM to ${BUILD_NUMBER}"
else
BUILD_NUMBER=$(($BUILD_NUMBER+1))
echo "ADD BUILD_NUM TO ${BUILD_NUMBER}"
fi
IPA_NAME="${IPA_NAME_PREFIX}${IPA_NAME_VERSION}(${BUILD_NUMBER})_${IPA_NAME_DATESTAMP}.ipa"


# xcodebuild parameters
WORKSPACE_NAME="JFZFortune.xcworkspace"
ARCHIVE_NAME="JFZFortune.xcarchive"
SCHEME="JFZFortune"
EXPORT_PROVISIONING_PROFILE="iOS Team Provisioning Profile: com.jfz.JFZFortune"

#Debug/Release, default = Debug
CONFIGURATION=Debug
# ================ Set ENV end ==================================

show_version()
{
echo "version: 0.2"
echo "updated date: 2015-08-07"
echo "change log: support script argument"
}

show_usage()
{
echo "`printf %-16s "Usage: $0"` [-h| print help]"
echo "`printf %-16s ` [-v| show script version]"
echo "`printf %-16s ` [-c| set package parameter, Debug/Release]"
}




# ================ Script Start  =========================
# Step 0: check script argument
[ $# -eq 0 ] && echo "argument required!" && show_usage && exit 1

while getopts "c:hv" arg #选项后面的冒号表示该选项需要参数
do
case $arg in
h)
#echo "a's arg:$OPTARG" #参数存在$OPTARG中
show_usage
exit 1
;;
v)
show_version
exit 1
;;
c)

if [ $OPTARG == "Debug" ];then
CONFIGURATION=$OPTARG
elif [ $OPTARG == "Release" ];then
CONFIGURATION=$OPTARG
EXPORT_PROVISIONING_PROFILE="XC Ad Hoc: com.jfz.JFZFortune"
else
echo "Unknown parameter $OPTARG for -c, use default value Debug"
CONFIGURATION="Debug"
fi
;;
?)  #当有不认识的选项的时候arg为?
echo "unkonw argument"
exit 1
;;
esac
done

echo "current provisioning profiles: ${EXPORT_PROVISIONING_PROFILE}"

# Step 1: Create Destination folder
rm -rf packages
mkdir ./packages
EXPORT_PATH="`pwd`/packages"


# ================ Start build package! =========================
# Step 2: archive app
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" ./JFZFortune/Info.plist

echo "[JinFuZi CI script:] Archive workspace..."
${XCTOOL} -workspace ${WORKSPACE_NAME} -scheme ${SCHEME} -configuration ${CONFIGURATION} clean build archive -archivePath "${EXPORT_PATH}/${ARCHIVE_NAME}"
echo "[JinFuZi CI script:] Archive app success."
# Step 3: export ipa
echo "[JinFuZi CI script:] Export archive as ipa package..."
${XCODEBUILD} -exportArchive -archivePath "${EXPORT_PATH}/${ARCHIVE_NAME}" -exportPath "${EXPORT_PATH}/${IPA_NAME}" -exportFormat ipa -exportProvisioningProfile "${EXPORT_PROVISIONING_PROFILE}" -verbose
echo "[JinFuZi CI script:] Export ipa success."
echo "[JinFuZi CI script:] Build package success."
echo "[JinFuZi CI script:] Package saved: `pwd`/packages/${IPA_NAME}"
# ================ End build package! ===========================



```

至此，使用命令行打包的方式就介绍到这里

#### 4.配合Jenkins完成持续集成
+ 创建一个slave
	注意：确保slave的java环境是1.8的环境
	![create_slave](http://o7kgwcg81.bkt.clouddn.com/jenkins_slave_create.jpg)
	
+  在slave下创建一个项目
	1. start
	
		![start_jenkins_project](http://o7kgwcg81.bkt.clouddn.com/blog/ci/start_project.jpg)
	
	2. 基本配置
	
		![start_jenkins_project](http://o7kgwcg81.bkt.clouddn.com/blog/ci/create_project_1.jpg)
	
	3. git仓库配置：每一次构建都会去分支中拉取最新的代码构建
	
		![start_jenkins_project](http://o7kgwcg81.bkt.clouddn.com/blog/ci/create_project_2.jpg)
	
	4. 跑脚本
	
	 	![start_jenkins_project](http://o7kgwcg81.bkt.clouddn.com/blog/ci/create_project_3.jpg)

+ 可能遇到的问题
	1. 在本机可以export成功，但是到了jenkins上却出现code signing error
	
		遇到这个问题一般都是证书没找到的原因，把签名需要用到的证书放到system环境下，基本上能解决问题。