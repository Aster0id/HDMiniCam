//
//  KHJNetWorkingManager.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHJNetWorkingManager : NSObject

typedef void(^codeBlock)(NSDictionary *dic,NSInteger code);

+ (KHJNetWorkingManager *)sharedManager;

@end































