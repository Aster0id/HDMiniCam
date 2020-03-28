//
//  TTAlarmConfigHeadView.h
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTAlarmConfigHeadViewDelegate <NSObject>

- (void)clickHeadWith:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TTAlarmConfigHeadView : UIView

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (nonatomic, strong) id<TTAlarmConfigHeadViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
