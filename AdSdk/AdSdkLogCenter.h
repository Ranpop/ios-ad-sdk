//
//  AdSdkLogCenter.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/21.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdSdkCommConstants.h"

#ifndef RLog
#define RLog(lv, fmt, ...) \
if([[AdSdkLogCenter shareInstance] canLog: lv]){\
    NSLog((@"AdSdk-" "<FUNCTION:%s>: " fmt),__FUNCTION__, ##__VA_ARGS__);\
}
#endif

typedef enum {
    AdSDKLogLevelNone   = 4,
    AdSDKLogLevelError  = 2,
    AdSDKLogLevelDebug  = 1
}AdSDKLogLevel;

typedef enum {
    LD      = 1,
    LE      = 2,
    LN      = 4
}LogLevelName;


@interface AdSdkLogCenter : NSObject

+(AdSdkLogCenter *)shareInstance;
-(BOOL)canLog:(int)levelFlag;
-(void)setLogLevelFlag: (AdSDKLogLevel)levelFlag;
-(AdSDKLogLevel)getLogLevelFlag;
@end
