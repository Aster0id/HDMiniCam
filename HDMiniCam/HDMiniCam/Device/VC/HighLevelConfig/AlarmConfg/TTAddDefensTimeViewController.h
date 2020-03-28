//
//  TTAddDefensTimeViewController.h
//  SuperIPC
//
//  Created by kevin on 2020/3/24.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseViewController.h"

@protocol TTAddDefensTimeViewControllerDelegate <NSObject>

- (void)addDefinesTime:(NSString *_Nullable)time;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TTAddDefensTimeViewController : TTBaseViewController

@property (nonatomic, strong) NSArray *timeArr;
@property (nonatomic, strong) id<TTAddDefensTimeViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
