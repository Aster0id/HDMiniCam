//
//  KHJAlarmConfFootView.h
//  HDMiniCam
//
//  Created by khj888 on 2020/3/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KHJAlarmConfFootViewDelegate <NSObject>

- (void)clickFootWith:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KHJAlarmConfFootView : UIView

@property (nonatomic, strong) id<KHJAlarmConfFootViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
