//
//  ViewController.m
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/19/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

#import "ViewController.h"
#import "DWURunLoopWorkDistribution.h"
#import "MCRunloopWork.h"

static NSString *IDENTIFIER = @"IDENTIFIER";

static CGFloat CELL_HEIGHT = 135.f;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *exampleTableView;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[MCRunloopWork sharedRunLoopWork]start];
    [self.exampleTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFIER];
    
//    DWURunLoopWorkDistribution.h 是大神原来写的类
//    MCRunloopWork.h 这是我优化之后的类,添加了一些方法和配置选项,方便在更多场景下使用
}
- (void)loadView {
    self.view = [UIView new];
    self.exampleTableView = [UITableView new];
    self.exampleTableView.delegate = self;
    self.exampleTableView.dataSource = self;
    [self.view addSubview:self.exampleTableView];
    
    UIButton * stopBtn = [[UIButton alloc]initWithFrame:(CGRect){CGPointZero,{60,60}}];
    [stopBtn addTarget:self action:@selector(stopRunloop) forControlEvents:UIControlEventTouchUpInside];
    [stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    [stopBtn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:stopBtn];
}
- (void)stopRunloop {
    [[MCRunloopWork sharedRunLoopWork]stop];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.exampleTableView.frame = self.view.bounds;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.currentIndexPath = indexPath;
    [ViewController task_5:cell indexPath:indexPath];
    [ViewController task_1:cell indexPath:indexPath];
    //任务通过block添加到队列
    [[MCRunloopWork sharedRunLoopWork] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            return NO;
        }
        [ViewController task_2:cell indexPath:indexPath];
        return YES;
    } withKey:indexPath];
    [[MCRunloopWork sharedRunLoopWork] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            return NO;
        }
        [ViewController task_3:cell indexPath:indexPath];
        return YES;
    } withKey:indexPath];
    [[MCRunloopWork sharedRunLoopWork] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            return NO;
        }
        [ViewController task_4:cell indexPath:indexPath];
        return YES;
    } withKey:indexPath];
    return cell;
}
+ (void)task_5:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    for (NSInteger i = 1; i <= 5; i++) {
        [[cell.contentView viewWithTag:i] removeFromSuperview];
    }
}

+ (void)task_1:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor redColor];
    label.text = [NSString stringWithFormat:@"%zd - Drawing index is top priority", indexPath.row];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.tag = 1;
    [cell.contentView addSubview:label];
}

+ (void)task_2:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(105, 20, 85, 85)];
    imageView.tag = 2;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:imageView];
    } completion:^(BOOL finished) {
    }];
}

+ (void)task_3:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 20, 85, 85)];
    imageView.tag = 3;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:imageView];
    } completion:^(BOOL finished) {
    }];
}

+ (void)task_4:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 99, 300, 35)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0 green:100.f/255.f blue:0 alpha:1];
    label.text = [NSString stringWithFormat:@"%zd - Drawing large image is low priority. Should be distributed into different run loop passes.", indexPath.row];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.tag = 4;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 85, 85)];
    imageView.tag = 5;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:imageView];
    } completion:^(BOOL finished) {
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 399;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}



@end
