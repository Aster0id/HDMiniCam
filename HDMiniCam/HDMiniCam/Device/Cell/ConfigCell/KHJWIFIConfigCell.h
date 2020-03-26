//
//  KHJWIFIConfigCell.h
//  SuperIPC
//
//  Created by 王涛 on 2020/1/19.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "TTBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^KHJWIFIConfigCellBlock)(NSInteger);

@interface KHJWIFIConfigCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *safeLab;
@property (weak, nonatomic) IBOutlet UILabel *stronglyLab;

@property (nonatomic, copy) KHJWIFIConfigCellBlock block;

@end

NS_ASSUME_NONNULL_END
