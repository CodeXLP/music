//
//  LrcLineCell.h
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/28.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LrcLine;

@interface LrcLineCell : UITableViewCell
+ (instancetype) cellWithtableView:(UITableView *)tableView;
@property (nonatomic,strong) LrcLine *lrcLine;

@end
