//
//  ImagePreviewViewController.h
//  TYKYTwoLearnOneDo
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTImagePreviewViewController : UIViewController
+ (instancetype)defaultShowPicture;

/**
 *展示本地图片，传入参数
 *1、图片数组 
 *2、当前图片位置currentNum 
 *3、根视图控制器rootVC
*/
- (void)showPictureWithImages:(NSArray *)imageArray withCurrentPageNum:(NSInteger)currentNum andRootViewController:(UIViewController *)rootVC;

/**
 *展示网络图片，传入参数
 *1、图片地址数组
 *2、当前图片位置currentNum
 *3、根视图控制器rootVC
 */
- (void)showPictureWithURL:(NSArray *)urlArray withCurrentPageNum:(NSInteger)currentNum andRootViewController:(UIViewController *)rootVC;

@end
