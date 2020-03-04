//
//  KHJHelpCameraData.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJHelpCameraData.h"

@interface KHJHelpCameraData()
{
    NSFileManager *fileManager ;
    NSString *docPath;
}

@end

@implementation KHJHelpCameraData

+ (KHJHelpCameraData *)sharedModel
{
    static KHJHelpCameraData *sharedInstance;
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[KHJHelpCameraData alloc] init];
        }
        return sharedInstance;
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        fileManager = [NSFileManager defaultManager];
        docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return self;
}

/*
 获取当前用户文件夹下所有视频和图片文件
 */
- (NSArray *)getAllFile
{
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:docPath error:nil];
    //倒序输出，最新的在最前面
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];
    NSMutableArray *tFiles = [[NSMutableArray alloc] initWithCapacity:0];;
    for (id tObject in reversedArray) {
        if ([tObject isKindOfClass:[NSString class]]) {
            if (![(NSString *)tObject containsString:@"alarmJpg"]) {
                [tFiles addObject:tObject];
            }
        }
    }
    NSMutableArray *tempA = [NSMutableArray array];
    for (id st  in tFiles) {
        if ([st isKindOfClass:[NSString class]]){
            if ([st containsString:@".png"] || [st containsString:@".mp4"] ||[st containsString:@".jpg"]) {
                [tempA addObject:st];
            }
        }
    }
    reversedArray = tempA;
    return reversedArray;
}

- (BOOL)isDirectory:(NSString *)filePath
{
    BOOL isDirectory = NO;
    [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

#pragma mark - 获取图片文件夹路径 NSFileManager

- (NSString *)getTakeCameraDocPath_deviceID:(NSString *)deviceID
{
    NSString *picPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Camera/%@",deviceID]];
//    NSLog(@"%@",picPath);
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效
    // isDirectory 判断是否是一个目录
    BOOL existed = [fileManager fileExistsAtPath:picPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:picPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return picPath;
}

#pragma mark - 获取视频文件夹路径 NSFileManager

- (NSString *)getTakeVideoDocPath_with_deviceID:(NSString *)deviceID
{
    NSString *videoPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Video/%@",deviceID]];   // 关联账户 account 文件夹
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:videoPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return videoPath;
}

/* 获取视频或图片的名称 */
- (NSString *)getVideoNameWithType:(NSString *)fileType deviceID:(NSString *)deviceID
{
    // 获取年月日
    NSDictionary *dicDay = [self getTodayDate] ;
    NSString *khjtoday = [NSString stringWithFormat:@"%@%@%@",dicDay[@"year"],dicDay[@"month"],dicDay[@"day"]] ;
    NSString *picOrVideoName  = [NSString stringWithFormat:@"%@-%@",khjtoday,deviceID] ;
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *allStr = [NSString stringWithFormat:@"%@-%@",picOrVideoName,timeStr];
    NSString *fileName = [NSString stringWithFormat:@"/%@.%@",allStr,fileType];
//    NSLog(@"fileName == %@",fileName);
    return fileName;
}

#pragma  mark - 获取当天的日期：年/月/日

- (NSDictionary *)getTodayDate
{
    NSDate *today = [NSDate date];
    /* 日历类 */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    /* 日历构成的格式 */
    NSCalendarUnit unit = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay;
    /* 获取对应的时间点 */
    NSDateComponents *components = [calendar components:unit fromDate:today];
    
    NSString *year = [NSString stringWithFormat:@"%ld", (long)[components year]];
    NSString *month = [NSString stringWithFormat:@"%02ld", (long)[components month]];
    NSString *day = [NSString stringWithFormat:@"%02ld", (long)[components day]];
    
    NSMutableDictionary *todayDic = [[NSMutableDictionary alloc] init];
    [todayDic setObject:year forKey:@"year"];
    [todayDic setObject:month forKey:@"month"];
    [todayDic setObject:day forKey:@"day"];
    return todayDic;
}

// 取得一个目录下得所有图片文件名
- (NSArray *)getPictureArray_with_deviceID:(NSString *)deviceID
{
    NSArray *files = [fileManager subpathsAtPath:[self getTakeCameraDocPath_deviceID:@""]];
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];       //倒序输出，最新的在最前面
    return reversedArray;
}

// 取得一个目录下得所有mp4视频文件名
- (NSArray *)getmp4VideoArray_with_deviceID:(NSString *)deviceID
{
    NSArray *files = [fileManager subpathsAtPath:[self getTakeVideoDocPath_with_deviceID:deviceID]];
    NSMutableArray *file = [files mutableCopy];
    if ([deviceID isEqualToString:@""]) {
        [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = (NSString *)obj;
            if (![name containsString:@"mp4"]) {
                [file removeObject:obj];
            }
        }];
    }
    // 倒序输出，最新的在最前面
    NSArray *reversedArray = [[file reverseObjectEnumerator] allObjects];
    return reversedArray;
}

// 读取某个文件
-(NSData *)getVideoData:(NSString *)path
{
    
    NSData *data = [fileManager contentsAtPath:path];
    return  data;
}

//删除文件
- (BOOL)DeleateFileWithPath:(NSString *)path
{
    // 删除文件/文件夹
    BOOL is = [fileManager removeItemAtPath:path error:nil];
    return is;
}


@end
