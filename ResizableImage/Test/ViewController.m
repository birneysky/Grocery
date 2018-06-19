//
//  ViewController.m
//  Test
//
//  Created by birney on 2018/3/2.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image0;
@property (weak, nonatomic) IBOutlet UIView *image0View;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (nonatomic,assign) CGFloat topInset;
@property (nonatomic,assign) CGFloat leftInset;
@property (nonatomic,assign) CGFloat bottomInset;
@property (nonatomic,assign) CGFloat rightInset;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *image0HeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *image0WidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightInsetConstraint;

@end

/// public_service_submenu_bg, SenderTextNodeBkg ,SentScreenSnipBtn, imageLeft imageRight
NSString*  const resizeImageName = @"imageRight";
const CGSize targetSize = (CGSize){166,43};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIImage* image = [UIImage imageNamed:resizeImageName];
    self.sizeLabel.text = NSStringFromCGSize(CGSizeMake(ceilf(image.size.width), ceilf(image.size.height)));
    UIEdgeInsets inset = UIEdgeInsetsMake(self.topInset, self.leftInset, self.bottomInset, self.rightInset);
    image = [image resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
    
//    image0Frame.size.width = image.size.width;
//    image0Frame.size.height = image.size.height;
    self.image0HeightConstraint.constant = image.size.height;
    self.image0WidthConstraint.constant = image.size.width;
    

    
    self.image0.image = image;
    self.image1.image = image;
    self.image2.image = image;
}


- (void)viewDidLayoutSubviews {
     UIImage* image = [UIImage imageNamed:resizeImageName];
    CGRect image0Frame = self.image0View.frame;
    CGRect image1Frame = self.image1.frame;
    image1Frame.origin.y = CGRectGetMaxY(image0Frame) + 50;
    image1Frame.size.width = image.size.width ;
    image1Frame.size.height = image.size.height * 1.5;
    self.image1.frame = image1Frame;
    self.secondLabel.text = NSStringFromCGSize(CGSizeMake(ceilf(image1Frame.size.width), ceilf(image1Frame.size.height)));
    CGRect image2Frame = self.image2.frame;
    image2Frame.size.width = image.size .width * 2;
    image2Frame.size.height = image.size.height * 2;
    self.image2.frame = image2Frame;
        self.thirdLabel.text = NSStringFromCGSize(CGSizeMake(ceilf(image2Frame.size.width), ceilf(image2Frame.size.height)));
}

#pragma mark - Target Action

- (IBAction)topAction:(UIStepper *)sender {
    self.topInset = sender.value;
    self.topLabel.text = [NSString stringWithFormat:@"Top:%lf",self.topInset];
    self.topInsetConstraint.constant = self.topInset;
    [self updateImage];
}
- (IBAction)leftAction:(UIStepper*)sender {
    self.leftInset = sender.value;
    self.leftLabel.text = [NSString stringWithFormat:@"Left:%lf",self.leftInset];
    self.leftInsetConstraint.constant = self.leftInset;
    [self updateImage];
}
- (IBAction)bottomAction:(UIStepper*)sender {
    self.bottomInset = sender.value;
    self.bottomLabel.text = [NSString stringWithFormat:@"Bottom:%lf",self.bottomInset];
    self.bottomInsetConstraint.constant = self.bottomInset;
    [self updateImage];
}
- (IBAction)rightAction:(UIStepper*)sender {
    self.rightInset = sender.value;
    self.rightLabel.text = [NSString stringWithFormat:@"Right:%lf",self.rightInset];
    self.rightInsetConstraint.constant = self.rightInset;
    [self updateImage];
}

- (void)updateImage {
    [self.image0View updateConstraintsIfNeeded];
    UIImage* image = [UIImage imageNamed:resizeImageName];
    UIEdgeInsets inset = UIEdgeInsetsMake(self.topInset, self.leftInset, self.bottomInset, self.rightInset);
    image = [image resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
    self.image1.image = image;
    self.image2.image = image;
}

- (UIImage *)captureView:(UIView *)view{
    
    UIGraphicsBeginImageContext(view.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:context];
    
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}


- (IBAction)doneAction:(id)sender {
    
    UIImage* image1 = [self captureView:self.image1];
    NSData* image1Data = UIImagePNGRepresentation(image1);
    NSString* image1Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image1.png"];
    [image1Data writeToFile:image1Path atomically:YES];
    
    UIImage* image2 = [self captureView:self.image2];
    NSData* image2Data = UIImagePNGRepresentation(image2);
    NSString* image2Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image2.png"];
    [image2Data writeToFile:image2Path atomically:YES];
    
    NSLog(@"%@",image1Path);
}

@end
