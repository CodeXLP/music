//
//  LrcView.m
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/27.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "LrcView.h"
#import "LrcLine.h"
#import "LrcLineCell.h"

@interface LrcView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *lrcTableView;
@property (nonatomic, strong) NSMutableArray *lrcLinesArray;
@property (nonatomic, assign) int currentIndex;

@end

@implementation LrcView

- (NSMutableArray *)lrcLinesArray
{
    if (!_lrcLinesArray) {
        self.lrcLinesArray = [NSMutableArray array];
    }
    return _lrcLinesArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decode
{
    if (self = [super initWithCoder:decode]) {
        //将从文件中读取
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.lrcTableView = [[UITableView alloc] init];
    [self addSubview:self.lrcTableView];
    self.lrcTableView.delegate = self;
    self.lrcTableView.dataSource = self;
    self.lrcTableView.backgroundColor = [UIColor clearColor];
    self.lrcTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lrcTableView.frame = self.bounds;
    self.lrcTableView.contentInset = UIEdgeInsetsMake(self.lrcTableView.frame.size.height * 0.5, 0, self.lrcTableView.frame.size.height * 0.5, 0);
}

- (void)setLrcname:(NSString *)lrcname
{
    [self.lrcLinesArray removeAllObjects];
    _lrcname = [lrcname copy];
    //加载歌曲文件歌词
    NSURL *url = [[NSBundle mainBundle] URLForResource:lrcname withExtension:nil];
    NSString *lrcstr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //将歌词文件分割
    NSArray *lrcCmps = [lrcstr componentsSeparatedByString:@"\n"];
    
    for (NSString *lrcCmp in lrcCmps) {
        LrcLine *line = [[LrcLine alloc] init];
        [self.lrcLinesArray addObject:line];
        if (![lrcCmp hasPrefix:@"["]) continue;
        
        if ([lrcCmp hasPrefix:@"[ti:"]||[lrcCmp hasPrefix:@"[ar:"]||[lrcCmp hasPrefix:@"[al:"]) {
            NSString *word = [[lrcCmp componentsSeparatedByString:@":"] lastObject];
            line.word = [word substringToIndex:word.length - 1];
        }else 
        {
            NSArray *array = [lrcCmp componentsSeparatedByString:@"]"];
            line.time = [[array firstObject] substringFromIndex:1];
            line.word = [array lastObject];
        }
    }
    
    
    [self.lrcTableView reloadData];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    if (currentTime < _currentTime) {
        self.currentIndex = -1;
    }
    
    _currentTime = currentTime;
    
    int minute = currentTime / 60;
    int second = (int)currentTime % 60;
    int msecond = (currentTime - (int)currentTime) * 100;
    //当前播放时间的字符串
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d.%02d", minute, second, msecond];
    
    NSInteger count = self.lrcLinesArray.count;
    for (int idx = self.currentIndex + 1; idx<count; idx++) {
        LrcLine *currentLine = self.lrcLinesArray[idx];
        // 当前模型的时间
        NSString *currentLineTime = currentLine.time;
        // 下一个模型的时间
        NSString *nextLineTime = nil;
        NSUInteger nextIdx = idx + 1;
        if (nextIdx < self.lrcLinesArray.count) {
            LrcLine *nextLine = self.lrcLinesArray[nextIdx];
            nextLineTime = nextLine.time;
        }
        
        // 判断是否为正在播放的歌词
        if (
            ([currentTimeStr compare:currentLineTime] != NSOrderedAscending)
            && ([currentTimeStr compare:nextLineTime] == NSOrderedAscending)
            && self.currentIndex != idx) {
            // 刷新tableView
            NSArray *reloadRows = @[
                                    [NSIndexPath indexPathForRow:self.currentIndex inSection:0],
                                    [NSIndexPath indexPathForRow:idx inSection:0]
                                    ];
            self.currentIndex = idx;
            [self.lrcTableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
            
            
            // 滚动到对应的行
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [self.lrcTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }

    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lrcLinesArray count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LrcLineCell *cell = [LrcLineCell cellWithtableView:tableView];
    cell.lrcLine = self.lrcLinesArray[indexPath.row];
    if (self.currentIndex == indexPath.row) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    }else{
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return cell;
}

@end
