//
//  ImagePreviewViewController.h
//  TYKYTwoLearnOneDo
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 深圳太极云软技术股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTDownloadWithSession;

@interface CTImagePreviewViewController : UIViewController

/**
 *展示网络图片，传入参数
 *1、图片数组(图片本身或者图片下载地址)imageArray
 *2、当前图片位置currentNum
 *3、根视图控制器rootVC
 */
+ (void)showPictureWithUrlOrImages:(NSArray *)imageOrUrlArray
                withCurrentPageNum:(NSInteger)currentNum;


@end
