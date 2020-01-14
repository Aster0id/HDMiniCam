//
//  KHJMqttManager.m
//  KHJCamera
//
//  Created by hezewen on 2019/2/26.
//  Copyright © 2019年 KHJ. All rights reserved.
//

#import "KHJMqttManager.h"
#import <MQTTClient/MQTTClient.h>
#import <MQTTSessionManager.h>
@interface KHJMqttManager()<MQTTSessionManagerDelegate,MQTTSessionDelegate>


@property(nonatomic,copy)NSString *username;//账号
@property(nonatomic,copy)NSString *password;//
@property(nonatomic,copy)NSString *cliendId;//设备账号ID
@property(nonatomic,strong)MQTTSessionManager *sessionManager;//
@property(nonatomic,strong)MQTTSession *mySession;//

@end

@implementation KHJMqttManager


+ (KHJMqttManager *)sharedManager
{
    static KHJMqttManager *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return instanceManager ;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [KHJMqttManager sharedManager] ;
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [KHJMqttManager sharedManager] ;
}
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)connectMqttWithUserName:(NSString *)userName mqttPassword:(NSString *)password mqttClientID:(NSString *)clientID
{
    self.username = @"ios";
    self.password = @"khj-ios";

    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
//    transport.host = @"mqtt.khjdevice.com";//MQTT服务器的地址,自己电脑的IP地址
    transport.host = @"acermq.khjdevice.com";//MQTT服务器的地址,自己电脑的IP地址

    transport.port = 1883;//设置MQTT服务器的端口
    if (!self.mySession) {
        self.mySession = [[MQTTSession alloc] init];//初始化MQTTSession对象
        self.mySession.transport = transport;       //给mySession对象设置基本信息
        self.mySession.delegate = self;             //设置mySession的代理
    }
    self.mySession.userName = self.username;
    self.mySession.password = self.password;
    self.mySession.clientId = clientID;
    self.mySession.keepAliveInterval = 360;
    self.mySession.cleanSessionFlag = true;
    self.mySession.willQoS = MQTTQosLevelAtMostOnce;
    [self.mySession addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    BOOL ret = [self.mySession connectAndWaitTimeout:30];//开始连接服务器，返回值为YES则说明连接成功
    if (ret) {
        
        NSLog(@"MQTT 连接成功！");
        // 订阅主题, qosLevel是一个枚举值,指的是消息的发布质量
        // 注意:订阅主题不能放到子线程进行,否则block不会回调
        NSString *topic = [NSString stringWithFormat:@"app/%@/share",self.mySession.clientId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mySession subscribeToTopic:topic atLevel:MQTTQosLevelAtLeastOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                if (error) {
                    NSLog(@"分享消息 订阅失败 = %@", error.localizedDescription);
                }
                else {
                    NSLog(@"分享消息 订阅成功 = %@", gQoss);
                    [self.mySession subscribeToTopic:@"app/adv" atLevel:MQTTQosLevelAtLeastOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                        if (error) {
                            NSLog(@"广告页 消息 订阅失败 = %@", error.localizedDescription);
                        }
                        else {
                            NSLog(@"广告页 消息 订阅成功 = %@", gQoss);
                        }
                    }];
                }
            }];
            
        });
    }
    else {
        NSLog(@"MQTT 连接失败！");
    }
}
//
////接收消息
- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    if ([topic containsString:@"share"]) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"接收到 - 分享 - 订阅消息 = %@",str);
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:KDidReceiveRemoteNotificationFrom_Apns_Key object:dict];
    }
    else if ([topic containsString:@"adv"]) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"接收到 - 广告 - 订阅消息 = %@",str);
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:KDidReceiveRemoteNotificationFrom_Adv_Key object:dict];
    }
    else {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"接收到 - 其他 - 订阅消息 = %@",str);
    }
}

- (void)sendDataToMqttWithData:(NSString *)dataStr onTopic:(NSString *)topic qos:(int)qos retained:(BOOL)retained
{
    
    CLog(@"topic = %@",topic);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      
        while (1) {
            if (self.mySession.status == MQTTSessionStatusConnected) {
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                UInt16 msgId = [self.mySession publishData:data onTopic:topic retain:retained qos:qos];
                NSLog(@"msgId = %d",msgId);
                break;
            }
            [NSThread sleepForTimeInterval:1.0];
        }
    });
}
- (void)reconnectMqtt
{
//    if (![SaveManager.isLogined boolValue]) {
//        return;
//    }
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self connectMqttWithUserName:@"" mqttPassword:@"" mqttClientID:SaveManager.usereAccount];
//    });
}

- (void)closeMqtt
{
    if (self.mySession) {
        
//        [self.mySession removeObserver:self forKeyPath:@"status"];
        [self.mySession disconnect];
    }
}
// 监听当前连接状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    switch (self.mySession.status) {
        case MQTTSessionStatusClosed:
            NSLog(@"连接已经关闭");
            break;
        case MQTTSessionStatusDisconnecting:
            NSLog(@"连接正在关闭");
            break;
        case MQTTSessionStatusConnected:
        {
            NSLog(@"已经连接");
        }
            break;
        case MQTTSessionStatusConnecting:
            
            NSLog(@"正在连接中");
            break;
        case MQTTSessionStatusError:
        {
            NSString *errorCode = self.sessionManager.lastErrorCode.localizedDescription;
            NSLog(@"连接异常 ----- %@",errorCode);
        }
            break;
        case MQTTSessionStatusCreated:
            NSLog(@"开始连接");
            break;
        default:
            break;
    }
}


@end
