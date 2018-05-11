//
//  ViewController.m
//  CTPicturesShow
//
//  Created by 腾 on 16/11/13.
//  Copyright © 2016年 腾. All rights reserved.
//

#import "ViewController.h"
#import "CTImagePreviewViewController.h"
#import "CTPictureBrowser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)showPicAction:(id)sender {
    
    [CTPictureBrowser showPictureWithUrlOrImages:@[@"http://up.enterdesk.com/edpic_source/1b/79/40/1b7940ec78c11a7e897bf702db3a77ac.jpg"] withCurrentPageNum:0];

//    [CTImagePreviewViewController showPictureWithUrlOrImages:@[@"http://up.enterdesk.com/edpic_source/1b/79/40/1b7940ec78c11a7e897bf702db3a77ac.jpg"] withCurrentPageNum:0];
    
}

@end
