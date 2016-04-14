//
//  GKVideoEditScrollView.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/11.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKHorizontalScrollView.h"

/*****************************
 * 数据源
 *****************************/
@protocol GKVideoHorizontalScrollDataSource <GKHorizontalScrollDataSource>

@required

- (GKHorizontalCell *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
                          cellForItemModel:(id)itemModel;

@end

/*****************************
 * 布局
 *****************************/
@protocol GKVideoHorizontalScrollViewLayout <GKHorizontalScrollViewLayout>

@required

- (CGFloat)defaultOffsetOfFrameMarkerOfHorizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView;

- (CGSize)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
              sizeForItemModel:(id)itemModel;

@end

/*****************************
 * 事件处理
 *****************************/
@protocol GKVideoHorizontalScrollViewDelegate <GKHorizontalScrollViewDelegate>

@required

/**
 * 分割视频，会返回分割后的 cellModels，交由 Delegate 处理， 再返回回来
 */
- (NSArray *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
cellModelAfterInterceptDividedModels:(NSArray *)cellModels;
- (NSArray *)horizontalScrollView:(GKHorizontalScrollView *)horizontalScrollView
cellModelAfterInterceptAppendModels:(NSArray *)cellModels;

@end

@interface GKVideoHorizontalScrollView : GKHorizontalScrollView

@property (nonatomic, weak) IBOutlet id <GKVideoHorizontalScrollDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <GKVideoHorizontalScrollViewLayout> layout;
@property (nonatomic, weak) IBOutlet id <GKVideoHorizontalScrollViewDelegate> delegate;

- (void)scrollToTimeInterval:(NSTimeInterval)timeInterval animated:(BOOL)animated;

- (void)attemptToDivideCellAtCurrentFrame;

- (void)appendCellModel:(id)cellModel;

@end
