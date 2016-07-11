---
layout: post
category: 学习之路
---

在UIView里面有一个方法layoutSubviews，这个方法具体作用是什么呢？

```
- (void)layoutSubviews; // override point. called by layoutIfNeeded automatically. As of iOS 6.0, when constraints-based layout is used the base implementation applies the constraints-based layout, otherwise it does nothing. 
```

## 官方文档解释

我们先来看看苹果官方文档的解释：

```
The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.

Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.

You should not call this method directly. If you want to force a layout update, call the setNeedsLayout method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the layoutIfNeeded method. 
```

最后一段说，不要直接调用此方法。如果你想强制更新布局，你可以调用setNeedsLayout方法；如果你想立即数显你的views，你需要调用layoutIfNeeded方法。

## layoutSubviews作用

layoutSubviews是对subviews重新布局。比如，我们想更新子视图的位置的时候，可以通过调用layoutSubviews方法，既可以实现对子视图重新布局。

layoutSubviews默认是不做任何事情的，用到的时候，需要在自雷进行重写。

## layoutSubviews以下情况会被调用

苹果官方文档已经强调，不能直接调用layoutSubviews对子视图进行重新布局。那么，layoutSubviews什么情况下会被调用呢？通过百度搜索，发现以下几种情况layoutSubviews会被调用。

1. 直接调用setLayoutSubviews。（这个在上面苹果官方文档里有说明）
2. addSubview的时候。
3. 当view的frame发生改变的时候。
4. 滑动UIScrollView的时候。
5. 旋转Screen会触发父UIView上的layoutSubviews事件。
6. 改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。

我简单测试了一下，上面基本都会被调用。 注意：

```
当view的fram的值为0的时候，`addSubview`也不会调用`layoutSubviews`的。
```

layoutSubviews方法在对自雷视图进行布局的时候非常方便。可以自己动手，深入理解layoutSubviews的调用机制。

