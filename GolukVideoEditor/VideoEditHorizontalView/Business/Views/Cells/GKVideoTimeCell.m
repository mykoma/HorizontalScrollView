//
//  GKVideoTimeCell.m
//  GolukVideoEditor
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 SCU. All rights reserved.
//

#import "GKVideoTimeCell.h"

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
    self.durationLabel.font = [UIFont systemFontOfSize:13];
    self.durationLabel.textColor = [UIColor whiteColor];
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
    self.durationLabel.frame = self.bounds;
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