//
//  ViewController.m
//  libo
//
//  Created by aaron on 2017/4/9.
//  Copyright © 2017年 aaron. All rights reserved.
//


#import "ViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "SVProgressHUD.h"

static NSString *urlString = @"http://libo.toumaps.com/index.html";

@interface ViewController ()<UIWebViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) AFNetworkReachabilityManager *afnetworkReachabilityManager;
//@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIImageView *pic;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     [self cleanCacheAndCookie];
    _webView.delegate = self;
//    _webView.scrollView.scrollEnabled = NO;
    _afnetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [_afnetworkReachabilityManager startMonitoring];
    
    if (_afnetworkReachabilityManager.isReachable) {
//        [SVProgressHUD dismiss];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [self.webView loadRequest:request];
    } else {
        _timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(checkAndLoad) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _pic.hidden = YES;
        // 设置状态栏颜色
        [self setStatusBarBackgroundColor:[UIColor colorWithRed:1/255.0 green:0/255.0 blue:121/255.0 alpha:1.0]];
        // 设置状态栏字体颜色白色（UIStatusBarStyleDefault是黑色）
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _webView = nil;
    [self cleanCacheAndCookie];
}

- (void)checkAndLoad
{
    NSLog(@"%ld",(long)_afnetworkReachabilityManager.networkReachabilityStatus);
    
    if (_afnetworkReachabilityManager.isReachable) {
        
        [_timer invalidate];
        _timer = nil;
        
//        [SVProgressHUD dismiss];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [self.webView loadRequest:request];
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex) {
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//        [self.webView loadRequest:request];
//    }
//}
//
//
//- (UIAlertView *)alertView
//{
//    if (!_alertView) {
//        _alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"产业监测需要您授权使用数据,如已授权，请点击重试，或者关掉app重新打开！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重试", nil];
//    }
//    return _alertView;
//}

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

// 设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

@end
