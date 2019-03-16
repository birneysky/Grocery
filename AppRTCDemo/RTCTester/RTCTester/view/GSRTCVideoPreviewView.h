//
//  RCVideoPreview.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2018/12/17.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 视频填充方式
 
 - RCVideoGravityAspect: 自适应大小显示
 - RCVideoGravityAspectFill: 填充显示
 */
typedef NS_ENUM(NSInteger, RCVideoFillMode) {
    RCVideoFillModeAspect ,
    RCVideoFillModeAspectFill
};

NS_ASSUME_NONNULL_BEGIN

@interface GSRTCVideoPreviewView : UIView

@property(nonatomic,assign) RCVideoFillMode filleMode;

@end

NS_ASSUME_NONNULL_END
