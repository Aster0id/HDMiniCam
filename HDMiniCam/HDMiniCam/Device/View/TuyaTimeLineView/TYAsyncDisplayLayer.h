//
//  TYAsyncDisplayLayer.h
//  TimeLineView
//
//  Created by 傅浪 on 2018/5/3.
//  Copyright © 2018年 傅浪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TYAsyncDisplayLayer;
@protocol TYAsyncDisplayLayerDelegate <NSObject>
@optional

- (void)asyncDisplayLayerWillDisplay:(TYAsyncDisplayLayer *)layer;

- (void)asyncDisplayLayer:(TYAsyncDisplayLayer *)layer
                 drawRect:(CGRect)rect
                inContext:(CGContextRef)ctx
              isCancelled:(BOOL(^)(void))isCancelled;

- (void)asyncDisplayLayer:(TYAsyncDisplayLayer *)layer didDisplay:(BOOL)complete;

@end

@interface TYAsyncDisplayLayer : CALayer

@property (nonatomic, assign) BOOL displaysAsynchronously;

@property (nonatomic, strong) dispatch_queue_t displaysQueue;

@property (nonatomic, weak) id<TYAsyncDisplayLayerDelegate> displayDelegate;

- (void)cancel;

@end
