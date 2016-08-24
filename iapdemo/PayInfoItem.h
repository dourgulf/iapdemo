//
//  PayInfoItem.h
//  iapdemo
//
//  Created by 黎达文 on 16/8/22.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayInfoItem : NSObject

// 支付信息：
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *goodId;
@property (assign, nonatomic) int amount;
@property (assign, nonatomic) int price;

// 角色信息
@property (copy, nonatomic) NSString *roleInfo;

@end
