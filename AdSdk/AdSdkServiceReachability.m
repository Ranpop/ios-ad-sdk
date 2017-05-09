//
//  AdSdkServiceReachability.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/21.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkServiceReachability.h"
#import "AdSdkLogCenter.h"
#import <CoreFoundation/CoreFoundation.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

NSString *rServiceReachabilityChangedNotification = @"rServiceReachabilityChangedNotification";

#pragma mark - Supporting functions

#define rShouldPrintReachabilityFlags 1

static void AdSdkPrintReachabilityFlags (SCNetworkReachabilityFlags flags, const char * comment){
#if rShouldPrintReachabilityFlags
    RLog(LD, @"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
         (flags & kSCNetworkReachabilityFlagsIsWWAN)                ? 'W' : '-',
         (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
         (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
         (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
         (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
         (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
         (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
         (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
         comment
         );
#endif
}

static void AdSdkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info){
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [AdSdkServiceReachability class]], @"info was wrong class in ReachabilityCallback");
    
    AdSdkServiceReachability* noteObject = (__bridge AdSdkServiceReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: rServiceReachabilityChangedNotification object: noteObject];
}

#pragma mark - Reachability implementation

@implementation AdSdkServiceReachability{
    BOOL _alwaysReturnLocalWiFiStatus; //default is NO
    SCNetworkReachabilityRef _reachabilityRef;
}

+(instancetype)reachabilityWithHostName:(NSString *)hostName{
    AdSdkServiceReachability * returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (NULL != reachability) {
        returnValue = [[self alloc]init];
        if (NULL != returnValue) {
            returnValue->_reachabilityRef = reachability;
            returnValue->_alwaysReturnLocalWiFiStatus = NO;
        }
    }
    
    return returnValue;
}

+(instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    
    AdSdkServiceReachability * returnValue = NULL;
    if (NULL != reachability) {
        returnValue = [[super alloc]init];
        if (NULL != returnValue) {
            returnValue->_reachabilityRef = reachability;
            returnValue->_alwaysReturnLocalWiFiStatus = NO;
        }
    }
    return returnValue;
}

+(instancetype)reachabilityForInternetConnection{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:&zeroAddress];
}

+(instancetype)reachabilityForLocalWiFi{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    
    AdSdkServiceReachability * returnValue = [self reachabilityWithAddress:&localWifiAddress];
    if (NULL != returnValue) {
        returnValue->_alwaysReturnLocalWiFiStatus = YES;
    }
    
    return returnValue;
}

#pragma mark - Start and Stop Notifier

-(BOOL)startNotifier{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void*)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, AdSdkReachabilityCallback, &context)){
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)){
            returnValue = YES;
        }
    }
    
    return returnValue;
}

-(void)stopNotifier{
    if (NULL != _reachabilityRef) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

-(void)dealloc{
    [self stopNotifier];
    if (NULL != _reachabilityRef) {
        CFRelease(_reachabilityRef);
    }
}

#pragma mark - Network Flag Handling
-(AdSdkNetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags{
    AdSdkPrintReachabilityFlags(flags, "localWiFiStatusForFlags");
    
    AdSdkNetworkStatus returnValue = AdSdkNetworkNotReachable;
    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
        returnValue = AdSdkNetworkStatusWiFi;
    }
    
    return returnValue;
}

-(AdSdkNetworkStatus) networkStatusForFlags:(SCNetworkReachabilityFlags)flags{
    AdSdkPrintReachabilityFlags(flags, "networkStatusForFlags");
    if (0 == (flags & kSCNetworkReachabilityFlagsReachable)) {
        return AdSdkNetworkNotReachable;
    }
    
    AdSdkNetworkStatus returnValue = AdSdkNetworkNotReachable;
    if (0 == (flags & kSCNetworkReachabilityFlagsConnectionRequired)) {
        return AdSdkNetworkStatusWiFi;
    }
    
    if((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
            returnValue = AdSdkNetworkStatusWiFi;
        }
    }
       
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN){
        returnValue = AdSdkNetworkStatusWWAN;
    }
    
    return returnValue;
}

-(BOOL) connectionRequired{
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}

-(AdSdkNetworkStatus)currentReachabilityStatus{
    AdSdkNetworkStatus returnValue = AdSdkNetworkNotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        if (_alwaysReturnLocalWiFiStatus) {
            returnValue = [self localWiFiStatusForFlags:flags];
        }else{
            returnValue = [self networkStatusForFlags:flags];
        }
    }
    
    return returnValue;
}

@end
