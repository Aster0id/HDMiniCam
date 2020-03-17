//
//  KHJPicker.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CDZConfirmBlock)(NSString *strings);

@interface KHJPicker : UIView

@property (nonatomic, copy) CDZConfirmBlock confirmBlock;
@property (nonatomic, assign) NSInteger tKind;

- (void)initSubViews:(NSString *)sTime;
@end
