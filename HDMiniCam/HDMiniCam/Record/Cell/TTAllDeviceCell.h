//
//  TTAllDeviceCell.h
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTAllDeviceCellDelegate <NSObject>

- (void)chooseDeviceWithRow:(NSInteger)row;

@end

@interface TTAllDeviceCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UILabel *deviceID;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;


@property (weak, nonatomic) IBOutlet UILabel *dayTotal;

@property (nonatomic, assign) id<TTAllDeviceCellDelegate> delegate;

@property (strong, nonatomic) UILabel *ssssLab;

@property (strong, nonatomic) UILabel *ddfudrLab;
@property (strong, nonatomic) UILabel *nasaafdmeLab;

@end

NS_ASSUME_NONNULL_END
