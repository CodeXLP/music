//
//  MusicPlayingTool.h
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/18.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MusicObject;

@interface MusicPlayingTool : NSObject

/**
 *  返回所有的歌曲
 */
+ (NSArray *)musicesArray;

/**
 *  返回当前正在播放的歌曲
 */
+ (MusicObject *)playingMusices;
+ (void) setPlayingMusices:(MusicObject *)playingMusices;

/**
 * 返回下一首要播放的歌曲
 */
+ (MusicObject *)nextPlayingMusices;

/**
 * 返回上一首要播放的歌曲
 */
+ (MusicObject *)pleviousPlayingMusices;

@end
