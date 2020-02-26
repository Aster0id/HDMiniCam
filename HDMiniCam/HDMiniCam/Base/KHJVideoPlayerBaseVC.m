//
//  KHJVideoPlayerBaseVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayerBaseVC.h"
#import "H26xHwDecoder.h"
#import "KHJErrorManager.h"

H26xHwDecoder *h264Decode;

@interface KHJVideoPlayerBaseVC ()<H26xHwDecoderDelegate>

@end

@implementation KHJVideoPlayerBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    h264Decode = [[H26xHwDecoder alloc] init];
    h264Decode.delegate = self;
}

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize
{
    
}

- (UIButton *)leftBtn
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 66, 44);
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    [leftBtn setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = barBut;
    return leftBtn;
}

- (UILabel *)titleLab
{
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, SCREEN_WIDTH - 160, 44)];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLab;
    return titleLab;
}

- (UIButton *)rightBtn
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 66, 44);
    rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barBut;
    return rightBtn;
}

#pragma mark - 设备回调

/// 设备状态改变
/// @param uuid 设备id
/// @param status 设备状态
/// IPCNetStartIPCNetSession这个函数是连接函数，连接成功，状态会从onStatus返回
void onStatus(const char* uuid,int status)
{
    // 子线程回调
    if (status != 0) {
        NSLog(@" \n onStatus \n 设备id = %s， 当前在线 ！！！！！！！！！！！！！！",uuid);
    }
    else {
        NSString *statusCodeString = [KHJErrorManager getError_with_code:status];
        NSLog(@" \n onStatus \n 设备id = %s \n 状态错误 = %@",uuid,statusCodeString);
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:[[NSString alloc] initWithUTF8String:uuid] forKey:@"deviceID"];
    [body setValue:@(status) forKey:@"deviceStatus"];
    [[NSNotificationCenter defaultCenter] postNotificationName:noti_onStatus_KEY object:body];
}

/// 获取视频数据
/// @param uuid 设备id
/// @param type 类型
/// @param data 视频数据
/// @param len 数据长度
/// @param timestamp 时间戳
void onVideoData(const char* uuid,int type,unsigned char*data,int len,long timestamp)
{
    // 子线程回调
//    NSLog(@"onVideoData uuid:%s type:%d len:%d timestamp:%ld\n\n",uuid,type,len,timestamp);
    [h264Decode decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
}

/// 获取音频数据
/// @param uuid 设备id
/// @param type 类型
/// @param data 音频数据
/// @param len 数据长度
/// @param timestamp 时间戳
void onAudioData(const char* uuid,int type,unsigned char*data,int len,long timestamp)
{
    // 子线程回调
//    CLog(@"onAudioData = %@",[NSThread currentThread]);
//    NSLog(@" \n onAudioData 设备id = %s \n type = %d  \n length = %d  \n timestamp = %ld",uuid,type,len,timestamp);
}

/// 返回的json数据
/// @param uuid 设备id
/// @param msg_type 信息类型
/// @param jsonstr json数据
void onJSONString(const char* uuid,int msg_type,const char* jsonstr)
{
    // 子线程回调
//    NSLog(@" \n 设备id = %s \n messageCode = %d \n json数据 = %s",uuid,msg_type,jsonstr);
    if (msg_type == 4003) {
        // 设备连接
        NSDictionary *body = [NSDictionary dictionary];
        body = [KHJUtility cString_changto_ocStringWith:jsonstr];
        CLog(@"登录设备，连接设备 body = %@",body);
        
        if ([body.allKeys containsObject:@"Login.info"]) {
#pragma mark - 登录回调
//            NSString *Tick = body[@"Login.info"][@"Tick"];
//            CLog(@"Tick = %@", Tick);
        }
        else if ([body.allKeys containsObject:@"dev_info"]) {
#pragma mark - 设备信息回调
            NSString *deviceName    = body[@"dev_info"][@"name"];
            NSString *deviceID      = body[@"dev_info"][@"p2p_uuid"];
            CLog(@" deviceID = %@, deviceName = %@",deviceID, deviceName);
            NSMutableDictionary *body2 = [NSMutableDictionary dictionary];
            [body2 setValue:deviceID forKey:@"deviceID"];
            [body2 setValue:deviceName forKey:@"deviceName"];
            [[NSNotificationCenter defaultCenter] postNotificationName:noti_onJSONString_KEY object:body2];
            
        }
    }
    else {
        
    }
}

@end
