//
//  AdSdkCommConstants.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#ifndef AdSdkCommConstants_h
#define AdSdkCommConstants_h

#import <UIKit/UIKit.h>
#import "AdSdkHttpRequest.h"
#import "AdSdkLogCenter.h"
#import "AdSdkDeviceInfo.h"
#import "AdSdkConfigData.h"

#import "AdSdkBanner.h"
#import "AdsSdkBannerDelegate.h"
#import "AdSdkInterstital.h"
#import "AdSdkInterstitalDelegate.h"

typedef enum {
    //初始化成功
    AdSdkInitSuccess            = 10001,
    
    //本机网络异常
    AdSdkInitFailWithNet        = 10002,
    
    //本机网络响应非200
    AdSdkInitFailWithResCodeNotOk = 10003,
    
    //AdSdk服务器没有响应
    AdSdkInitFailWithNoRes      = 10004,
    
    //AdSdk服务器没有响应异常
    AdSdkInitFailWithResError   = 10005,
    
    //AdSdk 开发者异常
    AdSdkInitFailWithPublisher  = 10006,
}AdSdkInitErrorCode;

typedef enum {
    //初始化成功
    AdSdkBanerInitSuccess           = 20001,
    
    //Sdk未初始化成功
    AdSdkBanerInitFailSdkInitError  = 20002,
    
    //Banner 广告位未配置
    AdSdkBanerInitFailSdkPosIdError  = 20003,
    
    //Banner 广告位暂停
    AdSdkBanerInitFailSdkPosIdPause  = 20004,
    
    //Banner 广告位删除
    AdSdkBanerInitFailSdkPosIdDelete = 20005,
    
    //Banner 广告未准备好
    AdSdkBanerLoadFailAdNotReady     = 20006,
    
    //Banner 图片加载失败
    AdSdkBanerImgLoadFail            = 20007,
}AdSdkBannerErrorCode;

typedef enum {
    //初始化成功
    AdSdkInterstitalInitSuccess           = 20001,
    
    //Sdk未初始化成功
    AdSdkInterstitalInitFailSdkInitError  = 20002,
    
    //Banner 广告位未配置
    AdSdkInterstitalInitFailSdkPosIdError  = 20003,
    
    //Banner 广告位暂停
    AdSdkInterstitalInitFailSdkPosIdPause  = 20004,
    
    //Banner 广告位删除
    AdSdkInterstitalInitFailSdkPosIdDelete = 20005,
    
    //Banner 广告未准备好
    AdSdkInterstitalLoadFailAdNotReady     = 20006,
    
    //Banner 图片加载失败
    AdSdkInterstitalImgLoadFail            = 20007,
}AdSdkInterStitalErrorCode;

typedef enum {
    //竖屏
    AdsSdkIOIsPortrait  =1,
    //横屏
    AdsSdkIOIsLandscape =2
}AdsSdkInterfaceOrientation;

//sdk 版本号
#define AdsSdkVersion @"1.0"

//初始化失败后，重新初始化时间间隔
#define AdsSdkInitFaieldRefreshInterval 30

//sdk初始化地址
//#define AdsSdkInitAddress @"https://adpssp.ad-mex.com/sdkinit"
#define AdsSdkInitAddress @"http://sdkassist.ssptest.ad-mex.com/sdkinit"

//sdk广告请求地址
//#define AdsSdkAdRequestAddress @"https://adpssp.ad-mex.com/adRequest"
#define AdsSdkAdRequestAddress @"http://sdkassist.ssptest.ad-mex.com/adRequest"


#endif /* AdSdkCommConstants_h */
