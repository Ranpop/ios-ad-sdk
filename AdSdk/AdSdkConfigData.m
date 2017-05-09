//
//  AdSdkConfigData.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/22.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkConfigData.h"

@implementation AdSdkConfigData
@synthesize is_okay;
@synthesize slots;
@synthesize publisherid;
@synthesize appid;
@synthesize token;

+(AdSdkConfigData *)shareConfData{
    static AdSdkConfigData * shareConf = nil;
    if (!shareConf) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareConf = [[self alloc]init];
        });
    }
    
    return shareConf;
}

-(void)getConfigerDataWithDictionary:(NSDictionary *)dict{
    if (nil != dict && ![dict isKindOfClass:[NSNull class]]) {
        self.is_okay = [[dict objectForKey:@"is_okay"] integerValue];
        self.slots = [dict objectForKey:@"slots"];
        
        self.publisherid = [dict objectForKey:@"publisher_id"];
        self.appid = [dict objectForKey:@"app_id"];
        self.token = [dict objectForKey:@"token"];
    }
}

@end
