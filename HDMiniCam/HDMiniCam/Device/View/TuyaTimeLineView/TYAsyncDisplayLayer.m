//
//  TYAsyncDisplayLayer.m
//  TimeLineView
//
//  Created by 傅浪 on 2018/5/3.
//  Copyright © 2018年 傅浪. All rights reserved.
//

#import "TYAsyncDisplayLayer.h"
#import <stdatomic.h>

@implementation TYAsyncDisplayLayer {
    atomic_int _sentinel;
}

- (instancetype)init {
    if (self = [super init]) {
        static CGFloat scale;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            scale = [UIScreen mainScreen].scale;
        });
        self.contentsScale = scale;
        self.displaysAsynchronously = YES;
        self.displaysQueue = dispatch_queue_create("com.tuya.asyncDisplay", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setNeedsDisplay {
    [self ty_cancelAsyncDisplay];
    [super setNeedsDisplay];
}

- (void)display {
    if (_displaysAsynchronously) {
        [self ty_displaysAsync];
    }else {
        [self ty_cancelAsyncDisplay];
        [super display];
    }
}

- (void)cancel {
    [self ty_cancelAsyncDisplay];
}

- (void)ty_displaysAsync {
    
    CGRect rect = self.bounds;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    if (![self.displayDelegate respondsToSelector:@selector(asyncDisplayLayer:drawRect:inContext:isCancelled:)]
        || rect.size.width <= 0 || rect.size.height <= 0) {
        [self ty_willDisplay];
        self.contents = nil;
        [self ty_didDisplay:YES];
        return;
    }
    
    
    if (_displaysAsynchronously) {
        [self ty_willDisplay];
        atomic_int sentinel = _sentinel;
        atomic_int *pSentinel = &_sentinel;
        BOOL (^isCancelled)(void) = ^BOOL() {
            return *pSentinel != sentinel;
        };
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
        dispatch_async(_displaysQueue, ^{
            if (isCancelled()) {
                CGColorRelease(backgroundColor);
                return;
            }
            UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            if (opaque) {
                CGContextSaveGState(ctx); {
                    if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
                        CGContextFillRect(ctx, rect);
                    }
                    if (backgroundColor) {
                        CGContextSetFillColorWithColor(ctx, backgroundColor);
                        CGContextFillRect(ctx, rect);
                    }
                } CGContextRestoreGState(ctx);
                CGColorRelease(backgroundColor);
            }
            [self.displayDelegate asyncDisplayLayer:self drawRect:rect inContext:ctx isCancelled:isCancelled];
            if (isCancelled()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self ty_didDisplay:NO];
                });
                return;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancelled()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self ty_didDisplay:NO];
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCancelled()) {
                    [self ty_didDisplay:NO];
                }else {
                    self.contents = (__bridge id)(image.CGImage);
                    [self ty_didDisplay:YES];
                }
            });
        });
    }else {
        [self ty_cancelAsyncDisplay];
        [self ty_willDisplay];
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (opaque) {
            CGContextSaveGState(ctx); {
                if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
                    CGContextFillRect(ctx, rect);
                }
                if (self.backgroundColor) {
                    CGContextSetFillColorWithColor(ctx, self.backgroundColor);
                    CGContextFillRect(ctx, rect);
                }
            } CGContextRestoreGState(ctx);
        }
        [self.displayDelegate asyncDisplayLayer:self drawRect:self.bounds inContext:ctx isCancelled:^{return NO;}];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id)(image.CGImage);
        [self ty_didDisplay:YES];
    }
}

- (void)ty_willDisplay {
    if ([self.displayDelegate respondsToSelector:@selector(asyncDisplayLayerWillDisplay:)]) {
        [self.displayDelegate asyncDisplayLayerWillDisplay:self];
    }
}

- (void)ty_didDisplay:(BOOL)complete {
    if ([self.displayDelegate respondsToSelector:@selector(asyncDisplayLayer:didDisplay:)]) {
        [self.displayDelegate asyncDisplayLayer:self didDisplay:complete];
    }
}

- (void)ty_cancelAsyncDisplay {
    atomic_fetch_add(&_sentinel, 1);
}

@end
