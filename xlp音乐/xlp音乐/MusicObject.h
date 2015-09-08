//
//  MusicObject.h
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/18.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicObject : NSObject
/** 歌曲名称 */
@property (nonatomic, copy) NSString *name;
/** 歌手 */
@property (nonatomic, copy) NSString *singer;
/** 歌词 */
@property (nonatomic, copy) NSString *lrcname;
/** 文件名 */
@property (nonatomic, copy) NSString *filename;
/** 歌手头像 */
@property (nonatomic, copy) NSString *singerIcon;
/** 头像 */
@property (nonatomic, copy) NSString *icon;

- (instancetype) initWithDict:(NSDictionary *) dict;
+ (instancetype) musicObjectWithDict:(NSDictionary *) dict;

@end
