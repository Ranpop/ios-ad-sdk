//
//  AdSdkInterstital.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/5/8.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkInterstital.h"
#import "AdSdkConfigData.h"
#import "AdSdkLogCenter.h"
#import "AdSdkPopView.h"
#import "AdSdkWebViewControlViewController.h"

@interface AdSdkInterstital () <AdSdkInterstitalDelegate, AdSdkPopViewDelegate,AdSdkWebViewControlDelegate>{
    NSInteger initStatus;
    NSDictionary *reqAd;
    
    UIImageView *imgView;
//    UIImageView *closeImg;
//    UILabel *tagView;
}
@end

@implementation AdSdkInterstital
@synthesize adposid;
@synthesize delegate;
@synthesize viewFrame;

+(AdSdkInterstital *)shareInterstital {
    static AdSdkInterstital * shareInterIns = nil;
    if (!shareInterIns) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareInterIns = [[self alloc]init];
        });
    }
    
    return shareInterIns;
}

-(void)initNormal{
    imgView = nil;
    initStatus = 0;
    reqAd = nil;
    
    AdSdkConfigData *conf = [AdSdkConfigData shareConfData];
    if (1 != conf.is_okay) {
        initStatus = 0;
        [self interstitalInitResult:AdSdkInterstitalInitFailSdkInitError];
        return;
    }
    
    BOOL hasId = NO;
    
    for (NSDictionary *dic in conf.slots) {
        if ([self.adposid isEqualToString: [dic objectForKey:@"slot_id"]]) {
            hasId = YES;
            NSInteger adposStatus = [[dic objectForKey:@"status"] integerValue];
            if (1 == adposStatus) {
                initStatus = 1;
                [self interstitalInitResult:AdSdkInterstitalInitSuccess];
            }else if (2 == adposStatus){
                initStatus = 0;
                [self interstitalInitResult:AdSdkInterstitalInitFailSdkPosIdPause];
            }else{
                initStatus = 0;
                [self interstitalInitResult:AdSdkInterstitalInitFailSdkPosIdDelete];
            }
        }
    }
    
    if (!hasId) {
        initStatus = 0;
        [self interstitalInitResult:AdSdkInterstitalInitFailSdkPosIdError];
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
    
    NSInteger w = (NSInteger)viewFrame.size.width;
    NSInteger h = (NSInteger)viewFrame.size.height;
    [imp setObject: [NSString stringWithFormat:@"%ld", w] forKey:@"w"];
    [imp setObject: [NSString stringWithFormat:@"%ld", h] forKey:@"h"];
    
    return body;
}

-(void)load{
    reqAd = [self requestBannerAd];
    if (nil == reqAd|| [[reqAd objectForKey:@"creative_url"] isKindOfClass:[NSNull class]]) {
        return;
    }
    
    [self interstitalDidLoading];
    
    NSURL *urlString = [NSURL URLWithString:[reqAd objectForKey:@"creative_url"]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *imgData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:urlString] returningResponse:&response error:&error];
    if (nil == error && (200 == (int)[(NSHTTPURLResponse *)response statusCode])) {
        
        imgView = [[UIImageView alloc]initWithFrame:viewFrame];
        
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imgView setImage:[UIImage imageWithData:imgData]];
        imgView.userInteractionEnabled = YES;
        
        [AdSdkPopView sharedInstance].delegate = self;
        [AdSdkPopView sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
        [AdSdkPopView sharedInstance].closeButtonType = ButtonPositionTypeRight;
        [[AdSdkPopView sharedInstance] showWithPresentView:imgView animated:YES];
        
        [self reportViews];
        [self interstitalDidLoadingFinish];
    }else{
        [self interstitalDidLoadingError:AdSdkInterstitalImgLoadFail];
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
        [self interstitalReportViewOKay];
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
        [self interstitalReportClickOKay];
    });
}

-(void)onClickClose{
    RLog(LD, @"图片被关闭");
    
}


#pragma mark - click
-(void)clickToLandingPage:(NSString *)url{
    UIViewController *previewController = (UIViewController *)self.delegate;
    
    AdSdkWebViewControlViewController *webViewControl =[[AdSdkWebViewControlViewController alloc]init];
    [previewController presentViewController:webViewControl animated:YES completion:nil];
    webViewControl.webView.delegate = webViewControl;
    webViewControl.delegate = self;
    
    [webViewControl loadRequest:url];
}

//插屏初始化delegate
-(void)interstitalInitResult:(NSInteger)code{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalInitResult:")]) {
        [self.delegate interstitalInitResult:code];
    }
}

//插屏被关闭
-(void)popViewClose{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalDidDismissScreen")]) {
        [self.delegate interstitalDidDismissScreen];
    }
}

//插屏被点击
-(void)popViewClick{
    [self clickToLandingPage:[reqAd objectForKey:@"curl"]];
}

//曝光上报
-(void)interstitalReportViewOKay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalReportViewOKay")]) {
        [self.delegate interstitalReportViewOKay];
    }
}

//点击上报
-(void)interstitalReportClickOKay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalReportClickOKay")]) {
        [self.delegate interstitalReportClickOKay];
    }
}


-(void)interstitalDidLoading{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalDidLoading")]) {
        [self.delegate interstitalDidLoading];
    }
}

-(void)interstitalDidLoadingFinish{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalDidLoadingFinish")]) {
        [self.delegate interstitalDidLoadingFinish];
    }
}

-(void)interstitalDidLoadingError:(NSInteger)error{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalDidLoadingError:")]) {
        [self.delegate interstitalDidLoadingError:error];
    }
}

-(void)interstitalAppStoreLoadOkay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalAppStoreLoadOkay")]) {
        [self.delegate interstitalAppStoreLoadOkay];
    }
}

-(void)interstitalLandingPageLoadOkay{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalLandingPageLoadOkay")]) {
        [self.delegate interstitalLandingPageLoadOkay];
    }
}

-(void)interstitalLandingPageLoadError{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalLandingPageLoadError")]) {
        [self.delegate interstitalLandingPageLoadError];
    }
}

-(void)interstitalDidDismissScreen{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"interstitalDidDismissScreen")]) {
        [self.delegate interstitalDidDismissScreen];
    }
}

-(void)webViewLoadSuccess{
    [self reportClicks];
    [self interstitalLandingPageLoadOkay];
}

-(void)webViewLoadFail{
    [self interstitalLandingPageLoadError];
}

-(void)webViewLoadOpenAppStore{
    [self interstitalAppStoreLoadOkay];
}

-(void)webViewClose{
    RLog(LD, @"loadingpage closed");
}


@end
