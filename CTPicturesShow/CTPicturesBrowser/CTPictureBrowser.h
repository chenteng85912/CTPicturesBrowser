//
//  CTPictureBrowser.h
//  CTPicturesShow
//
//  Created by 陈腾 on 2018/5/11.
//  Copyright © 2018年 腾. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTPictureBrowser : UIView
/**
 *展示网络图片，传入参数
 *1、图片数组(图片本身或者图片下载地址)imageArray
 *2、当前图片位置currentNum
 *3、根视图控制器rootVC
 */
+ (void)showPictureWithUrlOrImages:(NSArray * __nonnull)imageOrUrlArray
                withCurrentPageNum:(NSInteger)currentNum;


/**
 清空图片缓存
 
 @return 返回结果
 */
+ (BOOL)clearLocalImages;

@end
