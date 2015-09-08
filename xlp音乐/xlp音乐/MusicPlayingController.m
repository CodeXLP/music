//
//  MusicPlayingViewController.m
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/18.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "MusicPlayingController.h"
#import "UIView+Extension.h"
#import "MusicObject.h"
#import "MusicPlayingTool.h"
#import "AVAudioPlayerTool.h"
#import <AVFoundation/AVFoundation.h>
#import "LrcView.h"

@interface MusicPlayingController ()<AVAudioPlayerDelegate>
@property (nonatomic, strong) MusicObject *playingMusic;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic,strong) NSTimer *currentTimeTimer;
@property (nonatomic, strong) CADisplayLink *lrcTimer;  //刷针比较快，用这个定时器x

@property (weak, nonatomic) IBOutlet UIButton *lyricOrPic;  //切换歌词和头像
@property (weak, nonatomic) IBOutlet UILabel *songLabel;     //歌曲名称
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;   //歌手名称
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;  //歌曲时长
@property (weak, nonatomic) IBOutlet UIImageView *iconView;  //歌手大头像
@property (weak, nonatomic) IBOutlet UIButton *slider;       //进度条滑块
@property (weak, nonatomic) IBOutlet UIView *progressView;   //进度条背景
@property (weak, nonatomic) IBOutlet UIButton *showProgress;
@property (weak, nonatomic) IBOutlet UIButton *playOrPause;
@property (weak, nonatomic) IBOutlet UIButton *LrcOrPic;
@property (weak, nonatomic) IBOutlet LrcView *maoView;
- (IBAction)clickprogress:(UITapGestureRecognizer *)sender;  //手势点击进度条背景
- (IBAction)panSlider:(UIPanGestureRecognizer *)sender;      //拖拽手势滑块
- (IBAction)exit:(UIButton *)sender;                         //退出播放界面
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)LrcOrPic:(UIButton *)sender;

@end

@implementation MusicPlayingController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 显示和退出播放界面
/**
 *  显示播放界面
 */
- (void) show
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self.view];
    self.view.frame = window.bounds;
    window.userInteractionEnabled = NO;
    window.hidden = NO;
    if (self.playingMusic != [MusicPlayingTool playingMusices]) {
        //先清除掉以前的歌曲数据
        [self restMusicData];
    }
    self.view.y = self.view.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.y = 0;
    } completion:^(BOOL finished) {
        //加载正在播放的歌曲
        [self setupPlayingMusicData];
        window.userInteractionEnabled = YES;
    }];
}

/**
 *  退出播放界面
 */
- (IBAction)exit:(UIButton *)sender
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.y = self.view.height;
        
    } completion:^(BOOL finished) {
        window.hidden = YES;
    }];
}

- (IBAction)LrcOrPic:(UIButton *)sender {
    if (self.maoView.isHidden) { //显示毛玻璃效果
        self.maoView.hidden = NO;
        sender.selected = YES;
        [self addLrcTimer];
        
    }else
    {
        self.maoView.hidden = YES;
        sender.selected = NO;
        [self removeLrcTimer];
    }
}

#pragma mark - 定时器处理操作
- (void) addCurrentTimeTimer
{
    [self updateCurrentTime];
    //添加定时器
    self.currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.currentTimeTimer forMode:NSRunLoopCommonModes];
}

- (void) removeCurrentTimeTimer
{
    [self.currentTimeTimer invalidate];
    self.currentTimeTimer = nil;
}

- (void) updateCurrentTime
{
    double progress = self.player.currentTime / self.player.duration; //当前播放的进度【0~1】
    CGFloat sliderMaxX = self.view.width - self.slider.width;
    self.slider.x = progress * sliderMaxX;
    [self.slider setTitle:[self strWithTime:self.player.currentTime] forState:UIControlStateNormal];
    //设置进度条的背景
    self.progressView.width = self.slider.center.x;
    self.playOrPause.selected = YES;
}

//添加歌词控制定时器
- (void)addLrcTimer
{
    if (self.player.isPlaying == NO || self.maoView.hidden) return;
    [self removeLrcTimer];
    // 保证定时器的工作是及时的
    [self updateLrc];
    
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

/**
 *  更新歌词
 */
- (void)updateLrc
{
    self.maoView.currentTime = self.player.currentTime;
}

#pragma mark - 添加手势用来点击进度条背景和拖拽进度滑块
/**
 *  点击进度条背景
 */
- (IBAction)clickprogress:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];  //点击的是进度条背景的位置
    //更新播放时间
    self.player.currentTime = (point.x / self.view.width) * self.player.duration;
    [self updateCurrentTime];
}

- (IBAction)panSlider:(UIPanGestureRecognizer *)sender
{
    //1.获取移动的距离
    CGPoint point = [sender translationInView:sender.view];
    [sender setTranslation:CGPointZero inView:sender.view];
    
    //2.设置滑块和进度条的frame
    self.slider.x +=point.x;
    CGFloat sliderMaxX = self.view.width - self.slider.width;
    if (self.slider.x < 0) {
        self.slider.x = 0;
    }else if (self.slider.x > sliderMaxX){
        self.slider.x = sliderMaxX;
    }
    self.progressView.width = self.slider.center.x;
    
    //3.设置进度条上面的时间
    double progress = self.slider.x / sliderMaxX;
    NSTimeInterval time = progress * self.player.duration;
    [self.slider setTitle:[self strWithTime:time] forState:UIControlStateNormal];
    
    self.showProgress.x = self.slider.x;
    [self.showProgress setTitle:self.slider.currentTitle forState:UIControlStateNormal];
    
    //4.拖拽触发事件
    if (sender.state == UIGestureRecognizerStateBegan) {
        //开始拖拽
        //停止定时器
        [self removeCurrentTimeTimer];
        self.showProgress.hidden = NO;
        self.showProgress.y = self.showProgress.superview.height - 10 - self.showProgress.height;
        self.playOrPause.selected = NO;
    }else if (sender.state == UIGestureRecognizerStateEnded){
        //结束手势拖拽
        //开始定时器
        self.player.currentTime = time;
        [self addCurrentTimeTimer];
        self.showProgress.hidden = YES;
        self.playOrPause.selected = YES;
    }
}

#pragma mark - 设置播放歌曲
/**
 *  设置正在播放歌曲的数据
 */
- (void) setupPlayingMusicData
{
    self.playingMusic = [MusicPlayingTool playingMusices];
    self.iconView.image = [UIImage imageNamed:self.playingMusic.icon];
    self.songLabel.text = self.playingMusic.name;
    self.singerLabel.text = self.playingMusic.singer;
    //播放歌曲
    self.player = [AVAudioPlayerTool playMusic:self.playingMusic.filename];
    self.player.delegate = self;
    self.durationLabel.text = [self strWithTime:self.player.duration];
    if (self.player.isPlaying) {
        [self addCurrentTimeTimer];
        [self addLrcTimer];
    }
    self.maoView.lrcname = self.playingMusic.lrcname;
}

/**
 *  先清除掉以前的歌曲数据
 */
- (void) restMusicData
{
    self.iconView.image = [UIImage imageNamed:@"play_cover_pic_bg"];
    self.songLabel.text = nil;
    self.singerLabel.text = nil;
    self.durationLabel.text = nil;
    //如果不是同一首歌曲，停掉之前播放的歌曲
    [AVAudioPlayerTool stopMusic:self.playingMusic.filename];
    self.player = nil;
    [self removeCurrentTimeTimer];// 停掉定时器
    [self removeLrcTimer];
}

- (NSString *)strWithTime:(NSTimeInterval)time
{
    int minute = time / 60;
    int second = (int)time % 60;
    return [NSString stringWithFormat:@"%d:%d",minute,second];
}

#pragma mark - 切换上一首，下一首，暂停，播放
- (IBAction)previous:(id)sender {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    //切换上一首
    //清除掉以前的歌曲数据
    [self restMusicData];
    //获得上一首歌曲
    [MusicPlayingTool setPlayingMusices:[MusicPlayingTool pleviousPlayingMusices]];
    //播放
    [self setupPlayingMusicData];
    window.userInteractionEnabled = YES;
}

- (IBAction)play:(id)sender {
    if (self.playOrPause.isSelected) { //暂停
        self.playOrPause.selected = NO;
        [AVAudioPlayerTool pauseMusic:self.playingMusic.filename]; //暂停当前播放的歌曲
        [self removeCurrentTimeTimer]; // 将定时器移调
        [self removeLrcTimer];
    }else{
        self.playOrPause.selected = YES;
        [AVAudioPlayerTool playMusic:self.playingMusic.filename];
        [self addCurrentTimeTimer];
        [self addLrcTimer];
    }
}

- (IBAction)next:(id)sender {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    //切换下一首
    //清除掉以前的歌曲数据
    [self restMusicData];
    //获得下一首歌曲
    [MusicPlayingTool setPlayingMusices:[MusicPlayingTool nextPlayingMusices]];
    //播放
    [self setupPlayingMusicData];
    window.userInteractionEnabled = YES;
}

#pragma mark - AVAudioPlayerDelegate
/**
 *  当一个播放器播放完后会调用
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self next:nil];
}

/**
 *  当播放器遇到中断的时候调用（比如来电）
 */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (self.player.isPlaying) {
        [self.player pause];
    }
}


@end
