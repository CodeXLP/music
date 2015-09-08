//
//  MusicPlayingTool.m
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/18.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "MusicPlayingTool.h"
#import "MusicObject.h"

@implementation MusicPlayingTool
static NSArray *_musicesArray;
static MusicObject *_playingMusices;

/**
 *  返回所有的歌曲
 */
+ (NSArray *)musicesArray
{
    if (_musicesArray == nil) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Musics.plist" ofType:nil];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:plistPath];
        NSMutableArray *mutArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            MusicObject *musicObject = [MusicObject musicObjectWithDict:dict];
            [mutArray addObject:musicObject];
        }
        _musicesArray = mutArray;
    }
    return _musicesArray;
}

/**
 *  返回当前正在播放的歌曲
 */
+ (MusicObject *)playingMusices
{
    return _playingMusices;
}

+ (void) setPlayingMusices:(MusicObject *)playingMusices
{
    if (!playingMusices || ![[self musicesArray] containsObject:playingMusices]) return;
    _playingMusices = playingMusices;
}

/**
 * 返回下一首要播放的歌曲
 */
+ (MusicObject *)nextPlayingMusices
{
    NSInteger nextIndex = 0;
    if (_playingMusices) {
        NSUInteger playingIndex = [[self musicesArray] indexOfObject:_playingMusices];
        nextIndex = playingIndex + 1;
        if (nextIndex >[self musicesArray].count) {
            nextIndex = 0;
        }
    }
    return [self musicesArray][nextIndex];
}

/**
 * 返回上一首要播放的歌曲
 */
+ (MusicObject *)pleviousPlayingMusices
{
    NSInteger previousIndex = 0;
    if (_playingMusices) {
        NSUInteger playingIndex = [[self musicesArray] indexOfObject:_playingMusices];
        previousIndex = playingIndex - 1;
        if (previousIndex < 0) {
            previousIndex = [self musicesArray].count - 1;
        }
    }
    return [self musicesArray][previousIndex];
}

@end
