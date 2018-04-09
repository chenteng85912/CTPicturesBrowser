//
//  CTImageScrollView.h
//  TYKYLibraryDemo
//
//  Created by tjsoft on 2017/11/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CTImageScrollViewDelegate <NSObject>

- (void)singalTapAction;

@end
@interface CTImageScrollView : UIScrollView

+ (instancetype)initWithFrame:(CGRect)frame
                        image:(id)imageData;

@property (nonatomic,weak) id <CTImageScrollViewDelegate> scrolDelegate;

- (void)refreshShowImage:(UIImage *)img;

@end
