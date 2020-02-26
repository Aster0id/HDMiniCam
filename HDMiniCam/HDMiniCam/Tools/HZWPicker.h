//
//  HZWPicker.h
//  KHJCamera
//  时间控件
//  Created by hezewen on 2018/6/8.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CDZConfirmBlock)(NSString *strings);

@interface HZWPicker : UIView

@property (nonatomic, copy) CDZConfirmBlock confirmBlock;
@property (nonatomic, assign) NSInteger tKind;

- (void)initSubViews:(NSString *)sTime;
@end
