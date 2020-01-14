//
//  KHJUdpHelper.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHJUdpHelper : UIView
+ (KHJUdpHelper*)getinstance;
- (void)openUDPServer;
- (void)closeUpdServer;
@end

NS_ASSUME_NONNULL_END
