//
//  PaySelectionVC.m
//  iapdemo
//
//  Created by 黎达文 on 16/8/19.
//  Copyright © 2016年 dawenhing.top. All rights reserved.
//

#import "PaySelectionVC.h"
#import "UIViewController+SingleHudPrompt.h"
#import "UITableView+HideExtraLine.h"
#import "PBWebViewController.h"

@interface PaySelectionVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *productLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) IBOutlet UITableView *payWayTable;
@property (strong, nonatomic) NSArray *paymentWays;

@end

@implementation PaySelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productLabel.text = self.infoItem.name;
    self.priceLabel.text = [[NSString alloc] initWithFormat:@"%@元购买%@", @(self.infoItem.price), self.infoItem.name];
    self.quantityLabel.text = [[NSString alloc] initWithFormat:@"数量：%@", @(self.infoItem.amount)];
    self.amountLabel.text = [[NSString alloc] initWithFormat:@"总价：%@", @(self.infoItem.price * self.infoItem.amount)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onCloseClicked:)];
    // 后续子视图的导航返回统一用这个title。
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.payWayTable.delegate = self;
    self.payWayTable.dataSource = self;
    self.payWayTable.scrollEnabled = NO;
    [self.payWayTable hideExtraSeperators];
    
    NSString *configFile = [[NSBundle mainBundle] pathForResource:@"payways" ofType:@"plist"];
    self.paymentWays = [[NSArray alloc] initWithContentsOfFile:configFile];
}


- (IBAction)onCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 支付方式表

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.paymentWays.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"payway"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"payway"];
        cell.contentView.backgroundColor = tableView.backgroundColor;
        cell.backgroundColor = cell.contentView.backgroundColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *config = [self.paymentWays objectAtIndex:indexPath.row
                            ];
    NSString *title = config[@"title"];
    NSString *icon = config[@"icon"];
    cell.imageView.image = [UIImage imageNamed:icon];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *config = [self.paymentWays objectAtIndex:indexPath.row];
    NSString *request = config[@"request"];
    NSURL *serverURL = [self formatRequst:request];
    [self getPayInfoFromURL:serverURL completion:^(NSString *payInfo, NSString *cpOrderId) {
        [self presentPayWeb:payInfo withOrderId:cpOrderId];
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSURL *)formatRequst:(NSString *)request {
    NSString *formatted = [[NSString alloc] initWithFormat:request, self.infoItem.goodId, self.infoItem.roleInfo];
#ifdef DEBUG
    NSLog(@"server URL:\n%@", formatted);
#endif
    return [NSURL URLWithString:formatted];
}

#pragma mark 支付请求
- (void)getPayInfoFromURL:(NSURL *)serverURL
                   completion:(void (^)(NSString *payInfo, NSString *cpOrderId))handler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverURL];
    request.HTTPMethod = @"POST";
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
    {
        if (!connectionError) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp isKindOfClass:[NSHTTPURLResponse class]]) {
                NSString *respStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary *json = [[self class] toJSON:respStr];
                if ([json isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = json[@"data"];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSString *payInfo = data[@"pay_info"];
                        NSString *cpOrderId = data[@"cpOrderId"];
                        // 类型保护
                        if ([payInfo isKindOfClass:[NSNull class]]) {
                            payInfo = nil;
                        }
                        if ([cpOrderId isKindOfClass:[NSNull class]]) {
                            cpOrderId = nil;
                        }
                        if (handler) {
                            handler(payInfo, cpOrderId);
                            return ;
                        }
                    }
                }
            }
            [self hidePromptWithError:@"服务器异常，请联系客服"];
        }
        else {
            NSLog(@"Connection error:%@", connectionError);
            [self hidePromptWithError:@"网络异常，请稍后再试"];
        }
    }];
}

- (void)presentPayWeb:(NSString *)html withOrderId:(NSString *)cpOrderId {
    if (html) {
        PBWebViewController *web = [[PBWebViewController alloc] init];
        web.HTMLContent = html;
#ifdef DEBUG
        NSLog(@"payweb:\n%@", html);
#endif
        web.title = @"正在加载支付界面";
        [self.navigationController pushViewController:web animated:YES];
    }
    else {
        [self hidePromptWithError:@"服务器异常，请联系客服"];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma makr 工具方法
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

@end
