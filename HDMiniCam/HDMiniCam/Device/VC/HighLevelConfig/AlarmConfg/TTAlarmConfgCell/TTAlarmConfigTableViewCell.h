//
//  TTAlarmConfigTableViewCell.h
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

@protocol TTAlarmConfigTableViewCellDelegate <NSObject>

- (void)clickWith:(NSInteger)row;

@end
NS_ASSUME_NONNULL_BEGIN

@interface TTAlarmConfigTableViewCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *subNameLab;
@property (nonatomic, strong) id<TTAlarmConfigTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
