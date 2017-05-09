//
//  AdSdk.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdk.h"

@interface AdSdk () <HttpRequestDelegate, AdSdkDelegate>
@property (assign, nonatomic) NSInteger initResCode;
@property (assign, nonatomic) NSInteger initCount;

@property (assign, nonatomic) AdSdkBanner *bannerCache;
@end

@implementation AdSdk
@synthesize token;
@synthesize publisherid;
@synthesize appid;
@synthesize failTryCount;

@synthesize confData;

static AdSdk * shareAdSdk = nil;

+(AdSdk *)shareAdSdk {
    if (!shareAdSdk) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareAdSdk = [[self alloc]init];
        });
    }
    
    return shareAdSdk;
}

+(void)setSdkLogLevel:(AdSDKLogLevel)logLevel{
    NSLog(@"init for set sdk log level %d", logLevel);
    [[AdSdkLogCenter shareInstance]setLogLevelFlag:AdSDKLogLevelDebug];
}

+(void)initWithAdSdkToken:(NSString *)token publisherid:(NSString *)publisherid appid:(NSString *)appid failTryCount:(NSInteger)failTryCount delegate:(id<AdSdkDelegate>)delegate{
    
    [AdSdk shareAdSdk]->token = token;
    [AdSdk shareAdSdk]->publisherid = publisherid;
    [AdSdk shareAdSdk]->appid = appid;
    [AdSdk shareAdSdk]->failTryCount = failTryCount;
    [AdSdk shareAdSdk]->_delegate = delegate;
    
    [[AdSdk shareAdSdk]requestForConfig];
}

+(AdSdkBanner *)initWithFrame:(CGRect)frame adposid:(NSString *)adposid delegate:(id<AdSdkBannerDelegate>)delegate{
    
    AdSdkBanner * banner = [[AdSdkBanner alloc]initWithFrame:frame];
    banner.adposid = adposid;
    banner.delegate = delegate;
    
    if ([[NSThread currentThread]isMainThread]) {
        [NSThread detachNewThreadSelector:NSSelectorFromString(@"initNormal") toTarget:banner withObject:nil];
    }else{
        [banner initNormal];
    }
    
    return banner;
}

+(AdSdkInterstital *)InterstitalInitWithFrame:(CGRect)frame adposid:(NSString *)adposid delegate:(id<AdSdkInterstitalDelegate>)delegate{
    AdSdkInterstital *inter = [AdSdkInterstital shareInterstital];
    inter.adposid = adposid;
    inter.delegate = delegate;
    inter.viewFrame = frame;
    
    if ([[NSThread currentThread]isMainThread]) {
        [NSThread detachNewThreadSelector:NSSelectorFromString(@"initNormal") toTarget:inter withObject:nil];
    }else{
        [inter initNormal];
    }
    
    return inter;
}

-(void)requestForConfig{
    if ([[NSThread currentThread]isMainThread]) {
        [NSThread detachNewThreadSelector:NSSelectorFromString(@"requestForConfig") toTarget:self withObject:nil];
    }else{
        self.initCount++;
        NSDictionary * params = [self getConfigParams];
    
        NSMutableDictionary *httpHeader = [[NSMutableDictionary alloc]init];
        [httpHeader setValue:@"application/json" forKey:@"Content-Type"];
        
        AdSdkHttpRequest *initReq = [[AdSdkHttpRequest alloc]init];
        initReq.url = AdsSdkInitAddress;
        initReq.httpMethod = @"post";
        initReq.params = params;
        initReq.timeout = 5;
        initReq.httpHeaderFields = httpHeader;
        initReq.delegate = self;
        initReq.postDataType = HttpRequestPostDataTypeNormal;
        
        NSData *initRes = [initReq synchronousConnect];
        if (nil != initRes) {
            NSDictionary *initResDic = [AdSdkDeviceInfo JSONObjectWithData:initRes];
            if (![[initResDic objectForKey:@"is_okay"] isKindOfClass:[NSNull class]]) {
                [[AdSdkConfigData shareConfData] getConfigerDataWithDictionary:initResDic];
                [self AdSdkInitResult: AdSdkInitSuccess initCount:self.initCount];
            }else{
                if (self.initCount < self.failTryCount) {
                    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(requestForConfig) userInfo:nil repeats:NO];
                }
                
                if (200 == self.initResCode) {
                    [self AdSdkInitResult: AdSdkInitFailWithResError initCount:self.initCount];
                }else{
                    [self AdSdkInitResult: AdSdkInitFailWithResCodeNotOk initCount:self.initCount];
                }
            }
//            RLog(LD, "初始化结果：%ld", [AdSdkConfigData shareConfData].is_okay);
//            RLog(LD, "初始化结果：%@", [AdSdkConfigData shareConfData].slots);
        }
    }
}

-(NSDictionary *)getConfigParams{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    
    [params setObject:AdsSdkVersion forKey:@"adsdkver"];
    [params setObject:self->token forKey:@"token"];
    [params setObject:self->publisherid forKey:@"publisherid"];
    [params setObject:self->appid forKey:@"appid"];
    
    [params setObject:[[AdSdkDeviceInfo shareDevice] getAdReqDeviceParams] forKey:@"device"];
    
    RLog(LD, @"SDK初始化--\n%@",params);
    
    return params;
}

-(void)request:(AdSdkHttpRequest *)request didReceiveResCode:(NSInteger)code{
    self.initResCode = code;
    RLog(LD, @"http request response code: %ld", (long)code);
}

-(void)AdSdkInitResult:(AdSdkInitErrorCode)errorCode initCount:(NSInteger)initCount{
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"AdSdkInitResult:initCount:") ]) {
        [self.delegate AdSdkInitResult:errorCode initCount:initCount];
    }
}

@end
