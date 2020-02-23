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
    NSString *khjFileName = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];//关联账户
    khjFileName = [docPath stringByAppendingPathComponent:khjFileName];
    
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:khjFileName   error:nil];
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];       //倒序输出，最新的在最前面
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

- (NSString *)getTakeCameraDocPath
{
    /* 总的拼接方式。  KHJFileName_看护家账号_设备uid_年月日 后面还会加上具体时分秒 这样的图片/录制就是唯一的了
         1. 看护家账号 用来区分哪个用户截图/录制
         2. uid 哪台设备上的截图/录制
         3. 年月日 根据年月日来筛选截图/录制
     */
    SaveManager.userID = @"15273015567";
    NSString *userID = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];
    NSString *deviceUID = SaveManager.userDeviceUID;
    NSString *picPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/Camera", userID,deviceUID]];
//    NSLog(@"%@",picPath) ;
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效
    // isDirectory 判断是否是一个目录
    BOOL existed = [fileManager fileExistsAtPath:picPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:picPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return picPath;
}

#pragma mark - 获取报警文件夹路径 NSFileManager

- (NSString *)getTakeAlarmDocPath
{
    NSString *khjwant = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];
    NSString *alarmPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/alarmJpg", khjwant]];   //
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:alarmPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:alarmPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return alarmPath;
}

#pragma mark - 获取视频文件夹路径 NSFileManager

- (NSString *)getTakeVideoDocPath
{
    NSString *khjwant = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];
    NSString *khjdeviceuid = SaveManager.userDeviceUID ;
    NSString *videoPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/Video", khjwant,khjdeviceuid]];   // 关联账户 account 文件夹
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:videoPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return videoPath;
}

#pragma mark - 获取音频文件夹路径 NSFileManager

- (NSString *)getAudioDocPath
{
    NSString *khjwant = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];
    NSString *khjdeviceuid = SaveManager.userDeviceUID ;
    NSString *audioPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/Video", khjwant,khjdeviceuid]];
    
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:audioPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
    }
    return audioPath;
}

/* 获取视频或图片的名称 */
- (NSString *)getVideoNameWithType:(NSString *)fileType
{
    // 获取年月日
    NSDictionary *dicDay = [self getTodayDate] ;
    NSString *khjtoday = [NSString stringWithFormat:@"%@%@%@",dicDay[@"year"],dicDay[@"month"],dicDay[@"day"]] ;
    
    NSString *khjwant = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];
    NSString *picOrVideoName  = [NSString stringWithFormat:@"%@-%@",khjtoday,khjwant] ;
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *allStr = [NSString stringWithFormat:@"%@-%@",picOrVideoName,timeStr] ;
    NSString *fileName = [NSString stringWithFormat:@"/%@.%@",allStr,fileType];
//    NSLog(@"fileName == %@",fileName) ;
    return fileName;
}

#pragma mark - 获取报警音频文件夹路径 NSFileManager

/**
 文件夹路径 + 文件名称 = 文件可写入
 caf音频格式的文件路径
 */
- (NSString *)getAlarmAudioDocPath_caf
{
    NSString *userID = KHJString(@"KHJFileName_%@",SaveManager.userID);
    NSString *deviceUID = SaveManager.userDeviceUID;
    NSString *audioPath = [docPath stringByAppendingPathComponent:userID];
    audioPath = [audioPath stringByAppendingPathComponent:deviceUID];
    audioPath = [audioPath stringByAppendingPathComponent:KHJString(@"AlarmAudio")];
    audioPath = [audioPath stringByAppendingPathComponent:KHJString(@"caf")];
    
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:audioPath isDirectory:&isDir];
    if (!(isDir == YES && isExist == YES)) {
        [fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return audioPath;
}

/**
 提示：文件夹路径 + 文件名称 = 文件可写入
 amr音频格式的文件路径
 */
- (NSString *)getAlarmAudioDocPath_AMR
{
    NSString *userId = KHJString(@"KHJFileName_%@",SaveManager.userID);
    NSString *deviceId = SaveManager.userDeviceUID;
    NSString *audioPath = [docPath stringByAppendingPathComponent:userId];
    audioPath = [audioPath stringByAppendingPathComponent:deviceId];
    audioPath = [audioPath stringByAppendingPathComponent:KHJString(@"AlarmAudio")];
    audioPath = [audioPath stringByAppendingPathComponent:KHJString(@"AMR")];
    
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:audioPath isDirectory:&isDir];
    if (!(isDir == YES && isExist == YES)) {
        [fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return audioPath;
}

/*
 获取 amr音频格式的文件路径 下所有音频文件
 */
- (NSArray *)getAll_AMR_Audio
{
    NSString *userId = KHJString(@"KHJFileName_%@",SaveManager.userID);//关联账户
    NSString *deviceId = SaveManager.userDeviceUID;
    NSString *audioPath = [docPath stringByAppendingPathComponent:userId];
    audioPath = [audioPath stringByAppendingPathComponent:deviceId];
    audioPath = [audioPath stringByAppendingPathComponent:KHJString(@"AlarmAudio")];
    audioPath = [audioPath stringByAppendingPathComponent:KHJString(@"AMR")];
    /* 获取目录下的所有文件 */
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:audioPath error:nil];
    return files;
}

/**
 ap模式下不同设备类型的固件升级的统一文件路径
 */
- (NSString *)getFirmwareUpgradeDocPathWith:(NSString *)deviceType
{
    // 设备类型
    NSString *firmwarePath = [docPath stringByAppendingPathComponent:KHJString(@"FirmwareUpgrade")];
    firmwarePath = [firmwarePath stringByAppendingPathComponent:KHJString(@"%@",deviceType)];
    
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:firmwarePath isDirectory:&isDir];
    if (!(isDir == YES && isExist == YES)) {
        [fileManager createDirectoryAtPath:firmwarePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return firmwarePath;
}

/**
 获取 设备类型下的所有固件文件
 */
- (NSArray *)getAll_FirmwareUpgradeFileWith:(NSString *)deviceType
{
    NSString *firmwarePath = [docPath stringByAppendingPathComponent:@"FirmwareUpgrade"];
    firmwarePath = [firmwarePath stringByAppendingPathComponent:deviceType];
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:firmwarePath error:nil];
    return files;
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

/**
 拼接文件名称
 
 获取SD卡下载视频或图片的名称

 @param fileType 文件类型
 @param dateString
 @param timeString
 @return 视频名称
 */
- (NSString *)getVideoNameWithType:(NSString *)fileType withDate:(NSString *)dateString andTime:(NSString *)timeString
{
    NSString *khjwant = [NSString stringWithFormat:@"KHJFileName_%@",SaveManager.userID];
    NSString *picOrVideoName  = [NSString stringWithFormat:@"%@-%@",dateString,khjwant] ;
    NSString *allStr = [NSString stringWithFormat:@"%@-%@%@",picOrVideoName,dateString,timeString] ;
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",allStr,fileType];
    return fileName;
}
// 转换路径（sd卡命名不同）
- (NSString *)changeName:(NSString *)fileName withType:(NSInteger) type
{
    if (type ==0) {
        fileName = [fileName stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
    }else{
        fileName = [fileName stringByReplacingOccurrencesOfString:@".jpg" withString:@""];

    }
    fileName = [fileName stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
    NSArray *dArr = [fileName componentsSeparatedByString:@"_"];
    NSString *dateStr = [NSString stringWithFormat:@"%@%@%@",dArr[0],dArr[1],dArr[2]];
    NSString *timeStr = [NSString stringWithFormat:@"%@%@%@",dArr[3],dArr[4],dArr[5]];
    if(type == 0){
        return [self getVideoNameWithType:@"mp4" withDate:dateStr andTime:timeStr];
    }else
    {
        return [self getVideoNameWithType:@"jpg" withDate:dateStr andTime:timeStr];
    }
}
// 取得一个目录下得所有图片文件名
-(NSArray *)getPictureArray{
    
    NSArray *files = [fileManager subpathsAtPath:[self getTakeCameraDocPath]];
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];       //倒序输出，最新的在最前面
    return reversedArray;
}
// 取得一个目录下得所有报警图片文件名
-(NSArray *)getAlarmPictureArray{
    
    NSArray *files = [fileManager subpathsAtPath:[self getTakeAlarmDocPath]];
    CLog(@"files = %@",files);
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];       //倒序输出，最新的在最前面
    return reversedArray;
}
// 取得一个目录下得所有mp4视频文件名
-(NSArray *)getmp4VideoArray{
    
    NSArray *files = [fileManager subpathsAtPath:[self getTakeVideoDocPath]];
    NSArray *reversedArray = [[files reverseObjectEnumerator] allObjects];       //倒序输出，最新的在最前面
    
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
//自动生成10位随机密码
- (NSString *)getRandomPassword
{
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < 10; i++) {
        int number = arc4random() % 62;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else if (number < 36){
            int figure = (arc4random() % 26) + 65;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    
    //     NSLog(@"getRandomStringWithNum:%@",string);
    return string;
}

//WIFIAPENC_INVALID            = 0x00,
//WIFIAPENC_NONE                = 0x01, //
//WIFIAPENC_WEP                = 0x02, //WEP, for no password
//WIFIAPENC_WPA_TKIP            = 0x03,
//WIFIAPENC_WPA_AES            = 0x04,
//WIFIAPENC_WPA2_TKIP            = 0x05,
//WIFIAPENC_WPA2_AES            = 0x06,
//
//WIFIAPENC_WPA_PSK_TKIP  = 0x07,
//WIFIAPENC_WPA_PSK_AES   = 0x08,
//WIFIAPENC_WPA2_PSK_TKIP = 0x09,
//WIFIAPENC_WPA2_PSK_AES  = 0x0A,

//wifi安全选项转换为nsstring
-(NSString *)switchEncptry:(int)enctype{
    NSString *enctypestr;
    
    if (enctype == 0) {
        enctypestr = @"WIFIAPENC_INVALID";
    }else if (enctype == 1){
        enctypestr = @"WIFIAPENC_NONE";
    }else if (enctype == 2){
        enctypestr = @"WIFIAPENC_WEP";
    }else if (enctype == 3){
        enctypestr = @"WIFIAPENC_WPA_TKIP";
    }else if (enctype == 4){
        enctypestr = @"WIFIAPENC_WPA_AES";
    }else if (enctype == 5){
        enctypestr = @"WIFIAPENC_WPA2_TKIP";
    }else if (enctype == 6){
        enctypestr = @"WIFIAPENC_WPA2_AES";
    }else if (enctype == 7){
        enctypestr = @"WIFIAPENC_WPA_PSK_TKIP";
    }else if (enctype == 8){
        enctypestr = @"WIFIAPENC_WPA_PSK_AES";
    }else if (enctype == 9){
        enctypestr = @"WIFIAPENC_WPA2_PSK_TKIP";
    }else if (enctype == 10){
        enctypestr = @"WIFIAPENC_WPA2_PSK_AES";
    }else{
        enctypestr = @"WIFIAPENC_WPA2_PSK_AES";
    }
    return enctypestr;
}

@end
