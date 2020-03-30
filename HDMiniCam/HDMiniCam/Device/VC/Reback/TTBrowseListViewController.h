//
//  TTBrowseListViewController.h
//  SuperIPC
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTBrowseListViewControllerDelegate <NSObject>

- (void)exitListData:(BOOL)isExit;
@optional
- (void)kevinHadGetData:(BOOL)data;

@end

@interface TTBrowseListViewController : TTBaseViewController

@property (nonatomic, copy) NSString *getid;

#pragma mark - 设备id
@property (nonatomic, copy) NSString *did;

@property (nonatomic, assign) NSInteger howtodo;


#pragma mark - 查询日期
@property (nonatomic, copy) NSString *seekList_currentDate;



#pragma mark - 是否存在数据，避免多次请求
@property (nonatomic, assign) BOOL haveBackPlayData_now;


@property (nonatomic, strong) id<TTBrowseListViewControllerDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
