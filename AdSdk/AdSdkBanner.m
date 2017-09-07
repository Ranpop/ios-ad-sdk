//
//  AdSdkBanner.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkBanner.h"
#import "AdSdkConfigData.h"
#import "AdSdkLogCenter.h"
#import "AdSdkWebViewControlViewController.h"

@interface AdSdkBanner () <AdSdkBannerDelegate, AdSdkWebViewControlDelegate>{
    NSInteger initStatus;
    NSDictionary *reqAd;
    
    UITapGestureRecognizer *closeTapGesRecogn;
    UITapGestureRecognizer *clickTapGesRecogn;
    
    UIImageView *imgView;
    UIImageView *closeImg;
    UILabel *tagView;
    
    NSTimer *freshTimer;
}

@end

@implementation AdSdkBanner
@synthesize adposid;
@synthesize refreshInterval;
@synthesize delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
}

-(void)paramsInit{
    initStatus = 0;
    reqAd = nil;
    
    imgView = nil;
    closeImg = nil;
    tagView = nil;
    
    freshTimer = nil;
}

-(void)initNormal{
    [self paramsInit];
    
    AdSdkConfigData *conf = [AdSdkConfigData shareConfData];
    if (1 != conf.is_okay) {
        initStatus = 0;
        [self bannerInitResult:AdSdkSlotInitFailSdkInitError];
        return;
    }
    
    BOOL hasId = NO;
    
    for (NSDictionary *dic in conf.slots) {
        if ([self.adposid isEqualToString: [dic objectForKey:@"slot_id"]]) {
            hasId = YES;
            NSInteger adposStatus = [[dic objectForKey:@"status"] integerValue];
            if (1 == adposStatus) {
                initStatus = 1;
                self.refreshInterval = [[dic objectForKey:@"refresh"] integerValue];
                [self bannerInitResult:AdSdkSlotInitSuccess];
            }else if (2 == adposStatus){
                initStatus = 0;
                [self bannerInitResult:AdSdkSlotInitFailSdkPosIdPause];
            }else{
                initStatus = 0;
                [self bannerInitResult:AdSdkSlotInitFailSdkPosIdDelete];
            }
        }
    }
    
    if (!hasId) {
        initStatus = 0;
        [self bannerInitResult:AdSdkSlotInitFailSdkPosIdError];
    }
}

-(NSDictionary *)requestBannerAd{
    NSDictionary * params = [self requestParams];
    
    NSMutableDictionary *httpHeader = [[NSMutableDictionary alloc]init];
    [httpHeader setValue:@"application/json" forKey:@"Content-Type"];
    
    AdSdkHttpRequest *adReq = [[AdSdkHttpRequest alloc]init];
    adReq.url = AdsSdkAdRequestAddress;
    adReq.httpMethod = @"post";
    adReq.params = params;
    adReq.timeout = 10;
    adReq.httpHeaderFields = httpHeader;
    adReq.delegate = nil;
    adReq.postDataType = HttpRequestPostDataTypeNormal;
    
    NSData *adRes = [adReq synchronousConnect];
    if (nil != adRes) {
        
        NSDictionary *adResDic = [AdSdkDeviceInfo JSONObjectWithData:adRes];
        
        if ((![[adResDic objectForKey:@"status"] isKindOfClass:[NSNull class]]) && (0 == [[adResDic objectForKey:@"status"] integerValue])) {
            return adResDic;
        }
    }
    return nil;
}

-(void)load{
    if ((self.refreshInterval > 0)&&(!freshTimer)) {
         __weak typeof(self)WeakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                freshTimer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval target:WeakSelf selector:@selector(load) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:freshTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop]run];
        });
    }
    
    reqAd = [self requestBannerAd];
    if (nil == reqAd|| [[reqAd objectForKey:@"creative_url"] isKindOfClass:[NSNull class]]) {
        return;
    }
    
    [self bannerDidLoading];
    
    if (!closeImg) {
        //图片关闭触发器，也就是banner关闭
        closeTapGesRecogn = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickClose)];
        
        closeImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.origin.x+self.frame.size.width-20, self.frame.origin.y, 20, 20)];
        [closeImg setImage:[UIImage imageNamed:@"AdSdk.bundle/close.png"]];
        closeImg.userInteractionEnabled = YES;
        [closeImg addGestureRecognizer:closeTapGesRecogn];
    }
    if (!tagView) {
        tagView = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.origin.x+self.frame.size.width-30, self.frame.origin.y+self.frame.size.height-20, 30, 20)];
        
        //    label.backgroundColor = [UIColor lightGrayColor];
        //    label.textAlignment = UITextAlignmentCenter;
        tagView.font = [UIFont fontWithName:@"Arial" size:15];
        tagView.text = @"广告";
    }
    if (!clickTapGesRecogn) {
        //图片点击触发器
        clickTapGesRecogn = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage)];
    }
    
    NSURL *urlString = [NSURL URLWithString:[reqAd objectForKey:@"creative_url"]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *imgData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:urlString] returningResponse:&response error:&error];
    if (nil == error && (200 == (int)[(NSHTTPURLResponse *)response statusCode])) {
        [imgView removeFromSuperview];
        [closeImg removeFromSuperview];
        [tagView removeFromSuperview];
        
        imgView = [[UIImageView alloc]initWithFrame:self.frame];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imgView setImage:[UIImage imageWithData:imgData]];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:clickTapGesRecogn];
        
        [self.superview addSubview:imgView];
        [self.superview addSubview:closeImg];
        [self.superview addSubview:tagView];
        
        [self reportViews];
        [self bannerDidLoadingFinish];
    }else{
        [self bannerDidLoadingError:AdSdkSlotImgLoadFail];
    }
}

#pragma mark views
-(void)reportViews{
    NSArray *imp_urls = [reqAd objectForKey:@"imp_url"];
    NSInteger impCount = [imp_urls count];
    __block NSInteger impRepSuccessCount = 0;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t viewQ = dispatch_queue_create("viewreport", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSString *url in imp_urls) {
        dispatch_group_enter(group);
        dispatch_group_async(group, viewQ, ^{
            NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                RLog(LD, @"View Report Code: %d", (int)[(NSHTTPURLResponse *)response statusCode]);
                if (200 == (int)[(NSHTTPURLResponse *)response statusCode]) {
                    impRepSuccessCount++;
                }
                dispatch_group_leave(group);
            }];
            
            [task resume];
        });
    }
    
    dispatch_group_notify(group, viewQ, ^{
        RLog(LD, "report views. %ld-%ld", (long)impCount, (long)impRepSuccessCount);
        [self bannerReportViewOKay];
    });
}

#pragma mark clicks
-(void)reportClicks{
    NSArray *click_urls = [reqAd objectForKey:@"click_url"];
    NSInteger clickCount = [click_urls count];
    __block NSInteger clickRepSuccessCount = 0;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t clickQ = dispatch_queue_create("clickreport", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSString *url in click_urls) {
        dispatch_group_enter(group);
        dispatch_group_async(group, clickQ, ^{
            NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                RLog(LD, @"Click Report Code: %d", (int)[(NSHTTPURLResponse *)response statusCode]);
                if (200 == (int)[(NSHTTPURLResponse *)response statusCode]) {
                    clickRepSuccessCount++;
                }
                dispatch_group_leave(group);
            }];
            
            [task resume];
        });
    }
    
    dispatch_group_notify(group, clickQ, ^{
        RLog(LD, "report clicks. %ld-%ld", (long)clickCount, (long)clickRepSuccessCount);
        [self bannerReportClickOKay];
    });
}

-(void)onClickImage{
    [freshTimer invalidate];
    freshTimer = nil;
    
    [self clickToLandingPage:[reqAd objectForKey:@"curl"]];
}

-(void)onClickClose{
    RLog(LD, @"图片被关闭");
    [freshTimer invalidate];
    
    [self removeFromSuperview];
    [imgView removeFromSuperview];
    [closeImg removeFromSuperview];
    [tagView removeFromSuperview];
}

-(NSDictionary *)requestParams{
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc]init];
    
    [body setObject:AdsSdkVersion forKey:@"apiver"];
    [body setObject: [AdSdkConfigData shareConfData].publisherid forKey:@"publisherid"];
    [body setObject: [AdSdkConfigData shareConfData].appid forKey:@"appid"];
    [body setObject: [AdSdkConfigData shareConfData].token forKey:@"token"];
    [body setObject:self.adposid forKey:@"adposid"];
    
    [body setObject:@"" forKey:@"bundleid"];
    
    [body setObject:[[AdSdkDeviceInfo shareDevice] getAdReqDeviceParams] forKey:@"device"];
    
    NSMutableDictionary *imp = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *banner = [[NSMutableDictionary alloc]init];
    [body setObject: imp forKey:@"imp"];
    [imp setObject: banner forKey:@"banner"];
    
    NSInteger w = (NSInteger)self.frame.size.width;
    NSInteger h = (NSInteger)self.frame.size.height;
    [imp setObject: [NSString stringWithFormat:@"%ld", w] forKey:@"w"];
    [imp setObject: [NSString stringWithFormat:@"%ld", h] forKey:@"h"];
    
    return body;
}

#pragma mark - click
-(void)clickToLandingPage:(NSString *)url{
    UIViewController *previewController = (UIViewController *)self.delegate;
    
    AdSdkWebViewControlViewController *webViewControl =[[AdSdkWebViewControlViewController alloc]init];
    [previewController presentViewController:webViewControl animated:YES completion:nil];
    webViewControl.webView.delegate = webViewControl;
    webViewControl.delegate = self;
    
    [webViewControl loadRequest:url];
//    [webViewControl loadHtml:landingPage];
    
//    webViewControl.htmlString = @"<p>加载中...</p>";
//    [webViewControl loadHtml];
    /*
    __block BOOL openAppStore = NO;
    __block NSString * desWebURL = nil;
    __block NSString * htmlString = nil;

    dispatch_queue_t serialQ = dispatch_queue_create("q1", DISPATCH_QUEUE_SERIAL);

    dispatch_async(serialQ, ^{
        AdSdkHttpRequest *adContent = [[AdSdkHttpRequest alloc]init];
        adContent.url = landingPage;
        adContent.httpMethod = @"GET";
        adContent.timeout = 20;
        adContent.delegate = nil;
        NSData *content = [adContent synchronousConnect];
        if (nil != content) {
            htmlString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
            webViewControl.htmlString = htmlString;
        }
    });
//
    __weak typeof(self)WeakSelf = self;
    dispatch_async(serialQ, ^{
        desWebURL =  [WeakSelf regulaerExpression:@"href=\"https://itunes.apple.com/(.)+\"" forMatchString:htmlString==nil?@"":htmlString];
        if (nil != desWebURL) {
            openAppStore = YES;
        }
    });
    
    // 4. 进入对应页面
    dispatch_async(serialQ, ^{
        // 回到主线程，进入相关页面
        dispatch_async(dispatch_get_main_queue(), ^{
            if (openAppStore) {
//                [NSThread detachNewThreadSelector:NSSelectorFromString(@"backNative") toTarget:webViewControl withObject:nil];
                
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:desWebURL] options:@{} completionHandler:nil];
                [webViewControl loadRequest:landingPage];
            }else{
//                [webViewControl loadHtml];
                [webViewControl loadRequest:landingPage];
            }
        });
    });
     */
}

-(void)bannerInitResult:(NSInteger)code{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerInitResult:")]) {
        [self.delegate bannerInitResult:code];
    }
}

-(void)bannerDidLoading{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerDidLoading")]) {
        [self.delegate bannerDidLoading];
    }
}

-(void)bannerDidLoadingFinish{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerDidLoadingFinish")]) {
        [self.delegate bannerDidLoadingFinish];
    }
}

-(void)bannerDidLoadingError:(NSInteger)error{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerDidLoadingError:")]) {
        [self.delegate bannerDidLoadingError:error];
    }
}

-(void)bannerReportViewOKay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerReportViewOKay")]) {
        [self.delegate bannerReportViewOKay];
    }
}

-(void)bannerReportClickOKay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerReportClickOKay")]) {
        [self.delegate bannerReportClickOKay];
    }
}

-(void)bannerAppStoreLoadOkay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerAppStoreLoadOkay")]) {
        [self.delegate bannerAppStoreLoadOkay];
    }
}

-(void)bannerLandingPageLoadOkay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerLandingPageLoadOkay")]) {
        [self.delegate bannerLandingPageLoadOkay];
    }
}

-(void)bannerLandingPageLoadError{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerLandingPageLoadError")]) {
        [self.delegate bannerLandingPageLoadError];
    }
}

-(void)bannerDidDismissScreen{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"bannerDidDismissScreen")]) {
        [self.delegate bannerDidDismissScreen];
    }
}

-(void)webViewLoadSuccess{
    [self reportClicks];
    [self bannerLandingPageLoadOkay];
}

-(void)webViewLoadFail{
    [self bannerLandingPageLoadError];
}

-(void)webViewLoadOpenAppStore{
    [self bannerAppStoreLoadOkay];
}

-(void)webViewClose{
    RLog(LD, @"loadingpage loa okay, restart load timer.%@", freshTimer);
    if ((self.refreshInterval > 0)&&(!freshTimer)) {
        __weak typeof(self)WeakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            freshTimer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval target:WeakSelf selector:@selector(load) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:freshTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop]run];
        });
    }
}

@end
