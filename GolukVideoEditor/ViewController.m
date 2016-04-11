//
//  ViewController.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "ViewController.h"
#import "GKVideoChunkCell.h"
#import "GKVideoEditScrollView.h"

@interface ViewController ()
<
GKVideoEditScrollViewDataSource,
GKVideoEditScrollViewLayout,
GKVideoEditScrollViewDelegate
>

@property (nonatomic, strong) GKVideoEditScrollView * videoEditScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoEditScrollView = [[GKVideoEditScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
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

#pragma mark - GKVideoEditScrollViewDataSource

- (NSInteger)countOfVideoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
{
    return 20;
}

- (GKVideoEditCell *)videoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
                   cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKVideoChunkCell * cell = [[GKVideoChunkCell alloc] init];
    if (indexPath.row % 2 == 0)
    {
        cell.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor yellowColor];
    }
    return cell;
}

#pragma mark - GKVideoEditScrollViewLayout

- (CGRect)rectOfVideoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
{
    return CGRectMake(0, 10, self.view.bounds.size.width, 50);
}

- (CGSize)videoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
       sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        return CGSizeMake(50, 50);
    }
    return CGSizeMake(100, 50);
}

//- (UIEdgeInsets)edgeInsetsOfVideoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
//{
//    return UIEdgeInsetsMake(0, 10, 0, 10);
//}

- (UIEdgeInsets)videoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
            insetForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

@end
