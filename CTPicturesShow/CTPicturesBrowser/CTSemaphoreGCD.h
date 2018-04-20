//
//  TYKYSemaphoreGCD.h
//  TYKYWallBaseSDK
//
//  Created by tjsoft on 2017/11/16.
//  Copyright © 2017年 TENG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTDownloadWithSession.h"

@interface CTSemaphoreGCD : NSObject

/**
 图片下载后的内存对象

 @return 内存对象
 */
+ (NSCache *)imageCache;

/**
 获取正在下载的对象

 @param urlStr 下载地址
 @return 下载对象
 */
+ (CTDownloadWithSession *)oldDownloadTool:(NSString *)urlStr;

/**
添加下载队列

 @param download 下载对象
 @param urlStr 下载地址
 */
+ (void)addNewDownloadQueue:(CTDownloadWithSession *)download
                     forKey:(NSString *)urlStr;

/**
 重新下载

 @param urlStr 下载地址
 */
+ (void)reDownloadFile:(NSString *)urlStr;

/**
 下载成功或失败

 @param urlStr 下载地址
 */
+ (void)downloadedFile:(NSString *)urlStr;


/**
 清空下载队列
 */
+ (void)clearAllDownloadQueue;

@end
