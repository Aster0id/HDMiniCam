//
//  TTSingleBackPlayViewController.h
//  SuperIPC
//
//  Created by kevin on 2020/2/28.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTPlayerBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSingleBackPlayViewController : TTBaseViewController

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, strong) NSDictionary *body;

@end

NS_ASSUME_NONNULL_END
