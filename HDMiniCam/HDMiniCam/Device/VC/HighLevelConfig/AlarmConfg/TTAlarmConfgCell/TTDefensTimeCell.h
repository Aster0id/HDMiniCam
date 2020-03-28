//
//  TTDefensTimeCell.h
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

@protocol TTDefensTimeCellDelegate <NSObject>

- (void)closeWithSection:(NSInteger)section row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TTDefensTimeCell : TTBaseCell

@property (nonatomic, assign) NSInteger section;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (nonatomic, strong) id<TTDefensTimeCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
