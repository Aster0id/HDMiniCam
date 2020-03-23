//
//  KHJDefensTimeCell.h
//  HDMiniCam
//
//  Created by khj888 on 2020/3/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

@protocol KHJDefensTimeCellDelegate <NSObject>

- (void)closeWith:(NSInteger)row;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KHJDefensTimeCell : KHJBaseCell

@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (nonatomic, strong) id<KHJDefensTimeCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
