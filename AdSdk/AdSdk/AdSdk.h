//
//  AdSdk.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AdSdkCommConstants.h"
#import "AdSdkDelegate.h"

@interface AdSdk : NSObject

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *publisherid;
@property (strong, nonatomic) NSString *appid;

@property (strong, nonatomic) AdSdkConfigData *confData;

@property (assign, nonatomic) NSInteger failTryCount;

@property (nonatomic, assign) id<AdSdkDelegate>delegate;

+(AdSdk *)shareAdSdk;

/** 
 * SDK初始化，据此返回开发者在广告平台配置的应用和广告位信息
 */
+(void)initWithAdSdkToken: (NSString *)token
            publisherid: (NSString *)publisherid
                    appid: (NSString *)appid
             failTryCount: (NSInteger)failTryCount
                 delegate: (id<AdSdkDelegate>)delegate;

//banner 初始化
//+(AdSdkBanner *)initWithFrame:(CGRect)frame adposid: (NSString *)adposid;
//banner 初始化 以delegate方式
+(AdSdkBanner *)initWithFrame:(CGRect)frame adposid:(NSString *)adposid delegate:(id<AdSdkBannerDelegate>)delegate;

//interstital 初始化
+(AdSdkInterstital *)InterstitalInitWithFrame:(CGRect)frame adposid:(NSString *)adposid delegate:(id<AdSdkInterstitalDelegate>)delegate;

//插屏广告已经初始化的情况，可以直接调用广告展示
+(AdSdkInterstital *)interstitalShow: (AdSdkSlotErrorCode)errCode;

//设置日志级别，正式环境不用设置
+(void)setSdkLogLevel: (AdSDKLogLevel)logLevel;

////获取初始化参数
//-(NSDictionary *)getConfigParams;

////初始化请求
//-(void)requestForConfig;

@end
