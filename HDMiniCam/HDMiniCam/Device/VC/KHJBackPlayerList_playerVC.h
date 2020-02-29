//
//  KHJBackPlayerList_playerVC.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/28.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayerBaseVC.h"
#import "H26xHwDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJBackPlayerList_playerVC : KHJBaseVC

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, strong) NSDictionary *body;

@end

NS_ASSUME_NONNULL_END
