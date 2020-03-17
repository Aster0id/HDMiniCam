//
//  KHJPickerView.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dateChanged)(NSString *str);

@interface KHJPickerView : UIView

-(void)dateChanged:(dateChanged)block;
- (UIButton *)getShowButton;
- (void)changeRightBtnState:(BOOL)isH;

@end
