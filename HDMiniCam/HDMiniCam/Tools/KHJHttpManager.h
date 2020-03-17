//
//  KHJHttpManager.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHJHttpManager : NSObject

typedef void(^codeBlock)(NSDictionary *dic,NSInteger code);

+ (KHJHttpManager *)sharedManager;

@end































