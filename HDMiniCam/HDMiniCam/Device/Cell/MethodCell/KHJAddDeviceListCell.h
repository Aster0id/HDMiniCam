//
//  KHJAddDeviceListCell.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/18.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

typedef void(^KHJAddDeviceListCellBlock)(NSInteger);

NS_ASSUME_NONNULL_BEGIN

@interface KHJAddDeviceListCell : KHJBaseCell

@property (nonatomic, strong) KHJAddDeviceListCellBlock block;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLab;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDLab;

@end

NS_ASSUME_NONNULL_END
