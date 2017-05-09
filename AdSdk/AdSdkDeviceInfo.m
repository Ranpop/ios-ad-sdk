//
//  AdSdkDeviceInfo.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/21.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkDeviceInfo.h"
#import "AdSdkServiceReachability.h"
#import "AdSdkLogCenter.h"
#import "AdSdkKeyChain.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTCarrier.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <AdSupport/AdSupport.h>

#import "AdSdkDeviceIp.h"

typedef enum {
    AdSdkPingSelfDomain    = 1,
    AdSdkPingServerDomainMaxIndex,
}AdSdkPingServerDomain;

@interface AdSdkDeviceInfo () {
    AdSdkPingServerDomain pingHostFlag;
}

@property (strong, nonatomic) AdSdkServiceReachability *reachability;

@end

@implementation AdSdkDeviceInfo

+(AdSdkDeviceInfo *)shareDevice {
    static AdSdkDeviceInfo * sharedDevice = nil;
    if (!sharedDevice) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedDevice = [[self alloc]init];
        });
    }
    
    return sharedDevice;
}

- (NSString *)md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

-(NSString *)getPreferredLanguage{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSArray * languages = [defs objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];
    
    return preferredLang;
}

-(NSString *)getCurrentDeviceModel{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len,  NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    return [platform copy];
}

-(AdSdkNetworkStatus)getNetworkStatus{
    return [self.reachability currentReachabilityStatus];
}

-(BOOL)checkNetworkStatus{
    AdSdkNetworkStatus networkStatus = [self getNetworkStatus];
    if (AdSdkNetworkNotReachable == networkStatus) {
        return NO;
    }
    
    if (networkStatus == AdSdkNetworkStatusWWAN) {
        return YES;
    }
    
    return YES;
}

-(void)AdSdkNotReachableCheck{
    if (pingHostFlag == AdSdkPingServerDomainMaxIndex) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:@selector(getNetworkStatus) withObject:nil afterDelay:10.0];
    }else{
        pingHostFlag++;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:@selector(getNetworkStatus) withObject:nil afterDelay:1.0];
#pragma clang diagnostic pop
    }
}

-(NSString *)getBundleName{
    NSString * bn = [[NSBundle mainBundle]bundleIdentifier];
    if ([self isBlankString:bn]) {
        return @"";
    }
    return bn;
}

-(NSString *)getNetworkType{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString([NSString stringWithFormat:@"%@%@",@"UIStatusBarData",@"NetworkItemView"])]) {
            netType = [[child valueForKeyPath:[NSString stringWithFormat:@"%@%@",@"dataNet",@"workType"]]intValue];
            switch (netType) {
                case 0:
                    state = @"0";
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                    state = @"WIFI";
                    break;
                default:
                    break;
            }
        }
    }
    
    return state;
}

-(NSString *)getCurrentDate{
    NSDate * senddate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    
    [dateformatter setDateFormat:@"YYYYMMDdd"];
    
    NSString * locationString = [dateformatter stringFromDate:senddate];
    
    return locationString;
}

-(NSString *)getIDFA{
//    if([[self getCurrentVersion] floatValue] < 6.0){
//        return @"";
//    }
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//    NSString *advertisingIdentifier = @"";
//    id ASIdentifierManagerClazz = NSClassFromString(@"ASIdentifierManager");
//    if(ASIdentifierManagerClazz){
//        id ASIdentifierManagerClass = [ASIdentifierManagerClazz performSelector:NSSelectorFromString(@"sharedManager")];
//        if(ASIdentifierManagerClass){
//            id YMUUID = [ASIdentifierManagerClass performSelector:NSSelectorFromString(@"advertisingIdentifier")];
//            if(YMUUID){
//                advertisingIdentifier = [YMUUID performSelector:NSSelectorFromString(@"UUIDString")];
//            }
//        }
//    }
//#pragma clang diagnostic pop
//    return advertisingIdentifier == nil?@"":advertisingIdentifier;
    return [[[ASIdentifierManager sharedManager]advertisingIdentifier]UUIDString];
}

-(NSString *)getVendor{
    if ([[self getCurrentVersion] floatValue] >= 6.0) {
        NSString *vendor = @"";
        id curDevice = [UIDevice currentDevice];
        id x = [curDevice performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@%@",@"identi",@"fierForV",@"endor"])];
        if (x) {
            vendor = [x performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@%@",@"UUI",@"DS",@"tring"])];
        }
        return vendor == nil ? @"" : vendor;
    }
    
    return @"";
}

-(NSString *)getCurrentVersion{
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    return systemVersion;
}

-(NSString *)getOpenUDID{
    NSString * udid = [AdSdkKeyChain load:@"openUDID"];
    if (!udid) {
        //  创建一个唯一的标示符
        CFUUIDRef puuid = CFUUIDCreate(NULL);
        CFStringRef uuidString = CFUUIDCreateString(NULL, puuid);
        NSString *deviceIdentifier = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL,uuidString));
        
        //  将这个唯一的标示符保存在粘贴板上
        [AdSdkKeyChain save:@"openUDID" data:deviceIdentifier];
        
        CFRelease(puuid);
        CFRelease(uuidString);
    }
    return [AdSdkKeyChain load:@"openUDID"];
}

#pragma mark - 获取PLMNCode
-(NSString *)getPLMNCode{
    CTTelephonyNetworkInfo *networkInfo=[[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier=networkInfo.subscriberCellularProvider;
    if (carrier) {
        if (carrier.mobileCountryCode && carrier.mobileNetworkCode) {
            if ([carrier.mobileCountryCode length]!=0 && [carrier.mobileNetworkCode length]!=0) {
                NSString *countrynetwork=[NSString stringWithFormat:@"%@%@",carrier.mobileCountryCode,carrier.mobileNetworkCode];
                return countrynetwork;
            }
        }
    }
    return @"";
}

-(NSString *)getMacAdress{
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

-(NSString *)getDeviceMode {
    NSString *model = [[UIDevice currentDevice] model];
    return model;
}

-(BOOL)isBlankString:(NSString*)str{
    if (str==nil) {
        return YES;
    }
    if (str==NULL) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0) {
        return YES;
    }
    return NO;
}

-(NSString *)getVersionNum{
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString * versionNum =[infoDict objectForKey:[NSString stringWithFormat:@"%@%@",@"CFBundleShort",@"VersionString"]];
    return  [versionNum copy];
}

+(NSDictionary*)JSONObjectWithData:(NSData*)data{
    NSError *jsonerror;
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonerror];
    if (jsonerror) {
        RLog(LE, @"JSON analysis error---%@",jsonerror);
    }
    
    return dic;
}

/*当前时间戳*/
-(NSString *)getCurrentTime
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    
    return [NSString stringWithFormat:@"%.f",a];
}

-(NSString*)getSaveConfigStr:(NSString*)appid  channel:(NSString*)channel  version:(NSString*)version  adType:(NSUInteger)adType{
    return [NSString stringWithFormat:@"%@_%@_%@_%d",appid,channel,version,(int)adType];
}

-(NSString *)isPhoneOrIpad {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return @"1";
    }
    return @"0";
}

- (NSString *)getNetworkTypeNumber {
    NSString *net = [self getNetworkType];
    if ([net isEqualToString:@"2G"]) {
        return @"0";
    }else if ([net isEqualToString:@"3G"]) {
        return @"1";
        
    }else if ([net isEqualToString:@"4G"]) {
        return @"2";
        
    }else if ([net isEqualToString:@"WIFI"]) {
        return @"3";
        
    }
    return @"3";
}

-(int)getOrientation{
    UIApplication* app = [UIApplication sharedApplication];
    
    if(app.statusBarOrientation == UIInterfaceOrientationPortrait || app.statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown){
        return 1;
    }else
        return 0;
}

- (NSString *)getIDFV {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0) {
        return @"";
    }
    else {
        NSString *idfv =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if ([self isBlankString:idfv]) {
            idfv = @"";
        }
        return idfv;
    }
}

-(NSString *)getAppName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if ([self isBlankString:app_Name]) {
        return @"AdSdk";
    }
    return app_Name;
}

-(NSString *)getBundleID {
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString * versionNum =[infoDict objectForKey:@"CFBundleIdentifier"];
    if ([self isBlankString:versionNum]) {
        versionNum = @"";
    }
    return  [versionNum copy];
}

//获取外网地址
-(NSString *)getOutsideIp{
    return [self deviceIPAdress]==nil?@"127.0.0.1":[self deviceIPAdress];
}


-(NSString *)getOutNetIp {
    
    if ([NSThread isMainThread]) {
        return @"127.0.0.1";
    }
    
    NSString *urlStr = @"https://adpssp.ad-mex.com/sdk/ping";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request  = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *dict=nil;
    if (data!=nil) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    if (!dict[@"IP"]) {
        return @"";
    }
    return dict[@"IP"];
}

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
- (NSString *)deviceIPAdress {
//    NSString *address = @"an error occurred when obtaining ip address";
//    struct ifaddrs *interfaces = NULL;
//    struct ifaddrs *temp_addr = NULL;
//    int success = 0;
//    
//    success = getifaddrs(&interfaces);
//    
//    if (success == 0) { // 0 表示获取成功
//        temp_addr = interfaces;
//        while (temp_addr != NULL) {
//            if( temp_addr->ifa_addr->sa_family == AF_INET) {
//                // Check if interface is en0 which is the wifi connection on the iPhone
//                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
//                    // Get NSString from C String
//                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                }
//            }
//            
//            temp_addr = temp_addr->ifa_next;
//        }
//    }
//    
//    freeifaddrs(interfaces);
//    if ([self isBlankString:address]) {
//        address = @"";
//    }
//    
//    return address;
    NSString *ip = [[[AdSdkDeviceIp alloc]init]getIPAddress:YES];
    return ip;
}

-(NSString *)getCurrentLanguage{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}

-(NSDictionary *)getAdReqDeviceParams{
    
    NSMutableDictionary *device = [[NSMutableDictionary alloc]init];
    
    [device setObject:[self getOutsideIp] forKey:@"ip"];
    if ([[self getDeviceMode] hasPrefix:@"iPad"]) {
        [device setObject:[NSNumber numberWithInteger:(int)AdSdkDeviceTypeIpad]  forKey:@"devicetype"];
    }else{
        [device setObject:[NSNumber numberWithInteger:(int)AdSdkDeviceTypeIphone] forKey:@"devicetype"];
    }
    
    [device setObject:@"apple" forKey:@"make"];
    
    [device setObject:[self getCurrentDeviceModel] forKey:@"model"];
    
    [device setObject:[self getCurrentLanguage] forKey:@"language"];
    
    [device setObject:@"ios" forKey:@"os"];
    
    [device setObject:[self getCurrentVersion] forKey:@"osv"];
    
    [device setObject:[self getPLMNCode] forKey:@"carrier"];
    
    [device setObject:[self getIDFA] forKey:@"idfa"];
    
    [device setObject:[self getMacAdress] forKey:@"mac"];
    
    //网络模式 (wifi、3G、4G)
    [device setObject:[self getNetworkType] forKey:@"connectiontype"];
    if ([[device objectForKey:@"connectiontype"]isEqualToString:@"2G"]) {
        [device setObject:[NSNumber numberWithInteger:2] forKey:@"connectiontype"];
        
    }else if ([[device objectForKey:@"connectiontype"]isEqualToString:@"3G"]){
        [device setObject:[NSNumber numberWithInteger:3] forKey:@"connectiontype"];
        
    }else if ([[device objectForKey:@"connectiontype"]isEqualToString:@"4G"])
    {
        [device setObject:[NSNumber numberWithInteger:4] forKey:@"connectiontype"];
        
    }else if ([[device objectForKey:@"connectiontype"]isEqualToString:@"WIFI"]){
        [device setObject:[NSNumber numberWithInteger:1] forKey:@"connectiontype"];
        
    }else{
        [device setObject:[NSNumber numberWithInteger:0] forKey:@"connectiontype"];
    }
    
    NSString * openUDID = [self getOpenUDID];
    //openUDID
    [device setObject:openUDID == nil? @"": openUDID forKey:@"openUDID"];
    
    NSString *width =[NSString stringWithFormat:@"%0.f",[UIScreen mainScreen].bounds.size.width];
    NSString *height =[NSString stringWithFormat:@"%0.f",[UIScreen mainScreen].bounds.size.height];
    NSString *scale = [NSString stringWithFormat:@"%0.f",[UIScreen mainScreen].scale];
    // screenWidth	STRING	屏幕像素宽度
    [device setValue:[NSNumber numberWithInteger:[width intValue]*[scale intValue]] forKey:@"hww"];
    //  screenHeight	STRING	屏幕像素高度
    [device setValue:[NSNumber numberWithInteger:[height intValue]*[scale intValue]] forKey:@"hwh"];
    
    return device;
}

@end
