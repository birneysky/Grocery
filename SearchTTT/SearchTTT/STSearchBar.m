//
//  RCESearchBar.m
//  Search
//
//  Created by zhaobingdong on 2017/1/7.
//  Copyright © 2017年 Search. All rights reserved.
//

#import "STSearchBar.h"
#import "STSearchBarTextField.h"
#import "STSearchBarContainerView.h"

@interface STSearchBar () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView* background;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) STSearchBarTextField* textField;
@property (nonatomic, strong) UIImageView* searchIconView;
@property (nonatomic, strong) UILabel* placeholderLabel;
@property (nonatomic, strong) UIButton* cancelButton;
@property (nonatomic, assign) BOOL isSearching;
@end

NSNotificationName const RCESearchBarResignFirstResponderNotification = @"RCESearchBarResignFirstResponder";
NSNotificationName const RCESearchBarInputTextDidChangeNotification = @"RCESearchBarInputTextDidChangeNotification";

@implementation STSearchBar
#pragma mark - Properties
- (UIImageView*)background {
    if (!_background) {
        _background = [[UIImageView alloc] init];
        _background.backgroundColor = [UIColor colorWithRed:201/255.0f green:201/255.0f blue:206/255.0f alpha:1];
    }
    return _background;
}

- (UIView*)contentView {
    if (!_contentView) {
        _contentView  = [[UIView alloc] init];
    }
    return _contentView;
}

- (void)setFrame:(CGRect)frame {
    if ([self.superview isKindOfClass:[STSearchBarContainerView class]]) {
            CGRect rect = self.superview.frame;
            rect.origin.y = rect.size.height - 44;
            rect.size.height = 44;
        [super setFrame:rect];
    } else {
        [super setFrame:frame];        
    }
}


- (STSearchBarTextField*)textField {
    if (!_textField) {
        _textField = [[STSearchBarTextField alloc] init];
        _textField.delegate = self;
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    return _textField;
}

- (UIImageView*)searchIconView {
    if (!_searchIconView) {
        _searchIconView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,16,16}];
        _searchIconView.image = [UIImage imageNamed:@"SearchBarIcon"];
        _searchIconView.contentMode = UIViewContentModeScaleToFill;
    }
    return _searchIconView;
}

- (UILabel*)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 50, 16}];
        _placeholderLabel.text = @"搜索";
        _placeholderLabel.font = [UIFont systemFontOfSize:14.0f];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
    }
    return _placeholderLabel;
}

- (UIButton*)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:(CGRect){0, 0, 44, 44}];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                          action:@selector(cancelAction:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (NSString*)text {
    return self.textField.text;
}

- (void)setText:(NSString *)text {
    self.textField.text = text;
}

#pragma mark - Init
- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
 
#pragma mark - Helpers
- (void)setUp {
    //self.contentView.backgroundColor = [UIColor redColor];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.background];
    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.searchIconView];
    [self.contentView addSubview:self.placeholderLabel];
    [self.contentView addSubview:self.cancelButton];
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(inputTextDidChange:)
                          name:UITextFieldTextDidChangeNotification
                        object:nil];
}

#pragma mark - Override
- (void)layoutSubviews {
    CGRect originFrame = self.frame;
    CGSize statusBarSize =  [UIApplication sharedApplication].statusBarFrame.size;
    if (self.frame.size.height > 44) {
        originFrame.size.height = 44+statusBarSize.height;
        self.searchIconView.frame = (CGRect){12,14+statusBarSize.height,16,16};
        self.placeholderLabel.frame = (CGRect){12+20,14+statusBarSize.height,50,16};
        self.textField.frame = (CGRect){8,8+statusBarSize.height,self.bounds.size.width - 8 * 2 - 44, 44 - 8 *  2};
        CGFloat maxX = CGRectGetMaxX(self.textField.frame);
        self.cancelButton.frame = (CGRect){maxX,statusBarSize.height,44,44};
    } else {
        originFrame.size.height = 44;
        CGFloat midX =  CGRectGetMidX(originFrame);
        self.searchIconView.frame = (CGRect){midX - 20, 14, 16,16};
        self.textField.frame = (CGRect){8,8,statusBarSize.width - 8 * 2, 44 - 8 *  2};
        self.placeholderLabel.frame = (CGRect){midX+4,14,50,16};
        CGFloat maxX = CGRectGetMaxX(originFrame);
        self.cancelButton.frame =(CGRect){maxX,0,44,44};
    }
    self.frame = originFrame;
    self.contentView.frame = self.bounds;
    self.background.frame = self.bounds;
    
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    self.isSearching = NO;
    self.textField.text = nil;
    return [self.textField resignFirstResponder];
}

//- (CGSize)intrinsicContentSize {
//    return CGSizeMake(200, 54);
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!self.isSearching) {
        self.isSearching = YES;
//        [UIView animateWithDuration:0.35
//                              delay:0.35
//             usingSpringWithDamping:0.9
//              initialSpringVelocity:20
//                            options:UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             self.searchIconView.frame = (CGRect){12,11,20,20};
//                             self.tipsLabel.frame = (CGRect){12+20,11,50,20};
//                             self.textField.frame = (CGRect){8,8,self.bounds.size.width - 8 * 2 - 44, 44 - 8 *  2};
//                             CGFloat maxX = CGRectGetMaxX(self.textField.frame);
//                             self.cancelButton.frame = (CGRect){maxX,0,44,44};
//                         } completion:^(BOOL finished) {
//
//                         }];
        
        [UIView animateWithDuration:0.35 animations:^{
            self.searchIconView.frame = (CGRect){12,14,16,16};
            self.placeholderLabel.frame = (CGRect){12+20,14,50,16};
            self.textField.frame = (CGRect){8,8,self.bounds.size.width - 8 * 2 - 44, 44 - 8 *  2};
            CGFloat maxX = CGRectGetMaxX(self.textField.frame);
            self.cancelButton.frame = (CGRect){maxX,0,44,44};
        } completion:^(BOOL finished) {
            
        }];
    }

    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        [self.delegate searchBarShouldEndEditing:self];
    }
    return self.isSearching ? NO : YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.35 animations:^{
                         CGFloat midX =  CGRectGetMidX(self.frame);
                         self.searchIconView.frame = (CGRect){midX - 20, 14, 16,16};
                         self.textField.frame = (CGRect){8,8,self.frame.size.width - 8 * 2, 44 - 8 *  2};
                         self.placeholderLabel.frame = (CGRect){midX+4,14,50,16};
                         CGFloat maxX = CGRectGetMaxX(self.frame);
                         self.cancelButton.frame =(CGRect){maxX,0,44,44};
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:RCESearchBarInputTextDidChangeNotification object:self];
    return YES;
}

#pragma mark - Target Action
- (void)cancelAction:(UIButton*)sender {
    self.isSearching = NO;
    [self.textField resignFirstResponder];
    self.textField.text = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:RCESearchBarResignFirstResponderNotification
                                                        object:self];
}


#pragma mark - Notification selector
- (void)inputTextDidChange:(NSNotification*)notification {
    if (notification.object == self.textField) {
        self.placeholderLabel.hidden = self.textField.hasText;
    }

}
@end
