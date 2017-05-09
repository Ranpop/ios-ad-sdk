//
//  AdSdkKeyChain.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/22.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdSdkKeyChain : NSObject

+(void)save: (NSString *)service data:(id)data;
+(id)load: (NSString *)service;
+(void)delete:(NSString *)service;
@end
