//
//  CTImageScrollView.h
//  TYKYLibraryDemo
//
//  Created by TENG on 2017/11/21.
//  Copyright © 2017年 TENG. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CTImageScrollViewDelegate <NSObject>

- (void)singalTapAction;

@end
@interface CTImageScrollView : UIScrollView

@property (nonatomic,weak) id <CTImageScrollViewDelegate> scrollDelegate;

+ (instancetype)initWithFrame:(CGRect)frame
                        image:(id)imageData;


- (void)refreshShowImage:(UIImage *)img;

@end
