//
//  UIView+TToast.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "UIView+TToast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface UIView (ToastPrivate)

- (CGPoint)centerPointForPosition:(id)position
                        withToast:(UIView *)toast;

- (UIView *)viewForMessage:(NSString *)message
                     title:(NSString *)title
                     image:(UIImage *)image;

@end

@implementation UIView (TToast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message
{
    [self makeToast:message duration:3.0 position:@"bottom"];
}

- (void)makeToast:(NSString *)message
         duration:(CGFloat)interval
         position:(id)position
{
    [self showToast:[self viewForMessage:message] duration:interval position:position];
}

- (void)showToast:(UIView *)toast
         duration:(CGFloat)interval
         position:(id)point
{
    toast.center = [self centerPointForPosition:point withToast:toast];
    toast.alpha = 0.0;
    [self addSubview:toast];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toast.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:interval options:UIViewAnimationOptionCurveEaseIn animations:^{
            toast.alpha = 0.0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

#pragma mark - Private Methods

- (CGPoint)centerPointForPosition:(id)point
                        withToast:(UIView *)toast
{
    if ([point isKindOfClass:[NSString class]]) {
        
        if ([point caseInsensitiveCompare:@"top"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + 10.0);
        }
        else if ([point caseInsensitiveCompare:@"bottom"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - 10.0 - 60 - 20 );
        }
        else if ([point caseInsensitiveCompare:@"center"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    }
    else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    return [self centerPointForPosition:@"bottom" withToast:toast];
}

- (UIView *)viewForMessage:(NSString *)message
{
    if (message == nil) return nil;

    UILabel *messageLabel   = nil;
    
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = 5.0;
    wrapperView.layer.shadowColor   = [UIColor blackColor].CGColor;
    wrapperView.layer.shadowOpacity = 0.4;
    wrapperView.layer.shadowRadius  = 6.0;
    wrapperView.layer.shadowOffset  = CGSizeMake(4.0, 4.0);
    wrapperView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    if (message) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        messageLabel.font = [UIFont systemFontOfSize:14.0];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * 0.8), self.bounds.size.height * 0.8);
        
        CGSize expectedSizeMessage = [message boundingRectWithSize:maxSizeMessage options:NSStringDrawingTruncatesLastVisibleLine attributes:[NSDictionary dictionaryWithObjectsAndKeys:messageLabel.font,NSFontAttributeName, nil] context:nil].size;
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;

    if (messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft =  10.0;
        messageTop =  10.0;
    }
    else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    
    CGFloat longerWidth     = MAX(0, messageWidth);
    CGFloat longerLeft      = MAX(0, messageLeft);
    CGFloat wrapperWidth    = MAX((10.0 * 2), (longerLeft + longerWidth + 10.0));
    CGFloat wrapperHeight   = MAX((messageTop + messageHeight + 10.0), (10.0 * 2));
    
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
    if (messageLabel) {
        messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
        [wrapperView addSubview:messageLabel];
    }
    return wrapperView;
}

@end
