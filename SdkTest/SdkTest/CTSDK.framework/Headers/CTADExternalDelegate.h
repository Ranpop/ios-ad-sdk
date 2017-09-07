//
//  CTSDK
//

#import <UIKit/UIKit.h>

@class CTInterstitial;
@class CTNaTemplate;
@class CTBanner;
@class CTNativeAd;

@protocol CTInterstitialDelegate <NSObject>

#pragma mark Interstitial Interaction Notifications
@optional
/**
 * User click the advertisement.
 */
-(void)CTInterstitialDidClick:(CTInterstitial*)interstitialAD;
/**
 * Advertisement landing page will show.
 */
-(void)CTInterstitialDidIntoLandingPage:(CTInterstitial*)interstitialAD;
/**
 * User left the advertisement landing page.
 */
-(void)CTInterstitialDidLeaveLandingPage:(CTInterstitial*)interstitialAD;
/**
 * User close the advertisement.
 */
-(void)CTInterstitialClosed:(CTInterstitial*)interstitialAD;
/**
 * Leave App
 */
-(void)CTInterstitialWillLeaveApplication:(CTInterstitial*)interstitialAD;
/**
 * Jump failure
 */
-(void)CTInterstitialJumpfail:(CTInterstitial*)interstitialAD;
@end


@protocol CTNaTemplateDelegate <NSObject>

#pragma mark Interstitial Native Notifications
@optional
/**
 * User click the advertisement.
 */
-(void)CTNaTemplateDidClick:(CTNaTemplate*)naTemplate;
/**
 * Advertisement landing page will show.
 */
-(void)CTNaTemplateDidIntoLandingPage:(CTNaTemplate*)naTemplate;
/**
 * User left the advertisement landing page.
 */
-(void)CTNaTemplateDidLeaveLandingPage:(CTNaTemplate*)naTemplate;
/**
 * User close the advertisement.
 */
-(void)CTNaTemplateClosed:(CTNaTemplate*)naTemplate;
/**
 * Leave App
 */
-(void)CTNaTemplateWillLeaveApplication:(CTNaTemplate*)naTemplate;
/**
 * User close the Html5.
 */
-(void)CTNaTemplateHtml5Closed:(CTNaTemplate*)naTemplate;
/**
 * Jump failure
 */
-(void)CTNaTemplateJumpfail:(CTNaTemplate*)naTemplate;

@end


#pragma mark Banner delegate

@protocol CTBannerDelegate <NSObject>

@optional
/**
 * User click the advertisement.
 */
-(void)CTBannerDidClick:(CTBanner*)banner;
/**
 * Advertisement landing page will show.
 */
-(void)CTBannerDidIntoLandingPage:(CTBanner*)banner;
/**
 * User left the advertisement landing page.
 */
-(void)CTBannerDidLeaveLandingPage:(CTBanner*)banner;
/**
 * User close the advertisement.
 */
-(void)CTBannerClosed:(CTBanner*)banner;
/**
 * Leave App
 */
-(void)CTBannerWillLeaveApplication:(CTBanner*)banner;
/**
 * User close the Html5.
 */
-(void)CTBannerHtml5Closed:(CTBanner*)banner;
/**
 * Jump failure
 */
-(void)CTBannerJumpfail:(CTBanner*)banner;

@end

#pragma mark ElementAd Delegate

@protocol CTNativeAdDelegate <NSObject>

@optional
/**
 * User click the advertisement.
 */
-(void)CTNativeAdDidClick:(UIView *)nativeAd;
/**
 * Advertisement landing page will show.
 */
-(void)CTNativeAdDidIntoLandingPage:(UIView *)nativeAd;
/**
 * User left the advertisement landing page.
 */
-(void)CTNativeAdDidLeaveLandingPage:(UIView *)nativeAd;
/**
 * Leave App
 */
-(void)CTNativeAdWillLeaveApplication:(UIView *)nativeAd;
/**
 * Jump failure
 */
-(void)CTNativeAdJumpfail:(UIView*)nativeAd;
@end


#pragma mark CTAppWall Delegate

@protocol CTAppWallDelegate <NSObject>

@optional
/**
 * User click the advertisement.
 */
-(void)CTAppWallDidClick:(CTNativeAd *)nativeAd;
/**
 * Advertisement landing page will show.
 */
-(void)CTAppWallDidIntoLandingPage:(CTNativeAd *)nativeAd;
/**
 * User left the advertisement landing page.
 */
-(void)CTAppWallDidLeaveLandingPage:(CTNativeAd *)nativeAd;
/**
 * Leave App
 */
-(void)CTAppWallWillLeaveApplication:(CTNativeAd *)nativeAd;
/**
 * User close the advertisement.
 */
-(void)CTAppWallClosed;
/**
 * Jump failure
 */
-(void)CTAppWallJumpfail:(CTNativeAd*)nativeAd;
@end
