//
//  PaySelectionVC.m
//  iapdemo
//
//  Created by 黎达文 on 16/8/19.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import "PaySelectionVC.h"

@interface PaySelectionVC ()

@property (weak, nonatomic) IBOutlet UILabel *productDescrition;
@property (weak, nonatomic) IBOutlet UILabel *priceDescrition;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *amount;

@end

@implementation PaySelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
}

- (void)onClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onWechatPay:(id)sender {
}

- (IBAction)onAlipay:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
