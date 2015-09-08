//
//  LrcView.h
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/27.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "DRNRealTimeBlurView.h"

@interface LrcView : DRNRealTimeBlurView

@property (nonatomic, copy) NSString *lrcname;
@property (nonatomic, assign) NSTimeInterval currentTime;

@end
