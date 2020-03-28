//
//  TTHighConfigCell.h
//  SuperIPC
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"



NS_ASSUME_NONNULL_BEGIN

@protocol TTHighConfigCellDelegate <NSObject>

- (void)clickWithCell:(NSInteger)row;

@end

@interface TTHighConfigCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *lab;
@property (nonatomic, strong) id<TTHighConfigCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
