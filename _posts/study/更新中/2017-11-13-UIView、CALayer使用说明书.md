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

#### 属性：

**frame、bounds、center**

```
frame 复合属性 由bounds表示大小、center表示位置 后续介绍UIView和CALayer的区别文章中会具体解释

bounds 视图在其自己的坐标系中的位置与尺寸，但是无法确定自己在父视图中的位置

center 定义了当前视图在父视图中的位置

注意：

bounds属性与center属性是完全独立的，前者规定尺寸，后者定义位置

bounds中位置的修改不会影响自身在父视图中的位置，但是会影响自己的subView的位置
```

**transform**

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

**contentScaleFactor**

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



**exclusiveTouch**

```
ExclusiveTouch的作用是：可以达到同一界面上多个控件接受事件时的排他性,从而避免bug。
也就是说避免在一个界面上同时点击多个UIButton导致同时响应多个方法。
当这个UIView成为第一响应者时，在手指离开屏幕前其他view不会响应任何touch事件。
```

**autoresizesSubviews、autoresizingMask**

```
自动尺寸调整行为
当您改变视图的边框矩形时，其内嵌子视图的位置和尺寸往往也需要改变，以适应原始视图的新尺寸。如果视图的autoresizesSubviews属性声明被设置为YES，则其子视图会根据autoresizingMask属性的值自动进行尺寸调整。简单配置一下视图的自动尺寸调整掩码常常就能使应用程序得到合适的行为；否则，应用程序就必须通过重载layoutSubviews方法来提供自己的实现。
设置视图的自动尺寸调整行为的方法是通过位OR操作符将期望的自动尺寸调整常量连结起来，并将结果赋值给视图的autoresizingMask属性。表2-1列举了自动尺寸调整常量，并描述这些常量如何影响给定视图的尺寸和位置。举例来说，如果要使一个视图和其父视图左下角的相对位置保持不变，可以加入UIViewAutoresizingFlexibleRightMargin 和UIViewAutoresizingFlexibleTopMargin常量，并将结果赋值给autoresizingMask属性。当同一个轴向有 多个部分被设置为可变时，尺寸调整的裕量会被平均分配到各个部分上。
 	 
UIViewAutoresizingNone
这个常量如果被设置，视图将不进行自动尺寸调整。
UIViewAutoresizingFlexibleHeight
这个常量如果被设置，视图的高度将和父视图的高度一起成比例变化。否则，视图的高度将保持不变。
UIViewAutoresizingFlexibleWidth
这个常量如果被设置，视图的宽度将和父视图的宽度一起成比例变化。否则，视图的宽度将保持不变。
UIViewAutoresizingFlexibleLeftMargin
这个常量如果被设置，视图的左边界将随着父视图宽度的变化而按比例进行调整。否则，视图和其父视图的左边界的相对位置将保持不变。
UIViewAutoresizingFlexibleRightMargin
这个常量如果被设置，视图的右边界将随着父视图宽度的变化而按比例进行调整。否则，视图和其父视图的右边界的相对位置将保持不变。
UIViewAutoresizingFlexibleBottomMargin
这个常量如果被设置，视图的底边界将随着父视图高度的变化而按比例进行调整。否则，视图和其父视图的底边界的相对位置将保持不变。
UIViewAutoresizingFlexibleTopMargin
这个常量如果被设置，视图的上边界将随着父视图高度的变化而按比例进行调整。否则，视图和其父视图的上边界的相对位置将保持不变。


如 果您通过Interface Builder配置视图，则可以用Size查看器的Autosizing控制来设置每个视图的自动尺寸调整行为。上图中的灵活宽度及高度常量和 Interface Builder中位于同样位置的弹簧具有同样的行为，但是空白常量的行为则是正好相反。换句话说，如果要将灵活右空白的自动尺寸调整行为应用到 Interface Builder的某个视图，必须使相应方向空间的Autosizing控制为空，而不是放置一个支柱。幸运的是，Interface Builder通过动画显示了您的修改对视图自动尺寸调整行为的影响。
如果视图的autoresizesSubviews属性被设置为 NO，则该视图的直接子视图的所有自动尺寸调整行为将被忽略。类似地，如果一个子视图的自动尺寸调整掩码被设置为 UIViewAutoresizingNone，则该子视图的尺寸将不会被调整，因而其直接子视图的尺寸也不会被调整。
请注意：为了使自动尺寸调整的行为正确，视图的transform属性必须设置为恒等变换；其它变换下的尺寸自动调整行为是未定义的。
自动尺寸调整行为可以适合一些布局的要求，但是如果您希望更多地控制视图的布局，可以在适当的视图类中重载layoutSubviews方法。
```

#### 方法：

**sizeToFit、sizeThatFits:(CGSize)size**

```
- (CGSize)sizeThatFits:(CGSize)size;     // return 'best' size to fit given size. does not actually resize view. Default is return existing view size
- (void)sizeToFit;                       // calls sizeThatFits: with current view bounds and changes bounds size

根据文档解释，我们可以知道 sizeThatFits 会返回一个最合适的size，但是并不更新View的size，sizeToFit 调用 sizeThatFits： 并更新size
sizeToFit不应该在子类中被重写，应该重写sizeThatFits
sizeThatFits传入的参数是receiver当前的size，返回一个适合的size
```

UIView继承自UIResponder, 事件响应部分见：[iOS事件响应链](https://xilankong.github.io/2017年/2016/06/23/iOS事件响应链.html)



### 层次类别(UIViewHierarchy)

插入指定层次、变更View层次等

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

UI更新

```

//标记为需要重新布局，异步调用layoutIfNeeded刷新布局，不立即刷新，但layoutSubviews一定会被调用
- (void)setNeedsLayout; 
//如果有需要刷新的标记，立即调用layoutSubviews进行布局（如果没有标记，不会调用layoutSubviews）
//在视图第一次显示之前，标记总是“需要刷新”的，可以直接调用[view layoutIfNeeded]
- (void)layoutIfNeeded; 
- (void)layoutSubviews; //重新布局会进的方法、这个方法，默认没有做任何事情，需要子类进行重写
```

更详细的UIView的更新机制、以上方法的更多使用细节见：[UIView的更新机制](https://xilankong.github.io/2016年/2016/06/22/iOS自动布局使用说明书.html)



### 渲染类别(UIViewRendering)

#### 属性：

clipsToBounds：是否遮盖越界部分subView的显示，默认NO

opaque : view的不透明度  默认YES

clearsContextBeforeDrawing

```
重绘的时候清除原有内容
当view没有设置背景色的时候，或者说opaque为透明的时候不生效。
```

contentMode： 填充模式

contentStretch：内容拉伸

maskView：view上的遮罩层，不存在和view的层级关系



#### 方法：

```
//重写此方法，执行重绘任务
- (void)drawRect:(CGRect)rect;
//标记为需要重绘，异步调用drawRect,标上一个需要被重新绘图的标记，在下一个draw周期自动重绘，iphone device的刷新频率是60hz，也就是1/60秒后重绘 
- (void)setNeedsDisplay;
//标记为需要局部重绘
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

```
CALayer中存在三个tree，他们分别是：Model Tree
Presentation Tree
Render Tree
Model Tree代表CALayer的真实属性，Presentation Tree对应动画过程中的属性。无论动画进行中还是已经结束，Model Tree都不会发生变化，变化的是Presentation Tree。而动画结束后，Presentation Tree就被重置回到了初始状态。为了让其保持旋转状态，需要在加两句代码：

ba.fillMode=kCAFillModeForwards;

ba.removedOnCompletion=NO;
```



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



**anchorPoint** ： 

是一个CGPoint值，x，y取值范围（0~1），默认为（0.5，0.5） 对于图层本身而言，顾名思义，锚点就用来定位图层的点。

锚点有两个职能：

1）与position一同确定图层相对于父图层的位置；

2）作为图层旋转、平移、缩放的中心。

锚点 默认为(0.5,0.5)，即边界矩形的中心。



**transform ：CATransform3D**

CATransform3D 的数据结构定义了一个同质的三维变换（4x4 CGFloat值的矩阵），用于图层的旋转，缩放，偏移，歪斜和应用的透视。

```
CALayer的2个属性指定了变换矩阵：transform 和 sublayerTransform。

transform ： 是结合 anchorPoint（锚点）的位置来对图层和图层上的子图层进行变化。

sublayerTransform：是结合anchorPoint（锚点）的位置来对图层的子图层进行变化，不包括本身。

CATransform3DIdentity 是单位矩阵，该矩阵没有缩放，旋转，歪斜，透视。该矩阵应用到图层上，就是设置默认值。

```

分析一下CATransform3D的结构：

```
struct CATransform3D
{
  CGFloat m11, m12, m13, m14;
  CGFloat m21, m22, m23, m24;
  CGFloat m31, m32, m33, m34;
  CGFloat m41, m42, m43, m44;
};

typedef struct CATransform3D CATransform3D;
```

4 * 4 矩阵乘法：

![](https://xilankong.github.io/resource/transform3D.png)

转换计算：







接着上面的测试我们继续分析：

1、CALayer的 transform和sublayerTransform 属性都是CATransform3D 类型，允许实现3D变换

2、从第一次测试和第二次测试可以看到，关于3D旋转变化，如果不设置上面的m34属性，整个变化结束后不会有那种透视效果（近大远小）

```
m34负责z轴方向的translation（移动），m34= -1/D,  默认值是0，也就是说D无穷大。D越小透视效果越明显。 所谓的D，是eye（观察者）到投射面的距离。
```



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





UIView 自动布局的时候，frame的变化过程，