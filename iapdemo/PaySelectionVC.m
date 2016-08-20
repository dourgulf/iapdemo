//
//  PaySelectionVC.m
//  iapdemo
//
//  Created by 黎达文 on 16/8/19.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import "PaySelectionVC.h"
#import "UIViewController+SingleHudPrompt.h"

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

+(id)toJSON:(NSString *)json
{
    NSError* e = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &e];
    
    if(e==nil) {
        return jsonObject;
    }
    else {
        NSLog(@"%@",[e localizedDescription]);
        return nil;
    }
}

- (void)requestPayWebContentWithPID:(int)pid completion:(void (^)(NSString *payInfo, NSString *cpOrderId))handler{
    NSString *serverStr = [[NSString alloc] initWithFormat:@"http://119.29.102.184:85/api.php?method=addOrderInfoLog&pid=%d&itemId=101&roleId=2048&serverId=1&accounts=sgb&roleLevel=1&gameQn=1&channel_id=1&sign=12", pid];
    NSURL *serverURL = [NSURL URLWithString:serverStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverURL];
    request.HTTPMethod = @"POST";
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
    {
        if (!connectionError) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp isKindOfClass:[NSHTTPURLResponse class]]) {
                NSString *respStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(@"respStr:%@", respStr);
                NSDictionary *json = [[self class] toJSON:respStr];
                if ([json isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = json[@"data"];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSString *payInfo = data[@"pay_info"];
                        NSString *cpOrderId = data[@"cpOrderId"];
                        if (handler) {
                            handler(payInfo, cpOrderId);
                            return ;
                        }
                    }
                }
            }
            [self hidePromptWithError:@"服务器异常, 暂时无法支付"];
        }
        else {
            NSLog(@"Connection error:%@", connectionError);
            [self hidePromptWithError:@"暂时无法发起支付"];
            [self hidePromptAfterDelay:2];
        }
    }];
}
- (IBAction)onWechatPay:(id)sender {
}

- (IBAction)onAlipay:(id)sender {
    [self requestPayWebContentWithPID:36 completion:^(NSString *payInfo, NSString *cpOrderId) {
        NSLog(@"payInfo:%@", payInfo);
        NSLog(@"cpOrderId:%@", cpOrderId);
    }];
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
