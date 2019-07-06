---
layout: post
category: iOS开发基础
title : "UIView、CALayer使用说明书"
---

## 前言

​	iOS开发中 UI是很重要也是最直观可见的一部分，而所有的控件都是继承自UIView的，UIView既可以实现显示的功能，又可以实现响应用户操作的功能。我们还知道每个UIView中都存在一个东西叫CALayer，实现了内容绘制等功能。本文总结整理UIView和CALayer的一些基础知识和使用。



## UIView

UIView表示屏幕上的一块矩形区域，负责渲染区域的内容，并且响应该区域内发生事件。

UIView继承自UIResponder, 事件响应部分见：[iOS事件响应链](https://xilankong.github.io/ios开发基础/2016/06/23/事件响应链学习整理.html)

UIView动画方面扩展见: [iOS动画原理与实现](https://xilankong.github.io/ios开发基础/2016/06/12/常用动画的原理与实现.html)

### 1、基础类别

```
1、继承自UIResponder

2、layerClass： 可以设置rootLayer 为自定义layer

3、userInteractionEnabled： 设置响应用户事件能力

4、tag： 用于标记view，可以通过viewWithTag 查找对应view

5、layer：  获取rootLayer

6、canBecomeFocused：  是否能成为焦点
```



### 2、几何类别

#### frame、bounds、center

```
frame 复合属性 由bounds表示大小、center表示位置 后续会具体解释
bounds 视图在其自己的坐标系中的位置与尺寸，但是无法确定自己在父视图中的位置
center 定义了当前视图在父视图中的位置

注意：

bounds属性与center属性是完全独立的，前者规定尺寸，后者定义位置
bounds中位置的修改不会影响自身在父视图中的位置，但是会影响自己的subView的位置
```

#### transform

```
用于给UIView做一些形变(平移、缩放、旋转)

移动：
// 平移
//每次移动都是相对于上次位置
 _redView.transform = CGAffineTransformTranslate(_redView.transform, 100, 0);
//每次移动都是相对于最开始的位置
 _redView.transform = CGAffineTransformMakeTranslation(200, 0);
 
 缩放：
//每次缩放都是相对于上次
 _redView.transform = CGAffineTransformScale(_redView.transform, 10, 10)
//每次缩放都是相对于最开始
 _redView.transform = CGAffineTransformMakeScale(10, 10);
 
 旋转：
 // 每次旋转都是相对于最初的角度
_redView.transform = CGAffineTransformMakeRotation(M_PI_4);
//每次旋转都是相对于现在的角度
_redView.transform = CGAffineTransformRotate(_redView.transform, M_PI_4);
```

#### contentScaleFactor (scale的理解)

这个属性代表了从逻辑坐标系转化成当前的设备坐标系的转化比例，在[UIScreen mainScreen]中有个属性叫做scale 和这个是一样的。

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

#### exclusiveTouch

```
ExclusiveTouch的作用是：可以达到同一界面上多个控件接受事件时的排他性,从而避免bug。
也就是说避免在一个界面上同时点击多个UIButton导致同时响应多个方法。
当这个UIView成为第一响应者时，在手指离开屏幕前其他view不会响应任何touch事件。

如果你不想让2个button同时点击，只需要把它们的exclusiveTouch都设定为YES
```

#### multipleTouchEnabled

```
是否支持多点触控
```



#### convertPoint:toView:、convertRect:toView、convertPoint:fromView:、convertRect:fromView:

```
坐标转换

1、convertPoint:toView:

[self.view addSubview:myView];
[myView convertPoint:CGPointMake(10, 10) toView:self.view];

把子view中的坐标点转换到父容器坐标系中。

[myView convertPoint:CGPointMake(10, 10) fromView:self.view];

把父坐标系中的坐标点 转换到子容器坐标系中
```



#### autoresizesSubviews、autoresizingMask

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

```

#### sizeToFit、sizeThatFits:(CGSize)size

```
- (CGSize)sizeThatFits:(CGSize)size;     // return 'best' size to fit given size. does not actually resize view. Default is return existing view size
- (void)sizeToFit;                       // calls sizeThatFits: with current view bounds and changes bounds size

根据文档解释，我们可以知道 sizeThatFits 会返回一个最合适的size，但是并不更新View的size，sizeToFit 调用 sizeThatFits： 并更新size， 自动调用drawRect:方法

sizeToFit不应该在子类中被重写，应该重写sizeThatFits
sizeThatFits传入的参数是receiver当前的size，返回一个适合的size
```





### 3、层次类别

#### 方法

```
//从父容器移除自己
- (void)removeFromSuperview;

//添加一个view
- (void)addSubview:(UIView *)view;

//插入指定位置
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index

//调整A\B两个View的位置
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2

//把view提到其他subViews的上面
- (void)bringSubviewToFront:(UIView *)view;

//把view放到其他subViews的下面
- (void)sendSubviewToBack:(UIView *)view;

//根据tag查找对应的view
- (nullable __kindof UIView *)viewWithTag:(NSInteger)tag;

//UIView添加subView的生命周期

- (void)didAddSubview:(UIView *)subview;
- (void)willRemoveSubview:(UIView *)subview;
- (void)willMoveToSuperview:(nullable UIView *)newSuperview;
- (void)didMoveToSuperview;
- (void)willMoveToWindow:(nullable UIWindow *)newWindow;
- (void)didMoveToWindow;
```



### 4、渲染类别

#### 属性：

```
clipsToBounds：是否遮盖越界部分subView的显示，默认NO

opaque : view的不透明度  默认YES

clearsContextBeforeDrawing
重绘的时候清除原有内容
当view没有设置背景色的时候，或者说opaque为透明的时候不生效。

contentMode： 填充模式

contentStretch：内容拉伸

maskView：view上的遮罩层，不存在和view的层级关系
```



#### 方法：

```
//重写此方法，执行重绘任务
- (void)drawRect:(CGRect)rect;

//标记为需要重绘，异步调用drawRect,标上一个需要被重新绘图的标记，在下一个draw周期自动重绘，iphone device的刷新频率是60hz，也就是1/60秒后重绘 
- (void)setNeedsDisplay;

//标记为需要局部重绘
- (void)setNeedsDisplayInRect:(CGRect)rect;
```



### UI更新、渲染机制

#### 1、layoutSubviews方法

在UIView里面有一个方法layoutSubviews，这个方法具体作用是什么呢？

layoutSubviews是对subviews重新布局。比如，我们想更新子视图的位置的时候，可以通过调用layoutSubviews方法，既可以实现对子视图重新布局。layoutSubviews默认是不做任何事情的，用到的时候，需要在子类进行重写。

苹果官方文档建议不要直接调用此方法。如果你想强制更新布局，你可以调用setNeedsLayout方法；如果你想立即数显你的views，你需要调用layoutIfNeeded方法。

**layoutSubviews以下情况会被调用**

```
1、init初始化不会触发layoutSubviews。

2、addSubview会触发layoutSubviews。 注意：当view的fram的值为0的时候，`addSubview`也不会调用`layoutSubviews`的。

3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化。

4、滚动一个UIScrollView会触发layoutSubviews。

5、旋转Screen会触发父UIView上的layoutSubviews事件。

6、改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。

7、直接调用setLayoutSubviews。
```



#### 2、 setNeedsDisplay 、 setNeedsLayout 和  drawRect

首先 setNeedsDisplay 、 setNeedsLayout两个方法都是异步执行的。而 setNeedsDisplay 会调用自动调用drawRect方法，这样可以拿到  UIGraphicsGetCurrentContext，就可以画画了。而setNeedsLayout会默认调用 layoutSubViews，就可以处理子视图中的一些数据。

综上所诉，setNeedsDisplay方便绘图，而setNeedsLayout方便处理布局。

**drawRect方法以下情况会被调用**

```
 1、如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect调用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的.所以不用担心在控制器中,这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量值).
 
2、该方法在调用sizeToFit后被调用，所以可以先调用sizeToFit计算出size。然后系统自动调用drawRect:方法。

3、通过设置contentMode属性值为UIViewContentModeRedraw。那么将在每次设置或更改frame的时候自动调用drawRect:。

4、直接调用setNeedsDisplay，或者setNeedsDisplayInRect:触发drawRect:，但是有个前提条件是rect不能为0。

以上1,2推荐；而3,4不提倡
```

**drawRect方法使用注意点**

```
1、若使用UIView绘图，只能在drawRect：方法中获取相应的contextRef并绘图。如果在其他方法中获取将获取到一个invalidate的ref并且不能用于画图。drawRect：方法不能手动显示调用，必须通过调用setNeedsDisplay 或者 setNeedsDisplayInRect，让系统自动调该方法。

2、若使用calayer绘图，只能在drawInContext: 中（类似于drawRect）绘制，或者在delegate中的相应方法绘制。同样也是调用setNeedDisplay等间接调用以上方法

3、若要实时画图，不能使用gestureRecognizer，只能使用touchbegan等方法来掉用setNeedsDisplay实时刷新屏幕
```

#### 3、其他更新方法

setNeedsLayout：告知页面需要更新，但是不会立刻开始更新，做标记等待运行循环。执行后会立刻调用layoutSubviews。

layoutIfNeeded：告知页面布局立刻更新。所以一般都会和setNeedsLayout一起使用。如果希望立刻生成新的frame需要调用此方法，利用这点一般布局动画可以在更新布局后直接使用这个方法让动画生效。

layoutSubviews：可以重写布局，默认没有做任何事情，需要子类进行重写

setNeedsUpdateConstraints：告知需要更新约束，但是不会立刻开始

updateConstraintsIfNeeded：告知立刻更新约束

updateConstraints：系统更新约束

### 

## 2、CALayer



#### - init()

```
（1）默认为无色，不会显示。要想让绘制的图形显示出来，还需要设置图形的颜色。注意不能直接使用UI框架中的类

（2）在自定义layer中的 -(void)drawInContext:方法不会自己调用，只能自己通过setNeedDisplay方法调用，在view中画东西DrawRect:方法在view第一次显示的时候会自动调用。
```

#### - init(layer: Any)

```
这个初始值设定项CoreAnimation用来创建阴影的副本层

如用作表示层。子类可以重写这个方法来将自己的实例变量复制到演示层(子类应该调用超类之后)。

调用这个方法在其他任何情况下将导致未定义的行为错误。
```

#### presentationLayer、modelLayer

```
CALayer中存在三个tree，他们分别是：

presentLayer Tree(动画树)，modeLayer Tree(模型树), Render Tree(渲染树)

Model Tree代表CALayer的真实属性，Presentation Tree对应动画过程中的属性。无论动画进行中还是已经结束，Model Tree都不会发生变化，变化的是Presentation Tree。而动画结束后，Presentation Tree就被重置回到了初始状态。为了让其保持动画结束状态，需要在加两句代码：

layer.fillMode=kCAFillModeForwards;
layer.removedOnCompletion=NO;
```

#### zPosition

决定层级，zPosition的数值相当于层在垂直屏幕的Z轴 上的位移值。在没有经过任何Transform的2D环境下，zPosition仅仅会决定谁覆盖谁，具体差值是没有意义的，但是经过3D Transform，他们之间的差值，也就是距离，会显现出来。

我们写个测试：

```
CGRect frame = CGRectInset(self.view.bounds, 50, 50);
CALayer *layer = [CALayer layer];
layer.frame = frame;
[self.view.layer addSublayer:layer];
//第一个椭圆 蓝色
CAShapeLayer *shapeLayer = [CAShapeLayer layer];
shapeLayer.contentsScale = [UIScreen mainScreen].scale;
CGMutablePathRef path = CGPathCreateMutable();
CGPathAddEllipseInRect(path, NULL, layer.bounds);
shapeLayer.path = path;
shapeLayer.fillColor = [UIColor blueColor].CGColor;
shapeLayer.zPosition = 40;
[layer addSublayer:shapeLayer];

//第二个椭圆 绿色
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

1、如上代码，结果如下图 左

2、注释掉 `transform.m34` 这行代码，结果如下图 中

3、取消 transform 的设置，结果如下图 右

![](https://xilankong.github.io/resource/transform.png)

分析以上结果：

我们从第三次测试和第二次测试可以看到：

1、zPosition影响了原有的按先后添加顺序的层次（蓝色覆盖在了绿色、灰色上面）

2、zPosition的体现, 数值越大层级越高。

#### anchorPoint

是一个CGPoint值，x，y取值范围（0~1），默认为（0.5，0.5） 对于图层本身而言，顾名思义，锚点就用来定位图层的点。

锚点有两个职能：

1）与position一同确定图层相对于父图层的位置；

2）作为图层旋转、平移、缩放的中心。

锚点 默认为(0.5,0.5)，即边界矩形的中心。

#### transform ：CATransform3D

CATransform3D 的数据结构定义了一个同质的三维变换（4x4 CGFloat值的矩阵），用于图层的旋转，缩放，偏移，歪斜和应用的透视。

```
CALayer的2个属性指定了变换矩阵：transform 和 sublayerTransform。

transform ： 是结合 anchorPoint（锚点）的位置来对图层和图层上的子图层进行变化。

sublayerTransform：是结合anchorPoint（锚点）的位置来对图层的子图层进行变化，不包括本身。

CATransform3DIdentity 是单位矩阵，该矩阵没有缩放，旋转，歪斜，透视。该矩阵应用到图层上，就是设置默认值。
```

分析一下CATransform3D的结构：[iOS CATransform3D](http://www.jianshu.com/p/e8d1985dccec)

**CATransform3D 函数**

```
//-----平移
//返回一个平移变换的transform3D对象 tx，ty，tz对应x，y，z轴的平移
CATransform3D CATransform3DMakeTranslation (CGFloat tx, CGFloat ty, CGFloat tz);
//在某个transform3D变换的基础上进行平移变换，t是上一个transform3D，其他参数同上
CATransform3D CATransform3DTranslate (CATransform3D t, CGFloat tx, CGFloat ty, CGFloat tz);


//-----缩放
//x，y，z分别对应x轴，y轴，z轴的缩放比例
CATransform3D CATransform3DMakeScale (CGFloat sx, CGFloat sy, CGFloat sz);
//在一个transform3D变换的基础上进行缩放变换，其他参数同上
CATransform3D CATransform3DScale (CATransform3D t, CGFloat sx, CGFloat sy, CGFloat sz);


//-----旋转
//angle参数是旋转的角度 ，x，y，z决定了旋转围绕的中轴，取值为-1 — 1之间，如（1，0，0）,则是绕x轴旋转，（0.5，0.5，0），则是绕x轴与y轴中间45度为轴旋转
CATransform3D CATransform3DMakeRotation (CGFloat angle, CGFloat x, CGFloat y, CGFloat z);
//在一个transform3D的基础上进行旋转变换，其他参数如上
CATransform3D CATransform3DRotate (CATransform3D t, CGFloat angle, CGFloat x, CGFloat y, CGFloat z);
```

接着上面的zPosition的测试我们继续分析：

```
1、CALayer的 transform和sublayerTransform 属性都是CATransform3D 类型，允许实现3D变换

2、从第一次测试和第二次测试可以看到，关于3D旋转变化，如果不设置上面的m34属性，整个变化结束后不会有那种透视效果（近大远小）


m34负责z轴方向的translation（移动），m34= -1/D,  默认值是0，也就是说D无穷大。D越小透视效果越明显。 所谓的D，是eye（观察者）到投射面的距离。
```

#### masksToBounds、mask

masksToBounds：是否遮盖越界部分Layer，比如常用于边角等

mask：类似于UIView中的 maskView

#### contents、contentsRect、contentsGravity、contentsScale

```
1、 CALayer 有一个属性叫做contents，这个属性的类型被定义为id，意味着它可以是任何类型的对象。在这种情况下，你可以给contents属性赋任何值，你的app仍然能够编译通过。但是，在实践中，如果你给contents赋的不是CGImage，那么你得到的图层将是空白的。 

2、 事实上，你真正要赋值的类型应该是CGImageRef，它是一个指向CGImage结构的指针。UIImage有一个CGImage属性，它返回一个”CGImageRef”,如果你想把这个值直接赋值给CALayer的contents，那你将会得到一个编译错误。因为CGImageRef并不是一个真正的Cocoa对象，而是一个Core Foundation类型。 

尽管Core Foundation类型跟Cocoa对象在运行时貌似很像（被称作toll-free bridging），他们并不是类型兼容的，不过你可以通过bridged关键字转换。 
所以要为CALayer图层设置寄宿图片属性的最终代码： 
layer.contents = (__bridge id)image.CGImage; 


contentsGravity：类似于UIView的contentMode

contentsScale： 类似于UIView的sacle

```

#### contentsCenter

![](https://xilankong.github.io/resource/slicing.png)

```
图片拉伸

用过xcode应该都知道 图片的slicing功能


因此我们要设置好拉伸的部位，下图中黑色框中位置就是 contentsCenter 的(x, y) 值的占比，绿色部分的长宽就是要拉伸的部分。拉伸的宽高为占比。


一定要设置 view.layer.contentsScale = image.scale，否则图片在Retina 设备会显示不正确
```

#### shadowColor、shadowOpacity、shadowOffset、shadowRadius

```
self.startButton.layer.borderWidth = 1；／／按钮边缘宽度
self.startButton.layer.borderColor = [[UIColor whiteColor] CGColor];  //按钮边缘颜色
self.startButton.layer.shadowColor = [UIColor blackColor].CGColor; //按钮阴影颜色
self.startButton.layer.shadowOffset = CGSizeMake(3,3); //按钮阴影偏移量 正负值确认偏移方向
self.startButton.layer.shadowOpacity = 1; // 阴影的透明度，默认是0   范围 0-1 越大越不透明
```

#### -  (void)setNeedsDisplay; -  (void)setNeedsDisplayInRect:(CGRect)rect;

```
设置需要渲染，当运行循环开始就会去更新已标记的layer
```



#### 问题

1、UIView 自动布局的时候，frame的变化过程，



2、layer绘制的时候默认不会处理scale的问题

```
在CALayer中绘制图形会出现锯齿和模糊，同样绘图在UIView中就没有问题。经查资料发现不自动处理两倍像素的情况。

解决方案为：设置layer的contentsScale属性为[[UIScreen mainScreen] scale];

或者复写drawRect方法也有效
```





## UIView 和 CALayer的联系

前文整理了UIView和CALayer的使用方法，下面我们通过举例测试来比较、分析UIView和CALayer之间的联系和差异。



#### UIView和CALayer在构建方面的联系

我们新增两个类：DemoView：UIView 和 DemoLayer：CALayer

1、重新设置DemoView的rootLayer 的layerClass为DemoLayer（rootLayer：view的默认layer）

```
DemoView中
+(Class)layerClass {
    return [DemoLayer class];
}
```

2、在DemoLayer初始化 init方法行打上断点，打印堆栈信息

```
0 - [DemoLayer init]
1 - [UIView _createLayerWithFrame:]
2 - UIViewCommonInitWithFrame
3 - [UIView initWithFrame]
4 - [DemoView initWithFrame]
```

从上面堆栈信息我们可以看到，当我们初始化DemoView的时候，会自动调用 `_createLayerWithFrame` 方法创建rootLayer

3、layer创建完成后，我们重写一些方法来检查一下UIView和CALayer在几个基础属性上面的联系

UIView : frame、bounds、center

CALayer ： frame、bounds、position

重写上述属性在DemoLayer和DemoView中的 setter 方法，然后在ViewController中初始化添加DemoView：

```
ViewController中:
DemoView *view1 = [[DemoView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
[self.view addSubview:view1];

执行结果：
DemoLayer - setBounds
DemoView - setFrame 开始
DemoLayer - setFrame
DemoLayer - setPosition
DemoLayer - setBounds
DemoView - setFrame 结束

view1.frame = CGRectMake(0, 0, 150, 150); 动态修改frame执行结果：
DemoView - setFrame 开始
DemoLayer - setFrame
DemoLayer - setPosition
DemoLayer - setBounds
DemoView - setFrame 结束
```

**分析上面执行结果的顺序：**

我们对DemoView的frame设置中执行了对DemoLayer的frame、position、bounds的设置，并且没有执行DemoView中的center和bounds的设置。

**继续测试：**执行UIView的bounds 和 center的修改、属性的获取:

```
修改center 
DemoView - setCenter
DemoLayer - setPosition

修改bounds
DemoView - setBounds
DemoLayer - setBounds

frame的获取
DemoView - frame
DemoLayer - frame
...
```

**分析上面执行的结果可知：**

1、DemoView中的frame、bounds、center属性的setter方法执行了DemoLayer中的对应属性（center -> position）的setter方法

frame属于派生属性，依赖于 bounds、 anchorPoint、transform 和 position

当我们设置frame的时候，默认会执行DemoView的setFrame、CALayer的setFrame - setPosition -  setBounds

2、DemoView中的frame、bounds和center  的 getter方法，UIView并没有做什么工作，只是简单的各自调用它底层的CALayer的frame，bounds和position方法。

**注意：**

bounds 和 frame的区别: bounds原点默认 （0，0）基于view本身的坐标系统，frame原点基于父视图中的位置



#### UIView和CALayer在绘制方面的联系

**接着上面的demo测试：**

重写DemoView中的 drawRect、drawLayer:inContext:方法，用来画一条线

重写DemoLayer中的drawInContext方法

```
DemoView中：
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //画线
    //ctx 的备份
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, 5);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 0, 1);
    CGContextMoveToPoint(ctx, 0, 120);    //起点
    CGContextAddLineToPoint(ctx, 200, 120); //画线
    CGContextStrokePath(ctx);
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}

DemoLayer中：
-(void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
}

这里做个测试：

结果：
1、正常绘制出一条线，执行顺序是 
DemoView - drawRect:
DemoView - drawLayer:inContext:
DemoLayer - drawInContext:

同时打印成功执行测试的执行堆栈：
0 - DemoView drawRect:
1 - [UIView(CALayerDelegate) drawLayer:inContext:]
2 - [CALayer drawInContext:]
3 - [DemoLayer drawInContext:]

注释掉 drawInContext 中的super调用 再做一次测试：

结果: 不能正常绘制，执行顺序是 
DemoLayer - drawInContext
//并不会执行到DemoView

注释掉 drawLayer:inContext: 中的super调用 再做一次测试：

结果是: 不能正常绘制，执行顺序是 
DemoLayer - drawInContext
DemoView - drawLayer:inContext:

//不会执行到 DemoView - drawRect:
```

**分析以上结果：**

UIView实现了CALayerDelegate代理，rootLayer的代理就是DemoView，所以会执行 drawLayer:inContext: 方法，由上面的测试结果，我们可以推断一下，DemoView的drawRect 方法的执行是在 drawLayer:inContext:  方法的过程中完成的。

**我们继续测试：**先修改DemoView和DemoLayer中的代码：

```
DemoLayer中：
-(void)drawInContext:(CGContextRef)ctx {
//    [super drawInContext:ctx];
    CGContextSaveGState(ctx);

    CGContextSetLineWidth(ctx, 5);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
    CGContextMoveToPoint(ctx, 0, 120);    //起点
    CGContextAddLineToPoint(ctx, 200, 120); //画线
    CGContextStrokePath(ctx);
}
DemoView中：
-(void)drawRect:(CGRect)rect {
}

结果：成功绘制一条线
```

**分析以上结果：**

1、CALayer 和 UIView 中都可以根据上下文进行绘制，UIView的drawRect依赖 CALayer 传递过来的上下文才能执行

2、CALayer 绘制并不依赖UIView，所以如果 drawRect 中没有调用super 并不会影响layer中的绘制

3、如果layer中的 drawInContext 中 没有 super调用，view中的drawRect也无法绘制

4、如果view中的 drawLayer:inContext: 中没有super调用，view中的drawRect也无法绘制





## UIView 和 CALayer的区别

#### UIView可以响应用户事件、而 CALayer不能

UIView继承自UIResponder， 在 UIResponder中定义了处理各种事件和事件传递的接口, 而 CALayer直接继承 NSObject，并没有相应的处理事件的接口。

```
UIKit使用UIResponder作为响应对象，来响应系统传递过来的事件并进行处理。
UIApplication、UIViewController、UIView、和所有从UIView派生出来的UIKit类（包括UIWindow）都直接或间接地继承自UIResponder类。
```



#### UIView 和 CALayer 在基础属性上的区别

前面基础介绍有描述

#### UIView 和 CALayer在动画中的区别

在做 iOS 动画的时候，修改非 RootLayer的属性，会默认产生隐式动画，而修改UIView则不会。

[官方文档](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/ReactingtoLayerChanges/ReactingtoLayerChanges.html#//apple_ref/doc/uid/TP40004514-CH7-SW1)

**可动画属性：**在Api属性说明中 有 Animatable 结尾的都是可动画属性，属性的变化都会产生隐式动画。

**隐式动画实现原理:**

**做一个测试:** 1、2 号针对rootLayer ; 3、4号针对 非rootLayer ;  5、6号针对UIView属性变更

```
DemoView中重写actionForLayer:forKey:
-(id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    id<CAAction> action = [super actionForLayer:layer forKey:event];
    NSLog(@"action for layer: %@, for key:%@ is %@", layer, event, action);
    return action;
}
DemoLayer中重写 addAnimation:forKey
-(void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key {
    NSLog(@"anim : %@, for key:%@", anim, key);
    [super addAnimation:anim forKey:key];
}

事件触发：
1:
self.layer.position = CGPointMake(120, 120);
2:
[UIView animateWithDuration:0.3 animations:^{
    self.layer.position = CGPointMake(120, 120);
}];
3：
self.otherLayer.position = CGPointMake(120, 120);
4：
[UIView animateWithDuration:0.3 animations:^{
    self.otherLayer.position = CGPointMake(120, 120);
}];
5：
self.center = CGPointMake(120, 120);
6：
[UIView animateWithDuration:0.3 animations:^{
    self.center = CGPointMake(120, 120);
}];

self.layer是rootLayer、self.otherLayer是加在self.layer上的非rootLayer
结果：
1：
action for layer: <DemoLayer: 0x60300009e260>, for key:position is <null>
anim无输出
2：
action for layer: <DemoLayer: 0x60300009cc10>, for key:position is <_UIViewAdditiveAnimationAction: 0x6030000b5330>
anim : <CABasicAnimation: 0x6030000b5000>, for key:position
3：
action无输出
anim : <CABasicAnimation: 0x6030000b66e0>, for key:position
4：
action无输出
anim : <CABasicAnimation: 0x6030000b4e20>, for key:position
5:
action for layer: <DemoLayer: 0x60300009cbe0>, for key:position is <null>
anim无输出
6:
action for layer: <DemoLayer: 0x60300009ca60>, for key:position is <_UIViewAdditiveAnimationAction: 0x6030000bc6b0>
anim : <CABasicAnimation: 0x6030000bc380>, for key:position

初始化DemoView时候的输出：
action for layer: <DemoLayer: 0x60300009c670>, for key:bounds is <null>
action for layer: <DemoLayer: 0x60300009c670>, for key:opaque is <null>
action for layer: <DemoLayer: 0x60300009c670>, for key:position is <null>
action for layer: <DemoLayer: 0x60300009c670>, for key:sublayers is <null>
action for layer: <DemoLayer: 0x60300009c670>, for key:onOrderIn is <null>
```

**分析测试结果：**

1、从1、2、5、6号输出结果来看，view.layer正如官方文档中所写：每一个view.layer都以该view作为其delegate，并通过询问view的`actionForLayer:forKey:`方法来获得自己应该执行的CAAction对象。

2、从2、6输出结果我们可以看到、返回的action是 `_UIViewAdditiveAnimationAction`这么一个action，然后再有animation被添加到layer中，从上也可以看出来UIView的动画，属于对CAAnimation的一层封装。

3、从3、4号输出结果，我们看到除了rootLayer之外的layer属性变化就不再经过UIView这一层的action获取，而是直接由layer层进行动画添加。



**去除CALayer隐式动画：**

```
[CATransaction begin];
[CATransaction setDisableActions:YES];
//要去掉动画的操作
self.otherLayer.position = CGPointMake(120, 120);
[CATransaction commit];
```



## 总结

1、每个 UIView 内部都有一个 CALayer 在背后提供内容的绘制和显示，并且 UIView 的尺寸样式都由内部的 Layer 所提供。

2、两者都有树状层级结构，layer 内部有 SubLayers，View 内部有 SubViews。但是 Layer 比 View 多了个anchorPoint

3、UIView的frame、bounds、center基础属性都获取于view.layer的基础属性，setter方法也会调用view.layer的setter方法

4、CALayer 和 UIView中都可以根据上下文进行绘制，UIView的drawRect依赖CALayer传递过来的上下文才能执行、CALayer绘制并不依赖UIView，只依赖UIView进行展示

5、在做 iOS 动画的时候，修改非 RootLayer的属性，会默认产生隐式动画，而修改UIView则不会。



## 参考



[iOS图形渲染分析](http://www.cocoachina.com/ios/20160929/17673.html)

