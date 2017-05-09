//
//  AdSdkView.m
//  AdSdk
//
//  Created by 冉文龙 on 2017/4/20.
//  Copyright © 2017年 冉文龙. All rights reserved.
//

#import "AdSdkView.h"

@implementation AdSdkView
-(instancetype)initWithFrame: (CGRect)frame{
    self = [super initWithFrame:frame];
    NSLog(@"init with frame");
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.image = [UIImage imageNamed:@"AdSdk.bundle/test.jpeg"];
//        self.imageView.backgroundColor = UIColor.blueColor;
        [self addSubview:self.imageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
