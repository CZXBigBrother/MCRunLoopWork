简书地址:http://www.jianshu.com/p/2db318d68e7e

###这次主要讲的Runloop的实际应用,基础的内容就不在这介绍了,详细的文章可以查看[深入理解RunLoop](http://blog.ibireme.com/2015/05/18/runloop/)

![RunLoop_1.png](http://upload-images.jianshu.io/upload_images/3258209-19e2888899adddd6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

RunLoop 内部的逻辑大致就是上图的这样.
主线程中执行事件如滑动事件触摸事件等等都在3~5中执行,如果我们将其他大量的操作都放其中肯定会导致界面卡顿.
其实我们也可以将一些操作放在子线程中,需要渲染时再回到线程渲染效果也是可以的.
##好吧,现在开始正式介绍实现的方法:

![Snip20170119_40.png](http://upload-images.jianshu.io/upload_images/3258209-37e37530ba26617a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

因为runloop相当于一个while循环的东西,每当事件都处理完之后就进入休眠状态,当有新的任务加入才会重新唤醒,这就是我们需要利用的地方,runloop进入7之后说明当前所有的事件都已经结束了,所以在这个时候执行我们的需要的任务就不会影响到之前任务的刷新.
因为苹果提供了监听runloop状态的方法,所以我可以通过监听实现
####下面的代码只是给大家一个思路,具体实现可以去下载Demo
* 第一步添加runloop监听
```
static void _registerObserver(CFOptionFlags activities, CFRunLoopObserverRef observer, CFIndex order, CFStringRef mode, void *info, CFRunLoopObserverCallBack callback) {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,
        info,
        &CFRetain,
        &CFRelease,
        NULL
    };
    observer = CFRunLoopObserverCreate(     NULL,
                                            activities,
                                            YES,
                                            order,
                                            callback,
                                            &context);
    CFRunLoopAddObserver(runLoop, observer, mode);
    CFRelease(observer);
}
```
* 苹果提供了一下的监听状态,我们可以选择kCFRunLoopBeforeWaiting当正要进入休眠状态时执行,这样不需要重新唤醒
```
/* Run Loop Observer Activities */
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry = (1UL << 0),
    kCFRunLoopBeforeTimers = (1UL << 1),
    kCFRunLoopBeforeSources = (1UL << 2),
    = (1UL << 5),
    kCFRunLoopAfterWaiting = (1UL << 6),
    kCFRunLoopExit = (1UL << 7),
    kCFRunLoopAllActivities = 0x0FFFFFFFU
};
```

*  这里就是我的得到监听结果之后回调的方法,我们可以将需要执行的代码写到block中,然后加入数组中,每次runloop执行结束就执行一个

```
static void _runLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
  这里就是我的得到监听结果之后回调的方法,我们可以将需要执行的代码写到block中,然后加入数组中,每次runloop执行结束就执行一个
}
```

#如解释有误欢迎指正~
#特此鸣谢diwu大神
思路基本照搬大神的Demo,[diwu大神的github](https://github.com/diwu)大神虽然是中国人但是英文太好,文档都是英文的,而且demo没有写注解,特地写了一份带中文注解的库,随带稍微优化了性能大家也可以看看的我优化后的库喜欢就给个Star呗
[优化+注解后的库:https://github.com/CZXBigBrother/MCRunLoopWork,也保留了原来的库](https://github.com/CZXBigBrother/MCRunLoopWork)

>DWURunLoopWorkDistribution 是大神原来写的类
MCRunloopWork 这是我优化之后的类,添加了一些方法和配置选项,方便在更多场景下使用
