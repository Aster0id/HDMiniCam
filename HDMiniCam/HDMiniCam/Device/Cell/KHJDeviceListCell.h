//
//  KHJDeviceListCell.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KHJDeviceListCellDelegate <NSObject>

- (void)gotoVideoWithIndex:(NSInteger)index;
- (void)gotoSetupWithIndex:(NSInteger)index;
- (void)reConnectWithIndex:(NSInteger)index;

@end

@interface KHJDeviceListCell : KHJBaseCell

@property (nonatomic, assign) BOOL connected;

@property (weak, nonatomic) IBOutlet UIImageView *bigIMGV;
@property (weak, nonatomic) IBOutlet UIImageView *smalIMGV;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *idd;
@property (nonatomic, weak) id<KHJDeviceListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
