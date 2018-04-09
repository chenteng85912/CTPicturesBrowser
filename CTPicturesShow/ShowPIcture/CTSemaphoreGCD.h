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

+ (CTDownloadWithSession *)oldDownloadTool:(NSString *)urlStr;

//添加上传队列
+ (void)addNewDownloadQueue:(CTDownloadWithSession *)download;

//重新上传
+ (void)reDownloadFile:(NSString *)urlStr;

//下载成功或失败
+ (void)downloadedFile:(NSString *)urlStr;

//清空下载队列
+ (void)clearAllDownloadQueue;

@end
