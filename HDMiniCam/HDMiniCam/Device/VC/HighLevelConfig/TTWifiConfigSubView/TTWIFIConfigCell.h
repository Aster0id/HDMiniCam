//
//  TTWIFIConfigCell.h
//  SuperIPC
//
//  Created by 王涛 on 2020/1/19.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "TTBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTWIFIConfigCellDelegate <NSObject>

- (void)chooseWifiWith:(NSInteger)row;

@end

@interface TTWIFIConfigCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UILabel *first;
@property (weak, nonatomic) IBOutlet UILabel *second;
@property (weak, nonatomic) IBOutlet UILabel *third;
@property (nonatomic, strong) id<TTWIFIConfigCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
