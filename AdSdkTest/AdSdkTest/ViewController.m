//
//  ViewController.m
//  AdSdkTest
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

@import AdSdk;
@import AdSdk.AdSdkBanner;
@import AdSdk.AdsSdkBannerDelegate;

@import AdSdk.AdSdkInterstital;
@import AdSdk.AdSdkInterstitalDelegate;

#import "ViewController.h"

#ifndef ADSDK_BANNER_ID
#define ADSDK_BANNER_ID     @"598d49b81ad88e0100043101"
#endif

static BOOL AdSDKBannerInitFlag = NO;

@interface ViewController () <AdSdkInterstitalDelegate,AdSdkBannerDelegate>
@property (nonatomic, strong) AdSdkBanner* banner;
@property (nonatomic, strong) AdSdkInterstital* interstital;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [AdSdkTest printTest];
//    AdSdkView *sdkView = [[AdSdkView alloc]initWithFrame:CGRectMake(20, 20, 500, 100)];
//    [self.view addSubview:sdkView];
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
    UINavigationItem *navItem = [[UINavigationItem alloc]initWithTitle:@"My Game"];
    [navBar pushNavigationItem:navItem animated:YES];
    [self.view addSubview:navBar];
    
    UITabBar *tabBar = [[UITabBar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-60, self.view.bounds.size.width, 40)];
    
    UITabBarItem *news = [[UITabBarItem alloc]initWithTitle:@"资讯" image:[UIImage imageNamed:@"homepage.png"] tag:0];
    UITabBarItem *gifts = [[UITabBarItem alloc]initWithTitle:@"活动" image:[UIImage imageNamed:@"like.png"] tag:1];
    UITabBarItem *records = [[UITabBarItem alloc]initWithTitle:@"我的记录" image:[UIImage imageNamed:@"people.png"] tag:2];
    NSArray *tabItemsArray = [[NSArray alloc]initWithObjects:news, gifts, records, nil];
    [tabBar setItems:tabItemsArray];
    [self.view addSubview:tabBar];
    

    UIButton *btnBanner = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBanner.frame = CGRectMake(5, 65, 90, 40);
    btnBanner.backgroundColor = [UIColor blueColor];
    [btnBanner setTitle:@"横幅" forState:UIControlStateNormal];
    [btnBanner addTarget:self action:@selector(bannerAdShow) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:btnBanner];
    
    UIButton *btnInter = [UIButton buttonWithType:UIButtonTypeCustom];
    btnInter.frame = CGRectMake(100, 65, 90, 40);
    btnInter.backgroundColor = [UIColor blueColor];
    [btnInter setTitle:@"插屏" forState:UIControlStateNormal];
    [btnInter addTarget:self action:@selector(interstitalAdShow) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:btnInter];
    
    sleep(2);
    self.banner = [AdSdk initWithFrame:CGRectMake(0, self.view.bounds.size.height-120, self.view.bounds.size.width, 80) adposid:ADSDK_BANNER_ID delegate:self];
    
    self.interstital = [AdSdk InterstitalInitWithFrame:CGRectMake(0,0,300,450) adposid:ADSDK_BANNER_ID delegate:self];

}

-(void)bannerAdShow{
    if (AdSDKBannerInitFlag) {
        NSLog(@"横幅广告位展示");
        [self.view addSubview:self.banner];
        [self.banner load];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"初始化" message: @"横幅广告初始化中..." delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

-(void)interstitalAdShow{
//    if (AdSDKBannerInitFlag) {
        NSLog(@"插屏广告位展示");
//        [self.view addSubview:self.banner];
    [self.interstital load];
//    }else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"初始化" message: @"横幅广告初始化中..." delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alert show];
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)bannerInitResult:(NSInteger)code{
    NSLog(@"banner initResult Code: %ld", (long)code);
    if (code == (NSInteger)AdSdkSlotInitSuccess) {
        AdSDKBannerInitFlag = true;
//        [self.view addSubview:self.banner];
//        
//        [self.banner load];
    }
}

-(void)bannerDidLoading{
    NSLog(@"banner will loading");
}

-(void)bannerDidLoadingFinish{
    NSLog(@"banner loading finished");
}

-(void)bannerDidLoadingError:(NSInteger)errorCode{
    NSLog(@"banner loading error errorCode: %ld", (long)errorCode);
}

-(void)bannerReportViewOKay{
     NSLog(@"banner views okay");
}

-(void)bannerLandingPageLoadOkay{
    NSLog(@"落地页跳转完成");
}

-(void)bannerLandingPageLoadError{
    NSLog(@"落地页跳转失败");
}

@end
