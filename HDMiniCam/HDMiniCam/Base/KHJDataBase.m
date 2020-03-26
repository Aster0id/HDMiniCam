//
//  KHJDataBase.m
//  SuperIPC
//
//  Created by kevin on 2020/2/18.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJDataBase.h"

static KHJDataBase *_db = nil;

@interface KHJDataBase ()<NSCopying, NSMutableCopying>
{
    FMDatabase *fmdb;
}

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation KHJDataBase

// 懒加载数据库队列
- (FMDatabaseQueue *)queue
{
    if (!_queue) {
        // 获得Documents目录路径
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 文件路径
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"HDMiniCam.sqlite"];
        TLog(@"创建数据库");
        _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    }
    return _queue;
}

+ (instancetype)sharedDataBase
{
    if (!_db) {
        _db = [[KHJDataBase alloc] init];
    }
    return _db;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (_db == nil) {
        _db = [super allocWithZone:zone];
    }
    return _db;
}

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

- (void)initDataBase
{
    NSString *deviceInfoSQLite = @"CREATE TABLE IF NOT EXISTS 'DeviceInfoListTable' ('deviceID' VARCHAR(255), 'deviceStatus' VARCHAR(255), 'devicePassword' VARCHAR(255),'deviceName' VARCHAR(255),'deviceType' VARCHAR(255),'reserve1' VARCHAR(255),'reserve2' VARCHAR(255),'reserve3' VARCHAR(255),'reserve4' VARCHAR(255),'reserve5' VARCHAR(255),'reserve6' VARCHAR(255),'reserve7' VARCHAR(255),'reserve8' VARCHAR(255),'reserve9' VARCHAR(255),'reserve10' VARCHAR(255),'reserve11' VARCHAR(255),'reserve12' VARCHAR(255),'reserve13' VARCHAR(255),'reserve14' VARCHAR(255),'reserve15' VARCHAR(255))";
    // 创建设备信息表
    [self createTableWithSQL:deviceInfoSQLite];
}

// 创建表
- (void)createTableWithSQL:(NSString *)sql
{
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"创建表格成功");
        }
        else {
            NSLog(@"创建表格失败");
        }
    }];
}

// 获取所有设备
- (NSMutableArray *)getAllDeviceInfo
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM DeviceInfoListTable"];
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            
            KHJDeviceInfo *deviceInfo = [[KHJDeviceInfo alloc] init];
            
            NSString *deviceID       = [resultSet stringForColumn:@"deviceID"];
            NSString *devicePassword = [resultSet stringForColumn:@"devicePassword"];
            NSString *deviceName     = [resultSet stringForColumn:@"deviceName"];
            NSString *deviceType     = [resultSet stringForColumn:@"deviceType"];
            NSString *deviceStatus   = [resultSet stringForColumn:@"deviceStatus"];
            NSString *reserve1  = [resultSet stringForColumn:@"reserve1"];
            NSString *reserve2  = [resultSet stringForColumn:@"reserve2"];
            NSString *reserve3  = [resultSet stringForColumn:@"reserve3"];
            NSString *reserve4  = [resultSet stringForColumn:@"reserve4"];
            NSString *reserve5  = [resultSet stringForColumn:@"reserve5"];
            NSString *reserve6  = [resultSet stringForColumn:@"reserve6"];
            NSString *reserve7  = [resultSet stringForColumn:@"reserve7"];
            NSString *reserve8  = [resultSet stringForColumn:@"reserve8"];
            NSString *reserve9  = [resultSet stringForColumn:@"reserve9"];
            NSString *reserve10 = [resultSet stringForColumn:@"reserve10"];
            NSString *reserve11 = [resultSet stringForColumn:@"reserve11"];
            NSString *reserve12 = [resultSet stringForColumn:@"reserve12"];
            NSString *reserve13 = [resultSet stringForColumn:@"reserve13"];
            NSString *reserve14 = [resultSet stringForColumn:@"reserve14"];
            NSString *reserve15 = [resultSet stringForColumn:@"reserve15"];
            
            deviceInfo.deviceID = deviceID;
            deviceInfo.deviceName = deviceName;
            deviceInfo.deviceType = deviceType;
            deviceInfo.deviceStatus = deviceStatus;
            deviceInfo.devicePassword = devicePassword;
            deviceInfo.reserve1 = reserve1;
            deviceInfo.reserve2 = reserve2;
            deviceInfo.reserve3 = reserve3;
            deviceInfo.reserve4 = reserve4;
            deviceInfo.reserve5 = reserve5;
            deviceInfo.reserve6 = reserve6;
            deviceInfo.reserve7 = reserve7;
            deviceInfo.reserve8 = reserve8;
            deviceInfo.reserve9 = reserve9;
            deviceInfo.reserve10 = reserve10;
            deviceInfo.reserve11 = reserve11;
            deviceInfo.reserve12 = reserve12;
            deviceInfo.reserve13 = reserve13;
            deviceInfo.reserve14 = reserve14;
            deviceInfo.reserve15 = reserve15;
            
            [dataArray addObject:deviceInfo];
        }
    }];
    return dataArray;
}

// 移除所有设备
- (void)removeAllDevice
{
    NSArray *arr = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    for (int i = 0; i < arr.count; i++) {
        KHJDeviceInfo *info = arr[i];
        [self deleteDeviceInfo_with_deviceInfo:info reBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            TLog(@"deviecID = %@，已删除",info.deviceID);
        }];
    }
}

// 添加设备
- (void)addDeviceInfo_with_deviceInfo:(KHJDeviceInfo *)deviceInfo reBlock:(void(^)(KHJDeviceInfo *info,int code))reBlock
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO DeviceInfoListTable (deviceID,deviceStatus, devicePassword,deviceName,deviceType,reserve1,reserve2,reserve3,reserve4,reserve5,reserve6,reserve7,reserve8,reserve9,reserve10,reserve11,reserve12,reserve13,reserve14,reserve15) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
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
        
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"插入数据成功");
            reBlock(deviceInfo, 1);
        }
        else {
            NSLog(@"插入数据失败");
            reBlock(deviceInfo, 0);
        }
    }];
}

// 删除设备
- (void)deleteDeviceInfo_with_deviceInfo:(KHJDeviceInfo *)deviceInfo reBlock:(void(^)(KHJDeviceInfo *info,int code))reBlock
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete FROM DeviceInfoListTable WHERE deviceID='%@'",deviceInfo.deviceID];
        BOOL result = [db executeUpdate:sql];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                NSLog(@"删除数据成功");
                reBlock(deviceInfo, 1);
            }
            else {
                NSLog(@"删除数据失败");
                reBlock(deviceInfo, 0);
            }
        });
    }];
}

// 更新设备
- (void)updateDeviceInfo_with_deviceInfo:(KHJDeviceInfo *)deviceInfo reBlock:(void(^)(KHJDeviceInfo *info,int code))reBlock
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE DeviceInfoListTable SET deviceID='%@',deviceStatus='%@',devicePassword='%@',deviceName='%@',deviceType='%@',reserve1='%@',reserve2='%@',reserve3='%@',reserve4='%@',reserve5='%@',reserve6='%@',reserve7='%@',reserve8='%@',reserve9='%@',reserve10='%@',reserve11='%@',reserve12='%@',reserve13='%@',reserve14='%@',reserve15='%@'",
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
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"更新数据成功，当前设备状态.............. \n deviceID = %@ \n deviceStatus = %@",deviceInfo.deviceID,deviceInfo.deviceStatus);
            reBlock(deviceInfo, 1);
        }
        else {
            NSLog(@"更新数据失败");
            reBlock(deviceInfo, 0);
        }
    }];
}

// 查找设备
- (void)selectDeviceInfo_with_deviceInfo:(NSString *)deviceID reBlock:(void(^)(KHJDeviceInfo *info,int code))reBlock
{
    KHJDeviceInfo *deviceInfo = [[KHJDeviceInfo alloc] init];
    __block int code = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM DeviceInfoListTable WHERE deviceID='%@'",deviceID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            
            NSString *deviceID          = [resultSet stringForColumn:@"deviceID"];
            NSString *devicePassword    = [resultSet stringForColumn:@"devicePassword"];
            NSString *deviceName        = [resultSet stringForColumn:@"deviceName"];
            NSString *deviceType        = [resultSet stringForColumn:@"deviceType"];
            NSString *deviceStatus      = [resultSet stringForColumn:@"deviceStatus"];
            NSString *reserve1  = [resultSet stringForColumn:@"reserve1"];
            NSString *reserve2  = [resultSet stringForColumn:@"reserve2"];
            NSString *reserve3  = [resultSet stringForColumn:@"reserve3"];
            NSString *reserve4  = [resultSet stringForColumn:@"reserve4"];
            NSString *reserve5  = [resultSet stringForColumn:@"reserve5"];
            NSString *reserve6  = [resultSet stringForColumn:@"reserve6"];
            NSString *reserve7  = [resultSet stringForColumn:@"reserve7"];
            NSString *reserve8  = [resultSet stringForColumn:@"reserve8"];
            NSString *reserve9  = [resultSet stringForColumn:@"reserve9"];
            NSString *reserve10 = [resultSet stringForColumn:@"reserve10"];
            NSString *reserve11 = [resultSet stringForColumn:@"reserve11"];
            NSString *reserve12 = [resultSet stringForColumn:@"reserve12"];
            NSString *reserve13 = [resultSet stringForColumn:@"reserve13"];
            NSString *reserve14 = [resultSet stringForColumn:@"reserve14"];
            NSString *reserve15 = [resultSet stringForColumn:@"reserve15"];
            
            deviceInfo.deviceID = deviceID;
            deviceInfo.deviceName = deviceName;
            deviceInfo.deviceType = deviceType;
            deviceInfo.deviceStatus = deviceStatus;
            deviceInfo.devicePassword = devicePassword;
            deviceInfo.reserve1 = reserve1;
            deviceInfo.reserve2 = reserve2;
            deviceInfo.reserve3 = reserve3;
            deviceInfo.reserve4 = reserve4;
            deviceInfo.reserve5 = reserve5;
            deviceInfo.reserve6 = reserve6;
            deviceInfo.reserve7 = reserve7;
            deviceInfo.reserve8 = reserve8;
            deviceInfo.reserve9 = reserve9;
            deviceInfo.reserve10 = reserve10;
            deviceInfo.reserve11 = reserve11;
            deviceInfo.reserve12 = reserve12;
            deviceInfo.reserve13 = reserve13;
            deviceInfo.reserve14 = reserve14;
            deviceInfo.reserve15 = reserve15;
            
            code = 1;
        }
    }];
    reBlock(deviceInfo, code);
}

@end
