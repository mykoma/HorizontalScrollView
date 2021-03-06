//
//  ViewController.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "ViewController.h"
#import "GKVideoEditHorizontalView.h"
#import "GKVideoChunkCellModel.h"

@interface ViewController () <GKVideoEditHorizontalViewDelegate>

@property (nonatomic, strong) GKVideoEditHorizontalView * videoEditView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoEditView = [[GKVideoEditHorizontalView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    self.videoEditView.backgroundColor = [UIColor blackColor];
    self.videoEditView.delegate  = self;
    
    GKVideoChunkCellModel * model1 = [[GKVideoChunkCellModel alloc] init];
    model1.images = @[[UIImage imageNamed:@"1"], [UIImage imageNamed:@"2"]];
    model1.duration = 10;
    model1.beginTime = 3.0f;
    model1.endTime = 7.0f;
    
    GKVideoChunkCellModel * model2 = [[GKVideoChunkCellModel alloc] init];
    model2.images = @[[UIImage imageNamed:@"2"]];
    model2.duration = 3;
    
    GKVideoChunkCellModel * model3 = [[GKVideoChunkCellModel alloc] init];
    model3.images = @[[UIImage imageNamed:@"1"], [UIImage imageNamed:@"2"]];
    model3.duration = 8;
    
    GKVideoChunkCellModel * model4 = [[GKVideoChunkCellModel alloc] init];
    model4.duration = 12;
    model4.images = @[[UIImage imageNamed:@"2"], [UIImage imageNamed:@"1"]];
    
    [self.videoEditView.viewModel.chunkCellModels addObject:model1];
    [self.videoEditView.viewModel.chunkCellModels addObject:model2];
    [self.videoEditView.viewModel.chunkCellModels addObject:model3];
    [self.videoEditView.viewModel.chunkCellModels addObject:model4];
    
    [self.view addSubview:self.videoEditView];
    
    [self addBtns];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.videoEditView loadData];
}

- (void)addBtns
{
    UIButton * playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    playBtn.backgroundColor = [UIColor redColor];
    playBtn.frame = CGRectMake(0, CGRectGetMaxY(self.videoEditView.frame) + 10, 50, 30);
    [self.view addSubview:playBtn];
    
    [playBtn addTarget:self
                action:@selector(play)
      forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * removeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    removeBtn.backgroundColor = [UIColor magentaColor];
    removeBtn.frame = CGRectMake(CGRectGetMaxX(playBtn.frame) + 10, CGRectGetMaxY(self.videoEditView.frame) + 10, 50, 30);
    [self.view addSubview:removeBtn];
    
    [removeBtn addTarget:self
                  action:@selector(remove)
        forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * splitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    splitBtn.backgroundColor = [UIColor yellowColor];
    splitBtn.frame = CGRectMake(CGRectGetMaxX(removeBtn.frame) + 10, CGRectGetMaxY(self.videoEditView.frame) + 10, 50, 30);
    [self.view addSubview:splitBtn];
    
    [splitBtn addTarget:self
                  action:@selector(split)
        forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    resetBtn.backgroundColor = [UIColor blueColor];
    resetBtn.frame = CGRectMake(CGRectGetMaxX(splitBtn.frame) + 10, CGRectGetMaxY(self.videoEditView.frame) + 10, 50, 30);
    [self.view addSubview:resetBtn];
    
    [resetBtn addTarget:self
                 action:@selector(reset)
       forControlEvents:UIControlEventTouchUpInside];
}

static NSTimeInterval timeOffset = 0.0f;

static NSTimeInterval timeInterval = 1.0f / 60;

- (void)update
{
    [self.videoEditView updateCurrentFrameToTimeInterval:timeOffset];
    
    timeOffset += timeInterval;
}

- (void)play
{
    [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                     target:self
                                   selector:@selector(update)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)remove
{
    [self.videoEditView removeSelectedCell];
}

- (void)split
{
    [self.videoEditView splitCellAtCurrentFrame];
}

- (void)reset
{
    [self.videoEditView resetToNormalState];
}

#pragma mark - GKVideoEditHorizontalViewDelegate

- (void)scrollAreaBeganScrollByManual
{
    NSLog(@"Began Scroll By Manual.");
}

- (void)timeIntervalAtCurrentFrame:(CGFloat)timeInterval
{
    NSLog(@"time   %f", timeInterval);
}

- (void)chunkCellDidDeleteAtIndex:(NSInteger)index
{
    NSLog(@"Did Delete At   %ld", index);
}

- (void)chunkCellMovedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSLog(@"Moved from   %ld   to %ld", fromIndex, toIndex);
}

- (void)didTouchAddChunk
{
    NSLog(@"didTouchAddChunk");
    GKVideoChunkCellModel * model = [[GKVideoChunkCellModel alloc] init];
    model.duration = 5;
    model.images = @[[UIImage imageNamed:@"2"]];
    [self.videoEditView addChunkCellModel:model];
}

- (void)didTouchDownBackground
{
    NSLog(@"didTouchDownBackground");
}

- (void)didChangeToState:(GKVideoHorizontalState)state
{
    NSLog(@"didChangeToState   %ld", state);
}

- (void)chunkCellOfCurrentFrameChangedAtIndex:(NSInteger)index
{
    NSAssert(index == self.videoEditView.selectedIndex, @"");
    NSLog(@"chunkCellOfCurrentFrameChangedAtIndex  %ld    state:%ld", index, self.videoEditView.state);
}

- (void)didEditChunkCellAtIndex:(NSInteger)index
                      beginTime:(NSTimeInterval)beginTime
                        endTime:(NSTimeInterval)endTime
{
    NSLog(@"didEditChunkCellAtIndex: %ld  beginTime  %lf  endTime %lf", index, beginTime, endTime);
}

- (void)didSplitAtIndex:(NSInteger)index atTime:(NSTimeInterval)time
{
    NSLog(@"didSplitAtIndex   %ld atTime: %lf", index, time);
}

- (void)couldSplitAtCurrentFrame:(BOOL)couldSplit
{
    NSLog(@"couldSplitAtCurrentFrame  %d", couldSplit);
}

@end
