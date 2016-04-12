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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.videoEditView loadData];
}

static NSTimeInterval timeOffset = 0.0f;

static NSTimeInterval timeInterval = 1.0f / 60;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                     target:self
                                   selector:@selector(update)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)update
{
    self.videoEditView.viewModel.timeIntervalOfFrame = timeOffset;
    // TO DELETE
    [self.videoEditView updateTemp];
    
    timeOffset += timeInterval;
}

@end
