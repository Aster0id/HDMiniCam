//
//  KHJRecordListCell.h
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJRecordListCellDelegate <NSObject>

- (void)contentWith:(NSInteger)row;

@end

@interface KHJRecordListCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UILabel *idLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (nonatomic, assign) id<KHJRecordListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
