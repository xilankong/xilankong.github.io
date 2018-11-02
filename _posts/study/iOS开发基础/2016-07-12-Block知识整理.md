---
layout: post
category: iOS开发基础
title:  "iOS自动布局" 
---

## 自动布局来源

autoresizingMask，苹果提供用于处理坐标布局在多方面的不足的问题（屏幕旋转坐标变化，视图数量过多）。由于autoresizingMask的不足，基于autoresizingMask，在iOS 6 苹果引入自动布局（Auto Layout）和 布局约束（Layout Constraint）的概念，这也就是这里要说的自动布局。

## 自动布局原理

自动布局是对autoresizingMask的进一步改进，它允许开发者在界面上的任意两个视图之间建立精确的线性变化规则。比如我们要上下排列两个相同大小View A和B，那么B相对于A就只见就可以建立对应的线性变化规则即：

B的 y 坐标：就是A的 y 坐标加上 A 的高度

B的 x 坐标：因为上下排列，所以 B的x坐标和A一样

B的 高度：A的高度

B的 宽度： A的宽度

有上面四个规则，我们就可以知道B的具体位置，即使因为横竖屏幕切换，也不会变动这些规则。

每个线性变化规则称之为**布局约束（Layout Constraint）**。由于每个视图需要确定4个布局属性才能准确定位，因此一般来说都需要建立4个布局约束（除开可以自动计算高度的组件，UILabel等）。

## 自动布局使用方法

添加自动布局约束（下文简称约束）有以下几种方式：

- 使用Xcode的Interface Builder界面设计器添加并设置约束
- 通过系统原生的NSLayoutConstraint逐条添加约束
- 通过可视化格式语言VFL添加约束
- 使用第三方类库（如Masonry）添加约束

### Interface Builder创建布局约束

基础的使用大家都很熟悉，这里有份大神的详细文档：[文档](http://blog.csdn.net/pucker/article/details/41843511)

这里添加一部分内容，Interface Builder 给 UIScrollView添加自动布局约束：

一个简单的例子  :   在XIB中 设置一个自己根据内容变化的竖向scrollview 

步骤：

1、在scrollview中添加一个contentView，四边距依赖于self.view

2、设置 contentView 的 width、height equal scrollview （高度可以不设置，但是xib会提示错误，所以一般设置为 remove on build，选中约束勾选Remove at build time）

![一个工程下面的.git](https://xilankong.github.io/resource/scrollViewXIB.png)

3、在contentView里面添加需要展示的内容，保证可以根据内容推算出总高度。

比如：

添加三个不限行数的UILabel A、B、C

1、A 顶部、左右 依赖于contentView

2、B 顶部依赖于A的底部、左右依赖于contentView

3、C顶部依赖于B的底部、左右、底部依赖于contentView

4、约束设置完成后肯定会出现错误提示，因为根据内容自动扩展的 3个UILabel之间不知道在显示内容无法填满contentView的时候，哪个UILabel要去适应而变大。所以给C的 content Hugging Priority Vertical 属性 设置为250

5、三个文案内容随意，得到如下样式：

![一个工程下面的.git](https://xilankong.github.io/resource/scrollviewaddLabel.png)

6、运行起来，如下效果：（contentView背景色为橙色，self.view背景色为灰色）

![一个工程下面的.git](https://xilankong.github.io/resource/scrollShow.png)

### NSLayoutConstraint 创建布局约束

NSLayoutConstraint添加约束，其实就是相当于，你在xib中做的事情，被转成代码的形式添加。每一个布局约束是一个NSLayoutConstraint实例。

大神的详细文档：[文档](http://blog.csdn.net/pucker/article/details/45070955)

### VFL 创建布局约束

使用Visual Format Language（暂且翻译为可视化格式语言，简称VFL）创建约束。 

大神的详细文档：[文档](http://blog.csdn.net/pucker/article/details/45093483)

### Masonry 创建布局约束

Masonry是一个轻量级的布局框架 拥有自己的描述语法 采用更优雅的链式语法封装自动布局 简洁明了 并具有高可读性，而且同时支持 iOS 和 Max OS X。

#### 基础属性、使用方法

| MASViewAttribute  | NSLayoutAttribute         |
| ----------------- | ------------------------- |
| view.mas_left     | NSLayoutAttributeLeft     |
| view.mas_right    | NSLayoutAttributeRight    |
| view.mas_top      | NSLayoutAttributeTop      |
| view.mas_bottom   | NSLayoutAttributeBottom   |
| view.mas_leading  | NSLayoutAttributeLeading  |
| view.mas_trailing | NSLayoutAttributeTrailing |
| view.mas_width    | NSLayoutAttributeWidth    |
| view.mas_height   | NSLayoutAttributeHeight   |
| view.mas_centerX  | NSLayoutAttributeCenterX  |
| view.mas_centerY  | NSLayoutAttributeCenterY  |
| view.mas_baseline | NSLayoutAttributeBaseline |

Masonry 以链式写法来完成约束的添加，重点理解相对布局，如下是常用部分的约束写法

```
//.分别设置各个相对边距（superview为view的父类视图，下同）
make.left.mas_equalTo(superView.mas_left).mas_offset(10);
make.right.mas_equalTo(superView.mas_right).mas_offset(-10);
make.top.mas_equalTo(superView.mas_left).mas_offset(10);
make.bottom.mas_equalTo(superView.mas_bottom).offset(-10);

//直接连接使用left大于等于每个值
make.left.mas_greaterThanOrEqualTo(10);

//设置宽和高
make.width.mas_equalTo(60);
make.height.mas_equalTo(60);

//.设置center和款高比
make.center.mas_equalTo(superView);
make.width.mas_equalTo(superView).multipliedBy(1.00/3);
make.height.mas_equalTo(superView).multipliedBy(0.25);

//.关于约束优先级,此处要注意约束冲突的问题，统一约束优先级大的生效
make.left.mas_equalTo(100);
make.left.mas_equalTo(view.superview.mas_left).offset(10);
make.left.mas_equalTo(20).priority(700);
make.left.mas_equalTo(40).priorityHigh();
make.left.mas_equalTo(60).priorityMedium();
make.left.mas_equalTo(80).priorityLow();

//.如果你想让view的（x坐标）左边大于等于label的左边，以下两个约束的写法效果一样
 make.left.greaterThanOrEqualTo(label);
 make.left.greaterThanOrEqualTo(label.mas_left);
 
 //如果四个边距都和父类一样这种情况
 make.edges.equalTo(superView)；
 //或者通过UIEdgeInsetsMake 设置四边边距
 make.edges.equalTo(superview).insets(UIEdgeInsetsMake(5, 10, 15, 20))
 
 //设置大小可以通过size
 make.size.equalTo(CGSizeMake(200, 100));
```

#### 约束优先级

- .priority允许你设置一个非常准确的的约束优先级（0-1000）
- .priorityHigh 相当于系统的 UILayoutPriorityDefaultHigh
- .priorityMedium  介于 high and low之间的优先级
- .priorityLow 相当于系统的 UILayoutPriorityDefaultLow

注：默认通过mas_make添加的约束不设置优先级时，默认都是最高（1000）

优先级属性可以放在约束链的末端使用，如：

```
make.left.greaterThanOrEqualTo(label.mas_left).with.priorityLow();
make.top.equalTo(label.mas_top).with.priority(600);
```

#### 约束修改

**1、References**

你可以持有某个特定的约束，让其成为成员变量或者属性
//设置为公共或私接口

```
@property (nonatomic, strong) MASConstraint *widthConstraint;

self.widthConstraint.constant = 30;

[self.widthConstraint uninstall];
```

**2、mas_updateConstraints**

如果你只是想更新一下view对应的约束，可以使用 mas_updateConstraints 方法代替 mas_makeConstraints方法
//这是苹果推荐的添加或者更新约束的地方

// 在响应setNeedsUpdateConstraints方法时，这个方法会被调用多次

// 此方法会被UIKit内部调用，或者在你触发约束更新时调用

这个常用于只更新部分约束，不会影响未更新部分约束。

**3、mas_remakeConstraints**

mas_updateConstraints只是去更新一些约束，然而有些时候修改一些约束值是没用的，这时候mas_remakeConstraints就可以派上用场了

mas_remakeConstraints某些程度相似于mas_updateConstraints，但不同于mas_updateConstraints去更新约束值，他会移除之前的view的所有约束，然后再去添加约束。

#### 举个例子

同样对上面UIScrollView的约束设置用masonry写一遍：

使用 Masonry 设置一个自己根据内容变化的竖向scrollview 

1、在scrollview 中添加一个contentView，edges equalTo scrollview

2、设置 contentView 的 width equalTo scrollview,height equalTo scrollview（低优先级）

```
[contentView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.scrollView);
    make.width.equalTo(self.scrollView);
}];
```

3、在contentView里面添加需要展示的内容并且上下各自equal ,左右 margin contentView 0

```
[labelOne makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(contentView);
}];
[labelTwo makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(labelOne.mas_bottom);
    make.left.right.equalTo(contentView);
}];
[labelThree makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(labelTwo.mas_bottom);
    make.left.right.equalTo(contentView);
}];
```

4、在添加完成最后一个后，把 contentView 的 bottom margin 更新到依赖最后一个view的 bottom

```
[contentView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labelThree.bottom);
}];
```

#### 其他内容

1、make.height.equalTo(@[greenView, blueView]);   //can pass array of attributes

2、make.center.equalTo(CGPointMake(0, 50));  、  make.size.equalTo(CGSizeMake(200, 100));

3、make.edges.equalTo(lastView).insets(UIEdgeInsetsMake(5, 10, 15, 20));

4、make.width.and.height.lessThanOrEqualTo(self.topView); greaterThanOrEqualTo

```
make.right.greaterThanOrEqualTo(self.topView.mas_right).offset(10) 
make.right.greaterThanOrEqualTo(self.topView.mas_right).offset(-10) 
以上两种方式都不能让UILabel距离右边保持10边距。使用
make.right.lessThanOrEqualTo(self.topView.mas_right).offset(-10) 

当类似 make.right.lessThanOrEqualTo(self.topView.mas_right).offset(-10) ; 这种情况时，要分清楚，右边距防止超出是使用负值进行处理,如果期望的是距离右边边距大于10的像素，那边要使用的是lessThanOrEqualTo处理。
```

5、兼容数组调用同一个约束设定

```
    [lowerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(10.0);
    }];

    [centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
    }];

    [raiseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
    }];
    
    self.buttonViews = @[ raiseButton, lowerButton, centerButton ];
    
    - (void)updateConstraints {
        [self.buttonViews updateConstraints:^(MASConstraintMaker *make) {
            make.baseline.equalTo(self.mas_centerY).with.offset(self.offset);
        }];
        [super updateConstraints];
	}
```

### 自适应布局

大神文档：[文档](http://blog.csdn.net/pucker/article/details/45149759)



## 其他布局相关内容

在开发过程里面其实会忽略很多xcode自带布局的小功能，特殊情况下使用起来还是很方便的。

### UIStackView的使用

开发过程中经常会碰到一种情况就是 某几个小组件 拼装成一块来使用，一般处理起来就是外面套一层View，然后各种约束控制我们的展示方式。如下图在约束编辑toolbar的 embed in stack 功能

![](https://xilankong.github.io/resource/stack.png)

举个例子：

我们需要把三个label作为一整行等分排放，按shift选中三个label，选择embed in stack，会发现 xcode 自动创建了一个包裹三个label的view，这就是 UIStackView。

UIStackView 是支持 iOS 9+

**属性**：

Axis ：布局方向，横向和竖向

Alignment：对齐方式，针对不同的布局方向，UIStackView有不同的对齐方式

**横向布局支持**：

Fill：横向排练，所有组件都没有设置高度约束的时候，按最高的那个高度，当个别有高度约束的时候按约束高度，当所有组件都有约束的时候按左右顺序。

Top：各自高度不会被改变，对齐顶部

Center：各自高度不会被改变，Y轴居中对齐

Bottom：各自高度不会被改变，对齐底部

FirstBaseLine：以第一个组件的基线,各自高度不会被改变

LastBaseLine：以最后一个组件的基线,各自高度不会被改变

**竖向布局支持**：

Fill：竖向排列，高度不变，所有组件都没有设置宽度约束的时候，按最大的那个宽度，当个别有宽度约束的时候按约束宽度，当所有组件都有约束的时候按上下顺序。

Leading: 各自宽高不变，依赖左边对齐

center：各自宽高不变，依赖Y轴中对齐

trailing：各自宽高不变，依赖右边对齐

**Distribution: 一些约束的描述**

Fill

Fill Equally

Fill Proportionally

Equal Spacing

Equal Centering

**spacing：间距**



### autoResizingMask使用

autoResizingMask 是UIView的一个属性，在一些简单的布局中，使用autoResizingMask，可以实现子控件相对于父控件的自动布局。

autoResizingMask 是UIViewAutoresizing 类型的，其定义为：

```
@property(nonatomic) UIViewAutoresizing autoresizingMask;    // simple resize. default is UIViewAutoresizingNone
```

UIViewAutoresizing 是一个枚举类型，默认是 UIViewAutoresizingNone,其可以取得值有：

```
typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {
    UIViewAutoresizingNone                 = 0,
    UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
    UIViewAutoresizingFlexibleWidth        = 1 << 1,
    UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
    UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
    UIViewAutoresizingFlexibleHeight       = 1 << 4,
    UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
```

各属性解释：

| UIViewAutoresizingNone                 | 不会随父视图的改变而改变              |
| -------------------------------------- | ------------------------- |
| UIViewAutoresizingFlexibleLeftMargin   | 自动调整view与父视图左边距，以保证右边距不变  |
| UIViewAutoresizingFlexibleWidth        | 自动调整view的宽度，保证左边距和右边距不变   |
| UIViewAutoresizingFlexibleRightMargin  | 自动调整view与父视图右边距，以保证左边距不变  |
| UIViewAutoresizingFlexibleTopMargin    | 自动调整view与父视图上边距，以保证下边距不变  |
| UIViewAutoresizingFlexibleHeight       | 自动调整view的高度，以保证上边距和下边距不变  |
| UIViewAutoresizingFlexibleBottomMargin | 自动调整view与父视图的下边距，以保证上边距不变 |

注意：autoResizingMask 既可以在代码中直接使用，也可以在UIStoryboard中使用。

另外，autoResizingMask 可以组合使用。例如：

```
button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
表示的是，子控件相对于父控件的顶部和右侧的距离不变。
```



### UITableView 碰上自动布局

UITableViewCell 如何 在不计算的情况下自适应高度,需要测试attributeString等耗时操作的影响

```
第一步  给tableView设置估值高度 不要设置rowHeight  rowHeight返回方法也不要
self.tableView.rowHeight = UITableViewAutomaticDimension;
self.tableView.estimatedRowHeight = 200;

第二步

 JDGGoldDetailCell *cell = [JDGGoldDetailCell cellWithTableView:tableView];
 //MARK:自动计算行高最关键的一步  cell一定要重新布局
 [cell layoutIfNeeded];

第三步

cell的layoutSubViews中更新cell内容 
- (void)layoutSubviews {
    [super layoutSubviews];

    [self.imgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(34);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.left.mas_equalTo(self.imgview.mas_right).offset(24);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(13);
        make.left.mas_equalTo(self.imgview.mas_right).offset(24);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-25);
        
        //MARK:自动计算行高第四步---根据大家反映,更新后的代码
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    
}
```



### UIView更新机制、UI渲染机制

约束的设置、更新不可避免的涉及到View的更新，简单了解一下更新机制能更好的使用约束。



**1、UIView的setNeedsDisplay和setNeedsLayout方法**

首先两个方法都是异步执行的。而setNeedsDisplay会调用自动调用drawRect方法，这样可以拿到  UIGraphicsGetCurrentContext，就可以画画了。而setNeedsLayout会默认调用layoutSubViews，
 就可以  处理子视图中的一些数据。

综上所诉，setNeedsDisplay方便绘图，而setNeedsLayout方便处理数据。

```
layoutSubviews在以下情况下会被调用：

1、init初始化不会触发layoutSubviews。
2、addSubview会触发layoutSubviews。
3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化。
4、滚动一个UIScrollView会触发layoutSubviews。
5、旋转Screen会触发父UIView上的layoutSubviews事件。
6、改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。
7、直接调用setLayoutSubviews。

drawRect在以下情况下会被调用：

 1、如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect调用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的.所以不用担心在控制器中,这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量值).
 
2、该方法在调用sizeToFit后被调用，所以可以先调用sizeToFit计算出size。然后系统自动调用drawRect:方法。

3、通过设置contentMode属性值为UIViewContentModeRedraw。那么将在每次设置或更改frame的时候自动调用drawRect:。

4、直接调用setNeedsDisplay，或者setNeedsDisplayInRect:触发drawRect:，但是有个前提条件是rect不能为0。

以上1,2推荐；而3,4不提倡

drawRect方法使用注意点：

1、若使用UIView绘图，只能在drawRect：方法中获取相应的contextRef并绘图。如果在其他方法中获取将获取到一个invalidate的ref并且不能用于画图。drawRect：方法不能手动显示调用，必须通过调用setNeedsDisplay 或者 setNeedsDisplayInRect，让系统自动调该方法。

2、若使用calayer绘图，只能在drawInContext: 中（类似于drawRect）绘制，或者在delegate中的相应方法绘制。同样也是调用setNeedDisplay等间接调用以上方法

3、若要实时画图，不能使用gestureRecognizer，只能使用touchbegan等方法来掉用setNeedsDisplay实时刷新屏幕
```

**2、layoutSubviews方法**

在UIView里面有一个方法layoutSubviews，这个方法具体作用是什么呢？

```
- (void)layoutSubviews; // override point. called by layoutIfNeeded automatically. As of iOS 6.0, when constraints-based layout is used the base implementation applies the constraints-based layout, otherwise it does nothing. 
```

**官方文档解释**

我们先来看看苹果官方文档的解释：

```
The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.

Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.

You should not call this method directly. If you want to force a layout update, call the setNeedsLayout method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the layoutIfNeeded method. 
```

最后一段说，不要直接调用此方法。如果你想强制更新布局，你可以调用setNeedsLayout方法；如果你想立即数显你的views，你需要调用layoutIfNeeded方法。

**layoutSubviews作用**

layoutSubviews是对subviews重新布局。比如，我们想更新子视图的位置的时候，可以通过调用layoutSubviews方法，既可以实现对子视图重新布局。

layoutSubviews默认是不做任何事情的，用到的时候，需要在子类进行重写。

**layoutSubviews以下情况会被调用**

苹果官方文档已经强调，不能直接调用layoutSubviews对子视图进行重新布局。那么，layoutSubviews什么情况下会被调用呢？通过百度搜索，发现以下几种情况layoutSubviews会被调用。

1. 直接调用setLayoutSubviews。（这个在上面苹果官方文档里有说明）
2. addSubview的时候。
3. 当view的frame发生改变的时候。
4. 滑动UIScrollView的时候。
5. 旋转Screen会触发父UIView上的layoutSubviews事件。
6. 改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。

我简单测试了一下，上面基本都会被调用。

```
注意：当view的fram的值为0的时候，`addSubview`也不会调用`layoutSubviews`的。
```

**3、常用更新方法**

setNeedsLayout：告知页面需要更新，但是不会立刻开始更新。执行后会立刻调用layoutSubviews。

layoutIfNeeded：告知页面布局立刻更新。所以一般都会和setNeedsLayout一起使用。如果希望立刻生成新的frame需要调用此方法，利用这点一般布局动画可以在更新布局后直接使用这个方法让动画生效。

layoutSubviews：系统重写布局

setNeedsUpdateConstraints：告知需要更新约束，但是不会立刻开始

updateConstraintsIfNeeded：告知立刻更新约束

updateConstraints：系统更新约束

### 自动布局中的约束优先级

UIView 有两个类别的content优先级

抗扩张优先级：Content Hugging Priority 确定view有多大的优先级阻止自己变大。 默认 250 （例如保证UIButton不会因为屏幕边距变大而拉伸按钮）。

抗压缩优先级：Content Compression Resistance Priority 确定有多大的优先级阻止自己变小。 默认 750（例如保证UILabel不会被挤压导致显示不全）优先级越大 越不会被压缩。

说这个之前先了解一些信息：

这两个属性对有intrinsic content size的控件（例如button，label）非常重要。通俗的讲，具有intrinsic content size的控件自己知道（可以计算）自己的大小，例如一个label，当你设置text，font之后，其大小是可以计算到的。

```
UIView中关于Content Hugging 和 Content Compression Resistance的方法

- (UILayoutPriority)contentHuggingPriorityForAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

- (void)setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

- (UILayoutPriority)contentCompressionResistancePriorityForAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);

- (void)setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis NS_AVAILABLE_IOS(6_0);
```


默认优先级情况下从左到右，从上到下优先。 默认情况下两边的label的Content Hugging和Content Compression优先级都是一样的。

**Q1 : 当一个View 高度需要根据内容来扩张，那么内部label 和 view的优先级怎么判断 有什么不同吗？**

**A1 : 没有, 根据优先级来。**

**测试出现的情况：**

1.当xib的View中加了两个默认的Label 并自动计算高度适配，再通过代码在底下继续加上Label 的时候 label需要更改收缩优先级来保证他完整显示。(依然未解)

2.但是直接在xib中加入多个label，并设定好约束，label会正常扩张，父view也会正常扩张。

3.在 2 的基础上 再在底下通过代码添加的label 设定好masonry约束 同样能正常显示，正常扩张

4.一个View中 由上到下分别是 label、label、view（里面有一个label） 的布局，自动布局也可以正常扩张

5.hidden 并不会影响约束

例子：

当一个view中有一个图片和一个label，我希望label来决定view的宽度，这个时候就需要把图片的抗压缩优先级设置到小于label的抗扩张优先级



## SnapKit 创建布局约束

```
testView.snp.updateConstraints {
            $0.bottom.equalTo(view).offset(-55)
}
```







## 自动布局的小纸条

遇见的自动布局的bug







## warning !

1、IOS 自动化布局 masonry autolayout  等 尽量别混用

2、多看看masonry 官方 demo

3、masonry 的约束优先级的作用  和content优先级有什么区别