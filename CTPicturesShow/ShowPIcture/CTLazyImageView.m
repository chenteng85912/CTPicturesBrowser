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

#define Device_height   [[UIScreen mainScreen] bounds].size.height
#define Device_width    [[UIScreen mainScreen] bounds].size.width

@interface CTLazyImageView ()<TJSessionDownloadToolDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *vwIndView;
@property (nonatomic, strong) UILabel *progressLabel;//下载进度
@property (nonatomic, strong) UIButton *reFreshBtn;//重新下载按钮
@property (nonatomic, strong) NSString *urlStr;//下载地址
@property (nonatomic, assign) BOOL fullScreen;//全屏预览模式

@end
@implementation CTLazyImageView

#pragma mark 加载网络图片 默认占位图
- (void)loadImageFromURLString:(NSString*)imageURLString
              placeholderImage:(UIImage *)placeholderImage{
    self.image = placeholderImage;
    if (!imageURLString) {
        self.image = nil;
        return;
    }
    if (![self loadImageFromURLString:imageURLString]) {
        [self getDownloadToolFromTempArray:imageURLString];
        
    }
   
}
#pragma mark 加载网络图片
- (void)loadFullScreenImage:(NSString*)imageURLString{
    self.image = nil;
    self.fullScreen = YES;
    if (!imageURLString) {
        return;
    }
    if (![self loadImageFromURLString:imageURLString]) {
        //显示加载进度
        [self.vwIndView startAnimating];

        CTDownloadWithSession *request = [self getDownloadToolFromTempArray:imageURLString];
        request.delegate = self;
        self.progressLabel.text = request.percentStr;
    
    }

}

//读取本地存储图片
- (BOOL)loadImageFromURLString:(NSString *)imgUrl{
    self.urlStr = imgUrl;
    
    NSString *filePath  = [CTImagePath getImagePathWithURLstring:imgUrl];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath ])
    {
        UIImage *savedImage = [UIImage imageWithContentsOfFile:filePath];
        if (savedImage) {
            self.image = savedImage;
            if (self.fullScreen) {
                self.frame = [self makeImageViewFrame:savedImage];

            }
            return YES;
        }
        return NO;
    }
    return NO;

}
//生成下载工具
- (CTDownloadWithSession *)getDownloadToolFromTempArray:(NSString *)urlStr{
    
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
    return request;
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
    CGFloat scaleW = imageSize.width/Device_width;
    CGFloat picHeight = imageSize.height/scaleW;
    
    CGFloat picW;
    CGFloat picH;
    
    if (picHeight>Device_height) {
        CGFloat scaleH = picHeight/(Device_height);
        picW = Device_width/scaleH;
        picH = Device_height;
    }else{
        picW = Device_width;
        picH = picHeight;
    }
    
    CGRect newFrame = CGRectMake(Device_width/2-picW/2, Device_height/2-picH/2, picW, picH);
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
    if (self.fullScreen) {
        self.progressLabel.text = progress;
        
    }
    
}
- (void)downLoadedSuccessOrFail:(BOOL)state withUrl:(NSString *)urlStr{
    
    self.progressLabel.hidden = YES;
    [self.vwIndView stopAnimating];
    
    if (state) {//下载成功
        [self loadImageFromURLString:urlStr];
        
        if (self.fullScreen) {
            self.transform = CGAffineTransformMakeScale(0.01,0.01);
            [UIView animateWithDuration:0.25 animations:^{
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationCurve:7];
                self.transform = CGAffineTransformMakeScale(1.0,1.0);
                
            }];
            
            self.userInteractionEnabled = YES;
        }
        [CTSemaphoreGCD downloadedFile:urlStr];

    }else{
        //下载失败
        self.reFreshBtn.hidden = !self.fullScreen;
        [CTSemaphoreGCD downloadedFile:nil];

    }
}

//重新下载按钮
- (UIButton *)reFreshBtn{
  
    if (_reFreshBtn==nil) {
        _reFreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 60, 140, 35)];
        _reFreshBtn.layer.masksToBounds = YES;
        _reFreshBtn.layer.cornerRadius = 5.0;
        _reFreshBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _reFreshBtn.layer.borderWidth = 1.0;
        _reFreshBtn.center = self.center;
        [_reFreshBtn setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_reFreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _reFreshBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_reFreshBtn addTarget:self action:@selector(downloadImageAgain) forControlEvents:UIControlEventTouchUpInside];
        _reFreshBtn.hidden = YES;
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
        _vwIndView.center = CGPointMake(Device_width/2, Device_height/2-20);
        [self addSubview:_vwIndView];
    }
    return _vwIndView;
}
//图片下载进度
- (UILabel *)progressLabel{
    if (_progressLabel==nil) {
        _progressLabel  = [[UILabel alloc] initWithFrame:CGRectMake(Device_width/2-30, Device_height/2-10, 60, 40)];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:15];
        _progressLabel.textColor = [UIColor whiteColor];
        [self addSubview:_progressLabel];

    }
    return _progressLabel;
}
@end
