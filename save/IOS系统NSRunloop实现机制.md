#RunLoop

##什么是RunLoop

NSRunLoop是消息机制的处理模式。他的作用在于有事情做的时候使当前的NSRunLoop线程工作，没有事情做的时候，让当前的NSRunLoop休眠。

NSRunLoop就是一直在循环检测，从线程start到线程end，检测inputsource同步事件。

程序启动时，系统已经在主线程中加了RunLoop。他保证我们的主线程在运行起来后，就处于一种“等待”的状态，而不像一些命令行程序一样运行一次就结束，这个时候如果有接受到的事件，就会执行任务，否则就处于休眠状态。

##RunLoop 相关类
###CFRunLoopRef
代表一个RunLoop对象

###CFRunLoopModeRef
####1、代表RunLoop的运行模式
* 一个RunLoop包含若干个Mode，每个Mode又包含若干个Source/Timer/Observer
* 每次RunLoop启动，只能指定一个mode，如需切换mode，只能退出runloop，重新指定
* ![RunLoopMode](/Users/LF/Documents/MacDown-Documents/RunLoop/RunLoopMode.png)

####2、苹果内部提供了五种模式
* NSDefaultRunLoopMode（默认mode，通常主线程都是在这个mode下运行）
* UITrackingRunLoopMode（界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响）
* UIInitializationRunLoopMode（在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用）
* GSEventReceiveRunLoopMode（接收系统事件的内部mode，几乎用不到）
* NSRunLoopCommonModes

当相应的模式传递给runloop时，只能与该模式对应的input sources才能被监控并允许runloop对事件进行处理。举个经典的例子:

* 在timer和tableView同时运行的情况下，当拖动tableView，RunLoop将进入UITrackingRunLoopModes模式，这是如果timer是默认的NSDefaultRunLoopMode模式，timer将不会继续执行。将timer添加进UITrackingRunLoopModes或者CommonMode模式将解决这个问题。

###CFRunLoopSourceRef
用来管理所有事件的事件源，包括自定义事件，以及系统自带的事件

Source 有两个版本：Source0 和 Source1

* Source0 --- 为用户触发的事件（使用时，你需要先调用CFRunLoopSourceSignal（source），将这个Source标记为待处理，然后手动调用CFRunLoopWakeUp（runloop）来唤醒Runloop，让其处理这个事件）
* Source1 --- 通过内核和其他线程相互发送消息（Source能主动唤醒Runloop的线程）

###CFRunLoopTimerRef
CFRunLoopTimerRef和NSTimer是toll-free bridged，NSTimer是基于CFRunLoopTimerRef的封装，提供了面向对象的API。

###CFRunLoopObserverRef
####用来监听RunLoop的状态改变
####状态列表
* kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
* kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
* kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
* kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
* kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
* kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
* kCFRunLoopAllActivities = 0x0FFFFFFFU //所有状态


##RunLoop--启动与退出
根据官方文档对runloop启动的介绍，他一共有三种启动方式：

- Unconditionally（无条件的）
- With a set time limit（设置一个时间）
- In a particular mode（可以设定mode）

上面三种启动方式对应的三种方式如下：

- run
- runUntilDate
- runMode:beforeDate:


###启动

#### run方法
   运行NSRunLoop，运行模式为默认的NSDefaultRunLoopMode模式，没有超时限制，因为无条件运行。
   
   本质是无限调用runMode:beforeDate:
   
   不建议使用，因为这个接口会导致RunLoop永久性的运行在NSDefaultRunLoopMode模式，即使使用CFRunLoopStop(runloopRef)，也无法停止RunLoop的运行，那么这个子线程就无法停止，只能永久运行下去。结束runloop的唯一方式就是kill它。
   
#### runUntilDate方法

运行 NSRunLoop: 参数为运时间期限，运行模式为默认的NSDefaultRunLoopMode模式，自己设置的Run Loop运行时间，超时就退出。

本质是重复调用runMode:beforeDate:，只不过超时了就不调用了。

#### runMode:beforeDate:方法

此方法有返回值（BOOL）

mode：指定runloop模式来处理输入源

limitDate:设置为NSDate distantFuture，所以除非处理其他输入源结束，否则永不退出处理暂停的当前处理的流程

return BOOL:   返回值为YES表示是处理事件后返回的，NO表示是超时或者停止运行导致返回的


### 退出

相比较于启动，RunLoop退出就比较简单了，只有两种：

- 设置超时时间
- 手动结束

第一种方法就是设置超时时间。

第二种方法我们可以使用CFRunLoopStop()方法来手动结束一个runloop。

但是我们用这个去退出由第一种方法启动的runloop的时候，我们会发现根本无法终结。原因如下：

 The difference is that you can use this technique on run loops you started unconditionally.
 
 If you want the run loop to terminate, you shouldn't use this method
 
这是官方文档写的，总的来说，如果想从runloop里面退出来，就不能用run方法。因为CFRunLoopStop()方法置灰结束当前的runMode:beforeDate:调用，而不会结束后续的调用。

##RunLoop与线程的关系
RunLoop的管理并不是自动运行的，你需要编写线程代码去开始一个RunLoop，并在合适的实际响应事件。

你可以通过 pthread_ main_ thread_ np() 、pthread_ self() 或 [NSThread currentThread] 来获取当前线程。CFRunLoop 是基于 pthread 来管理的。苹果不允许直接创建 RunLoop，它只提供了两个自动获取的函数：CFRunLoopGetMain() 和 CFRunLoopGetCurrent()。 这两个函数内部的逻辑大概是下面这样:

~~~
static CFMutableDictionaryRef loopsDic;
static CFSpinLock_t loopsLock;

CFRunLoopRef _CFRunLoopGet(pthread_t thread) {
    OSSpinLockLock(&loopsLock);
    if (!loopsDic) {
        // 第一次进入时，初始化全局Dic，并先为主线程创建一个 RunLoop。
        loopsDic = CFDictionaryCreateMutable();
        CFRunLoopRef mainLoop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, pthread_main_thread_np(), mainLoop);
    }
    // 直接从 Dictionary 里获取。
    CFRunLoopRef loop = CFDictionaryGetValue(loopsDic, thread));

    if (!loop) {
        loop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, thread, loop);
        // 注册一个回调，当线程销毁时，顺便也销毁其对应的 RunLoop。
        _CFSetTSD(..., thread, loop, __CFFinalizeRunLoop);
    }

    OSSpinLockUnLock(&loopsLock);
    return loop;
}

CFRunLoopRef CFRunLoopGetMain() {
    return _CFRunLoopGet(pthread_main_thread_np());
}

CFRunLoopRef CFRunLoopGetCurrent() {
    return _CFRunLoopGet(pthread_self());
}
~~~

* 线程刚创建的时候并没有RunLoop，如果你不主动去获取，那它一直都不会有。
* runloop退出的条件：app退出；线程关闭；设置最大时间到期；modeItem为空


##RunLoop事件队列
每次运行RunLoop，你线程的RunLoop都会自动处理之前未处理的消息，并通知相关的观察者。具体的顺序如下：

~~~
1、通知观察者run loop已经启动
2、通知观察者任何即将要开始的定时器
3、通知观察者任何即将启动的非基于端口的源
4、启动任何准备好的非基于端口的源
5、如果基于端口的源准备好并处于等待状态，立即启动；并进入步骤9。
6、通知观察者线程进入休眠
7、将线程置于休眠直到任一下面的事件发生：
* 某一事件到达基于端口的源
* 定时器启动
* Run loop设置的时间已经超时
* run loop被显式唤醒
8、通知观察者线程将被唤醒。
9、处理未处理的事件
* 如果用户定义的定时器启动，处理定时器事件并重启run loop。进入步骤2
* 如果输入源启动，传递相应的消息
* 如果run loop被显式唤醒而且时间还没超时，重启run loop。进入步骤2
10、通知观察者run loop结束。
~~~

因为定时器和观察者是在相应事件发生之前传递消息的，所以通知的时间和实际发生的时间之间可能存在误差！

从这个队列中，我们可以看出：

* 如果是事件到达，消息会被传递给相应的处理程序来处理， runloop处理完当次事件后，run loop会退出，而不管之前预定的时间到了没有。你可以重新启动run loop来等待下一事件。
* 如果线程中有需要处理的源，但是响应的事件没有到来的时候，线程就会休眠等待相应事件的发生。这就是为什么run loop可以做到让线程有工作的时候忙于工作，而没工作的时候处于休眠状态。

##RunLoop使用场景
仅当在为你的程序创建辅助线程的时候，你才需要显式运行一个run loop。Run loop是程序主线程基础设施的关键部分。所以，Cocoa和Carbon程序提供了代码运行主程序的循环并自动启动run loop。IOS程序中UIApplication的run方法（或Mac OS X中的NSApplication）作为程序启动步骤的一部分，它在程序正常启动的时候就会启动程序的主循环。类似的，RunApplicationEventLoop函数为Carbon程序启动主循环。如果你使用xcode提供的模板创建你的程序，那你永远不需要自己去显式的调用这些例程。

对于辅助线程，你需要判断一个run loop是否是必须的。如果是必须的，那么你要自己配置并启动它。你不需要在任何情况下都去启动一个线程的run loop。比如，你使用线程来处理一个预先定义的长时间运行的任务时，你应该避免启动run loop。Run loop在你要和线程有更多的交互时才需要，比如以下情况：

1、使用端口或自定义输入源来和其他线程通信
2、使用线程的定时器
3、Cocoa中使用任何performSelector…的方法
4、使线程周期性工作

* 使用port或input sources和其他线程通信（这个还不是很了解）
* 在线程中使用timer（如果不启动runloop，timer是不会响应的）
* 使用performSelector（这个应该是会启动一个新线程，然后运行runloop）
* 让线程执行一个周期性任务

##实例

###利用RunLoop空闲时间执行预缓存任务

TableViewCell的高度缓存是一个优化功能，他要求页面处于空闲状态时才执行计算，当用户正在滑动列表时显然不应该执行计算任务影响滑动体验。

其中一种方法是，根据UITabelView的滑动状态来判断，但是这种实现十分不优雅，而且可能会破坏UITableViewDelegate结构。在此，我们将使用RunLoop工具，了解它的运行机制后，可以用较简单的代码实现上述功能。

####空闲时间
当用户滑动UITableView的时候，RunLoop将切换到UITrackingRunLoopMode接受滑动手势和处理滑动事件（包括减速和弹簧效果），此时，其他Mode（除NSRunLoopCommonModes这个组合Mode）下的时间将全部暂停执行，来保证滑动事件的优先处理，这也是iOS滑动顺畅的重要原因。

当UI没在滑动时，默认的Mode是NSDefaultRunLoopMode（同CF中的kCFRunLoopDefaultMode），同时也是CF中定义的“空闲状态Mode”。当用户啥也不点，此时也没有什么网络 IO时，就是在这个Mode下。

####用RunLoopObserver找准时机

注册RunLoopObserver可以观测当前RunLoop的运行状态，并在状态机切换时收到通知：

    - RunLoop开始
    - RunLoop即将处理Timer
    - RunLoop即将处理Source
    - RunLoop即将进入休眠状态
    - RunLoop即将从休眠状态被事件唤醒
    - RunLoop退出

因为 “预缓存高度” 的任务需要在最无感知的时刻进行，所以应该同时满足：

- RunLoop处于 “空闲” 状态Mode
- 当这次RunLoop迭代处理完所有事件，马上要休眠时。

### AFNetWorking

[AFNetWorking && RunLoop](http://vizlabxt.github.io/blog/2012/11/30/Runloop-in-AFNetworking/)

###界面刷新

当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次时，或者手动调用了 UIView/CALayer 的 setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去

###NSTimer
 一个NSTimer注册到RunLoop后，runLoop会为其重复的时间点注册号时间，runLoop
为了节省资源，并不会再非常准确的时间点回调这个timer。timer有个属性叫做tolerance
（宽容度），表示当时间点后，容许有多少最大误差。

~~~
NSTimer常用的两个方法：
1、+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo; //生成timer但不执行

2、 + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo; //生成timer并且纳入当前线程的run loop来执行

主线程上有runloop，所以NSTimer一般在主线程上运行都不必再调用addTimer。但是如果在非主线程上调用，就必须配置runloop，不然timer不能启动。
~~~

###PerformSelector
当调用NSObject的PerformSelector方法后，实际上其内部会创建一个timer并添加
到当前线程的runLoop中，如果当前线程没有runLoop，则这个方法会失效。


##代码实现
~~~
// RunLoop的实现
int CFRunLoopRunSpecific(runloop, modeName, seconds, stopAfterHandle) {

    // 0.1 根据modeName找到对应mode
    CFRunLoopModeRef currentMode = __CFRunLoopFindMode(runloop, modeName, false);
    // 0.2 如果mode里没有source/timer/observer, 直接返回。
    if (__CFRunLoopModeIsEmpty(currentMode)) return;

    // 1.1 通知 Observers: RunLoop 即将进入 loop。---（OB会创建释放池）
    __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopEntry);

    // 1.2 内部函数，进入loop
    __CFRunLoopRun(runloop, currentMode, seconds, returnAfterSourceHandled) {

        Boolean sourceHandledThisLoop = NO;
        int retVal = 0;
        do {

            // 2.1 通知 Observers: RunLoop 即将触发 Timer 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeTimers);
            // 2.2 通知 Observers: RunLoop 即将触发 Source0 (非port) 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeSources);
            // 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);

            // 2.3 RunLoop 触发 Source0 (非port) 回调。
            sourceHandledThisLoop = __CFRunLoopDoSources0(runloop, currentMode, stopAfterHandle);
            // 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);

            // 2.4 如果有 Source1 (基于port) 处于 ready 状态，直接处理这个 Source1 然后跳转去处理消息。
            if (__Source0DidDispatchPortLastTime) {
                Boolean hasMsg = __CFRunLoopServiceMachPort(dispatchPort, &msg)
                if (hasMsg) goto handle_msg;
            }

            // 3.1 如果没有待处理消息，通知 Observers: RunLoop 的线程即将进入休眠(sleep)。--- (OB会销毁释放池并建立新释放池)
            if (!sourceHandledThisLoop) {
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
            }

            // 3.2. 调用 mach_msg 等待接受 mach_port 的消息。线程将进入休眠, 直到被下面某一个事件唤醒。
            // -  一个基于 port 的Source1 的事件。
            // -  一个 Timer 到时间了
            // -  RunLoop 启动时设置的最大超时时间到了
            // -  被手动唤醒
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort) {
                mach_msg(msg, MACH_RCV_MSG, port); // thread wait for receive msg
            }

            // 3.3. 被唤醒，通知 Observers: RunLoop 的线程刚刚被唤醒了。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopAfterWaiting);

            // 4.0 处理消息。
            handle_msg:

            // 4.1 如果消息是Timer类型，触发这个Timer的回调。
            if (msg_is_timer) {
                __CFRunLoopDoTimers(runloop, currentMode, mach_absolute_time())
            } 

            // 4.2 如果消息是dispatch到main_queue的block，执行block。
            else if (msg_is_dispatch) {
                __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            } 

            // 4.3 如果消息是Source1类型，处理这个事件
            else {
                CFRunLoopSourceRef source1 = __CFRunLoopModeFindSourceForMachPort(runloop, currentMode, livePort);
                sourceHandledThisLoop = __CFRunLoopDoSource1(runloop, currentMode, source1, msg);
                if (sourceHandledThisLoop) {
                    mach_msg(reply, MACH_SEND_MSG, reply);
                }
            }

            // 执行加入到Loop的block
            __CFRunLoopDoBlocks(runloop, currentMode);


            // 5.1 如果处理事件完毕，启动Runloop时设置参数为一次性执行,设置while参数退出Runloop
            if (sourceHandledThisLoop && stopAfterHandle) {
                retVal = kCFRunLoopRunHandledSource;
            // 5.2 如果启动Runloop时设置的最大运转时间到期，设置while参数退出Runloop
            } else if (timeout) {
                retVal = kCFRunLoopRunTimedOut;
            // 5.3 如果启动Runloop被外部调用强制停止，设置while参数退出Runloop
            } else if (__CFRunLoopIsStopped(runloop)) {
                retVal = kCFRunLoopRunStopped;
            // 5.4 如果启动Runloop的modeItems为空，设置while参数退出Runloop
            } else if (__CFRunLoopModeIsEmpty(runloop, currentMode)) {
                retVal = kCFRunLoopRunFinished;
            }

            // 5.5 如果没超时，mode里没空，loop也没被停止，那继续loop，回到第2步循环。
        } while (retVal == 0);
    }

    // 6. 如果第6步判断后loop退出，通知 Observers: RunLoop 退出。--- (OB会销毁新释放池)
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
}
~~~

##函数栈显示

~~~
{
    // 1.1 通知Observers，即将进入RunLoop
    // 此处有Observer会创建AutoreleasePool: _objc_autoreleasePoolPush();
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopEntry);
    do {

        // 2.1 通知 Observers: 即将触发 Timer 回调。
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeTimers);
        // 2.2 通知 Observers: 即将触发 Source (非基于port的,Source0) 回调。
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeSources);
         // 执行Block
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);

        // 2.3 触发 Source0 (非基于port的) 回调。
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__(source0);
        // 执行Block
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);

        // 3.1 通知Observers，即将进入休眠
        // 此处有Observer释放并新建AutoreleasePool: _objc_autoreleasePoolPop(); _objc_autoreleasePoolPush();
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeWaiting);

        // 3.2 sleep to wait msg.
        mach_msg() -> mach_msg_trap();

        // 3.3 通知Observers，线程被唤醒
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopAfterWaiting);

        // 4.1 如果是被Timer唤醒的，回调Timer
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__(timer);

        // 4.2 如果是被dispatch唤醒的，执行所有调用 dispatch_async 等方法放入main queue 的 block
        __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(dispatched_block);

        // 4.3 如果如果Runloop是被 Source1 (基于port的) 的事件唤醒了，处理这个事件
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__(source1);

        // 5. 退出判断函数调用栈无显示
    } while (...);

    // 6. 通知Observers，即将退出RunLoop
    // 此处有Observer释放AutoreleasePool: _objc_autoreleasePoolPop();
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopExit);
~~~