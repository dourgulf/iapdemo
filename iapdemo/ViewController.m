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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *productTextField;
@property (weak, nonatomic) IBOutlet UILabel *paymentResultLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *payingActivity;


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

- (IBAction)onAppleBuy:(id)sender {
    
    NSString *productString = self.productTextField.text;
    if(![IAPShare sharedHelper].iap) {
        NSSet* dataSet = [[NSSet alloc] initWithObjects:productString, nil];
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    
    [IAPShare sharedHelper].iap.production = NO;
    
    [self.payingActivity startAnimating];
    
    self.paymentResultLabel.text = @"正在请求产品信息...";
    
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         if(response > 0 ) {
             self.paymentResultLabel.text = @"发起支付...";
             SKProduct* product =[[IAPShare sharedHelper].iap.products objectAtIndex:0];
             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans)
             {
                 if(trans.error)
                 {
                     NSLog(@"Fail %@",[trans.error localizedDescription]);
                     self.paymentResultLabel.text = [trans.error localizedDescription];
                     [self.payingActivity stopAnimating];
                 }
                 else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                     self.paymentResultLabel.text = @"本地验证支付...";
                     
                     // 为了防止本地破解, 这一步应该放在后台进行
                     [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:@"your sharesecret" onCompletion:^(NSString *response, NSError *error) {
                         
                         //Convert JSON String to NSDictionary
                         NSDictionary* rec = [IAPShare toJSON:response];
                         
                         if([rec[@"status"] integerValue]==0)
                         {
                             
                             [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                             NSLog(@"SUCCESS %@",response);
                             NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);

                             self.paymentResultLabel.text = @"验证成功, 购买完成.";
                             [self.payingActivity stopAnimating];
                         }
                         else {
                             self.paymentResultLabel.text = @"验证失败.";
                             NSLog(@"Fail:%@", rec);
                             [self.payingActivity stopAnimating];
                         }
                     }];
                 }
                 else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                     NSLog(@"Fail");
                     self.paymentResultLabel.text = @"支付失败.";
                     [self.payingActivity stopAnimating];
                 }
             }];//end of buy product
         }
     }];
}

- (IBAction)onCaifutongPlay:(id)sender {
    PaySelectionVC *selection = [[PaySelectionVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selection];
//    [self.navigationController pushViewController:nav animated:NO];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
