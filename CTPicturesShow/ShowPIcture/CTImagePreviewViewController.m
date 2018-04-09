//
//  ImagePreviewViewController.m
//  TYKYTwoLearnOneDo
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import "CTImagePreviewViewController.h"
#import "CTImageScrollView.h"

#define Device_height   [[UIScreen mainScreen] bounds].size.height
#define Device_width    [[UIScreen mainScreen] bounds].size.width

NSString *const CTImageShowIdentifier = @"CTImageShowIdentifier";

@interface CTImagePreviewViewController ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,CTImageScrollViewDelegate>

@property (strong, nonatomic) UICollectionView *colView;
@property (strong, nonatomic) NSArray *dataArray;//图片或者网址数据
@property (strong, nonatomic) UILabel *pageNumLabel;//页码显示

@end

@implementation CTImagePreviewViewController


#pragma mark 单例
+ (instancetype)defaultShowPicture
{

    @synchronized(self){
        static CTImagePreviewViewController *imageShowInstance = nil;
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            imageShowInstance = [[self alloc] init];
            
        });
        return imageShowInstance;
    }
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
    self.colView = colView;
    
    [self.colView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CTImageShowIdentifier];

    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(Device_width/2-20, Device_height-60, 40, 26)];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.font = [UIFont systemFontOfSize:13];
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    pageLabel.layer.masksToBounds = YES;
    pageLabel.layer.cornerRadius = 5.0;
    [self.view addSubview:pageLabel];
    self.pageNumLabel = pageLabel;
    
}

#pragma mark 展示图片
+ (void)showPictureWithUrlOrImages:(NSArray * __nonnull)imageArray
                withCurrentPageNum:(NSInteger)currentNum{
    
    if (imageArray.count == 0) {
        return;
    }
    [[self defaultShowPicture] initUI];

    [[self defaultShowPicture] showPicture:imageArray withCurrentPageNum:currentNum];
}

- (void)showPicture:(NSArray *__nonnull)imageArray
 withCurrentPageNum:(NSInteger)currentNum{

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
    
    [[self p_currentViewController] presentViewController:self animated:YES completion:nil];
    
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
    UICollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:CTImageShowIdentifier forIndexPath:indexPath];
    
    [mycell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CTImageScrollView *scrView = [CTImageScrollView initWithFrame:CGRectMake(0, 0, Device_width, Device_height)
                                  image:self.dataArray[indexPath.row]];
    scrView.scrolDelegate = self;
    [mycell.contentView addSubview:scrView];

    return mycell;
}

#pragma mark 正在滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int pageNum = (scrollView.contentOffset.x - (Device_width+20) / 2) / (Device_width+20) + 1;
    self.pageNumLabel.text = [NSString stringWithFormat:@"%d/%lu",pageNum+1,(long)self.dataArray.count];
  
}

#pragma mark CTImageScrollViewDelegate
- (void)singalTapAction {
   
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}

//获取最顶部控制器
- (UIViewController *)p_currentViewController {
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        }else if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

@end
