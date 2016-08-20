//
//  UIViewController+SingleHudPrompt.h
//  iapdemo
//
//  Created by 黎达文 on 16/8/20.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UIViewController (SingleHudPrompt)<MBProgressHUDDelegate>

- (void)showPromptText:(NSString *)text;
- (void)hidePromptAfterDelay:(NSTimeInterval)delay;
- (void)hidePromptWithSuccess:(NSString *)text;
- (void)hidePromptWithError:(NSString *)text;

@end
