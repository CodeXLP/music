//
//  AVAudioPlayerTool.m
//  08-14-AVAudioPlayer
//
//  Created by 熊鲁平 on 15/8/14.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "AVAudioPlayerTool.h"

@implementation AVAudioPlayerTool
+ (void)initialize
{
    // 音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // 设置会话类型（播放类型、播放模式,会自动停止其他音乐的播放）
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    
    // 激活会话
    [session setActive:YES error:nil];
}

/**
 *  存放所有的音效ID
 */
static NSMutableDictionary *_soundIDs;
+ (NSMutableDictionary *)soundIDs
{
    if (!_soundIDs) {
        _soundIDs = [NSMutableDictionary dictionary];
    }
    return _soundIDs;
}

/**
 *  创建一个装音频播放器字典
 */
static NSMutableDictionary *_musicPlayer;
+(NSMutableDictionary *)musicPlayer
{
    if (!_musicPlayer) {
        _musicPlayer = [NSMutableDictionary dictionary];
    }
    return _musicPlayer;
}

/**
 *  播放音乐
 *
 *  @param filename 音乐的文件名
 */
+ (AVAudioPlayer *)playMusic:(NSString *)filename
{
    if (!filename) return nil;
    AVAudioPlayer *player = [self musicPlayer][filename];
    if (!player) {
        //音频播放路径
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (!url) return nil;
        //创建一个音频播放器， 一个音频播放器只能播放一个url路径
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        //缓存
        if (![player prepareToPlay]) return nil;
        //存入_musicPlayer字典
        [self musicPlayer][filename] = player;
    }
    
    if (!player.isPlaying) {
        //若播放器没有播放，则播放
        [player play];
    }
    return player;
}

/**
 *  暂停音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)pauseMusic:(NSString *)filename
{
    if (!filename) return;
    AVAudioPlayer *player = [self musicPlayer][filename];
    
    if (player.isPlaying) {
        [player pause];
    }
}

/**
 *  停止音乐
 *
 *  @param filename 音乐的文件名
 */
+ (void)stopMusic:(NSString *)filename
{
    if (!filename) return;
    AVAudioPlayer *player = [self musicPlayer][filename];
    [player stop];
    //停止音乐后，将音频播放器清空，从_musicPlayer字典中移除
    [[self musicPlayer] removeObjectForKey:filename];
}

/**
 *  播放音效
 *
 *  @param filename 音效的文件名
 */
+ (void)playSound:(NSString *)filename
{
    if (!filename) return;
    
    // 1.取出对应的音效ID
    SystemSoundID soundID = (int)[[self soundIDs][filename] unsignedLongValue];
    // 2.初始化
    if (!soundID) {
        // 音频文件的URL
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (!url) return;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        // 存入字典
        [self soundIDs][filename] = @(soundID);
    }
    // 3.播放
    AudioServicesPlaySystemSound(soundID);
}

/**
 *  销毁音效
 *
 *  @param filename 音效的文件名
 */
+ (void)disposeSound:(NSString *)filename
{
    if (!filename) return;
    // 1.取出对应的音效ID
    SystemSoundID soundID = (int)[[self soundIDs][filename] unsignedLongValue];
    // 2.销毁
    if (soundID) {
        //移除音效ID
        AudioServicesDisposeSystemSoundID(soundID);
        //从_soundIDs字典中移除filename音效的文件名
        [[self soundIDs] removeObjectForKey:filename];
    }
}

@end
