//
//  PaySelectionVC.m
//  iapdemo
//
//  Created by 黎达文 on 16/8/19.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import "PaySelectionVC.h"

@interface PaySelectionVC ()

@property (weak, nonatomic) IBOutlet UILabel *productLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation PaySelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productLabel.text = self.productDescrition;
    self.priceLabel.text = self.priceDescrition;
    self.quantityLabel.text = self.quantity;
    self.amountLabel.text = self.amount;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
