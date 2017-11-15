---
layout: post
category: 学习之路
title : "UIView、CALayer的联系和区别"
---

## 前言

前文整理了UIView和CALayer的使用方法，下面我们比较分析UIView和CALayer之间的差异和联系。

> 所有测试基于iOS 11.0、Xcode9.0。



## UIView 和 CALayer的联系

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

从上面堆栈信息我们可以看到，当我们初始化DemoView的时候，会自动调用 `_createLayerWithFrame` 方法创建rootLayer

3、layer创建完成后，我们重写一些方法来检查一下UIView和CALayer在几个基础属性上面的联系

UIView : frame、bounds、center

CALayer ： frame、bounds、position

重写上述属性在DemoLayer和DemoView中的 setter 方法，然后在ViewController中初始化添加DemoView：

```
ViewController中:
//frame布局
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

我们对DemoView的frame设置中执行了对DemoLayer的frame、position、bounds的设置，并且并未执行DemoView中的center和bounds的设置。

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

1、DemoView中的frame、bounds、center属性的setter方法执行了DemoLayer中的setter方法

2、DemoView中的frame、bounds和center  的 getter方法，UIView并没有做什么工作，只是简单的各自调用它底层的CALayer的frame，bounds和position方法。

**注意：**

frame属于派生属性，依赖于 bounds、 anchorPoint、transform 和 position

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

1、CALayer 和 UIView中都可以根据上下文进行绘制，UIView的drawRect依赖CALayer传递过来的上下文才能执行

2、CALayer绘制并不依赖UIView



## UIView 和 CALayer的区别

#### UIView可以响应用户事件、而 CALayer不能

UIView继承自UIResponder， 在 UIResponder中定义了处理各种事件和事件传递的接口, 而 CALayer直接继承 NSObject，并没有相应的处理事件的接口。

```
UIKit使用UIResponder作为响应对象，来响应系统传递过来的事件并进行处理。
UIApplication、UIViewController、UIView、和所有从UIView派生出来的UIKit类（包括UIWindow）都直接或间接地继承自UIResponder类。
```



#### UIView 和 CALayer 在基础属性上的区别

这一部分可以看之前的[UIView和CALayer的使用介绍](https://xilankong.github.io/学习之路/2017/11/13/UIView-CALayer使用说明书.html)



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

4、CALayer 和 UIView中都可以根据上下文进行绘制，UIView的drawRect依赖CALayer传递过来的上下文才能执行、CALayer绘制并不依赖UIView，依赖UIView进行展示

5、在做 iOS 动画的时候，修改非 RootLayer的属性，会默认产生隐式动画，而修改UIView则不会。



## 参考



[iOS图形渲染分析](http://www.cocoachina.com/ios/20160929/17673.html)

