//
//  TTAlarmConfigFootView.h
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTAlarmConfigFootViewDelegate <NSObject>

- (void)clickFootWith:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TTAlarmConfigFootView : UIView

@property (nonatomic, strong) id<TTAlarmConfigFootViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
