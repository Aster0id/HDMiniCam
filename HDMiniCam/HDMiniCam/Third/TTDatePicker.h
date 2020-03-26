//
//  TTDatePicker.h
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PassValue)(NSString *str);
typedef void(^CancelValue)(void);

@interface TTDatePicker : UIView

@property (nonatomic, copy) CancelValue cancelBlock;

+ (instancetype)setDate;

- (void)passvalue:(PassValue)block;

@end
