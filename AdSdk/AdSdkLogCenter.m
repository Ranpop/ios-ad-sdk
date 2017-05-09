//
//  AdSdkLogCenter.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/21.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkLogCenter.h"

static AdSdkLogCenter * instance;

@interface AdSdkLogCenter () {
    int currentLogLevelFlag;
}
@end

@implementation AdSdkLogCenter

+(void)load {
    [AdSdkLogCenter shareInstance];
}

+(AdSdkLogCenter *)shareInstance{
    if (!instance) {
        instance = [[AdSdkLogCenter alloc]init];
    }
    
    return instance;
}

-(id)init{
    if (self == [super init]) {
        currentLogLevelFlag = AdSDKLogLevelNone;
    }
    return self;
}

-(BOOL)canLog:(int)levelFlag{
    if (AdSDKLogLevelNone != currentLogLevelFlag) {
        return YES;
    }
    return NO;
}

-(void)setLogLevelFlag:(AdSDKLogLevel)levelFlag{
    currentLogLevelFlag = levelFlag;
}

-(AdSDKLogLevel)getLogLevelFlag{
    return currentLogLevelFlag;
}

@end
