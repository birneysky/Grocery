//
//  DrawViewController.m
//  Test
//
//  Created by birney on 2018/4/15.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "DrawViewController.h"
#import <math.h>

@interface DrawViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect rect = self.imageView.frame;
    self.imageView.image = [self drawPopoverImage:rect.size arrowOffset:rect.size.width/2];
    self.imageView.backgroundColor = [UIColor whiteColor];
//    self.imageView.layer.contentsScale = [UIScreen mainScreen].scale;
//    self.imageView.layer.shouldRasterize = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIImage*)drawPopoverImage:(CGSize)size arrowOffset:(NSUInteger)offset {
    const CGSize arrowSize = (CGSize){12,8};
    const CGFloat arrowOffsetMin = 16;
    const CGFloat arrowOffsetMax = size.width - 8;
    const CGFloat radius = 40;
    CGFloat lineWidth = 0.5;
    CGFloat margin = 2;
    if (offset < arrowOffsetMin) {
        offset = arrowOffsetMin;
    } else if (offset > arrowOffsetMax){
        offset = arrowOffsetMax;
    }
    
    UIColor* fillColor = [UIColor whiteColor];
    UIColor* strokeColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1];

    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextBeginTransparencyLayer(context, nil);
    CGFloat startX = arrowSize.width / 2 + offset - margin;
    UIBezierPath* path = [UIBezierPath bezierPath];
    path.lineWidth = lineWidth;
    path.lineJoinStyle = kCGLineJoinMiter;
    path.lineCapStyle = kCGLineCapSquare;
    
    [path moveToPoint:CGPointMake(margin+lineWidth, radius+margin+lineWidth)];
    [path addArcWithCenter:CGPointMake(margin+radius+lineWidth,radius+margin+lineWidth) radius:radius startAngle:M_PI endAngle:-0.5*M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(size.width-radius-lineWidth-margin, margin+lineWidth)];
    [path addArcWithCenter:CGPointMake(size.width-radius-lineWidth-margin,radius+lineWidth+margin) radius:radius startAngle:-0.5*M_PI endAngle:0 clockwise:YES];

    [path addLineToPoint:CGPointMake(size.width-margin-lineWidth, size.height-radius-margin-lineWidth-arrowSize.height)];
    
    [path addArcWithCenter:CGPointMake(size.width-radius-lineWidth-margin,size.height-radius-margin-lineWidth-arrowSize.height) radius:radius startAngle:0 endAngle:0.5*M_PI clockwise:YES];
    
    [path addLineToPoint:CGPointMake(startX+arrowSize.width/2, size.height-margin-lineWidth-arrowSize.height)];
    [path addLineToPoint:CGPointMake(startX, size.height-margin)];
    [path addLineToPoint:CGPointMake(startX-arrowSize.width/2, size.height-margin-lineWidth-arrowSize.height)];
    [path addLineToPoint:CGPointMake(margin+radius+lineWidth, size.height-margin-lineWidth-arrowSize.height)];
    [path addArcWithCenter:CGPointMake(margin+radius+lineWidth,size.height-radius-margin-lineWidth-arrowSize.height) radius:radius startAngle:0.5*M_PI endAngle:M_PI clockwise:YES];
    [path moveToPoint:CGPointMake(margin+lineWidth,size.height-radius-margin-lineWidth-arrowSize.height)];
    [path addLineToPoint:CGPointMake(margin+lineWidth, margin+radius+lineWidth)];
    
    path.miterLimit = 1;
    path.usesEvenOddFillRule = YES;
    path.flatness = 1;
    [strokeColor setStroke];
    [fillColor setFill];
    [path fill];
    [path stroke];
    [path closePath];
    
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context,YES);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetFlatness(context, 1);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


//- (UIImage*)drawPopoverImage:(CGSize)size arrowOffset:(NSUInteger)offset {
//    const CGSize arrowSize = (CGSize){12,8};
//    const CGFloat arrowOffsetMin = 16;
//    const CGFloat arrowOffsetMax = size.width - 8;
//    const CGFloat radius = 8;
//    CGFloat lineWidth = 0.5;
//    CGFloat margin = 4;
//    if (offset < arrowOffsetMin) {
//        offset = arrowOffsetMin;
//    } else if (offset > arrowOffsetMax){
//        offset = arrowOffsetMax;
//    }
//
//    UIColor* fillColor = [UIColor whiteColor];
//    UIColor* strokeColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1];
//
//    UIGraphicsBeginImageContext(size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    CGContextBeginTransparencyLayer(context, nil);
//    CGFloat startX = arrowSize.width / 2 + offset - margin;
//    UIBezierPath* path = [UIBezierPath bezierPath];
//    path.lineWidth = lineWidth;
//    path.lineJoinStyle = kCGLineJoinMiter;
//    path.lineCapStyle = kCGLineCapSquare;
//
//    UIBezierPath* leftTopArcPath = [UIBezierPath bezierPath];
//    [leftTopArcPath addArcWithCenter:CGPointMake(margin+radius+lineWidth,radius+margin+lineWidth) radius:radius startAngle:M_PI endAngle:-0.5*M_PI clockwise:YES];
//    [path appendPath:leftTopArcPath];
//
//    [path moveToPoint:CGPointMake(radius+margin+lineWidth, margin+lineWidth)];
//    [path addLineToPoint:CGPointMake(size.width-radius-lineWidth-margin, margin+lineWidth)];
//
//    UIBezierPath* rightTopArcPath = [UIBezierPath bezierPath];
//    [rightTopArcPath addArcWithCenter:CGPointMake(size.width-radius-lineWidth-margin,radius+lineWidth+margin) radius:radius startAngle:-0.5*M_PI endAngle:0 clockwise:YES];
//    [path appendPath:rightTopArcPath];
//
//    [path moveToPoint:CGPointMake(size.width-margin-lineWidth , margin+radius+lineWidth)];
//    [path addLineToPoint:CGPointMake(size.width-margin-lineWidth, size.height-radius-margin-lineWidth-arrowSize.height)];
//
//    UIBezierPath* rightbottomArcPath = [UIBezierPath bezierPath];
//    [rightbottomArcPath addArcWithCenter:CGPointMake(size.width-radius-lineWidth-margin,size.height-radius-margin-lineWidth-arrowSize.height) radius:radius startAngle:0 endAngle:0.5*M_PI clockwise:YES];
//    [path appendPath:rightbottomArcPath];
//
//    [path moveToPoint:CGPointMake(size.width-radius-lineWidth-margin, size.height-margin-lineWidth-arrowSize.height)];
//    [path addLineToPoint:CGPointMake(startX+arrowSize.width/2, size.height-margin-lineWidth-arrowSize.height)];
//    [path addLineToPoint:CGPointMake(startX, size.height-margin)];
//    [path addLineToPoint:CGPointMake(startX-arrowSize.width/2, size.height-margin-lineWidth-arrowSize.height)];
//    [path addLineToPoint:CGPointMake(margin+radius+lineWidth, size.height-margin-lineWidth-arrowSize.height)];
//    UIBezierPath* leftbottomArcPath = [UIBezierPath bezierPath];
//    [leftbottomArcPath addArcWithCenter:CGPointMake(margin+radius+lineWidth,size.height-radius-margin-lineWidth-arrowSize.height) radius:radius startAngle:0.5*M_PI endAngle:M_PI clockwise:YES];
//    [path appendPath:leftbottomArcPath];
//    [path moveToPoint:CGPointMake(margin+lineWidth,size.height-radius-margin-lineWidth-arrowSize.height)];
//    [path addLineToPoint:CGPointMake(margin+lineWidth, margin+radius+lineWidth)];
//
//    path.miterLimit = 1;
//    path.usesEvenOddFillRule = YES;
//    [strokeColor setStroke];
//    [fillColor setFill];
//    [path fill];
//    [path stroke];
//
//    CGContextSetLineCap(context, kCGLineCapSquare);
//    CGContextSetLineJoin(context, kCGLineJoinRound);
//    CGContextSetShouldAntialias(context, YES);
//    CGContextSetAllowsAntialiasing(context,YES);
//    CGContextSetLineWidth(context, lineWidth);
//    CGContextSetFlatness(context, 1);
//    CGContextFillPath(context);
//    CGContextStrokePath(context);
//    CGContextEndTransparencyLayer(context);
//    CGContextRestoreGState(context);
//    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return image;
//}

@end
