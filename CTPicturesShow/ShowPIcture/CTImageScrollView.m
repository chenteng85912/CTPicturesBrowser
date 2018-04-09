//
//  CTImageScrollView.m
//  TYKYLibraryDemo
//
//  Created by tjsoft on 2017/11/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CTImageScrollView.h"
#import "CTLazyImageView.h"

@interface CTImageScrollView ()<UIScrollViewDelegate>

@property (nonatomic,strong) CTLazyImageView *zoomImageView;

@end

@implementation CTImageScrollView

+ (instancetype)initWithFrame:(CGRect)frame image:(id)imageData{
    return [[self alloc] initWithFrame:frame image:imageData];
}
- (instancetype)initWithFrame:(CGRect)frame image:(id)imageData
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate =self;
        self.showsVerticalScrollIndicator =NO;
        self.showsHorizontalScrollIndicator =NO;
        self.maximumZoomScale = 3;
        self.minimumZoomScale = 1;

        //承载当前图片的imageview
        _zoomImageView = [[CTLazyImageView alloc] initWithFrame:self.bounds];
        if ([imageData isKindOfClass:[UIImage class]]) {
            [_zoomImageView loadFullImage:imageData];
        }
        if ([imageData isKindOfClass:[NSString class]]) {
            [_zoomImageView loadFullScreenImage:imageData];
        }
        [self addSubview:_zoomImageView];
        
        //单击消失
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:singleTapGesture];
        
        //双击放大
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self           action:@selector(doubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];

    }
    return self;
}
- (void)singleTap:(UISwipeGestureRecognizer *)gesture{
    if ([self.scrolDelegate respondsToSelector:@selector(singalTapAction)]) {
        [self.scrolDelegate singalTapAction];
    }
}
- (void)doubleTap:(UITapGestureRecognizer *)gesture {
    //点击位置 为主中心 按比例选择周围区域 放到到整个屏幕
    if (self.zoomScale > 1.0) {
        [self setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:_zoomImageView];
        CGRect newRect = [self zoomRectForScale:self.maximumZoomScale withCenter:touchPoint];;
        [self zoomToRect:newRect animated:YES];
    }
}

//获取显示区域
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;

    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}

// 图片放大缩小后位置校正
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGFloat offsetX = (self.bounds.size.width > self.contentSize.width)?
    (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.bounds.size.height > self.contentSize.height)?
    (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;

    _zoomImageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                                 self.contentSize.height * 0.5 + offsetY);
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomImageView;
}
- (void)refreshShowImage:(UIImage *)img{
    [_zoomImageView loadFullImage:img];
}
@end
