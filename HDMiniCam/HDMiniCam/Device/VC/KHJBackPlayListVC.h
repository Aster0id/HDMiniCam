//
//  KHJBackPlayListVC.h
//  SuperIPC
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJBackPlayListVCSaveListDelegate <NSObject>

- (void)exitListData:(BOOL)isExit;

@end

@interface KHJBackPlayListVC : KHJBaseVC

@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) BOOL exitVideoList;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, strong) id<KHJBackPlayListVCSaveListDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
