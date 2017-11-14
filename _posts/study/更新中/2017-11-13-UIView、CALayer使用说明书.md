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




