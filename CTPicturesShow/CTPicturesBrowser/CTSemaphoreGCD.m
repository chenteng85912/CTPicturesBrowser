//
//  TYKYSemaphoreGCD.m
//  TYKYWallBaseSDK
//
//  Created by tjsoft on 2017/11/16.
//  Copyright © 2017年 TENG. All rights reserved.
//

#import "CTSemaphoreGCD.h"

//同时最大下载数量
NSInteger const maxNum = 99;

@interface CTSemaphoreGCD ()

//待上传队列
@property (strong, nonatomic) NSMutableDictionary <NSString *,CTDownloadWithSession *> *prepareUploadArray;

@property (strong, nonatomic) dispatch_queue_t uploadQueue;//队列

@property (strong, nonatomic) dispatch_semaphore_t uploadSemaphore;//信号量

@end

@implementation CTSemaphoreGCD

+ (CTSemaphoreGCD *)shareSemaphoreGCD{
    static CTSemaphoreGCD *UploadGCD = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UploadGCD = [self new];
       
        UploadGCD.prepareUploadArray = [NSMutableDictionary new];
        UploadGCD.uploadQueue =  dispatch_queue_create("CTImageSemaphoreGCD", DISPATCH_QUEUE_CONCURRENT);
        UploadGCD.uploadSemaphore = dispatch_semaphore_create(maxNum);

        NSLog(@"同时上传数量：%ld",(long)maxNum);

    });
    return UploadGCD;
}

+ (CTDownloadWithSession *)oldDownloadTool:(NSString *)urlStr{
    if (!urlStr) {
        return nil;
    }
    return [self shareSemaphoreGCD].prepareUploadArray[urlStr];
}
+ (void)addNewDownloadQueue:(CTDownloadWithSession *)download{
    [[self shareSemaphoreGCD].prepareUploadArray setObject:download forKey:download.urlStr];
    [self startDownload:download];
}
//重新上传
+ (void)reDownloadFile:(NSString *)urlStr{
    CTDownloadWithSession *session = [self shareSemaphoreGCD].prepareUploadArray[urlStr];
    [self startDownload:session];
}
//开发上传
+ (void)startDownload:(CTDownloadWithSession *)uploadFile{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        void (^task)(void) = ^{
            dispatch_semaphore_wait([self shareSemaphoreGCD].uploadSemaphore, DISPATCH_TIME_FOREVER);

            [uploadFile startDownload];

        };
        dispatch_async([self shareSemaphoreGCD].uploadQueue, task);

    });
  
}
//上传成功或失败
+ (void)downloadedFile:(NSString *)urlStr{
  
    dispatch_semaphore_signal([self shareSemaphoreGCD].uploadSemaphore);

    if (!urlStr) {
        return;
    }
    @synchronized(self) {
        //上传成功移除 上传工具
        [[self shareSemaphoreGCD].prepareUploadArray removeObjectForKey:urlStr];

    }

}
//清空所有上传队列
+ (void)clearAllDownloadQueue{
    
    for (CTDownloadWithSession *upload in [self shareSemaphoreGCD].prepareUploadArray.allValues) {
        if (upload.downloadState==DownloadingState) {
            [upload cancelDownload];
            dispatch_semaphore_signal([self shareSemaphoreGCD].uploadSemaphore);

        }
    }

    [[self shareSemaphoreGCD].prepareUploadArray removeAllObjects];
}
@end
