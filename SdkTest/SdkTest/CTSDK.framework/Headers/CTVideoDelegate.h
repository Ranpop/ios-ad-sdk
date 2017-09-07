//
//  CTVideoDelegate.h
//  CTSDK
//

#import <Foundation/Foundation.h>

@protocol CTVideoDelegate <NSObject>

@optional
- (void)CTVideoStartPlay:(UIView *)videoView;
- (void)CTVideoPlayEnd:(UIView *)videoView;
- (void)CTVideoClicked:(UIView *)videoView;
- (void)CTVideoDidLeaveApplication:(UIView *)videoView;
- (void)CTVideoJumpfailed:(UIView *)videoView;

@end
