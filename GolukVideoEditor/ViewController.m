//
//  ViewController.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "ViewController.h"
#import "GKVideoChunkCell.h"
#import "GKVideoFenceCell.h"
#import "GKVideoAddChunkCell.h"
#import "GKVideoTailerCell.h"
#import "GKVideoHorizontalScrollView.h"

@interface ViewController ()
<
GKHorizontalScrollDataSource,
GKHorizontalScrollViewLayout,
GKHorizontalScrollViewDelegate
>

@property (nonatomic, strong) GKVideoHorizontalScrollView * videoEditScrollView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [@[@"GKVideoChunkCell",
                         @"GKVideoFenceCell",
                         @"GKVideoChunkCell",
                         @"GKVideoFenceCell",
                         @"GKVideoChunkCell",
                         @"GKVideoFenceCell",
                         @"GKVideoChunkCell",
                         @"GKVideoTailerCell",
                         @"GKVideoAddChunkCell"] mutableCopy];
    
    self.videoEditScrollView = [[GKVideoHorizontalScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    self.videoEditScrollView.dataSource = self;
    self.videoEditScrollView.layout = self;
    self.videoEditScrollView.delegate = self;
    
    self.videoEditScrollView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.videoEditScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoEditScrollView reloadData];
}

#pragma mark - GKHorizontalScrollDataSource

- (NSInteger)countOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return self.dataSource.count;
}

- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * str = self.dataSource[indexPath.row];
    return [[NSClassFromString(str) alloc] init];
}

#pragma mark - GKHorizontalScrollViewLayout

- (CGRect)rectOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return CGRectMake(0, 10, self.view.bounds.size.width, 50);
}

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
       sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        if ((indexPath.row / 2 ) % 2 == 1) {
            return CGSizeMake(100, 50);
        } else {
            return CGSizeMake(70, 50);
        }
    }
    return CGSizeMake(20, 50);
}

- (UIEdgeInsets)edgeInsetsOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (UIEdgeInsets)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
            insetForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

@end
