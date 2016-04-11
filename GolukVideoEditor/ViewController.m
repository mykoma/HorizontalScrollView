//
//  ViewController.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "ViewController.h"
#import "GKVideoChunkCell.h"
#import "GKVideoChunkFenceCell.h"
#import "GKHorizontalScrollView.h"

@interface ViewController ()
<
GKHorizontalScrollDataSource,
GKHorizontalScrollViewLayout,
GKHorizontalScrollViewDelegate
>

@property (nonatomic, strong) GKHorizontalScrollView * horizontalScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.horizontalScrollView = [[GKHorizontalScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    self.horizontalScrollView.dataSource = self;
    self.horizontalScrollView.layout = self;
    self.horizontalScrollView.delegate = self;
    
    self.horizontalScrollView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.horizontalScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.horizontalScrollView reloadData];
}

#pragma mark - GKHorizontalScrollDataSource

- (NSInteger)countOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return 20;
}

- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                   cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKHorizontalCell * cell;
    if (indexPath.row % 2 == 1)
    {
        cell = [[GKVideoChunkCell alloc] init];
    } else {
        cell = [[GKVideoChunkFenceCell alloc] init];
    }
    return cell;
}

#pragma mark - GKHorizontalScrollViewLayout

- (CGRect)rectOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
{
    return CGRectMake(0, 10, self.view.bounds.size.width, 50);
}

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
       sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1) {
        if ((indexPath.row / 2 ) % 2 == 1) {
            return CGSizeMake(100, 50);
        } else {
            return CGSizeMake(70, 50);
        }
    }
    return CGSizeMake(20, 50);
}

//- (UIEdgeInsets)edgeInsetsOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
//{
//    return UIEdgeInsetsMake(0, 10, 0, 10);
//}

- (UIEdgeInsets)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
            insetForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

@end
