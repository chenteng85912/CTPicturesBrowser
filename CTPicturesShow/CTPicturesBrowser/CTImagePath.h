//
//  CTImagePath.h
//  TJBaoAnWallSDK
//
//  Created by tjsoft on 2017/8/22.
//  Copyright © 2017年 TENG. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPictureBrowserScreenHeight   [[UIScreen mainScreen] bounds].size.height
#define kPictureBrowserScreenWidth    [[UIScreen mainScreen] bounds].size.width

@interface CTImagePath : NSObject

/**
 单张图片存储的本地地址

 @param imageURL 图片下载地址
 @return 返回图片存储的本地地址
 */
+ (NSString *)getImagePathWithURLstring:(NSString *)imageURL;


/**
 图片存储的根目录
 
 @return 返回根目录
 */
+ (NSString *)documentPath;

@end
