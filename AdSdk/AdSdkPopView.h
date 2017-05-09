//
//  AdSdkPopView.h
//  AdSdk
//
//  Created by 冉文龙 on 2017/5/8.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AdSdkPopViewDelegate <NSObject>
@optional
-(void)popViewClose;
-(void)popViewClick;
@end

//关闭按钮位置
typedef NS_ENUM(NSInteger, ButtonPositionType){
    /**
     *  无
     */
    ButtonPositionTypeNone = 0,
    /**
     *  左上角
     */
    ButtonPositionTypeLeft = 1 << 0,
    /**
     *  右上角
     */
    ButtonPositionTypeRight = 2 << 0
};

//蒙版背景色
typedef NS_ENUM(NSInteger, ShadeBackgroundType){
    /**
     *  渐变色
     */
    ShadeBackgroundTypeGradient = 0,
    /**
     *  固定色
     */
    ShadeBackgroundTypeSolid = 1 << 0
};

typedef void(^completeBlock)(void);

@interface AdSdkPopView : NSObject

@property (nonatomic, weak) id<AdSdkPopViewDelegate> delegate;

//弹出视图背景色
@property (strong, nonatomic) UIColor *popBackgroudColor;
//点击蒙板是否弹出视图消失
@property (assign, nonatomic) BOOL tapOutsideToDismiss;
//关闭按钮的类型
@property (assign, nonatomic) ButtonPositionType closeButtonType;
//蒙板的背景色
@property (assign, nonatomic) ShadeBackgroundType shadeBackgroundType;

/** 
 * 创建一个实例
 *
 **/
+(AdSdkPopView *)sharedInstance;

/**
 *  弹出要展示的View
 *
 *  @param presentView show View
 *  @param animated    是否动画
 */

- (void)showWithPresentView:(UIView *)presentView animated:(BOOL)animated;

/**
 *  关闭弹出视图
 *
 *  @param complete complete block
 */
- (void)closeWithBlcok:(void(^)())complete;

@end
