//
//  TTDataBase.m
//  SuperIPC
//
//  Created by kevin on 2020/2/18.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTDataBase.h"

static TTDataBase *_TDataBase = nil;

@interface TTDataBase ()
<
NSCopying,
NSMutableCopying
>

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation TTDataBase


+ (instancetype)shareDB
{
    if (!_TDataBase) {
        _TDataBase = [[TTDataBase alloc] init];
    }
    return _TDataBase;
}

#pragma mark - NSCopying && NSMutableCopying

- (id)copy
{
    return self;
}

- (id)mutableCopy
{
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

// 懒加载数据库队列
- (FMDatabaseQueue *)queue
{
    if (!_queue) {
        TLog(@"创建数据库");
        _queue = [FMDatabaseQueue databaseQueueWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HDMiniCam.sqlite"]];
    }
    return _queue;
}

- (void)initDataBase
{
    NSString *deviceInfoSQLite = @"CREATE TABLE IF NOT EXISTS 'DeviceInfoListTable' ('deviceID' VARCHAR(255), 'deviceStatus' VARCHAR(255), 'devicePassword' VARCHAR(255),'deviceName' VARCHAR(255),'deviceType' VARCHAR(255),'reserve1' VARCHAR(255),'reserve2' VARCHAR(255),'reserve3' VARCHAR(255),'reserve4' VARCHAR(255),'reserve5' VARCHAR(255),'reserve6' VARCHAR(255),'reserve7' VARCHAR(255),'reserve8' VARCHAR(255),'reserve9' VARCHAR(255),'reserve10' VARCHAR(255),'reserve11' VARCHAR(255),'reserve12' VARCHAR(255),'reserve13' VARCHAR(255),'reserve14' VARCHAR(255),'reserve15' VARCHAR(255))";
    [self createTableWithSQL:deviceInfoSQLite];
}

#pragma mark - 创建设备信息表

- (void)createTableWithSQL:(NSString *)sql
{
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            TLog(@"创建表格成功");
        }
        else {
            TLog(@"创建表格失败");
        }
    }];
}

#pragma mark - 获取所有设备

- (NSMutableArray *)getAllDeviceInfo
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM DeviceInfoListTable"];
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            
            TTDeviceInfo *deviceInfo = [[TTDeviceInfo alloc] init];
            deviceInfo.deviceID         = [resultSet stringForColumn:@"deviceID"];
            deviceInfo.deviceName       = [resultSet stringForColumn:@"deviceName"];
            deviceInfo.deviceType       = [resultSet stringForColumn:@"deviceType"];
            deviceInfo.deviceStatus     = [resultSet stringForColumn:@"deviceStatus"];
            deviceInfo.devicePassword   = [resultSet stringForColumn:@"devicePassword"];
            deviceInfo.reserve1         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve2         = [resultSet stringForColumn:@"reserve2"];
            deviceInfo.reserve3         = [resultSet stringForColumn:@"reserve3"];
            deviceInfo.reserve4         = [resultSet stringForColumn:@"reserve4"];
            deviceInfo.reserve5         = [resultSet stringForColumn:@"reserve5"];
            deviceInfo.reserve6         = [resultSet stringForColumn:@"reserve6"];
            deviceInfo.reserve7         = [resultSet stringForColumn:@"reserve7"];
            deviceInfo.reserve8         = [resultSet stringForColumn:@"reserve8"];
            deviceInfo.reserve9         = [resultSet stringForColumn:@"reserve9"];
            deviceInfo.reserve10        = [resultSet stringForColumn:@"reserve10"];
            deviceInfo.reserve11        = [resultSet stringForColumn:@"reserve11"];
            deviceInfo.reserve12        = [resultSet stringForColumn:@"reserve12"];
            deviceInfo.reserve13        = [resultSet stringForColumn:@"reserve13"];
            deviceInfo.reserve14        = [resultSet stringForColumn:@"reserve14"];
            deviceInfo.reserve15        = [resultSet stringForColumn:@"reserve15"];
            [dataArray addObject:deviceInfo];
        }
    }];
    return dataArray;
}

#pragma mark - 移除所有设备

- (void)removeAllDevice
{
    NSArray *arr = [[TTDataBase shareDB] getAllDeviceInfo];
    for (int i = 0; i < arr.count; i++) {
        TTDeviceInfo *info = arr[i];
        [self deleteDeviceInfo_with_deviceInfo:info reBlock:^(TTDeviceInfo * _Nonnull info, int code) {
            TLog(@"deviecID = %@，已删除",info.deviceID);
        }];
    }
}

#pragma mark - 添加设备

- (void)addDeviceInfo_with_deviceInfo:(TTDeviceInfo *)deviceInfo reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock
{
    NSString *sqlite = [NSString stringWithFormat:@"INSERT INTO DeviceInfoListTable (deviceID,deviceStatus, devicePassword,deviceName,deviceType,reserve1,reserve2,reserve3,reserve4,reserve5,reserve6,reserve7,reserve8,reserve9,reserve10,reserve11,reserve12,reserve13,reserve14,reserve15) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                     deviceInfo.deviceID,
                     deviceInfo.deviceStatus,
                     deviceInfo.devicePassword,
                     deviceInfo.deviceName,
                     deviceInfo.deviceType,
                     deviceInfo.reserve1,
                     deviceInfo.reserve2,
                     deviceInfo.reserve3,
                     deviceInfo.reserve4,
                     deviceInfo.reserve5,
                     deviceInfo.reserve6,
                     deviceInfo.reserve7,
                     deviceInfo.reserve8,
                     deviceInfo.reserve9,
                     deviceInfo.reserve10,
                     deviceInfo.reserve11,
                     deviceInfo.reserve12,
                     deviceInfo.reserve13,
                     deviceInfo.reserve14,
                     deviceInfo.reserve15];
    [self.queue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sqlite];
        if (result) {
            TLog(@"插入数据成功");
            reBlock(deviceInfo, 1);
        }
        else {
            TLog(@"插入数据失败");
            reBlock(deviceInfo, 0);
        }
    }];
}

#pragma mark - 删除设备

- (void)deleteDeviceInfo_with_deviceInfo:(TTDeviceInfo *)deviceInfo reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sqlite = [NSString stringWithFormat:@"delete FROM DeviceInfoListTable WHERE deviceID='%@'",deviceInfo.deviceID];
        BOOL result = [db executeUpdate:sqlite];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                TLog(@"删除数据成功");
                reBlock(deviceInfo, 1);
            }
            else {
                TLog(@"删除数据失败");
                reBlock(deviceInfo, 0);
            }
        });
    }];
}

- (void)deleteDeviceInfo_with_deviceID:(NSString *)deviceID reBlock:(void(^)(NSString *deviceID,int code))reBlock
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sqlite = [NSString stringWithFormat:@"delete FROM DeviceInfoListTable WHERE deviceID='%@'",deviceID];
        BOOL result = [db executeUpdate:sqlite];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                TLog(@"删除数据成功");
                reBlock(deviceID, 1);
            }
            else {
                TLog(@"删除数据失败");
                reBlock(deviceID, 0);
            }
        });
    }];
}

#pragma mark - 更新设备

- (void)updateDeviceInfo_with_deviceInfo:(TTDeviceInfo *)deviceInfo reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sqlite = [NSString stringWithFormat:@"UPDATE DeviceInfoListTable SET deviceID='%@',deviceStatus='%@',devicePassword='%@',deviceName='%@',deviceType='%@',reserve1='%@',reserve2='%@',reserve3='%@',reserve4='%@',reserve5='%@',reserve6='%@',reserve7='%@',reserve8='%@',reserve9='%@',reserve10='%@',reserve11='%@',reserve12='%@',reserve13='%@',reserve14='%@',reserve15='%@'",
                         deviceInfo.deviceID,
                         deviceInfo.deviceStatus,
                         deviceInfo.devicePassword,
                         deviceInfo.deviceName,
                         deviceInfo.deviceType,
                         deviceInfo.reserve1,
                         deviceInfo.reserve2,
                         deviceInfo.reserve3,
                         deviceInfo.reserve4,
                         deviceInfo.reserve5,
                         deviceInfo.reserve6,
                         deviceInfo.reserve7,
                         deviceInfo.reserve8,
                         deviceInfo.reserve9,
                         deviceInfo.reserve10,
                         deviceInfo.reserve11,
                         deviceInfo.reserve12,
                         deviceInfo.reserve13,
                         deviceInfo.reserve14,
                         deviceInfo.reserve15];
        BOOL result = [db executeUpdate:sqlite];
        if (result) {
            TLog(@"更新数据成功，当前设备状态.............. \n deviceID = %@ \n deviceStatus = %@",deviceInfo.deviceID,deviceInfo.deviceStatus);
            reBlock(deviceInfo, 1);
        }
        else {
            TLog(@"更新数据失败");
            reBlock(deviceInfo, 0);
        }
    }];
}

#pragma mark - 查找设备

- (void)selectDeviceInfo_with_deviceInfo:(NSString *)deviceID reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock
{
    TTDeviceInfo *deviceInfo = [[TTDeviceInfo alloc] init];
    __block int code = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sqlite = [NSString stringWithFormat:@"SELECT * FROM DeviceInfoListTable WHERE deviceID='%@'",deviceID];
        FMResultSet *resultSet = [db executeQuery:sqlite];
        while (resultSet.next) {
            deviceInfo.deviceID         = [resultSet stringForColumn:@"deviceID"];
            deviceInfo.deviceName       = [resultSet stringForColumn:@"deviceName"];
            deviceInfo.deviceType       = [resultSet stringForColumn:@"deviceType"];
            deviceInfo.deviceStatus     = [resultSet stringForColumn:@"deviceStatus"];
            deviceInfo.devicePassword   = [resultSet stringForColumn:@"devicePassword"];
            deviceInfo.reserve1         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve2         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve3         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve4         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve5         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve6         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve7         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve8         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve9         = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve10        = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve11        = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve12        = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve13        = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve14        = [resultSet stringForColumn:@"reserve1"];
            deviceInfo.reserve15        = [resultSet stringForColumn:@"reserve1"];
            code = 1;
        }
    }];
    reBlock(deviceInfo, code);
}

@end
