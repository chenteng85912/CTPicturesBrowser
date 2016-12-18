//
//  ImagePreviewViewController.h
//  TYKYTwoLearnOneDo
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTDownloadTool;

@interface CTImagePreviewViewController : UIViewController

+ (instancetype)defaultShowPicture;

@property (strong, nonatomic) NSMutableArray <CTDownloadTool *> *requestArray;//下载对象

/**
 *展示网络图片，传入参数
 *1、图片(下载地址或图片)数组
 *2、当前图片位置currentNum
 *3、根视图控制器rootVC
 */
- (void)showPictureWithUrlOrImages:(NSArray *)imageArray withCurrentPageNum:(NSInteger)currentNum andRootViewController:(UIViewController *)rootVC;
;

@end
