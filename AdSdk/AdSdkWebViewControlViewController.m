//
//  AdSdkWebViewControlViewController.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/25.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkWebViewControlViewController.h"
#import "AdSdkLogCenter.h"

@interface AdSdkWebViewControlViewController ()

@property (nonatomic, strong)UINavigationBar *navBar;

@property (nonatomic, assign) BOOL theBool;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation AdSdkWebViewControlViewController
@synthesize htmlString;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
//    self.webView.allowsInlineMediaPlayback = YES;
    [self.webView setScalesPageToFit:YES];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '150%'"];
    
    [self.view addSubview:self.webView];
    
    self.navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
    UINavigationItem *navItem = [[UINavigationItem alloc]initWithTitle:@""];
    [navItem setLeftBarButtonItem: [self backItem]];
    [self.navBar pushNavigationItem:navItem animated:YES];
    [self.view addSubview:self.navBar];
    
    [self addLeftButton];
    [self addProgressBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)addLeftButton{
    [self backItem];
}

- (void)loadHtml:(NSString *)url{
//    [self.webView loadHTMLString:self.htmlString baseURL:nil];
    
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:url]]) {
        RLog(LD, @"------yes i can do it");
    }else{
       RLog(LD, @"-----no, i can not do it");
    }

         NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
         NSURLSession *session = [NSURLSession sharedSession];
         NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
             RLog(LD, @"Request html Code: %d", (int)[(NSHTTPURLResponse *)response statusCode]);
             if (nil == error) {
                 NSString *htmlStringTmp = nil;
                 NSString *desWebURL = nil;
                 htmlStringTmp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                 desWebURL = [self regulaerExpression:@"href=\"https://itunes.apple.com/(.)+\"" forMatchString:htmlStringTmp==nil?@"":htmlStringTmp];
                 if (nil != desWebURL) {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:desWebURL] options:@{} completionHandler:nil];
                 }else{
                     [self.webView loadHTMLString:htmlStringTmp baseURL:[NSURL URLWithString:url]];
                 }
             }
         }];
         
         [task resume];
}


#pragma mark - regex url
-(NSString *)regulaerExpression:(NSString *)expression forMatchString:(NSString *)matchString{
    
    NSString *desWebURL = nil;
    NSString *searchText = matchString;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    if (result) {
        NSString *matchString = [searchText substringWithRange:result.range];
        desWebURL = [matchString substringWithRange:NSMakeRange(11, matchString.length-12)];
        //        desWebURL = [NSString stringWithFormat:@"https%@", desWebURL];
        desWebURL = [NSString stringWithFormat:@"itms-apps%@", desWebURL];
        
        RLog(LD, @"appStore: %@", desWebURL);
    }
    
    return desWebURL;
}

-(void)loadRequest:(NSString *)url{
    NSURL *urlStr = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:urlStr]];
}

#pragma mark - UIWebViewDelegate
//设置webview的title为导航栏的title
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    RLog(LD, @"加载完成");
    self.theBool = true; //加载完毕后，进度条完成
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [self webViewLoadSuccess];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    RLog(LD, @"加载错误：%ld,%@", (long)error.code, error.domain);
    
    //跳转appStore
    if (102 == error.code && [error.domain isEqualToString:@"WebKitErrorDomain"]) {
        [self webViewLoadOpenAppStore];
        [self webViewLoadSuccess];
    }else{
        [self webViewLoadFail];
    }
    
    self.theBool = true;
}

- (void)backNative{
    RLog(LD, @"关闭落地页");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self webViewClose];
}

#pragma mark - init

- (UIBarButtonItem *)backItem{
    return  [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backNative)];
}

- (void)addProgressBar{
    // 仿微信进度条
    CGFloat progressBarHeight = 0.5f;
    CGRect navigationBarBounds = self.navBar.bounds;
    CGRect barFrame = CGRectMake(0, 40, navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.trackTintColor = [UIColor grayColor]; //背景色
    self.progressView.progressTintColor = [UIColor blueColor]; //进度色
    [self.navBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //移除progressView  because UINavigationBar is shared with other ViewControllers
    [self.progressView removeFromSuperview];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    RLog(LD, @"加载开始");

    NSURL *url = [webView.request mainDocumentURL];
    NSLog(@"The Redirected URL is: %@", url);
    
    self.progressView.progress = 0;
    self.theBool = false;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)timerCallback{
    if (self.theBool) {
        if (self.progressView.progress >= 1) {
            self.progressView.hidden = true;
            [self.timer invalidate];
        } else {
            self.progressView.progress += 0.1;
        }
    } else {
        self.progressView.progress += 0.1;
        if (self.progressView.progress >= 0.9) {
            self.progressView.progress = 0.9;
        }
    }
}

-(void)webViewLoadSuccess{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"webViewLoadSuccess")]) {
        [self.delegate webViewLoadSuccess];
    }
}

-(void)webViewLoadFail{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"webViewLoadFail")]) {
        [self.delegate webViewLoadFail];
    }
}

-(void)webViewLoadOpenAppStore{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"webViewLoadOpenAppStore")]) {
        [self.delegate webViewLoadOpenAppStore];
    }
}

-(void)webViewClose{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"webViewClose")]) {
        [self.delegate webViewClose];
    }
}

@end
