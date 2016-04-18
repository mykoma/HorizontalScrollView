//
//  GKVideoCurrentFrameView.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoCurrentFrameView.h"

CGFloat WIDTH_OF_ARC = 10.0f;
CGFloat HEIGHT_OF_ARC = 8.5f;

@interface GKVideoCurrentFrameView ()

@property (nonatomic, strong) UIImageView * topArcIV;
@property (nonatomic, strong) UIImageView * bottomArcIV;

@end

@implementation GKVideoCurrentFrameView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor colorWithRed:0xef/255.0f
                                               green:0x2e/255.0f
                                                blue:0x2e/255.0f
                                               alpha:1.0f];
        self.topArcIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_top_arc"]];
        [self addSubview:self.topArcIV];
        self.bottomArcIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_bottom_arc"]];
        [self addSubview:self.bottomArcIV];
    }
    return self;
}

-(void)layoutSubviews
{
    self.topArcIV.frame = CGRectMake((CGRectGetMinX(self.bounds) - WIDTH_OF_ARC) / 2, 0,
                                     WIDTH_OF_ARC, HEIGHT_OF_ARC);
    self.bottomArcIV.frame = CGRectMake(CGRectGetMinX(self.topArcIV.frame),
                                        CGRectGetHeight(self.bounds) - HEIGHT_OF_ARC,
                                        WIDTH_OF_ARC, HEIGHT_OF_ARC);
}

@end
