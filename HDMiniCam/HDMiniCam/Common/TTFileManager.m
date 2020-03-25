//
//  TTFileManager.m
//  HDMiniCam
//
//  Created by kevin on 2020/3/25.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "TTFileManager.h"

@interface TTFileManager()
{
    NSFileManager *fileManager ;
    NSString *docPath;
}

@end

@implementation TTFileManager

+ (TTFileManager *)sharedModel
{
    static TTFileManager *sharedInstance;
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[TTFileManager alloc] init];
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

#pragma mark - 获取当前用户文件夹下所有视频和图片文件

- (NSArray *)get_all_video_and_pic_File
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
            if ([st containsString:@".jpg"]) {
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

#pragma mark - 获取直播视频截图文件路径

- (NSString *)get_live_screenShot_DocPath_with_deviceID:(NSString *)deviceID
{
    NSString *picPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Camera/%@",deviceID]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:picPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:picPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return picPath;
}

#pragma mark - 视频每日最后一张截图保存的文件夹路径

- (NSString *)get_screenShot_DocPath_deviceID:(NSString *)deviceID
{
    NSString *screenShotPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Date_ScreenShot/%@",deviceID]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:screenShotPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:screenShotPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return screenShotPath;
}

#pragma mark - 视频每日录屏的截图保存的文件夹路径

- (NSString *)get_recordVideo_screenShot_DocPath_with_deviceID:(NSString *)deviceID
{
    NSString *screenShotPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Date_ScreenShot/%@/recordScreenShot",deviceID]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:screenShotPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:screenShotPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return screenShotPath;
}

#pragma mark - 获取视频或图片的名称

- (NSString *)get_videoName_With_fileType:(NSString *)fileType deviceID:(NSString *)deviceID
{
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
    return fileName;
}

#pragma  mark - 获取当天的日期：年/月/日

- (NSDictionary *)getTodayDate
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay;
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

#pragma mark - 获取 直播录屏 文件夹 路径 NSFileManager

- (NSArray *)get_live_record_VideoArray_with_deviceID:(NSString *)deviceID
{
    NSArray *files = [fileManager subpathsAtPath:[self get_live_recordVideo_DocPath_with_deviceID:deviceID]];
    NSMutableArray *file = [files mutableCopy];
    if ([deviceID isEqualToString:@""]) {
        [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = (NSString *)obj;
            if (![name containsString:@"mp4"]) {
                [file removeObject:obj];
            }
        }];
    }
    NSArray *reversedArray = [[file reverseObjectEnumerator] allObjects];
    return reversedArray;
}

#pragma mark - 获取 直播录屏 存放路径

- (NSString *)get_live_recordVideo_DocPath_with_deviceID:(NSString *)deviceID
{
    NSString *videoPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Video/%@",deviceID]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:videoPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoPath;
}

#pragma mark - 获取 回放录屏 文件夹 路径 NSFileManager

- (NSArray *)get_reback_record_videoArray_with_deviceID:(NSString *)deviceID
{
    NSArray *files = [fileManager subpathsAtPath:[self get_reback_recordVideo_DocPath_with_deviceID:deviceID]];
    NSMutableArray *file = [files mutableCopy];
    if ([deviceID isEqualToString:@""]) {
        [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = (NSString *)obj;
            if (![name containsString:@"mp4"]) {
                [file removeObject:obj];
            }
        }];
    }
    NSArray *reversedArray = [[file reverseObjectEnumerator] allObjects];
    return reversedArray;
}

#pragma mark - 获取 回放录屏 存放路径

- (NSString *)get_reback_recordVideo_DocPath_with_deviceID:(NSString *)deviceID
{
    NSString *videoPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"RebackPlayVideo/%@",deviceID]];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:videoPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoPath;
}

#pragma mark - 读取某个文件

- (NSData *)get_VideoData_with_path:(NSString *)path
{
    NSData *data = [fileManager contentsAtPath:path];
    return  data;
}

#pragma mark - 删除文件

- (BOOL)delete_videoFile_With_path:(NSString *)path
{
    BOOL is = [fileManager removeItemAtPath:path error:nil];
    return is;
}


@end
