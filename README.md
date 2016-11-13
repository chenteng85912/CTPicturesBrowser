# CTPicturesShow
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
