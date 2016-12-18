//
//  ImagePreviewViewController.m
//  TYKYTwoLearnOneDo
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import "CTImagePreviewViewController.h"
#import "CTDownloadTool.h"
#import "CTLazyImageView.h"

#define Device_height   [[UIScreen mainScreen] bounds].size.height
#define Device_width    [[UIScreen mainScreen] bounds].size.width

#define CTImageShowIdentifier @"CTImageShowIdentifier"

static CTImagePreviewViewController *imageShowInstance = nil;

@interface CTImagePreviewViewController ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *colView;
@property (strong, nonatomic) NSArray *dataArray;//图片或者网址数据
@property (strong, nonatomic) UILabel *pageNumLabel;//页码显示

@end

@implementation CTImagePreviewViewController

+ (instancetype)defaultShowPicture
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            imageShowInstance = [[self alloc] init];
            [imageShowInstance initUI];
            
        });
    }
    return imageShowInstance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageShowInstance = [super allocWithZone:zone];
    });
    return imageShowInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return imageShowInstance;
}

#pragma mark 界面布局
- (void)initUI{
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(Device_width+10, Device_height);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
    UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Device_width+20, Device_height) collectionViewLayout:layout];
    colView.pagingEnabled = YES;
    colView.delegate = self;
    colView.dataSource = self;
    [self.view addSubview:colView];
    colView.backgroundColor= [UIColor blackColor];
    colView.directionalLockEnabled  = YES;
    imageShowInstance.colView = colView;
    
    [self.colView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CTImageShowIdentifier];
    
    //单击返回
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [imageShowInstance.view addGestureRecognizer:singleTapGestureRecognizer];
    
    //双击放大
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [imageShowInstance.view addGestureRecognizer:doubleTapGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];

    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(Device_width/2-25, Device_height-60, 50, 30)];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    pageLabel.layer.masksToBounds = YES;
    pageLabel.layer.cornerRadius = 5.0;
    [imageShowInstance.view addSubview:pageLabel];
    imageShowInstance.pageNumLabel = pageLabel;
    imageShowInstance.requestArray = [NSMutableArray new];
    
}

#pragma mark 展示图片
- (void)showPictureWithUrlOrImages:(NSArray *)imageArray withCurrentPageNum:(NSInteger)currentNum andRootViewController:(UIViewController *)rootVC{
    [self showPicture:imageArray withCurrentPageNum:currentNum andRootViewController:rootVC];
}

- (void)showPicture:(NSArray *)imageArray withCurrentPageNum:(NSInteger)currentNum andRootViewController:(UIViewController *)rootVC{
    if (imageArray.count == 0||!rootVC) {
        return;
    }
    if (imageArray.count<currentNum+1) {
        currentNum = imageArray.count-1;
    }
    
    if (imageArray.count==1) {
        self.pageNumLabel.hidden = YES;
    }else{
        self.pageNumLabel.hidden = NO;
        
    }
    self.dataArray = imageArray;
    [self.colView reloadData];
    
    [self.colView setContentOffset:CGPointMake((Device_width+20)*currentNum, 0)];
    self.pageNumLabel.text = [NSString stringWithFormat:@"%ld/%lu",currentNum+1,(unsigned long)imageArray.count];
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [rootVC presentViewController:imageShowInstance animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];

}
#pragma mark UICollectionViewDelegate
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:CTImageShowIdentifier forIndexPath:indexPath];
    
    [mycell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIScrollView *scrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Device_width, Device_height)];
    scrView.delegate = self;
    scrView.tag = indexPath.item+2000;
    scrView.maximumZoomScale = 3.0;
    scrView.minimumZoomScale = 0.9;
    
    id obj = self.dataArray[indexPath.row];
    if ([obj isKindOfClass:[UIImage class]]) {
        UIImageView *imgView = [self makeImageView:self.dataArray[indexPath.row]];
        imgView.tag = indexPath.item+1000;
        [scrView addSubview:imgView];
    }else{
        CTLazyImageView *imgView = [[CTLazyImageView alloc] initWithFrame:scrView.frame];
        imgView.request  = [self getDownloadToolFromTempArray:self.dataArray[indexPath.item]];
        imgView.tag = indexPath.item+1000;
        [scrView addSubview:imgView];
    }
  
    [mycell.contentView addSubview:scrView];

    return mycell;
}
#pragma mark 生成或获取下载工具
- (CTDownloadTool *)getDownloadToolFromTempArray:(NSString *)urlStr{
  
    CTDownloadTool *request = nil;
    for (CTDownloadTool *req in imageShowInstance.requestArray) {
        if ([req.URL.absoluteString isEqualToString:urlStr]) {
            request = req;
            break;
        }
    }
    if (!request) {
        request = [CTDownloadTool requestWithURL:[NSURL URLWithString:urlStr]];
        [imageShowInstance.requestArray addObject:request];

    }
    return request;
}
#pragma mark 正在滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        NSInteger pageNum = (scrollView.contentOffset.x - (Device_width+20) / 2) / (Device_width+20) + 1;
        self.pageNumLabel.text = [NSString stringWithFormat:@"%ld/%lu",pageNum+1,(long)self.dataArray.count];
    }
  
}
#pragma mark 设置预览图片的大小
- (UIImageView *)makeImageView:(UIImage *)image{
    
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
    
    UIImageView *preImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, picW, picH)];
    preImg.center = CGPointMake(Device_width/2, Device_height/2);
    preImg.userInteractionEnabled = YES;
    preImg.image = image;
    
    return preImg;
    
}

#pragma mark 图片放大缩小后位置校正
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UICollectionViewCell *mycell = self.colView.visibleCells[0];
    NSIndexPath *index = self.colView.indexPathsForVisibleItems[0];
    UIScrollView *scrView = (UIScrollView *)[mycell viewWithTag:index.item+2000];
    UIImageView *imgView = (UIImageView *)[mycell viewWithTag:index.item+1000];
    
    CGFloat offsetX = (scrView.bounds.size.width > scrView.contentSize.width)?
    (scrView.bounds.size.width - scrView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrView.bounds.size.height > scrView.contentSize.height)?
    (scrView.bounds.size.height - scrView.contentSize.height) * 0.5 : 0.0;
    imgView.center = CGPointMake(scrView.contentSize.width * 0.5 + offsetX,
                                 scrView.contentSize.height * 0.5 + offsetY);
}

#pragma mark 手势放大图片
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)tmpScrollView
{
    
    UICollectionViewCell *mycell = self.colView.visibleCells[0];
    NSIndexPath *index = self.colView.indexPathsForVisibleItems[0];
    UIImageView *imgView = (UIImageView *)[mycell viewWithTag:index.item+1000];
    return imgView;
}

#pragma mark 单击图片返回
-(void)singleTap:(UITapGestureRecognizer *)gestureRecognize {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
#pragma mark 双击放大缩小
-(void)doubleTap:(UITapGestureRecognizer *)gestureRecognize {
    
    UICollectionViewCell *mycell = self.colView.visibleCells[0];
    NSIndexPath *index = self.colView.indexPathsForVisibleItems[0];
    UIScrollView *scrView = (UIScrollView *)[mycell viewWithTag:index.item+2000];
    
    if (scrView.zoomScale==1.0) {
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            scrView.zoomScale = 3.0;
            
        }];
        
    }else{
        
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            scrView.zoomScale = 1.0;
            
        }];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
