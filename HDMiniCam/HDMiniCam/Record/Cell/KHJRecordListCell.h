//
//  KHJRecordListCell.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJRecordListCellDelegate <NSObject>

- (void)deleteWith:(NSInteger)row;
- (void)contentWith:(NSInteger)row;

@end

@interface KHJRecordListCell : KHJBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *imgv;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *idLab;
@property (weak, nonatomic) IBOutlet UILabel *sizeLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraint;

@property (nonatomic, assign) BOOL show;

@property (nonatomic, assign) id<KHJRecordListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
