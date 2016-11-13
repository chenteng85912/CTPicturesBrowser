//
//  DLRequest.h
//  Instaver
//
//  Created by 腾 on 15/8/4.
//  Copyright (c) 2015年 Raman Soni. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJDownloadTooltDelegate <NSObject>

- (void)changeProgressValue:(NSString *)value;//发送下载进度
- (void)downLoadedSuccessOrFail:(BOOL)state withUrl:(NSString *)dataUrl;;//下载成功或失败

@end

@interface CTDownloadTool : NSMutableURLRequest

@property (nonatomic, weak) id <TJDownloadTooltDelegate>delegate;

@property (nonatomic, strong) NSString *percentStr;//下载进度百分比
@property (nonatomic, strong) NSNumber *state; //0未下载 1正在下载 2下载成功 3下载失败
@property (nonatomic, strong) NSString *filePath;//下载完成后存入的本地路径
//开始下载
-(void)startDownload;
//-(void)cancelDownload;
@end
