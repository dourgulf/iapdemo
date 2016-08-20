//
//  UITableView+HideExtraLine.m
//  iapdemo
//
//  Created by 黎达文 on 16/8/20.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import "UITableView+HideExtraLine.h"

@implementation UITableView (HideExtraLine)

-(void)hideExtraSeperators
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.tableFooterView = view;
}

@end
