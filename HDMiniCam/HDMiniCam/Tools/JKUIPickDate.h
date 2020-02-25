//
//  JKUIPickDate.h
//  OCTest
//
//  Created by hezezewen on 2018/2/25.
//  Copyright        rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PassValue)(NSString *str);
typedef void(^CancelValue)(void);

@interface JKUIPickDate : UIView

@property (nonatomic, copy) CancelValue cancelBlock;

+ (instancetype)setDate;

- (void)passvalue:(PassValue)block;

@end
