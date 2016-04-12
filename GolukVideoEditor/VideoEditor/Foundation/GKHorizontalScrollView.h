//
//  GKHorizontalScrollView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKHorizontalCell;
@class GKHorizontalScrollView;

/*****************************
 * 数据源
 *****************************/
@protocol GKHorizontalScrollDataSource <NSObject>

@required

- (NSInteger)countOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView;

- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

/*****************************
 * 布局
 *****************************/
@protocol GKHorizontalScrollViewLayout <NSObject>

@required

- (CGRect)rectOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView;

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
        sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (UIEdgeInsets)edgeInsetsOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView;

- (UIEdgeInsets)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
             insetForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/*****************************
 * 事件处理 Delegate
 *****************************/
@protocol GKHorizontalScrollViewDelegate <NSObject>


@end

/*****************************
 * GKHorizontalScrollView
 *****************************/
@interface GKHorizontalScrollView : UIView

@property (nonatomic, weak) IBOutlet id <GKHorizontalScrollDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <GKHorizontalScrollViewLayout> layout;
@property (nonatomic, weak) IBOutlet id <GKHorizontalScrollViewDelegate> delegate;

- (void)reloadData;

- (void)scrollToOffset:(CGFloat)offset;

@end
