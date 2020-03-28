//
//  KHJDeviceListCell.h
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KHJDeviceListCellDelegate <NSObject>

- (void)gotoVideoWithIndex:(NSString *)index;
- (void)gotoSetupWithIndex:(NSString *)deviceID;

@end

@interface KHJDeviceListCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *bigIMGV;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *idd;

@property (nonatomic, copy) NSString *deviceID;

@property (nonatomic, weak) id<KHJDeviceListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
