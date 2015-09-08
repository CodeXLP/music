//
//  MusicesViewController.m
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/18.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "MusicsController.h"
#import "MusicPlayingController.h"
#import "UIImage+MJ.h"
#import "MusicPlayingTool.h"
#import "MusicObject.h"
#import "Colours.h"

@interface MusicsController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) MusicPlayingController *playingVc;

@end

@implementation MusicsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 65;
}

- (MusicPlayingController *)playingVc
{
    if (_playingVc == nil) {
        _playingVc = [[MusicPlayingController alloc] init];
    }
    return _playingVc;
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MusicPlayingTool musicesArray].count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"musicesID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    MusicObject *musices = [MusicPlayingTool musicesArray][indexPath.row];
    cell.textLabel.text = musices.name;
    cell.detailTextLabel.text = musices.singer;
    cell.imageView.image = [UIImage circleImageWithName:musices.singerIcon borderWidth:2.0 borderColor:[UIColor skyBlueColor]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //设置点击的歌曲
    [MusicPlayingTool setPlayingMusices:[MusicPlayingTool musicesArray][indexPath.row]];
    //显示播放界面
    [self.playingVc show];
}

@end
