//
//  CTImagePath.m
//  TJBaoAnWallSDK
//
//  Created by TENG on 2017/8/22.
//  Copyright © 2017年 TENG. All rights reserved.
//

#import "CTImagePath.h"

@implementation CTImagePath

#pragma mark 获取图片地址
+ (NSString *)getImagePathWithURLstring:(NSString *)imageURL{
    NSString *fileName = [imageURL stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imgPath = [[self documentPath] stringByAppendingPathComponent:fileName];
    
    return imgPath;
}

#pragma mark 获取图片根目录
+ (NSString *)documentPath
{
    //项目名称
    NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:executableFile];
    
    BOOL isDir = YES;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if(!isExist || !isDir){
        
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return cachePath;
}

@end
