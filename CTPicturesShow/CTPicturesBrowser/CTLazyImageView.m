//
//  LazyImageView.m
//  FacePk
//
//  Created by 腾 on 16/6/26.
//  Copyright © 2016年 腾. All rights reserved.
//

#import "CTLazyImageView.h"
#import "CTDownloadWithSession.h"
#import "CTSemaphoreGCD.h"
#import "CTImagePath.h"
#import "CTImagePreviewViewController.h"

@interface CTLazyImageView ()<TJSessionDownloadToolDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *vwIndView;
@property (nonatomic, strong) UILabel *progressLabel;//下载进度
@property (nonatomic, strong) UIButton *reFreshBtn;//重新下载按钮
@property (nonatomic, strong) NSString *urlStr;//下载地址

@end
@implementation CTLazyImageView


#pragma mark 加载网络图片
- (void)loadFullScreenImage:(NSString*)imageURLString{
    self.image = nil;

    if (!imageURLString) {
        return;
    }
    if (![self loadImageFromURLString:imageURLString]) {
        //显示加载进度
        [self.vwIndView startAnimating];

        [self creatDownloadRequestAndStartDownload:imageURLString];
    
    }

}

//读取本地图片
- (BOOL)loadImageFromURLString:(NSString *)imgUrl{
    self.urlStr = imgUrl;
    
    NSString *filePath  = [CTImagePath getImagePathWithURLstring:imgUrl];
    
    UIImage *savedImage;
    
    NSCache *imgsCache = [CTImagePreviewViewController imageCache];
    NSPurgeableData *cachedData = [imgsCache objectForKey:imgUrl];
    if (cachedData) {
        //读取内存成功
        [cachedData beginContentAccess];
        savedImage = [UIImage imageWithData:cachedData];
        [cachedData endContentAccess];
    }else{
        //存入内存
        savedImage = [UIImage imageWithContentsOfFile:filePath];
        cachedData = [NSPurgeableData dataWithContentsOfFile:filePath];
        if (cachedData) {
            [imgsCache setObject:cachedData forKey:filePath cost:cachedData.length];
        }
        [cachedData endContentAccess];
      
    }
    
    if (savedImage) {
        self.image = savedImage;
        self.frame = [self makeImageViewFrame:savedImage];
        
        return YES;
    }
   
    return NO;
    
}
//生成下载工具
- (void)creatDownloadRequestAndStartDownload:(NSString *)urlStr{
    
    CTDownloadWithSession *request = [CTSemaphoreGCD oldDownloadTool:urlStr];
   
    //新的下载工具
    if (!request) {
        NSString *filePath  = [CTImagePath getImagePathWithURLstring:urlStr];

        request = [CTDownloadWithSession initWithUrlStr:urlStr filePath:filePath];
        [CTSemaphoreGCD addNewDownloadQueue:request];
        
    }else{
        if (request.downloadState==DownloadFailState) {
            [CTSemaphoreGCD reDownloadFile:self.urlStr];

        }
    }
    
    request.delegate  = self;
    self.progressLabel.text = request.percentStr;

}
- (void)loadFullImage:(UIImage *)image{
    if (image) {
        self.image = image;
        self.frame = [self makeImageViewFrame:image];
    }
    
}

#pragma mark 根据图片大小设置imageview的frame
- (CGRect)makeImageViewFrame:(UIImage *)image{
    
    CGSize imageSize = image.size;
    CGFloat scaleW = imageSize.width/kPictureBrowserScreenWidth;
    CGFloat picHeight = imageSize.height/scaleW;
    
    CGFloat picW;
    CGFloat picH;
    
    if (picHeight>kPictureBrowserScreenHeight) {
        CGFloat scaleH = picHeight/(kPictureBrowserScreenHeight);
        picW = kPictureBrowserScreenWidth/scaleH;
        picH = kPictureBrowserScreenHeight;
    }else{
        picW = kPictureBrowserScreenWidth;
        picH = picHeight;
    }
    
    CGRect newFrame = CGRectMake(kPictureBrowserScreenWidth/2-picW/2, kPictureBrowserScreenHeight/2-picH/2, picW, picH);
    return  newFrame;
}
#pragma mark 重新下载
- (void)downloadImageAgain{
    
    [self.vwIndView startAnimating];
    self.reFreshBtn.hidden = YES;
    self.progressLabel.hidden = NO;
    
    [CTSemaphoreGCD reDownloadFile:self.urlStr];
}

#pragma mark TJSessionDownloadToolDelegate
- (void)changeProgressValue:(NSString *)progress{
    self.progressLabel.text = progress;

}
- (void)downLoadedSuccessOrFail:(BOOL)state withUrl:(NSString *)urlStr{
    
    self.progressLabel.hidden = YES;
    [self.vwIndView stopAnimating];
    
    if (state) {//下载成功
        BOOL downloaded = [self loadImageFromURLString:urlStr];
        if (!downloaded) {
            //下载失败
            self.reFreshBtn.hidden = NO;
            [CTSemaphoreGCD downloadedFile:nil];
            return;
        }
        self.transform = CGAffineTransformMakeScale(0.01,0.01);
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            self.transform = CGAffineTransformMakeScale(1.0,1.0);
            
        }];
        
        self.userInteractionEnabled = YES;
        
        [CTSemaphoreGCD downloadedFile:urlStr];

    }else{
        //下载失败
        self.reFreshBtn.hidden = NO;
        [CTSemaphoreGCD downloadedFile:nil];

    }
}

//重新下载按钮
- (UIButton *)reFreshBtn{
  
    if (_reFreshBtn==nil) {
        _reFreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _reFreshBtn.center  = self.center;
        [_reFreshBtn setImage:[UIImage imageNamed:@"ct_refresh"] forState:UIControlStateNormal];
        [_reFreshBtn addTarget:self action:@selector(downloadImageAgain) forControlEvents:UIControlEventTouchUpInside];
        if (self.superview&&[self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scr = (UIScrollView *)self.superview;
            scr.maximumZoomScale = 1.0;
            [scr addSubview:self.reFreshBtn];
        }
    }
   
    return _reFreshBtn;

}

//加载toast
- (UIActivityIndicatorView *)vwIndView{
    if (_vwIndView==nil) {
        _vwIndView = [UIActivityIndicatorView new];
        _vwIndView.hidesWhenStopped = YES;
        _vwIndView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _vwIndView.center = CGPointMake(kPictureBrowserScreenWidth/2, kPictureBrowserScreenHeight/2-20);
        [self addSubview:_vwIndView];
    }
    return _vwIndView;
}
//图片下载进度
- (UILabel *)progressLabel{
    if (_progressLabel==nil) {
        _progressLabel  = [[UILabel alloc] initWithFrame:CGRectMake(kPictureBrowserScreenWidth/2-30, kPictureBrowserScreenHeight/2-10, 60, 40)];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:15];
        _progressLabel.textColor = [UIColor whiteColor];
        [self addSubview:_progressLabel];

    }
    return _progressLabel;
}
@end
