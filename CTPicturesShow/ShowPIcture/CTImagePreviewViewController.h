//
//  ImagePreviewViewController.h
//
//  Created by teng on 16/7/22.
//

#import <UIKit/UIKit.h>

@class CTDownloadTool;

@interface CTImagePreviewViewController : UIViewController

+ (instancetype)defaultShowPicture;

@property (strong, nonatomic) NSMutableArray <CTDownloadTool *> *requestArray;//下载对象

/**
 *展示网络图片，传入参数
 *1、图片数组(图片本身或者图片下载地址)imageArray
 *2、当前图片位置currentNum
 *3、根视图控制器rootVC
 */
- (void)showPictureWithUrlOrImages:(NSArray *)imageArray withCurrentPageNum:(NSInteger)currentNum andRootViewController:(UIViewController *)rootVC;
;

@end
