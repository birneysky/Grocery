//
//  RTPickerContainer.h
//  RTCTester
//
//  Created by birney on 2019/1/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTPickerContainerDelegate <NSObject>

- (void)cancel;
- (void)done;

@end

@interface GSPickerContainer : UIView
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) id<RTPickerContainerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
