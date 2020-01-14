//
//  KHJShakeObj.h
//  KHJCamera
//
//  Created by hezewen on 2018/7/18.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface KHJShakeObj : NSObject

/* 震动 + 声音 */
- (void)sharkAndPlaySound;
- (void)stopSharkAndPlaySound;
/* 震动 */
- (void)onlyShark;
- (void)stopOnlyShark;

@end
