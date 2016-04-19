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
    
    UIButton * divideBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    divideBtn.backgroundColor = [UIColor yellowColor];
    divideBtn.frame = CGRectMake(CGRectGetMaxX(removeBtn.frame) + 10, CGRectGetMaxY(self.videoEditView.frame) + 10, 50, 30);
    [self.view addSubview:divideBtn];
    
    [divideBtn addTarget:self
                  action:@selector(divide)
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
//    self.videoEditView.viewModel.timeIntervalOfFrame = 3.0f;
//    [self.videoEditView updateTempAnimation];
    
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

- (void)divide
{
    [self.videoEditView divideCellAtCurrentFrame];
}

#pragma mark - GKVideoEditHorizontalViewDelegate

- (void)timeIntervalOfCurrentFrame:(CGFloat)timeInterval
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

- (void)indexOfChunkCellAtCurrentFrame:(NSInteger)index
{
    NSLog(@"indexOfChunkCellAtCurrentFrame  %ld----selectedIndex==%ld", index, self.videoEditView.selectedIndex);
}

@end
