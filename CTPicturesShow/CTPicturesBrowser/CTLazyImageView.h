//
//  LazyImageView.h
//  FacePk
//
//  Created by 腾 on 16/6/26.
//  Copyright © 2016年 腾. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLazyImageView : UIImageView


// 加载全屏网络图片
- (void)loadFullScreenImage:(NSString *)imageURLString;

// 直接加载图片
- (void)loadFullImage:(UIImage *)image;

@end
