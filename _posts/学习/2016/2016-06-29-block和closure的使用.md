---
layout: post
category: 学习之路
title : "block和closure的使用"
---

## 1.什么是block

在iOS 4.0之后，block横空出世，它本身封装了一段代码并将这段代码当做变量，通过block()的方式进行回调。

自从block出现之后，很多API都开始采用这样的结构，由此可见，block确实有许多优势存在，这里将一些简单用法总结如下：

### 1、如何声明一个block变量

我们通过^符号来声明block类型，形式如下：

```
void (^myBlock)();

其中第一个void是返回值，可以是任意类型，中间括号中^后面的是这个block变量的名字，我把它命名为myBlock，最后一个括号中是参数，如果多参数，可以写成如下样式：

int (^myBlock)(int,int);

同样，你也可以给参数起名字：

int (^myBlock)(int a,int b);

很多时候，我们需要将我们声明的block类型作为函数的参数，也有两种方式：

1、-(void)func:(int (^)(int a,int b))block；

第二种方式是通过typedef定义一种新的类型，这也是大多数情况下采用的方式：

2、typedef int (^myBlock)(int a,int b) ;

-(void)func:(myBlock)block ;

```



### 2、block特性

既然block可以被声明为变量，那么就一定可以实现它，就像其他类型变量的赋值。我自己对block的理解为它是一断代码块，所以给它赋值赋便是一段代码段：

```
typedef int (^myBlock)(int,int) ;
@interface ViewController ()
{
    myBlock block1;
}
@end
 
@implementation ViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    block1 =^(int a, int b){
        return a+b;
    };
   NSLog(@"%d",block1(1,1));
}
```

这里打印的结果是2，从这里可以发现block和函数的功能很像。
注意 :  1、在上面的代码里 block1是一个对象，如果直接打印将打印对象地址
            2、block()，加上后面的括号才是执行block语句块



### 3、block中访问对象的微妙关系

1、如果你在一个block块中仅仅访问对象，而不是对他进行修改操作，是没有任何问题的：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    int tem=2;
    block1 = ^(int a,int b){
        int count= tem+1;
        return count;
    };
    NSLog(@"%d",block1(1,1));
}
```

2、如果在block块中直接修改变量，编译器会报错：

```
 block1 = ^(int a,int b){
        tem+=1;
        return tem+1;
 };
为什么会出现这样的情况，根据猜测，可能是block内部将访问的变量都备份了一份，如果我们在内部修改，外部的变量并不会被修改，我们可以通过打印变量的地址来证明这一点：

- (void)setUp {
    int i = 1;
     NSLog(@"%p + out",&i);
    self.block = ^(int a,int b){
        NSLog(@"%p + inside",&i);
        return 1;
    };
    self.block(2,3);
}
打印结果如下：
2017-03-06 11:11:07.657 SwiftDemo[7890:9947536] 0x7fff535bba7c + out
2017-03-06 11:11:07.657 SwiftDemo[7890:9947536] 0x7fff535bba78 + inside

可以看出，变量的地址已经改变。
```

3、block在捕获变量的时候只会保存变量被捕获时的状态（对象变量除外），之后即便变量再次改变，block中的值也不会发生改变。


4、如何对外部变量进行修改，__block 做了什么

为了可以在block块中访问并修改外部变量，我们常会把变量声明成__block类型，通过上面的原理，可以发现，其实这个关键字只做了一件事，如果在block中访问没有添加这个关键字的变量，会访问到block自己拷贝的那一份变量，它是在block创建的时候创建的，而访问加了这个关键字的变量，则会访问这个变量的地址所对应的变量。我们可以通过代码来证明：

```
- (void)setUp {
    __block int i = 1;
     NSLog(@"%p + out",&i);
    self.block = ^(int a,int b){
        NSLog(@"%p + inside",&i);
        return 1;
    };
    self.block(2,3);
}

结果：
2017-03-06 11:17:16.438 SwiftDemo[8088:9950943] 0x7fff51ef0a78 + out
2017-03-06 11:17:16.439 SwiftDemo[8088:9950943] 0x7fff51ef0a78 + inside

由此，我们可以理解，如果block中操作的对象是指针，那么直接可以进行修改，这包括OC对象，如果不是，则需要用__block关键字修饰。
```



5、关于引用计数  

```
在block中访问的对象，会默认retain：

- (void)setUp {
    UIImage *image = [UIImage new];
    NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(image)));
    
    self.block = ^(int a,int b){
        NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(image)));
    };
    self.block(2,3);
}
结果如下：
2017-03-06 11:27:47.856 SwiftDemo[8494:9958586] 1
2017-03-06 11:27:47.856 SwiftDemo[8494:9958586] 3

而添加__block的对象不会被retain;

2017-03-06 13:41:02.850 SwiftDemo[8747:9968324] 1
2017-03-06 13:41:02.850 SwiftDemo[8747:9968324] 1

注意：如果我们访问类的成员变量，或者通过类方法来访问对象，那么这些对象不会被retain，而类对象会被retain，最常见的是在block中直接使用self会有warning：

! Capturing 'self' strongly in this block is likely to lead to a retain cycle

循环引用

block在iOS开发中被视作是对象，因此其生命周期会一直等到持有者的生命周期结束了才会结束。另一方面，由于block捕获变量的机制，使得持有block的对象也可能被block持有，从而形成循环引用，导致两者都不能被释放。导致内存泄露。所谓的内存泄露就是本应该释放的对象，在其生命周期结束之后依旧存在。

解决办法

系统提供给我们__weak的关键字用来修饰对象变量，声明这是一个弱引用的对象
__weak typeof(*&self) weakSelf = self;
```



```
typedef BOOL (^filterRule)(id item);
typedef NSArray *(^filterMethod)(filterRule rule);

@interface NSArray(FilterExtend)
@property (nonatomic, copy, readonly) filterMethod filterMethod;
@end

@implementation NSArray(FilterExtend)
-(filterMethod)filterMethod {
    filterMethod filte = (filterMethod)^(filterRule rule) {
        NSMutableArray *array = @[].mutableCopy;
        for (id item in self)
            if (rule(item)) {
                [array addObject:item];
            }
        return array;
    };
    return filte;
}
@end


///////////

NSArray * array = @[@"111",@"222",@"333",@"444",@"ff"];
NSArray *array_m = array.filterMethod((filterRule)^(id item){
    NSString *str = item;
    return str.length > 2;
});
NSLog(@"%@",array_m);
```

