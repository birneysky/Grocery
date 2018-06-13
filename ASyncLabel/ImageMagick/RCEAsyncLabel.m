//
//  RCEAsyncLabel.m
//  ImageMagick
//
//  Created by zhaobingdong on 2018/3/21.
//  Copyright © 2018年 one. All rights reserved.
//

#import "RCEAsyncLabel.h"
#import "RCETextAttribute.h"
#import "YYAsyncLayer.h"

@interface RCEAsyncLabel () <NSLayoutManagerDelegate>

@property (nonatomic,strong) NSLayoutManager* layoutManager;
@property (nonatomic,strong) NSTextContainer *textContainer;
@property (nonatomic,strong) NSTextStorage *textStorage;
@property (nonatomic,strong) RCETextHighlightedAttribute* hightlightedAttribute;
@property (nonatomic,assign) NSRange heightRange;
@property (nonatomic,readonly) YYAsyncLayer* asyncLayer;

@end

#pragma mark - Properties



@implementation RCEAsyncLabel
- (NSTextStorage *)textStorage {
    if (!_textStorage) {
        _textStorage = [[NSTextStorage alloc] init];
    }
    return _textStorage;
}

- (NSLayoutManager *)layoutManager {
    if (!_layoutManager) {
        _layoutManager = [[NSLayoutManager alloc] init];
        //_layoutManager.allowsNonContiguousLayout = NO;
        _layoutManager.delegate = self;
    }
    return _layoutManager;
}

- (NSTextContainer *)textContainer
{
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc] init];
        _textContainer.maximumNumberOfLines = 0;
        _textContainer.lineBreakMode = NSLineBreakByClipping;
        _textContainer.lineFragmentPadding = 0.0f;
        _textContainer.size = CGSizeMake(375, 100);
    }
    return _textContainer;
}

#pragma mark - Override
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

+(Class)layerClass {
    return [YYAsyncLayer class];
}

- (YYAsyncLayer*)asyncLayer {
    return (YYAsyncLayer*)self.layer;
}

#pragma mark - Helper
- (void)setup {
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
    self.asyncLayer.opaque = YES;
}

- (RCETextHighlightedAttribute*)textHeightlightedAttributeAtPoint:(CGPoint)point
                                                   effectiveRange:(NSRangePointer)range {
    CGFloat distanceToPoint = 1.0;
    NSUInteger index = [self.layoutManager characterIndexForPoint:point
                                                  inTextContainer:self.textContainer
                         fractionOfDistanceBetweenInsertionPoints:&distanceToPoint];
    RCETextHighlightedAttribute* attribute = [self.textStorage attribute:RCETextHighlightedAttribute.name
                                                                 atIndex:index
                                                   longestEffectiveRange:range
                                                                 inRange:NSMakeRange(0, self.textStorage.length)];
    return attribute;
}

#pragma mark - NSLayoutManagerDelegate
//- (NSUInteger)layoutManager:(NSLayoutManager *)layoutManager
//       shouldGenerateGlyphs:(const CGGlyph *)glyphs
//                 properties:(const NSGlyphProperty *)props
//           characterIndexes:(const NSUInteger *)charIndexes
//                       font:(UIFont *)aFont
//              forGlyphRange:(NSRange)glyphRange
//{
//    NSLog(@"shouldGenerateGlyphs:  start:%ld end:%ld",*charIndexes,charIndexes[glyphRange.length-1]);
//    [layoutManager setGlyphs:glyphs
//                  properties:props
//            characterIndexes:charIndexes
//                        font:aFont
//               forGlyphRange:glyphRange];
//    return glyphRange.length;
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

#pragma mark - Api
- (void)setText:(NSString *)text
{
    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:text];
    [self.textStorage setAttributedString:attString];
    
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self.textStorage setAttributedString:attributedText];
    self.asyncLayer.displaysAsynchronously = YES;
    [self.asyncLayer setNeedsDisplay];
}


#pragma mark - Override
- (void)drawRect:(CGRect)rect {
    //这里根据container的size和manager布局属性以及字符串来得到实际绘制的range区间
    NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];

    //获取绘制区域大小
    //CGRect drawBounds = [self.layoutManager usedRectForTextContainer:self.textContainer];

    //绘制文字
    if (self.hightlightedAttribute) {
//        CGRect hightlightRect =
//            [self.layoutManager boundingRectForGlyphRange:self.heightRange inTextContainer:self.textContainer];
        [self.textStorage addAttributes:self.hightlightedAttribute.attributes range:self.heightRange];
//        [self.layoutManager drawBackgroundForGlyphRange:self.heightRange atPoint:hightlightRect.origin];
//        [self.layoutManager drawGlyphsForGlyphRange:self.heightRange atPoint:hightlightRect.origin];
    } else {

    }
    [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:CGPointZero];
    [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:CGPointZero];


}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    RCETextHighlightedAttribute* hightlightedAttribute =
        [self textHeightlightedAttributeAtPoint:point effectiveRange:&range];
    if (!hightlightedAttribute) {
        [super touchesBegan:touches withEvent:event];
        return;
    } else {
        self.heightRange = range;
        self.hightlightedAttribute  = hightlightedAttribute;
        CGRect hightlightRect =
        [self.layoutManager boundingRectForGlyphRange:self.heightRange inTextContainer:self.textContainer];
        NSLog(@"hightlight rect %@",NSStringFromCGRect(hightlightRect));
    }
    self.asyncLayer.displaysAsynchronously = NO;
    [self.asyncLayer setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    RCETextHighlightedAttribute* hightlightedAttribute =
        [self textHeightlightedAttributeAtPoint:point effectiveRange:&range];
    if (self.hightlightedAttribute != hightlightedAttribute) {
        self.hightlightedAttribute = nil;
    }
    self.asyncLayer.displaysAsynchronously = NO;
    [self.asyncLayer setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    RCETextHighlightedAttribute* hightlightedAttribute =
        [self textHeightlightedAttributeAtPoint:point effectiveRange:&range];
    if (self.hightlightedAttribute != hightlightedAttribute) {
        self.hightlightedAttribute = nil;
        //[self.layer setNeedsDisplay];
    } else {
    }
    self.asyncLayer.displaysAsynchronously = NO;
    [self.asyncLayer setNeedsDisplay];
}

- (YYAsyncLayerDisplayTask *)newAsyncDisplayTask {

    
    YYAsyncLayerDisplayTask *task = [[YYAsyncLayerDisplayTask alloc]init];
    // will display
    task.willDisplay = ^(CALayer * _Nonnull layer) {

    };
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void)) {
        NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        
        //获取绘制区域大小
        //CGRect drawBounds = [self.layoutManager usedRectForTextContainer:self.textContainer];
        
        //绘制文字
        if (self.hightlightedAttribute) {
//                    CGRect hightlightRect =
//                        [self.layoutManager boundingRectForGlyphRange:self.heightRange inTextContainer:self.textContainer];
            [self.textStorage addAttributes:self.hightlightedAttribute.attributes range:self.heightRange];
//                    [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:CGPointZero];
//                    [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:CGPointZero];
        }
        [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:CGPointZero];
        [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:CGPointZero];
    };
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
    };
    return task;
}

@end
