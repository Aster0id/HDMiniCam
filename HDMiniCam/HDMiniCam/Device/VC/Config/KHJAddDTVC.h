//
//  KHJAddDTVC.h
//  SuperIPC
//
//  Created by kevin on 2020/3/24.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJBaseVC.h"

@protocol KHJAddDTVCDelegate <NSObject>

- (void)addDefinesTime:(NSString *_Nullable)time;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KHJAddDTVC : KHJBaseVC

@property (nonatomic, strong) NSArray *timeArr;
@property (nonatomic, strong) id<KHJAddDTVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
