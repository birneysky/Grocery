//
//  JoinViewController.m
//  RTCTester
//
//  Created by birney on 2019/1/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSJoinViewController.h"
//#import <RongIMLib/RongIMLib.h>
//#import <RongRTCLib/RongRTCLib.h>
#import "GSAVChatViewController.h"

// 88060000
//#define RONGCLOUD_IM_APPKEY @"lmxuhwagli01d" // online key
//#define RONGCLOUD_IM_TOKEN @"PFXIZSdC6XvReEG2tVZ8SrRNzeFHa4P3IzvSmKhMNfGz60RTyr5rAb/BUmugTQDUZ59Lo67pOzFByRI/boyvGCAli5AdghPf"
//
//// 88060001
//#define REMOTE_IM_TOKEN @"WhFxgx2FOYkcl1sXKrOn7QRBMfi1wh6EyS7l6gJfnzYcPu3FzXIauIFJV7YobVSQdI6DgbzWuiM9ejcZrr1ORA=="

#define RONGCLOUD_IM_APPKEY @"e0x9wycfx7flq" // online key
#define RONGCLOUD_IM_TOKEN @"lBrpjC+Iry41go6BLgitsgpRCpGrPzwCFuGMdWXYpP7HqNp27QlOgFSsNuW+YpkdkA5KlKHN5HyyBp3i2uRchqcJF/wOnBc4"

@interface GSJoinViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property(nonatomic,copy) NSString* roomId;
@property(nonatomic,copy) NSString* targetId;
@end

@implementation GSJoinViewController

- (void)loadView {
    [super loadView];

    self.inputTextField.layer.borderColor = self.view.tintColor.CGColor;
    self.inputTextField.layer.borderWidth = 0.5;
    self.inputTextField.layer.cornerRadius = 30;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL sender = YES;
    NSString * token;
    if (sender) {
        token = RONGCLOUD_IM_TOKEN;
    }
    else{
        //token = REMOTE_IM_TOKEN;
    }
    
//    [[RCIMClient sharedRCIMClient] initWithAppKey:RONGCLOUD_IM_APPKEY];
//    [[RCIMClient sharedRCIMClient] useRTCOnly];
//    [[RCIMClient sharedRCIMClient] setServerInfo:@"http://navxq.rongcloud.net" fileServer:@"xiaxie"];
//    [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
//        self.targetId = userId;
//
//    } error:^(RCConnectErrorCode status) {
//        NSLog(@"链接失败了---%@",@(status));
//    } tokenIncorrect:^{
//        
//    }];
}

-(void)didReceiveCall{
    
}

-(void)didConnected{
    
}

-(void)receiveButton{
    
}

-(void)sendButton{
    
//    [[RongRTCP2PTester sharedTester] startCall];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"push_avchat_vc"]) {
        UINavigationController* nav = (UINavigationController*)segue.destinationViewController;
        GSAVChatViewController* avc = (GSAVChatViewController*)nav.viewControllers.firstObject;
        avc.targetId = self.targetId;
        avc.roomId = self.roomId;
        self.navigationItem.hidesBackButton = YES;
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.roomId = textField.text;
        self.targetId = textField.text;
        NSAssert(self.targetId.length > 0,@"invalid target Id");
        [self performSegueWithIdentifier:@"push_avchat_vc" sender:textField];
        return YES;
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    return YES;
}

@end
