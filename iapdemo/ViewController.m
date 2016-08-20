//
//  ViewController.m
//  iapdemo
//
//  Created by jinchu darwin on 16/8/19.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import "ViewController.h"
#import "IAPShare.h"
#import "PaySelectionVC.h"
#import "UIViewController+SingleHudPrompt.h"

@interface ViewController ()<MBProgressHUDDelegate> {
    MBProgressHUD *_promptingHUD;
}

@property (weak, nonatomic) IBOutlet UILabel *paymentResultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 用户操作
- (IBAction)onAppleBuy:(id)sender {
    
    NSString *productString = @"top.dawenhing.iap01";
    // 先在iPhone手机注销你自己的AppStore的账号
    // 用测试账号iaptest@dawenhing.top， 密码Zz1234567&
    
    if(![IAPShare sharedHelper].iap) {
        NSSet* dataSet = [[NSSet alloc] initWithObjects:productString, nil];
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    
    [IAPShare sharedHelper].iap.production = NO;
    
    [self showPromptText:@"正在请求产品信息..."];
    
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         SKProduct* product =[[IAPShare sharedHelper].iap.products firstObject];
         if(response > 0 && product != nil) {
             [self showPromptText:@"发起支付..."];

             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans)
             {
                 if(trans.error)
                 {
                     NSLog(@"Fail %@",[trans.error localizedDescription]);
                     [self hidePromptWithError:[trans.error localizedDescription]];
                     self.paymentResultLabel.text = [trans.error localizedDescription];
                     
                 }
                 else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                     [self showPromptText:@"发起本地订单验证..."];
                     
                     // 为了防止本地破解, 这一步应该放在后台进行
                     [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:@"your sharesecret" onCompletion:^(NSString *response, NSError *error) {
                         
                         //Convert JSON String to NSDictionary
                         NSDictionary* rec = [IAPShare toJSON:response];
                         
                         if([rec[@"status"] integerValue]==0)
                         {
                             
                             [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                             NSLog(@"SUCCESS %@",response);
                             NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);

                             [self hidePromptWithSuccess: @"验证成功, 购买完成."];
                             self.paymentResultLabel.text = @"验证成功, 购买完成.";
                         }
                         else {
                             [self hidePromptWithError:@"验证失败."];
                             NSLog(@"Fail:%@", rec);
                             self.paymentResultLabel.text = @"验证失败.";
                         }
                     }];
                 }
                 else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                     NSLog(@"Fail");
                     [self hidePromptWithError:@"支付失败."];
                     self.paymentResultLabel.text = @"支付失败.";
                 }
             }];//end of buy product
         }
         else {
             [self hidePromptWithError:@"获取不到产品信息, 请稍后再试"];
             self.paymentResultLabel.text = @"获取不到产品信息";
         }
     }];
}

- (IBAction)onCaifutongPlay:(id)sender {
    PaySelectionVC *selection = [[PaySelectionVC alloc] init];
    selection.productDescrition = @"购买500金币";
    selection.priceDescrition = @"1元购买500金币";
    selection.quantity = @"数量：1";
    selection.amount = @"总价：￥1";
    [self presentViewController:selection animated:YES completion:nil];
}

@end
