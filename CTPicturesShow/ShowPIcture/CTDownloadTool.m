//
//  DLRequest.m
//
//  Created by 腾 on 15/8/4.
//

#import "CTDownloadTool.h"

#define debugLog(...) NSLog(__VA_ARGS__)

@interface CTDownloadTool ()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *mediaData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float value;


@end
@implementation CTDownloadTool

{
    long long contentLenght;
}

//开始下载
-(void)startDownload

{
    if (self.state.integerValue==0||self.state.integerValue==3) {
        self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
        self.progress = 0;
        self.value = 0;
        self.percentStr = @"";
        [self.connection start];
    }
 
}

//取消下载
-(void)cancelDownload{
    [self.connection cancel];
    self.progress = 0;
    self.value = 0;
    self.percentStr = @"";
    self.mediaData = nil;

}
//准备接收数据
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.mediaData = [NSMutableData data];
    contentLenght = [response expectedContentLength];
    
}
//添加数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.state = @1;
    [self.mediaData appendData:data];
    self.progress = self.progress + data.length;
    self.value = self.progress/contentLenght;
    
    //浮点转百分比
    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    CFNumberFormatterRef numberFormatter = CFNumberFormatterCreate(NULL, currentLocale, kCFNumberFormatterPercentStyle);
    CFNumberRef number = CFNumberCreate(NULL, kCFNumberFloatType, &_value);
    CFStringRef numberString = CFNumberFormatterCreateStringWithNumber(NULL, numberFormatter, number);
    
    self.percentStr = [NSString stringWithFormat:@"%@",numberString];
     dispatch_async(dispatch_get_main_queue(), ^{
         
         if (contentLenght>0) //文件总长度有效
         {
             if ([self.delegate respondsToSelector:@selector(changeProgressValue:)]) {
                 [self.delegate changeProgressValue:self.percentStr];
                 
             }
         }
         

     });
   
    debugLog(@"正在下载图片.........:%@",self.percentStr);
}
//下载成功
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.state = @2;

    dispatch_async(dispatch_get_main_queue(), ^{
        //存入本地缓存
        [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:self.mediaData attributes:nil];
       
        if ([self.delegate respondsToSelector:@selector(downLoadedSuccessOrFail: withUrl:)]) {
            [self.delegate downLoadedSuccessOrFail:YES withUrl:self.URL.absoluteString];
        }
        
        self.mediaData = nil;
    });
    
    debugLog(@"下载成功,图片大小:%lld",contentLenght);
}
//下载失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.state = @3;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(downLoadedSuccessOrFail:withUrl:)]) {
            [self.delegate downLoadedSuccessOrFail:NO withUrl:nil];
        }
        self.progress = 0;
        self.value = 0;
        self.percentStr = @"";
        self.mediaData = nil;
    });
    debugLog(@"图片下载失败");

}

@end
