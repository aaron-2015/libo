//
//  ViewController.m
//  libo
//
//  Created by aaron on 2017/4/9.
//  Copyright © 2017年 aaron. All rights reserved.
//


#import "ViewController.h"
#import "AFNetworkReachabilityManager.h"

static NSString *urlString = @"http://libo.toumaps.com/index.html";

@interface ViewController ()<UIWebViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) AFNetworkReachabilityManager *afnetworkReachabilityManager;
@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _webView.delegate = self;
    _afnetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    __weak typeof(self) weakSelf = self;
    [_afnetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"%ld",(long)status);
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusNotReachable:
            {
                [weakSelf.alertView show];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                [weakSelf.afnetworkReachabilityManager stopMonitoring];
                [weakSelf.alertView dismissWithClickedButtonIndex:0 animated:YES];
                
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
                [weakSelf.webView loadRequest:request];
            }
                break;
            default:
                break;
        }
    }];
    
    [_afnetworkReachabilityManager startMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _webView = nil;
    [self cleanCacheAndCookie];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [self.webView loadRequest:request];
    }
}


- (UIAlertView *)alertView
{
    if (!_alertView) {
        _alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"产业监测需要您授权使用数据,如已授权，请点击重试，或者关掉app重新打开！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重试", nil];
    }
    return _alertView;
}

/**清除缓存和cookie*/

- (void)cleanCacheAndCookie{
    
    //清除cookies
    
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies]){
        
        [storage deleteCookie:cookie];
        
    }
    
    //清除UIWebView的缓存
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURLCache * cache = [NSURLCache sharedURLCache];
    
    [cache removeAllCachedResponses];
    
    [cache setDiskCapacity:0];
    
    [cache setMemoryCapacity:0];
    
}


@end
