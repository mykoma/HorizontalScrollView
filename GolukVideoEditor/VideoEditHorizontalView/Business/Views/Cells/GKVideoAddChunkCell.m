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
@property (nonatomic, strong) UIImageView * bgIV;

@end

@implementation GKVideoAddChunkCell

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    
    self.bgIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_video_chunk"]];
    [self addSubview:self.bgIV];

    self.touchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.touchBtn addTarget:self
                      action:@selector(touch:)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.touchBtn];
}

- (void)layoutSubviews
{
    self.bgIV.frame = self.bounds;
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
