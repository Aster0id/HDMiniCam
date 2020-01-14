//
//  KHJsubMqttManager.h
//  KHJCamera
//
//  Created by khj888 on 2019/2/28.
//  Copyright © 2019 KHJ. All rights reserved.
//

#import "KHJMqttManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJsubMqttManager : KHJMqttManager <NSCopying>

@property (nonatomic, copy) NSString *test;

@end

NS_ASSUME_NONNULL_END
