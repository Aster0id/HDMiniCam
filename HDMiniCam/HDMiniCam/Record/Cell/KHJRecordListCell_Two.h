//
//  KHJRecordListCell_Two.h
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJRecordListCell_TwoDelegate <NSObject>

- (void)chooseDateWith:(NSInteger)row;

@end

@interface KHJRecordListCell_Two : KHJBaseCell

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *date;
@property (weak, nonatomic) IBOutlet UIImageView *picImgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (nonatomic, strong) id<KHJRecordListCell_TwoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
