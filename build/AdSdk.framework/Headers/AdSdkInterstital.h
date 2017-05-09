//
//  AdSdkInterstital.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/5/8.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdSdkInterstitalDelegate.h"


@interface AdSdkInterstital : NSObject

+(AdSdkInterstital *)shareInterstital;

@property (nonatomic, weak) id<AdSdkInterstitalDelegate> delegate;

//广告位Id
@property (nonatomic, strong) NSString * adposid;

@property (nonatomic, assign) CGRect viewFrame;

-(void)initNormal;
//加载
-(void) load;

//广告请求
//-(NSDictionary *)requestBannerAd;

@end
