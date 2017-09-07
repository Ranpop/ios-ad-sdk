//
//  CTManager.h
//  CTSDK
//  You should call [[CTService shareManager] loadRequestGetCTSDKConfigBySlot_id:@"slotID"] in didFinishLaunchingWithOptions Method

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CTElementModel.h"

typedef enum : NSUInteger {
    CTImageWHRateOneToOne= 0,           //Width:Hight  = 1:1
    CTImageWHRateOnePointNineToOne      //Width:Hight  = 1.9:1
} CTImageWidthHightRate;

@interface CTService : NSObject

#pragma mark - CTService config Method
/**
 You should pass the singleton method to create the object, then calls the requests of the different types of ads.

 @return returns a global instance of CTService
 */
+ (instancetype)shareManager;

/**
 Get CT AD Config in Appdelegate(didFinishLaunchingWithOptions:)

 @param slot_id Ad
 */
- (void)loadRequestGetCTSDKConfigBySlot_id:(NSString *)slot_id;


#pragma mark - Native Ad Interface（Return Ad Elements）
/**
 We recommend use CTNative Interface！！！
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
- (void)getNativeADswithSlotId:(NSString *)slot_id
                      delegate:(id)delegate
           imageWidthHightRate:(CTImageWidthHightRate)WHRate
                        isTest:(BOOL)isTest
                       success:(void (^)(CTNativeAdModel *nativeModel))success
                       failure:(void (^)(NSError *error))failure;


/**
 Preload native ADs with image
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param preloadImage    preload AD images if afferent YES
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
- (void)preloadNativeADswithSlotId:(NSString *)slot_id
                      delegate:(id)delegate
           imageWidthHightRate:(CTImageWidthHightRate)WHRate
                  preloadImage:(BOOL)preloadImage
                        isTest:(BOOL)isTest
                       success:(void (^)(CTNativeAdModel *nativeModel))success
                       failure:(void (^)(NSError *error))failure;
/**
 Get Keywords Element Native ADs
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param cat             ad type
 @param keyWords        Set Ad Keywords
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
- (void)getNativeADswithSlotId:(NSString *)slot_id
                      delegate:(id)delegate
           imageWidthHightRate:(CTImageWidthHightRate)WHRate
                         adcat:(NSInteger)cat
                      keyWords:(NSArray *)keyWords
                        isTest:(BOOL)isTest
                       success:(void (^)(CTNativeAdModel *nativeModel))success
                       failure:(void (^)(NSError *error))failure;


/**
 Get Multiterm Element Native ADs
 Using inheritance CTNativeAd advertising View customize layout, in prior to add to the parent View will return to the frame and successful nativeModel assigned to a custom View.
 
 @param slot_id         Cloud Tech Native AD ID
 @param num             Ad numbers
 @param delegate        Set Delegate of Ad event(<CTNativeAdDelegate>)
 @param WHRate          Set Image Rate
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Element Ad
 @param failure         The request failed Block, retuen error
 */
-(void)getMultitermNativeADswithSlotId:(NSString *)slot_id
                             adNumbers:(NSInteger)num
                              delegate:(id)delegate
                   imageWidthHightRate:(CTImageWidthHightRate)WHRate
                                isTest:(BOOL)isTest
                               success:(void (^)(NSArray *nativeArr))success
                               failure:(void (^)(NSError *error))failure;


#pragma mark - Banner AD Interface
/**
 Get Banner Ad View
 
 @param slot_id         Cloud Tech Banner AD ID
 @param delegate        Set Delegate of Ad event(<CTBannerDelegate>)
 @param frame           Set Ad Frame
 @param isNeedBtn       show close button at the top-right corner of the advertisement
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Banner Ad View
 @param failure         The request failed Block, retuen error
 */
- (void)getBannerADswithSlotId:(NSString *)slot_id
                      delegate:(id)delegate
                         frame:(CGRect)frame
               needCloseButton:(BOOL)isNeedBtn
                        isTest:(BOOL)isTest
                       success:(void (^)(UIView *bannerView))success
                       failure:(void (^)(NSError *error))failure;


#pragma mark - Interstitial Ad interface
/**
 Preload Interstitial, Get Interstitial Ad View

 @param slot_id         Cloud Tech Intersitital AD ID
 @param delegate        Set Delegate of Ad event(<CTInterstitialDelegate>)
 @param isFull          If is Screen，set Yes,else set No
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Interstitial Ad View
 @param failure         The request failed Block, retuen error
 */
- (void)preloadInterstitialWithSlotId:(NSString *)slot_id
                             delegate:(id)delegate
                         isFullScreen:(BOOL)isFull
                               isTest:(BOOL)isTest
                              success:(void (^)(UIView *InterstitialView))success
                              failure:(void (^)(NSError *error))failure;

/**
 Interstitial Show
 */
- (BOOL)interstitialShow;

/**
 Interstitial Close
  */
- (BOOL)interstitialClose;

/**
 Interstitial Screen Direction
 If you use interstitialShow,you can use this method Support the relation screen
 */
- (void)ScreenIsVerticalScreen:(BOOL)isVerticalScreen;

/**
 Interstitial Show With Controller Style
 Show interstitial advertisement by present VC stryle
  */
- (BOOL)interstitialShowWithControllerStyleFromRootViewController:(UIViewController *)rootViewController;
- (BOOL)interstitialShowWithControllerStyle;//deprecated


#pragma mark - Native AD Interface
/**
 Get NaTemplate Ad View

 @param slot_id         Cloud Tech Native AD ID
 @param delegate        Set Delegate of Ad event(<CTNaTemplateDelegate>)
 @param frame           Set Ad Frame
 @param isNeedBtn       show close button at the top-right corner of the advertisement
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block, return Native Ad View
 @param failure         The request failed Block, retuen error
 */
- (void)getNaTemplateADswithSlotId:(NSString *)slot_id
                          delegate:(id)delegate
                             frame:(CGRect)frame
                   needCloseButton:(BOOL)isNeedBtn
                            isTest:(BOOL)isTest
                           success:(void (^)(UIView *NaTemplateView))success
                           failure:(void (^)(NSError *error))failure;


#pragma mark - AppWall Ad Interface
/**
 Get AppWall ViewController
 First,you must should Call preloadAppWallWithSlotID method,Then get successs,call showAppWallViewController method show Appwall！
 
 @param slot_id         Cloud Tech Native AD ID
 @param customColor     If you want set custom UI,you should create CTCustomColor object
 @param delegate        Set Delegate of Ads event (<CTAppWallDelegate>)
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block
 @param failure         The request failed Block, retuen error
 */
- (void)preloadAppWallWithSlotID:(NSString *)slot_id
                customColor:(CTCustomColor *)customColor
                   delegate:(id)delegate
                     isTest:(BOOL)isTest
                    success:(void(^)())success
                    failure:(void(^)(NSError *error))failure;

/**
 Get App Wall ViewController

 @return AppWallViewController
 */
- (UIViewController *)showAppWallViewController;


#pragma mark - Video Ad Interface
/**
 Get Video Ad View
 First,you must should Call (getVideoADswithSlotId:delegate:frame:isTest:success:failure:) method,Then get successs,call videoViewPlay:isMute: method show Video Ad！

 @param slot_id         Cloud Tech AD ID
 @param delegate        Set Delegate of Ads event (<CTVideoDelegate>)
 @param frame           Set frame for video Ad
 @param isTest          Use test advertisement or not
 @param success         The request is successful Block
 @param failure         The request failed Block, retuen error
 */
- (void)getVideoADswithSlotId:(NSString *)slot_id
                    delegate:(id)delegate
                       frame:(CGRect)frame
                      isTest:(BOOL)isTest
                     success:(void (^)(UIView *videoView))success
                     failure:(void (^)(NSError *error))failure;

/**
 Video play Method

 @param videoView       use videoView play
 @param mute            voice
 */
- (void)videoViewPlay:(UIView *)videoView  isMute:(BOOL)mute;


#pragma mark - RewardVideo Ad Interface
//Get Reward Video Ads
/**
 Get RewardVideo Ad
 First,you must should Call (loadRewardVideoWithSlotId:delegate:) method get RewardVideo Ad！Then On his return to the success of the proxy method invokes the （showRewardVideo） method

 @param slot_id         Cloud Tech AD ID
 @param delegate        Set Delegate of Ads event (<CTRewardVideoDelegate>)
 */
- (void)loadRewardVideoWithSlotId:(NSString *)slot_id delegate:(id)delegate finishPageIsVertical:(BOOL)isVertical;

/**
 show RewardVideo
 */
- (void)showRewardVideo;


#pragma mark - CTSDK Version
/**
 Get SDK Version

 @return SDK Version (NSString class)
 */
- (NSString*)getSDKVersion;

@end


