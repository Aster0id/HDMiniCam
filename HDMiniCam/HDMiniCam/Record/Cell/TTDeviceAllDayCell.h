//
//  TTDeviceAllDayCell.h
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTDeviceAllDayCellDelegate <NSObject>

- (void)chooseDateWith:(NSInteger)row;

@end

@interface TTDeviceAllDayCell : TTBaseCell

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *date;
@property (weak, nonatomic) IBOutlet UIImageView *picImgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (nonatomic, strong) id<TTDeviceAllDayCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
