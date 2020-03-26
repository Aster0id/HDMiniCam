//
//  KHJDefensTimeCell.h
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

@protocol KHJDefensTimeCellDelegate <NSObject>

- (void)closeWithSection:(NSInteger)section row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KHJDefensTimeCell : TTBaseCell

@property (nonatomic, assign) NSInteger section;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (nonatomic, strong) id<KHJDefensTimeCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
