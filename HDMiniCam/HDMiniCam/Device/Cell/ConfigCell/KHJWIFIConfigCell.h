//
//  KHJWIFIConfigCell.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/19.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^KHJWIFIConfigCellBlock)(int);

@interface KHJWIFIConfigCell : KHJBaseCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic, copy) KHJWIFIConfigCellBlock block;

@end

NS_ASSUME_NONNULL_END
