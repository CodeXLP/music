//
//  MusicObject.m
//  xlp音乐
//
//  Created by 熊鲁平 on 15/8/18.
//  Copyright (c) 2015年 XLP. All rights reserved.
//

#import "MusicObject.h"

@implementation MusicObject
- (instancetype) initWithDict:(NSDictionary *) dict
{
    if (self = [super init]) {
        self.name = [dict objectForKey:@"name"];
        self.singer = [dict objectForKey:@"singer"];
        self.filename = [dict objectForKey:@"filename"];
        self.lrcname = [dict objectForKey:@"lrcname"];
        self.singerIcon = [dict objectForKey:@"singerIcon"];
        self.icon = [dict objectForKey:@"icon"];
    }
    return self;
}

+ (instancetype) musicObjectWithDict:(NSDictionary *) dict
{
    return [[self alloc] initWithDict:dict];
}

@end
