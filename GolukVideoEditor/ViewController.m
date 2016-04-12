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
    GKVideoChunkCellModel * model2 = [[GKVideoChunkCellModel alloc] init];
    GKVideoChunkCellModel * model3 = [[GKVideoChunkCellModel alloc] init];
    GKVideoChunkCellModel * model4 = [[GKVideoChunkCellModel alloc] init];
    [self.videoEditView.viewModel.chunkCellModels addObject:model1];
    [self.videoEditView.viewModel.chunkCellModels addObject:model2];
    [self.videoEditView.viewModel.chunkCellModels addObject:model3];
    [self.videoEditView.viewModel.chunkCellModels addObject:model4];
    [self.view addSubview:self.videoEditView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoEditView loadData];
}

@end
