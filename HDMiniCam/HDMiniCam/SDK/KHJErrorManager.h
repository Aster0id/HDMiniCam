//
//  KHJErrorManager.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/19.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHJErrorManager : NSObject

/// 错误代码
/// @param code 错误编码
+ (NSString *)getError_with_code:(int)code;

@end

NS_ASSUME_NONNULL_END
