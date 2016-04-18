//
//  GKVideoTimeCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoTimeCell.h"

CGFloat HEIGHT_OF_TIME_CELL_TEXT = 22.0f;

@interface GKVideoTimeCell ()

@property (nonatomic, weak) UILabel * durationLabel;

@end

@implementation GKVideoTimeCell

- (void)setup
{
    [super setup];
    UILabel * label = [[UILabel alloc] init];
    [self addSubview:label];
    self.durationLabel = label;
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    self.durationLabel.backgroundColor = [UIColor colorWithRed:0x1f/255.0f
                                                         green:0x1f/255.0f
                                                          blue:0x1f/255.0f
                                                         alpha:1.0f];
    self.durationLabel.font = [UIFont systemFontOfSize:12.0f];
    self.durationLabel.textColor = [UIColor whiteColor];
}

- (void)dealloc
{
    [self.cellModel removeObserver:self
                        forKeyPath:@"totalDuration"];
}

- (void)setCellModel:(GKVideoTimeCellModel *)cellModel
{
    [_cellModel removeObserver:self
                    forKeyPath:@"totalDuration"];
    _cellModel = cellModel;
    [_cellModel addObserver:self
                 forKeyPath:@"totalDuration"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];
}

- (void)layoutSubviews
{
    self.durationLabel.frame = CGRectMake(0, (CGRectGetHeight(self.bounds) - HEIGHT_OF_TIME_CELL_TEXT) / 2,
                                          CGRectGetWidth(self.bounds), HEIGHT_OF_TIME_CELL_TEXT);
    self.durationLabel.layer.cornerRadius = 4.0f;
    self.durationLabel.clipsToBounds = YES;
}

- (void)updateDurationWithTimeInterval:(NSTimeInterval)timeInterval
{
    self.durationLabel.text = [NSString stringWithFormat:@"%.1f秒", timeInterval];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"totalDuration"])
    {
        NSNumber * time = change[NSKeyValueChangeNewKey];
        if ([time isKindOfClass:[NSNumber class]]) {
            [self updateDurationWithTimeInterval:time.doubleValue];
        }
    }
}

@end

@implementation GKVideoTimeCellModel

@end