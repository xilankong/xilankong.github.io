---
layout: post
category: 学习之路
title : "UIView、CALayer使用说明书"
---

## 前言

​	iOS开发中 UI是很重要也是最直观可见的一部分，而所有的控件都是继承自UIView的，UIView既可以实现显示的功能，又可以实现响应用户操作的功能。我们还知道每个UIView中都存在一个东西叫CALayer，实现了内容绘制等功能。本文总结整理UIView和CALayer的常用属性、方法、开发中容易遇到的问题等

## 1、UIView

UIView表示屏幕上的一块矩形区域，负责渲染区域的内容，并且响应该区域内发生事件。

### 几何类别(UIViewGeometry)

属性：

frame、bounds、center

```
frame 复合属性 由bounds表示大小、center表示位置 后续介绍UIView和CALayer的区别文章中会具体解释

bounds 视图在其自己的坐标系中的位置与尺寸，但是无法确定自己在父视图中的位置

center 定义了当前视图在父视图中的位置

注意：

bounds属性与center属性是完全独立的，前者规定尺寸，后者定义位置

bounds中位置的修改不会影响自身在父视图中的位置，但是会影响自己的subView的位置
```

transform

```
用于给UIView做一些形变(平移、缩放、旋转)

移动：
// 平移
//每次移动都是相对于上次位置
 _redView.transform = CGAffineTransformTranslate(_redView.transform, 100, 0);
//每次移动都是相对于最开始的位置
 _redView.transform = CGAffineTransformMakeTranslation(200, 0);
 
 缩放：
 // 平移
//每次移动都是相对于上次位置
 _redView.transform = CGAffineTransformTranslate(_redView.transform, 100, 0);
//每次移动都是相对于最开始的位置
 _redView.transform = CGAffineTransformMakeTranslation(200, 0);
 
 旋转：
 // 每次旋转都是相对于最初的角度
_redView.transform = CGAffineTransformMakeRotation(M_PI_4);
//每次旋转都是相对于现在的角度
_redView.transform = CGAffineTransformRotate(_redView.transform, M_PI_4);
```

contentScaleFactor

```
这个属性代表了从逻辑坐标系转化成当前的设备坐标系的转化比例，在[UIScreen mainScreen]中有个属性叫做scale 和这个是一样的
```

逻辑坐标系即我们数学上经常用的坐标体系,是对现实事物的一种抽象。

比如说我们要在app上显示一个正方形，我们会确定它的坐标(100,100) 和 宽高(100,100).在这里,坐标和宽高的数值都是对这个正方形的一种抽象。在实际显示的过程中，坐标的具体位置和宽高的实际长度则由具体硬件的物理属性和它规定的坐标体系进行表达。在逻辑坐标系中，以points作为测量单位,即通常在数学的坐标系中用点来表示最小的测量单位。

在我们进行编程时，frame、center中设置的表达坐标位置所使用的CGFloat参数就是以point为单位的。

设备坐标系是设备实际的坐标系.在实际屏幕中,是以像素(Pixel)作为基本的测量单位.

由于两个坐标系的单位不统一,这时需要进行坐标系的转换.

> iOS中当我们使用Quartz，UIKit，CoreAnimation等框架时,所有的坐标系统采用Point来衡量.系统在实际渲染到设置时会帮助我们处理Point到Pixel的转换.

scale属性反映了从逻辑坐标到设备屏幕坐标的转换。在非视网膜屏幕上，比例因子值为1.0，即逻辑坐标系中的一个点等于设备中一个像素(1×1)，在视网膜屏幕中,比例因子值为2.0,即逻辑坐标系中的一个点等于设备中四个像素(2×2)。同理，在6plus这种scale为3.0的设备上，1point等于9pixels。

因此，当我们在绘图中做出一条线宽为1的线时,在非视网膜屏幕和视网膜屏幕上的情况是不同的。

非视网膜屏幕和视网膜屏幕上一个线宽时的显示情况：



![](https://xilankong.github.io/resource/scale.png)



在非视网膜屏幕中，当我们把线宽为1的线画在(3,0)上时，线为一个`像素点`的宽度(虚线部分)，由于事实上不能让一个像素点显示半个像素，所以iOS的反锯齿技术让1个线宽的线显示出了2个像素宽度的一条线(浅色部分)，并且颜色变浅。只有对线进行0.5的偏移才能显示真正的线宽为1的线。

偏移了0.5(point)才能显示一个像素宽度的线：

![](https://xilankong.github.io/resource/scale2.png)

在视网膜屏幕中,如果想要画出宽度为一个像素的线，不仅需要先0.5point的线宽,还要进行0.25point的偏移，才能绘出一个像素点宽度的线。    



exclusiveTouch

autoresizesSubviews

autoresizingMask

方法：

sizeToFit

UIView继承自UIResponder, 事件响应部分见：[iOS事件响应链](https://xilankong.github.io/2017年/2016/06/23/iOS事件响应链.html)





### 层次类别(UIViewHierarchy)

插入指定层次、变更View层次等：

```
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2
```

UIView添加subView的生命周期

```
- (void)didAddSubview:(UIView *)subview;
- (void)willRemoveSubview:(UIView *)subview;
- (void)willMoveToSuperview:(nullable UIView *)newSuperview;
- (void)didMoveToSuperview;
- (void)willMoveToWindow:(nullable UIWindow *)newWindow;
- (void)didMoveToWindow;
```



```
- (void)setNeedsLayout;
- (void)layoutIfNeeded;
- (void)layoutSubviews; 
```



### 渲染类别(UIViewRendering)

属性：

clipsToBounds

opaque

clearsContextBeforeDrawing

contentMode

contentStretch

maskView



方法：

```
- (void)drawRect:(CGRect)rect;

- (void)setNeedsDisplay;
- (void)setNeedsDisplayInRect:(CGRect)rect;
```



### 动画类别(UIViewAnimation)

```
+ (void)beginAnimations:(nullable NSString *)animationID context:(nullable void *)context;  // additional context info passed to will start/did stop selectors. begin/commit can be nested
+ (void)commitAnimations;         
```



### 手势类别(UIViewAnimation)

```
- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);
- (void)removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);

// called when the recognizer attempts to transition out of UIGestureRecognizerStatePossible if a touch hit-tested to this view will be cancelled as a result of gesture recognition
// returns YES by default. return NO to cause the gesture recognizer to transition to UIGestureRecognizerStateFailed
// subclasses may override to prevent recognition of particular gestures. for example, UISlider prevents swipes parallel to the slider that start in the thumb
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer NS_AVAILABLE_IOS(6_0);

```







## 2、CALayer



presentationLayer

modelLayer



bounds

position

zPosition

anchorPoint

anchorPointZ

transform

frame

masksToBounds

mask



contents

contentsRect

contentsGravity

contentsScale

contentsCenter

shadowColor

shadowOpacity

shadowOffset

shadowRadius



\- (void)setNeedsDisplay;

\- (void)setNeedsDisplayInRect:(CGRect)r;



CAAction



#### 2、UIView 和 CALayer在基础属性的区别

**UIView**

```
transform ： CGAffineTransform
```

**CALayer**

**zPosition** 

决定层级，zPosition的数值相当于层在垂直屏幕的Z轴 上的位移值。在没有经过任何Transform的2D环境下，zPosition仅仅会决定谁覆盖谁，具体差值是没有意义的，但是经过3D Transform，他们之间的差值，也就是距离，会显现出来。

我们写个测试：

```
CGRect frame = CGRectInset(self.view.bounds, 50, 50);
CALayer *layer = [CALayer layer];
layer.frame = frame;
[self.view.layer addSublayer:layer];
//第一个椭圆
CAShapeLayer *shapeLayer = [CAShapeLayer layer];
shapeLayer.contentsScale = [UIScreen mainScreen].scale;
CGMutablePathRef path = CGPathCreateMutable();
CGPathAddEllipseInRect(path, NULL, layer.bounds);
shapeLayer.path = path;
shapeLayer.fillColor = [UIColor blueColor].CGColor;
shapeLayer.zPosition = 40;
[layer addSublayer:shapeLayer];

//第二个椭圆
CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
shapeLayer2.contentsScale = [UIScreen mainScreen].scale;
CGMutablePathRef path2 = CGPathCreateMutable();
CGPathAddEllipseInRect(path2, NULL, layer.bounds);
shapeLayer2.path = path2;
shapeLayer2.fillColor = [UIColor greenColor].CGColor;
shapeLayer2.zPosition = 0;
[layer addSublayer:shapeLayer2];

//背景矩形
CALayer *backLayer = [CALayer layer];
backLayer.contentsScale = [UIScreen mainScreen].scale;
backLayer.backgroundColor = [UIColor grayColor].CGColor;
backLayer.frame = layer.bounds;
backLayer.zPosition = -40;
[layer addSublayer:backLayer];
    
//Identity transform
CATransform3D transform = CATransform3DIdentity;
//Perspective 3D
transform.m34 = -1.0 / 700;
//旋转
transform = CATransform3DRotate(transform, M_PI / 3, 0, 1, 0);
//设置CALayer的sublayerTransform，注意3D Transform是设置在父CALayer的sublayerTransform属性上的，而不
//是transform属性。因为Transform需要设置给每个子Layer，而如果设置transform属性的话，会把整个Layer当做一
//个整体去变换
layer.sublayerTransform = transform;
```



上面代码分别做三次测试：

1、如上代码，结果如下图左

2、注释掉 `transform.m34` 这行代码，结果如下图中

3、取消 transform 的设置，结果如下图右

![](https://xilankong.github.io/resource/transform.png)

分析以上结果：

我们从第三次测试和第二次测试可以看到：

1、zPosition影响了原有的按先后添加顺序的层次（蓝色覆盖在了绿色、灰色上面）

2、zPosition的体现, 数值越大层级越高。



**transform ：CATransform3D**

三维变换矩阵



接着上面的测试我们继续分析：

1、CALayer的 transform和sublayerTransform 属性都是CATransform3D 类型，允许实现3D变换

2、从第一次测试和第二次测试可以看到，关于3D旋转变化，如果不设置上面的m34属性，整个变化结束后不会有那种透视效果（近大远小）

```
m34负责z轴方向的translation（移动），m34= -1/D,  默认值是0，也就是说D无穷大。D越小透视效果越明显。 所谓的D，是eye（观察者）到投射面的距离。
```





**anchorPoint** ： 

是一个CGPoint值，x，y取值范围（0~1），默认为（0.5，0.5） 对于图层本身而言，顾名思义，锚点就用来定位图层的点。锚点有两个职能：（1）与position一同确定图层相对于父图层的位置；（2）作为图层旋转、平移、缩放的中心。

锚点 默认为(0.5,0.5),即边界矩形的中心







UIView 自动布局的时候，frame的变化过程，