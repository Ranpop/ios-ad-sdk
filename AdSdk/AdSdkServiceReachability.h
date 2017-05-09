//
//  AdSdkServiceReachability.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/21.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    AdSdkNetworkNotReachable = 0,
    AdSdkNetworkStatusWiFi,
    AdSdkNetworkStatusWWAN
} AdSdkNetworkStatus;

extern NSString * rServiceReachabilityChangedNotification;

@interface AdSdkServiceReachability : NSObject

/**
 * Use to check the reachability of a given host name.
 */
+(instancetype) reachabilityWithHostName:(NSString *)hostName;


/**
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/**
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

/**
 * Checks whether a local WiFi connection is available.
 */
+ (instancetype)reachabilityForLocalWiFi;

/**
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

-(AdSdkNetworkStatus) currentReachabilityStatus;

/**
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;

@end
