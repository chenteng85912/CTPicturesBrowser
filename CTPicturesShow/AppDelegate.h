//
//  AppDelegate.h
//  CTPicturesShow
//
//  Created by 腾 on 16/11/13.
//  Copyright © 2016年 腾. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

