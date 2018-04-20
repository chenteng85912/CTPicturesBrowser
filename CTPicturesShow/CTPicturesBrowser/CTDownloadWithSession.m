//
//  TJSessionDownloadTool.m
//  TAIJIToolsFramework
//
//  Created by Apple on 2016/11/9.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "CTDownloadWithSession.h"
#import "CTImagePath.h"
#import "CTSemaphoreGCD.h"

@interface CTDownloadWithSession ()<NSURLSessionDownloadDelegate,NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;//下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *task;//下载请求
@property (nonatomic, copy) NSString *filePath;     //文件本地地址
@property (nonatomic, copy) NSString *urlStr;     //下载链接
@end

@implementation CTDownloadWithSession
{
    long long contentLenght;
}
+ (instancetype)initWithUrlStr:(NSString *)urlStr{
    return [[self alloc] initWithDownloadUrlStr:urlStr];
}
- (instancetype)initWithDownloadUrlStr:(NSString *)urlStr{
    self = [super init];
    if (self) {
        _urlStr = urlStr;
        _filePath = [CTImagePath getImagePathWithURLstring:urlStr];
    }
    return self;
}


//开始下载
-(void)startDownload
{
    //创建网络任务
    self.task = [self.session downloadTaskWithURL:[NSURL URLWithString:_urlStr]];

    [self.task resume];
    NSLog(@"start download task");
    self.downloadState = DownloadingState;
}

//取消下载
- (void)cancelDownload{
    if (self.task) {
        [self.task cancel];
    }
    self.task = nil;
}
#pragma mark NSURLSessionDownloadDelegate
//下载成功
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    //取消任务 防止循环引用
    [self.session invalidateAndCancel];
    self.session = nil;
    self.task = nil;

    self.downloadState = DownloadSuccessState;
    //写入缓存
   [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.filePath error:nil];
    
    //写入内存
    NSPurgeableData *purgeableData = [NSPurgeableData dataWithContentsOfFile:self.filePath];
    if (purgeableData) {
        [CTSemaphoreGCD.imageCache setObject:purgeableData forKey:self.filePath cost:purgeableData.length];
    }
    [purgeableData endContentAccess];
    
    [CTSemaphoreGCD downloadedFile:self.urlStr];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(downLoadedSuccessOrFail:)]) {
            [self.delegate downLoadedSuccessOrFail:YES];
        }
        
    });

    
}

/**
 bytesWritten               : 本次下载的字节数
 totalBytesWritten          : 已经下载的字节数
 totalBytesExpectedToWrite  : 下载总大小
 */
/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.downloadState = DownloadingState;
    contentLenght = totalBytesExpectedToWrite;
    
    float currentProgress = totalBytesWritten/(double)totalBytesExpectedToWrite;
    
    if (currentProgress>0) {
        self.percentStr = [NSString stringWithFormat:@"%@",[self makePasentFromFloat:currentProgress]];
        NSLog(@"正在下载文件...:%@",self.percentStr);

    }else{
        self.percentStr = nil;

    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(changeProgressValue:)]) {
            [self.delegate changeProgressValue:self.percentStr];
        }
        
    });

}
/** 续传的代理方法 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"续传");
}
// 由于下载失败导致的下载中断会进入此协议方法,也可以得到用来恢复的数据
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        //取消任务 防止循环引用
        [self.session invalidateAndCancel];
        self.session = nil;
        self.task = nil;
        self.downloadState = DownloadFailState;

        NSLog(@"error:%@",error.userInfo);
        [CTSemaphoreGCD downloadedFile:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.delegate respondsToSelector:@selector(downLoadedSuccessOrFail:)]) {
                [self.delegate downLoadedSuccessOrFail:self.urlStr];
            }
        });
        
    }
    
}

//浮点转百分比
- (NSString *)makePasentFromFloat:(float)value{
    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    CFNumberFormatterRef numberFormatter = CFNumberFormatterCreate(NULL, currentLocale, kCFNumberFormatterPercentStyle);
    CFNumberRef number = CFNumberCreate(NULL, kCFNumberFloatType, &value);
    CFStringRef numberString = CFNumberFormatterCreateStringWithNumber(NULL, numberFormatter, number);
    return [NSString stringWithFormat:@"%@",numberString];
    
}
#pragma mark - NSURLSessionDelegate
/*
 // 只要访问的是HTTPS的路径就会调用
 // 该方法的作用就是处理服务器返回的证书, 需要在该方法中告诉系统是否需要安装服务器返回的证书
 // 1.从服务器返回的受保护空间中拿到证书的类型
 // 2.判断服务器返回的证书是否是服务器信任的
 // 3.根据服务器返回的受保护空间创建一个证书
 // 4.创建证书 安装证书
 //   completionHandler(NSURLSessionAuthChallengeUseCredential , credential);
 */
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    //AFNetworking中的处理方式
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    //判断服务器返回的证书是否是服务器信任的
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        /*disposition：如何处理证书
         NSURLSessionAuthChallengePerformDefaultHandling:忽略证书 默认的做法
         NSURLSessionAuthChallengeUseCredential：使用指定的证书
         NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消请求,忽略证书
         NSURLSessionAuthChallengeRejectProtectionSpace 拒绝,忽略证书
         */
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    //安装证书
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    }
    return _session;
    
}
- (void)dealloc{
    
    NSLog(@"%@ CTDownloadWithSession dealloc",_urlStr);
}
@end
