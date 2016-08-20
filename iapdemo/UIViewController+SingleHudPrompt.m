//
//  UIViewController+SingleHudPrompt.m
//  iapdemo
//
//  Created by 黎达文 on 16/8/20.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+SingleHudPrompt.h"

static int promptingHUDKey = 0;

@implementation UIViewController (SingleHudPrompt)

- (MBProgressHUD *)publicHUD {
    MBProgressHUD *_promptingHUD = objc_getAssociatedObject(self, &promptingHUDKey);
    if (!_promptingHUD) {
        _promptingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _promptingHUD.delegate = self;
        objc_setAssociatedObject(self, &promptingHUDKey, _promptingHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _promptingHUD;
}

- (void)showPromptText:(NSString *)text {
    MBProgressHUD *prompt = [self publicHUD];
    if (text) {
        prompt.label.text = text;
    }
}

- (void)hidePromptAfterDelay:(NSTimeInterval)delay {
    [[self publicHUD] hideAnimated:YES afterDelay:delay];
}

- (void)hidePromptWithSuccess:(NSString *)text {
    MBProgressHUD *prompt = [self publicHUD];
    
    prompt.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"ok-mark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    prompt.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    prompt.square = YES;
    if (text) {
        prompt.label.text = text;
    }
    [prompt hideAnimated:YES afterDelay:1.0f];
}

- (void)hidePromptWithError:(NSString *)text {
    MBProgressHUD *prompt = [self publicHUD];
    
    prompt.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"close-mark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    prompt.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    prompt.square = YES;
    if (text) {
        prompt.label.text = text;
    }
    [prompt hideAnimated:YES afterDelay:3.0f];
}

#pragma mark HUD的回调
- (void)hudWasHidden:(MBProgressHUD *)hud {
    MBProgressHUD *_promptingHUD = objc_getAssociatedObject(self, &promptingHUDKey);
    
    if (_promptingHUD == hud) {
        _promptingHUD = nil;
        objc_setAssociatedObject(self, &promptingHUDKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
