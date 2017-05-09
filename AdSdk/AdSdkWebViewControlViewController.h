//
//  AdSdkWebViewControlViewController.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/25.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdSdkWebViewControlDelegate <NSObject>

@optional
-(void)webViewLoadSuccess;

-(void)webViewLoadFail;

-(void)webViewLoadOpenAppStore;

-(void)webViewClose;

@end


@interface AdSdkWebViewControlViewController : UIViewController<AdSdkWebViewControlDelegate, UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSString * htmlString;

@property (nonatomic, weak) id<AdSdkWebViewControlDelegate> delegate;

-(void)loadHtml:(NSString *)url;

-(void)loadRequest:(NSString *)url;

@end
