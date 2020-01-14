//
//  CreateTwoCode.h
//  KHJCamera
//
//  Created by hezewen on 2018/5/24.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateTwoCode : NSObject

+(UIImage *)createTCode:(NSString *)pString;
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size ;

//+

@end
