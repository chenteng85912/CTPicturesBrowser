//
//  CTPictureBrowser.m
//  CTPicturesShow
//
//  Created by 陈腾 on 2018/5/11.
//  Copyright © 2018年 腾. All rights reserved.
//

#import "CTPictureBrowser.h"
#import "CTImagePath.h"
#import "CTImageScrollView.h"

@interface CTPictureBrowser ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,CTImageScrollViewDelegate>

@property (strong, nonatomic) UICollectionView *colView;
@property (strong, nonatomic) NSArray *dataArray;//图片或者网址数据
@property (strong, nonatomic) UILabel *pageNumLabel;//页码显示

@end

NSString *const kCTPictureBrowserIdentifier = @"kCTPictureBrowserIdentifier";

@implementation CTPictureBrowser

#pragma mark 展示图片
+ (void)showPictureWithUrlOrImages:(NSArray * __nonnull)imageArray
                withCurrentPageNum:(NSInteger)currentNum{
    
    if (imageArray.count == 0) {
        return;
    }
    
    CTPictureBrowser *browser = [[CTPictureBrowser alloc] initWithImageArray:imageArray withCurrentPageNum:currentNum];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelAlert;
    browser.alpha = 0.0;
    [UIView animateWithDuration:0.1 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        browser.alpha = 1.0;

    }];

}
- (instancetype)initWithImageArray:(NSArray * __nonnull)imageArray
                withCurrentPageNum:(NSInteger)currentNum{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        if (imageArray.count<currentNum+1) {
            currentNum = imageArray.count-1;
        }
        
        self.pageNumLabel.hidden = imageArray.count==1 ?YES:NO;
   
        self.dataArray = imageArray;
        [self.colView reloadData];
    
        [self.colView setContentOffset:CGPointMake((kPictureBrowserScreenWidth+20)*currentNum, 0)];
        self.pageNumLabel.text = [NSString stringWithFormat:@"%ld/%lu",currentNum+1,(unsigned long)imageArray.count];
    }
    return self;
}
#pragma mark UICollectionViewDelegate
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:kCTPictureBrowserIdentifier forIndexPath:indexPath];
    
    [mycell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CTImageScrollView *scrView = [CTImageScrollView initWithFrame:CGRectMake(0, 0, kPictureBrowserScreenWidth, kPictureBrowserScreenHeight)
                                                            image:self.dataArray[indexPath.row]];
    scrView.scrollDelegate = self;
    [mycell.contentView addSubview:scrView];
    
    return mycell;
}

#pragma mark 正在滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int pageNum = (scrollView.contentOffset.x - (kPictureBrowserScreenWidth+20) / 2) / (kPictureBrowserScreenWidth+20) + 1;
    self.pageNumLabel.text = [NSString stringWithFormat:@"%d/%lu",pageNum+1,(long)self.dataArray.count];
    
}
+ (BOOL)clearLocalImages{
    NSString *imgsLocalPath = CTImagePath.documentPath;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:CTImagePath.documentPath ]){
        NSError *error;
        return [[NSFileManager defaultManager] removeItemAtPath:imgsLocalPath error:&error];
        
    }
    
    return YES;
}
- (void)singalTapAction{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelNormal;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (UICollectionView *)colView{
    if (!_colView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kPictureBrowserScreenWidth+10, kPictureBrowserScreenHeight);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kPictureBrowserScreenWidth+20, kPictureBrowserScreenHeight) collectionViewLayout:layout];
        colView.pagingEnabled = YES;
        colView.delegate = self;
        colView.dataSource = self;
        colView.backgroundColor= [UIColor blackColor];
        colView.directionalLockEnabled  = YES;
        colView.alwaysBounceHorizontal = YES;
        _colView = colView;

        [_colView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCTPictureBrowserIdentifier];
        
        [self addSubview:_colView];

    }
    return _colView;
}

- (UILabel *)pageNumLabel{
    if (!_pageNumLabel) {
        UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPictureBrowserScreenWidth/2-20, kPictureBrowserScreenHeight-60, 40, 26)];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.font = [UIFont systemFontOfSize:12];
        pageLabel.textColor = [UIColor whiteColor];
        pageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        pageLabel.layer.masksToBounds = YES;
        pageLabel.layer.cornerRadius = 5.0;
        _pageNumLabel = pageLabel;
        [self.colView addSubview:pageLabel];

    }
    
    return _pageNumLabel;
}

- (void)dealloc{
    NSLog(@"dealloc  %@",self);
}
@end
