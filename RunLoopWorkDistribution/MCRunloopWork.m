//
//  MCRunloopWork.m
//  MCMessageHub
//
//  Created by marco chen on 2017/1/18.
//  Copyright © 2017年 marco chen. All rights reserved.
//

#import "MCRunloopWork.h"


@interface MCRunloopWork ()

/*
 *  任务队列
 */
@property (nonatomic, strong) NSMutableArray *tasks;
/*
 *  任务标示队列
 */
@property (nonatomic, strong) NSMutableArray *tasksKeys;
/*
 *  时间钟
 */
@property (nonatomic, strong) NSTimer *timer;


@property (assign, nonatomic) CFRunLoopObserverRef observer;

@end

@implementation MCRunloopWork

- (void)removeAllTasks {
    [self.tasks removeAllObjects];
    [self.tasksKeys removeAllObjects];
}

- (void)addTask:(MCRunLoopWorkUnit)unit withKey:(id)key{
    [self addTimer];
    [self.tasks addObject:unit];
    [self.tasksKeys addObject:key];
    if (self.tasks.count > self.maximumQueueLength) {
        [self.tasks removeObjectAtIndex:0];
        [self.tasksKeys removeObjectAtIndex:0];
    }
}
- (instancetype)init
{
    if ((self = [super init])) {
        self.maximumQueueLength = 30;
        self.tasks = [NSMutableArray array];
        self.tasksKeys = [NSMutableArray array];
        self.runLoopflag = MCRunLoopBeforeWaiting;
        self.runlopMode = 0;
        
    }
    return self;
}
- (void)addTimer
{
    if(self.timer) return;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFiredMethod:) userInfo:nil repeats:YES];
    
}
-(void)stopTimer
{
    [self.timer invalidate];
    self.timer=nil;
}
- (void)timerFiredMethod:(NSTimer *)timer {}

+ (instancetype)sharedRunLoopWork {
    static MCRunloopWork *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[MCRunloopWork alloc] init];
    });
    return singleton;
}
- (void)start {
    [self registerRunLoopWorkDistributionAsMainRunloopObserver];
}
- (void)stop {
    [self removeRunLoopWorkDistributionAsMainRunloopObserver];
}
/*
 *  注册runloop
 */
- (void)registerRunLoopWorkDistributionAsMainRunloopObserver {
    [self setupRunLoopObserverCreate];
    registerObserver(self.observer, self.runlopMode ? kCFRunLoopCommonModes : kCFRunLoopDefaultMode);
}
/*
 *  取消注册
 */
- (void)removeRunLoopWorkDistributionAsMainRunloopObserver {
    removeObserver(self.observer, self.runlopMode ? kCFRunLoopCommonModes : kCFRunLoopDefaultMode);
    CFRelease(self.observer);
}
- (void)setupRunLoopObserverCreate {
    if (self.observer) {return;}
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    self.observer = CFRunLoopObserverCreate(NULL,
                                            self.runLoopflag,
                                            YES,
                                            NSIntegerMax - 999,
                                            &defaultModeRunLoopWorkDistributionCallback,
                                            &context);
}
/*
 * 注册runloop监听
 */
static void registerObserver(CFRunLoopObserverRef observer,CFStringRef mode) {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddObserver(runLoop, observer, mode);
}

/*
 * 删除runloop监听
 */
static void removeObserver(CFRunLoopObserverRef observer,CFRunLoopMode mode) {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopRemoveObserver(runLoop, observer, mode);
}
/*
 *  接受到监听执行的方法
 */
static void defaultModeRunLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    runLoopWorkDistributionCallback(observer, activity, info);
}
static void runLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    MCRunloopWork *runLoopWorkDistribution = (__bridge MCRunloopWork *)info;
    if (runLoopWorkDistribution.tasks.count == 0) {
        [runLoopWorkDistribution stopTimer];
        return;
    }
    BOOL result = NO;
    while (result == NO && runLoopWorkDistribution.tasks.count) {
        MCRunLoopWorkUnit unit  = runLoopWorkDistribution.tasks.firstObject;
        result = unit();
        [runLoopWorkDistribution.tasks removeObjectAtIndex:0];
        [runLoopWorkDistribution.tasksKeys removeObjectAtIndex:0];
    }
}
@end
