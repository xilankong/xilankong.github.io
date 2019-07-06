---
layout: post
category: iOS开发基础
title:  "CoreGraphics使用说明书" 
---



## iOS的绘图框架

iOS的绘图框架有多种，我们平常最常用的就是UIKit，其底层是依赖CoreGraphics实现的，而且绝大多数的图形界面也都是由UIKit完成，并且UIImage、NSString、UIBezierPath、UIColor等都知道如何绘制自己，也提供了一些方法来满足我们常用的绘图需求。除了UIKit，还有CoreGraphics、Core Animation，Core Image，OpenGL ES等多种框架，来满足不同的绘图要求。各个框架的大概介绍如下：

- UIKit：最常用的视图框架，封装度最高，都是OC对象
- CoreGraphics：主要绘图系统，常用于绘制自定义视图，纯C的API，使用Quartz2D做引擎
- CoreAnimation：提供强大的2D和3D动画效果
- CoreImage：给图片提供各种滤镜处理，比如高斯模糊、锐化等
- OpenGL-ES：主要用于游戏绘制，但它是一套编程规范，具体由设备制造商实现



## 绘图的了解

**绘图周期**

```
运行循环会遍历所有待处理的 UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面，这是一个绘图周期。
```

**绘制操作只发生在主线程**

```

```

**视图绘制**

```
UIView的 drawRect: 方法 进行绘制，如果调用一个视图的 setNeedsDisplay，该视图就会被标记为重新绘制，在下一次绘图周期中会调用drawRect: 重新绘制。
```

**视图布局**

```
调用UIView的layoutSubviews方法。如果调用一个视图的setNeedsLayout方法，那么该视图就被标记为需要重新布局，UIKit会自动调用layoutSubviews方法及其子视图的layoutSubviews方法。
```

在绘图时，我们应该尽量多使用布局，少使用绘制，是因为布局使用的是GPU，而绘制使用的是CPU。GPU对于图形处理有优势，而CPU要处理的事情较多，且不擅长处理图形，所以尽量使用GPU来处理图形。



## CoreGraphics

### 

### 1.context 绘图上下文

iOS的绘图必须在一个上下文中绘制，所以在绘图之前要获取一个上下文。如果是绘制图片，就需要获取一个图片的上下文；如果是绘制其它视图，就需要一个非图片上下文。对于上下文的理解，可以认为就是一张画布，然后在上面进行绘图操作。

#### 获取上下文方法

**1、重载UIView的 drawrect: 方法**

在我们执行任何绘制代码前，该方法自动配置好绘图上下文，我们只需要通过 UIGraphicsGetCurrentContext 方法就可以获取到当前绘图上下文用于绘制操作。

**2、自己生成绘图上下文**

当不是在 drawrect：方法中执行绘制操作，imageContext 图片上下文，可以通过UIGraphicsBeginImageContextWithOptions:获取一个图片上下文，然后绘制完成后，调用UIGraphicsGetImageFromCurrentImageContext获取绘制的图片，最后要记得关闭图片上下文UIGraphicsEndImageContext。



### 2.绘图状态

#### 1、pop 、 push （设置绘图的上下文环境（context））

**push**：UIGraphicsPushContext(context)把context压入栈中，并把context设置为当前绘图上下文

**pop**：UIGraphicsPopContext将栈顶的上下文弹出，恢复先前的上下文，但是绘图状态不变

```
override func draw(_ rect: CGRect) {
    UIColor.red.setFill()
    let context = UIGraphicsGetCurrentContext()
    UIGraphicsPushContext(context!)
    UIColor.blue.setFill()
    UIGraphicsPopContext()
    UIRectFill(self.bounds)
}//结果显示的是蓝色
```



#### 2、save 、restore (设置绘图的状态)

**save**：CGContextSaveGState 压栈当前的绘图状态，仅仅是绘图状态，不是绘图上下文

**restore**：恢复刚才保存的绘图状态

```
override func draw(_ rect: CGRect) {
    UIColor.red.setFill()
    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()
    context?.setFillColor(UIColor.blue.cgColor)
    context?.restoreGState()
    context?.fill(self.bounds)
}//结果显示的是红色
```





### 3、CGPathRef / UIBezierPath

图形的绘制需要绘制一个路径，然后再把路径渲染出来，而CGPathRef就是CoreGraphics框架中的路径绘制类，UIBezierPath是封装CGPathRef的面向OC的类，使用更加方便，但是一些高级特性还是不及CGPathRef。



### 4.绘图方法

#### 1、图片类型的上下文绘图

不在复写方法中进行

```
UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
let context = UIGraphicsGetCurrentContext()
context?.addEllipse(in: CGRect(x: 0, y: 0, width: 100, height: 100))
context?.setFillColor(UIColor.red.cgColor)
context?.fillPath()
let image = UIGraphicsGetImageFromCurrentImageContext()
UIGraphicsEndImageContext()
let imageView = UIImageView(image: image)
imageView.frame = CGRect(x: 0, y: 100, width: 100, height: 100)
view.addSubview(imageView)
```

#### 2、draw(_ rect: CGRect)

```
在view子类的 draw(_ rect: CGRect) 方法进行重绘
```



#### 3、draw(_ layer: CALayer, in ctx: CGContext)

```
在view子类的 draw(_ layer: CALayer, in ctx: CGContext) 方法进行重绘
```



#### 4、 draw(in ctx: CGContext)

```
在CALayer中绘制
```



#### 5、具体的几个绘制



**Shadows阴影使用**

```
ctx.setShadow(offset: CGSize(width: 2, height: 2), blur: 0.5, color: UIColor.red.cgColor)

offset: 偏移量

blur: 透明度

color: 颜色
```



**Gradients渐变效果使用**

绘制

```
绘制一个由上到下的 红-橙 渐变

let array = [UIColor.red.cgColor, UIColor.orange.cgColor] as CFArray

ctx.drawLinearGradient(CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: array, locations: [0.0, 1.0])!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 100, y: 100), options: [])
```

CAGradientLayer

```
绘制一个横向5色彩虹

let myLayer = CAGradientLayer()

myLayer.position = CGPoint(x: 100, y: 100)
myLayer.bounds = CGRect(x: 0, y: 0, width: 200, height: 100)
myLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor,UIColor.yellow.cgColor, UIColor.green.cgColor,UIColor.blue.cgColor]
myLayer.locations = [NSNumber(floatLiteral: 0.2),NSNumber(floatLiteral: 0.4),NSNumber(floatLiteral: 0.6),NSNumber(floatLiteral: 0.8),NSNumber(floatLiteral: 1.0)]
myLayer.startPoint = CGPoint(x: 0, y: 0)
myLayer.endPoint = CGPoint(x: 1.0, y: 0)
```



**Transparency Layers使用**

```
透明图层
```

https://blog.csdn.net/rhljiayou/article/details/10144993