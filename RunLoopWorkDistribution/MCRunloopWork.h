//
//  MCRunloopWork.h
//  MCMessageHub
//
//  Created by marco chen on 2017/1/18.
//  Copyright © 2017年 marco chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^MCRunLoopWorkUnit)(void);

typedef enum : NSUInteger {
    MCRunLoopEntry = kCFRunLoopEntry,//进入runloop时
    MCRunLoopBeforeTimers = kCFRunLoopBeforeTimers,//执行timer之前时
    MCRunLoopBeforeSources = kCFRunLoopBeforeSources,//执行sources之前时
    MCRunLoopBeforeWaiting = kCFRunLoopBeforeWaiting,//开始waiting之前时
    MCRunLoopAfterWaiting = kCFRunLoopAfterWaiting,//开始waiting之后时
    MCRunLoopExit = kCFRunLoopExit,//退出runloop时
    MCRunLoopAllActivities = kCFRunLoopAllActivities//所有的状态
}MCRunLoopFlag;//runloop的各种状态

typedef enum : NSUInteger {
    MCRunLoopDefaultMode = 0,
    MCRunLoopCommonMode
}MCRunlopMode;

@interface MCRunloopWork : NSObject
/*
 *  接受的最大任务队列,默认30个
 */
@property (nonatomic, assign) NSUInteger maximumQueueLength;
/*
 *  监听Runloop的状态属性,默认MCRunLoopBeforeWaiting
 */
@property (assign, nonatomic) MCRunLoopFlag runLoopflag;
/*
 *  监听Runloop的模式 
 *  默认MCRunLoopDefaultMode(kCFRunLoopDefaultMode) 系统渲染优先,当系统渲染结束才能执行我们需要的事件
 *  MCRunLoopCommonMode(kCFRunLoopCommonModes) 将timer插入runloop顶层提高优先级(使用后切勿将耗时操作加入任务,慎用)
 */
@property (assign, nonatomic) MCRunlopMode runlopMode;

+ (instancetype)sharedRunLoopWork;
/*
 *  开始监听Runloop
 */
- (void)start;
/*
 *  停止监听Runloop
 */
- (void)stop;
/*
 *  添加需要在Runloop中执行的任务
 */
- (void)addTask:(MCRunLoopWorkUnit)unit withKey:(id)key;
/*
 *  删除所有的队列
 */
- (void)removeAllTasks;

@end
