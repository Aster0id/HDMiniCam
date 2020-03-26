//
//  KHJAlarmConfHeadView.h
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KHJAlarmConfHeadViewDelegate <NSObject>

- (void)clickHeadWith:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KHJAlarmConfHeadView : UIView

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (nonatomic, strong) id<KHJAlarmConfHeadViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
