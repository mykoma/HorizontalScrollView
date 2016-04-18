//
//  GKVideoTailerCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoTailerCell.h"

@interface GKVideoTailerCell ()

@property (nonatomic, strong) UIImageView * bgIV;

@end

@implementation GKVideoTailerCell

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    
    self.bgIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_tailer"]];
    [self addSubview:self.bgIV];
}

- (void)layoutSubviews
{
    self.bgIV.frame = self.bounds;
}

@end

@implementation GKVideoTailerCellModel

@end