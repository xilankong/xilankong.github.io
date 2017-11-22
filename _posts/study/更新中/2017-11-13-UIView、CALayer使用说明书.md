---
layout: post
category: 学习之路
title : "UIView、CALayer使用说明书"
---

## 前言

​	iOS开发中 UI是很重要也是最直观可见的一部分，而所有的控件都是继承自UIView的，UIView既可以实现显示的功能，又可以实现响应用户操作的功能。我们还知道每个UIView中都存在一个东西叫CALayer，实现了内容绘制等功能。本文总结整理UIView和CALayer的常用属性、方法、开发中容易遇到的问题等

## 1、UIView

UIView表示屏幕上的一块矩形区域，负责渲染区域的内容，并且响应该区域内发生事件。

基本属性：

```
frame
bounds
center
树形结构，可以添加subView
层次结构，App中的UIView各自有各自的层次
```

UIView可以渲染内容:

```
- drawRect:(CGRect)rect;
alpha
opaque
hidden
```

UIView可以执行动画：

```
+ animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay...
+ beginAnimations:(nullable NSString *)animationID context:(nullable void *)context
```

UIView继承自UIResponder，可以响应用户事件：

```
响应触摸事件
– touchesBegan:withEvent:
– touchesMoved:withEvent:
– touchesEnded:withEvent:
– touchesCancelled:withEvent:

添加其他操作手势 等等
- addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
- removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
```







## 2、CALayer



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