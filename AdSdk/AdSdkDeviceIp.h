//
//  AdSdkDeviceIp.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/25.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdSdkDeviceIp : NSObject

- (NSString *)getIPAddress:(BOOL)preferIPv4;

- (NSDictionary *)getIPAddresses;

@end
