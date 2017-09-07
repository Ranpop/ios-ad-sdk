//
//  CTElementAd.h
//  CTSDK
//

#import <UIKit/UIKit.h>
#import "CTElementModel.h"
@protocol CTNativeAdDelegate;

@interface CTNativeAd : UIView
@property(nonatomic,strong)CTNativeAdModel* adNativeModel;
@property(nonatomic, weak)id<CTNativeAdDelegate> delegate;

//初始化方法
-(instancetype)init;
-(instancetype)initWithFrame:(CGRect)frame;
@end
