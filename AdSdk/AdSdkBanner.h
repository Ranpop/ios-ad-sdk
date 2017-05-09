//
//  AdSdkBanner.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdsSdkBannerDelegate.h"

@interface AdSdkBanner : UIView

@property (nonatomic, weak) id<AdSdkBannerDelegate> delegate;

//banner刷新间隔
@property (nonatomic)NSInteger refreshInterval;

//广告位Id
@property (nonatomic, strong) NSString * adposid;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)initNormal;
//加载
-(void) load;

//广告请求
-(NSDictionary *)requestBannerAd;

@end
