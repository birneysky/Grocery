//
//  RTSettingTableViewController.h
//  RTCTester
//
//  Created by birney on 2019/1/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GSRTCVideoCaptureParam;

@protocol RTSettingTableViewControllerDeleggate <NSObject>

- (void)DidChanegeCameraCaptureParam:(GSRTCVideoCaptureParam*)params;

@end

@interface GSSettingTableViewController : UITableViewController

@property(nonatomic,weak) id<RTSettingTableViewControllerDeleggate> delegate;

@end

NS_ASSUME_NONNULL_END
