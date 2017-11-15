---
layout: post
category: 学习之路
title : "UIView、CALayer的联系和区别"
---

## 前言

​	前文整理了UIView和CALayer的使用方法，那么这里就有个问题了：你给我解析清楚，为什么要有CALayer和UIView两个差不多功能的东西，整理成一个不就好了么？（[答案](http://www.cocoachina.com/ios/20150828/13257.html)）

​	如果你看了答案指的文章应该能知道，这是一种为了维护升级更方便的原因、苹果把功能拆分为两部分，下面我们比较分析UIView和CALayer之间的差异和联系。



## 1、UIView 和 CALayer的区别

#### UIView可以响应用户事件、而 CALayer不能

UIView继承自UIResponder， 在 UIResponder中定义了处理各种事件和事件传递的接口, 而 CALayer直接继承 NSObject，并没有相应的处理事件的接口。

```
UIKit使用UIResponder作为响应对象，来响应系统传递过来的事件并进行处理。
UIApplication、UIViewController、UIView、和所有从UIView派生出来的UIKit类（包括UIWindow）都直接或间接地继承自UIResponder类。
```



#### UIView 和 CALayer在基础属性的区别

**UIView**

```
transform ： CGAffineTransform
```

**CALayer**

**zPosition ：** 

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
//设置CALayer的sublayerTransform
layer.sublayerTransform = transform;
```





**anchorPoint** ： 

锚点 默认为(0.5,0.5),即边界矩形的中心

**transform ：** 

CATransform3D





#### UIView 和 CALayer在动画中的区别

在做 iOS 动画的时候，修改非 RootLayer的属性，会默认产生隐式动画，而修改UIView则不会。



```
对于每一个 UIView 都有一个 layer,把这个 layer 且称作RootLayer,而不是 View 的根 Layer的叫做 非 RootLayer。我们对UIView的属性修改时时不会产生默认动画，而对单独 layer属性直接修改会，这个默认动画的时间缺省值是0.25s.
在 Core Animation 编程指南的 “How to Animate Layer-Backed Views” 中，对为什么会这样做出了一个解释：
UIView 默认情况下禁止了 layer 动画，但是在 animation block 中又重新启用了它们
是因为任何可动画的 layer 属性改变时，layer 都会寻找并运行合适的 'action' 来实行这个改变。在 Core Animation 的专业术语中就把这样的动画统称为动作 (action，或者 CAAction)。  
layer 通过向它的 delegate 发送 actionForLayer:forKey: 消息来询问提供一个对应属性变化的 action。delegate 可以通过返回以下三者之一来进行响应：    

它可以返回一个动作对象，这种情况下 layer 将使用这个动作。
它可以返回一个 nil， 这样 layer 就会到其他地方继续寻找。
它可以返回一个 NSNull 对象，告诉 layer 这里不需要执行一个动作，搜索也会就此停止。  

当 layer 在背后支持一个 view 的时候，view 就是它的 delegate；

```



## 2、UIView 和 CALayer的联系

#### UIView和CALayer在构建方面的联系

1、写个DemoView，重新设置它的rootLayerClass为DemoLayer

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

从上面堆栈信息我们可以看到，当我们初始化DemoView的时候，会自动调用 _createLayerWithFrame 方法创建rootLayer

3、layer创建完成后，我们重写一些方法来检查一下UIView和CALayer在几个基础属性上面的联系

UIView : frame、bounds、center

CALayer ： frame、bounds、position

重写上述属性在DemoLayer和DemoView中的 setter 方法，然后在ViewController中初始化添加DemoView：

```
ViewController中:
//frame布局
DemoView *view1 = [[DemoView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
[self.view addSubview:view1];

执行顺序结果：
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

分析上面执行顺序结果：
我们对DemoView的frame设置中执行了对DemoLayer的frame、position、bounds的设置，并且并未执行DemoView中的center和bounds的设置。

后续测试中执行UIView的bounds 和 center的修改、属性的获取:

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

分析上面执行的结果：

DemoView中的frame、bounds、center属性的setter方法执行了DemoLayer中的setter方法

DemoView中的frame、bounds和center  的 getter方法，UIView并没有做什么工作，只是简单的各自调用它底层的CALayer的frame，bounds和position方法。

注意：

frame属于派生属性，依赖于 bounds、 anchorPoint、transform 和 position

bounds 和 frame的区别: bounds原点默认 （0，0）基于view本身的坐标系统，frame原点基于父视图中的位置



#### UIView和CALayer在绘制方面的联系

接着上面的demo，

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
DemoView - drawRect
DemoLayer - drawInContext

同时打印成功执行测试的执行堆栈：
0 - DemoView drawRect:
1 - [UIView(CALayerDelegate) drawLayer:inContext:]
2 - [CALayer drawInContext:]
3 - [DemoLayer drawInContext:]

注释掉 drawInContext 中的super调用 再做一次测试：

结果: 不能正常绘制，执行顺序是 
DemoLayer - drawInContext

注释掉 drawLayer:inContext: 中的super调用 再做一次测试：

结果是: 不能正常绘制，执行顺序是 
DemoLayer - drawInContext
DemoView - drawLayer:inContext:
```

分析以上结果：

UIView实现了CALayerDelegate代理，rootLayer的代理就是DemoView，所以会执行 drawLayer:inContext: 方法，由上面的测试结果，我们可以推断一下，DemoView的drawRect 方法的执行是在 drawLayer:inContext:  方法的过程中完成的。



我们继续做一个测试，先修改DemoView和DemoLayer中的代码：

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

分析以上结果：

CALayer 和 UIView中都可以根据上下文进行绘制，UIView的drawRect依赖CALayer传递过来的上下文才能执行，CALayer绘制并不依赖UIView





## 4、总结

1、每个 UIView 内部都有一个 CALayer 在背后提供内容的绘制和显示，并且 UIView 的尺寸样式都由内部的 Layer 所提供。

2、两者都有树状层级结构，layer 内部有 SubLayers，View 内部有 SubViews。但是 Layer 比 View 多了个anchorPoint

