//
//  GKVideoEditScrollView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKVideoEditCell;
@class GKVideoEditScrollView;

/*****************************
 * 数据源
 *****************************/
@protocol GKVideoEditScrollViewDataSource <NSObject>

@required

- (NSInteger)countOfVideoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView;

- (GKVideoEditCell *)videoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
                   cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

/*****************************
 * 布局
 *****************************/
@protocol GKVideoEditScrollViewLayout <NSObject>

@required

- (CGRect)rectOfVideoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView;

- (CGSize)videoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
       sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (UIEdgeInsets)edgeInsetsOfVideoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView;

- (UIEdgeInsets)videoEditScrollView:(GKVideoEditScrollView *)videoEditScrollView
            insetForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/*****************************
 * 事件处理 Delegate
 *****************************/
@protocol GKVideoEditScrollViewDelegate <NSObject>


@end

/*****************************
 * GKVideoEditScrollView
 *****************************/
@interface GKVideoEditScrollView : UIView

@property (nonatomic, weak) IBOutlet id <GKVideoEditScrollViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <GKVideoEditScrollViewLayout> layout;
@property (nonatomic, weak) IBOutlet id <GKVideoEditScrollViewDelegate> delegate;

- (void)reloadData;

@end
