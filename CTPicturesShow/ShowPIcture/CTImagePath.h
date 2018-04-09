//
//  CTImagePath.h
//  TJBaoAnWallSDK
//
//  Created by tjsoft on 2017/8/22.
//  Copyright © 2017年 TENG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTImagePath : NSObject

#pragma mark 获取图片本地存储地址
+ (NSString *)getImagePathWithURLstring:(NSString *)imageURL;

@end
