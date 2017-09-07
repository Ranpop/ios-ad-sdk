//
//  AdSdkSplash.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/9/6.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdSdkSplashDelegate.h"

@interface AdSdkSplash : NSObject

+(AdSdkSplash *)shareSplash;

@property (nonatomic, weak) id<AdSdkSplashDelegate> delegate;

@property (nonatomic, strong) NSString * adposid;

@property (nonatomic, assign) CGRect viewFrame;

-(void)initNormal;

-(void)load;

@end
