//
//  TTHourMinSeconsPicker.h
//  HDMiniCam
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CDZConfirmBlock)(NSString *strings);

@interface TTHourMinSeconsPicker : UIView

@property (nonatomic, copy) CDZConfirmBlock confirmBlock;
@property (nonatomic, assign) NSInteger pickerType;

- (void)initSubViews:(NSString *)sTime;

@end
