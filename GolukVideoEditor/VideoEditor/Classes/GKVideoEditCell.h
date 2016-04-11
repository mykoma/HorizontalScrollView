//
//  GKVideoEditCell.h
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKVideoEditCell;

@protocol GKVideoEditCellDelegate <NSObject>

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
     moveBeganAtPoint:(CGPoint)point;

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
         changeCenter:(CGPoint)newCenter;

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
       moveEndAtPoint:(CGPoint)point;

- (void)videoEditCell:(GKVideoEditCell *)videoEditCell
  moveCanceledAtPoint:(CGPoint)point;

@end

@interface GKVideoEditCell : UIView

@property (nonatomic, weak) IBOutlet id <GKVideoEditCellDelegate> delegate;
@property (nonatomic, assign, readonly) CGRect originFrameInUpdating;

- (void)setup;
- (void)beginUpdating;
- (void)endUpdating;

@end
