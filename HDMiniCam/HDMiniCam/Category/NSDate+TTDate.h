//
//  NSDate+TTDate.h
//  HDMiniCam
//
//  Created by khj888 on 2020/3/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (TTDate)

+ (NSTimeInterval)get_todayZeroInterverlWith:(NSTimeInterval) timeInterval;

@end

NS_ASSUME_NONNULL_END
