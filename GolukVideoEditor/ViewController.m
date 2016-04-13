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

@interface ViewController ()

@property (nonatomic, strong) GKVideoEditHorizontalView * videoEditView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoEditView = [[GKVideoEditHorizontalView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    
    self.videoEditView.backgroundColor = [UIColor blueColor];
    
    GKVideoChunkCellModel * model1 = [[GKVideoChunkCellModel alloc] init];
    model1.duration = 10;
    model1.beginPercent = 0.1f;
    model1.endPercent = 0.5f;
    GKVideoChunkCellModel * model2 = [[GKVideoChunkCellModel alloc] init];
    model2.duration = 5;
    model2.beginPercent = 0.1f;
    model2.endPercent = 0.8f;
    GKVideoChunkCellModel * model3 = [[GKVideoChunkCellModel alloc] init];
    model3.duration = 8;
    GKVideoChunkCellModel * model4 = [[GKVideoChunkCellModel alloc] init];
    model4.duration = 5;
    [self.videoEditView.viewModel.chunkCellModels addObject:model1];
    [self.videoEditView.viewModel.chunkCellModels addObject:model2];
    [self.videoEditView.viewModel.chunkCellModels addObject:model3];
    [self.videoEditView.viewModel.chunkCellModels addObject:model4];
    [self.view addSubview:self.videoEditView];
    
    [self.videoEditView setAddChunkAction:^{
        // TODO Add Chunk
    }];
    
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
    self.videoEditView.viewModel.timeIntervalOfFrame = timeOffset;
    // TO DELETE
    [self.videoEditView updateTemp];
    
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

@end
