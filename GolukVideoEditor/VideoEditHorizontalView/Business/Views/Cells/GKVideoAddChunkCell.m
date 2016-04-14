//
//  GKVideoAddChunkCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/10.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoAddChunkCell.h"

@interface GKVideoAddChunkCell ()

@property (nonatomic, strong) UIButton * touchBtn;

@end

@implementation GKVideoAddChunkCell

- (void)setup
{
    [super setup];
    self.touchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:self.touchBtn];
    
    [self.touchBtn addTarget:self
                      action:@selector(touch:)
            forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor cyanColor];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.touchBtn.frame = self.bounds;
}

- (void)touch:(id)sender
{
    if (self.touchAction) {
        self.touchAction();
    }
}

@end

@implementation GKVideoAddChunkCellModel

@end
