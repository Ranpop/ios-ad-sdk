//
//  CTRewardVideoDelegate.h
//  CTSDK
//
//  Created by 兰旭平 on 2017/3/10.
//  Copyright © 2017年 Mirinda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CTRewardVideoDelegate <NSObject>
@optional
/**
 *  CTRewardVideo
 **/
- (void)CTRewardVideoLoadSuccess;

/**
 *  CTRewardVideo bigin playing Ad
 **/
- (void)CTRewardVideoDidStartPlaying;

/**
 *  CTRewardVideo playing Ad finish
 **/
- (void)CTRewardVideoDidFinishPlaying;

/**
 *  CTRewardVideo Click Ads
 **/
- (void)CTRewardVideoDidClickRewardAd;

/**
 * CTRewardVideo will leave Application
 **/
- (void)CTRewardVideoWillLeaveApplication;

/**
 *  CTRewardVideo jump AppStroe failed
 **/
- (void)CTRewardVideoJumpfailed;

/**
 *  CTRewardVideo loading failed
 **/
- (void)CTRewardVideoLoadingFailed:(NSError *)error;

/**
 *  CTRewardVideo closed
 **/
- (void)CTRewardVideoClosed;

@end
