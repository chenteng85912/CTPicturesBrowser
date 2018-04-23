//
//  LazyImageView.m
//  Created by 腾 on 16/6/26.
//  Copyright © 2016年 腾. All rights reserved.
//

#import "CTLazyImageView.h"
#import "CTDownloadWithSession.h"
#import "CTSemaphoreGCD.h"
#import "CTImagePath.h"

@interface CTLazyImageView ()<TJSessionDownloadToolDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *vwIndView;
@property (nonatomic, strong) UILabel *progressLabel;//下载进度
@property (nonatomic, strong) UIButton *reFreshBtn;//重新下载按钮
@property (nonatomic, strong) NSString *urlStr;//下载地址
@property (nonatomic, strong) CTDownloadWithSession *session;

@end
@implementation CTLazyImageView

#pragma mark 加载网络图片
- (void)loadFullScreenImage:(NSString*)imageURLString{
    self.image = nil;

    if (!imageURLString) {
        return;
    }
    self.urlStr = imageURLString;

    if (![self p_loadImageFromURLString:imageURLString]) {
        //显示加载进度
        [self.vwIndView startAnimating];

        [self p_downLoadImage];
    
    }

}
- (void)loadFullImage:(UIImage *)image{
    if (image) {
        self.image = image;
        self.frame = [self p_makeImageViewFrame:image];
    }
    
}
//读取本地图片
- (BOOL)p_loadImageFromURLString:(NSString *)imgUrl{
    
    NSString *filePath  = [CTImagePath getImagePathWithURLstring:imgUrl];
    
    UIImage *savedImage;
    
    NSPurgeableData *cachedData = [CTSemaphoreGCD.imageCache objectForKey:filePath];
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
            [CTSemaphoreGCD.imageCache setObject:cachedData forKey:filePath cost:cachedData.length];
        }
        [cachedData endContentAccess];
      
    }

    if (savedImage) {
        self.image = savedImage;
        self.frame = [self p_makeImageViewFrame:savedImage];
        
        return YES;
    }
   
    return NO;
    
}
//生成下载工具
- (void)p_downLoadImage{
    
    CTDownloadWithSession *request = [CTSemaphoreGCD oldDownloadTool:self.urlStr];

    //新的下载工具
    if (!request) {

        request = [CTDownloadWithSession initWithUrlStr:self.urlStr];
        [CTSemaphoreGCD addNewDownloadQueue:request forKey:self.urlStr];
    }
    
    request.delegate  = self;
    self.progressLabel.text = request.percentStr;
    
}

#pragma mark 根据图片大小设置imageview的frame
- (CGRect)p_makeImageViewFrame:(UIImage *)image{
    
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
- (void)p_reDownloadImage{
    
    [self.vwIndView startAnimating];
    self.reFreshBtn.hidden = YES;
    self.progressLabel.hidden = NO;
    
    [self p_downLoadImage];
}

#pragma mark TJSessionDownloadToolDelegate
- (void)changeProgressValue:(NSString *)progress{
    self.progressLabel.text = progress;

}
- (void)downLoadedSuccessOrFail:(BOOL)state{
    self.progressLabel.text = nil;
    self.progressLabel.hidden = state;
    [self.vwIndView stopAnimating];

    if (state) {//下载成功
        [self p_loadImageFromURLString:self.urlStr];
        self.transform = CGAffineTransformMakeScale(0.01,0.01);
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            self.transform = CGAffineTransformMakeScale(1.0,1.0);
            
        }];
    }
}

//重新下载按钮
- (UIButton *)reFreshBtn{
  
    if (_reFreshBtn==nil) {
        _reFreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _reFreshBtn.center  = self.center;
        [_reFreshBtn setImage:[UIImage imageNamed:@"ct_refresh"] forState:UIControlStateNormal];
        [_reFreshBtn addTarget:self action:@selector(p_reDownloadImage) forControlEvents:UIControlEventTouchUpInside];
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
        _progressLabel.font = [UIFont systemFontOfSize:13];
        _progressLabel.textColor = [UIColor whiteColor];
        [self addSubview:_progressLabel];

    }
    return _progressLabel;
}

@end
