//
//  LrcLineCell.m
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/28.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "LrcLineCell.h"
#import "LrcLine.h"

@implementation LrcLineCell

+ (instancetype) cellWithtableView:(UITableView *)tableView
{
    static NSString *ID = @"Lrc";
    LrcLineCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[LrcLineCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setLrcLine:(LrcLine *)lrcLine
{
    self.textLabel.text = lrcLine.word;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}
@end
