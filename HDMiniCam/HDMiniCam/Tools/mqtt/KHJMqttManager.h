//
//  KHJMqttManager.h
//  KHJCamera
//
//  Created by hezewen on 2019/2/26.
//  Copyright © 2019年 KHJ. All rights reserved.
//


/**
 1.退出登录需要断开mqtt
 2.进入后台会被动断开
 3.进入前台需要重新连接
 4.重新登录后需要重新连接mqtt
 5.权限修改，
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHJMqttManager : NSObject

@property(nonatomic,assign)BOOL isNeedUpdateClientType;

+ (KHJMqttManager *)sharedManager;
//连接mqtt并且订阅主题
- (void)connectMqttWithUserName:(NSString *)userName mqttPassword:(NSString *)password mqttClientID:(NSString *)clientID;
//向mqtt发送数据()
- (void)sendDataToMqttWithData:(NSString *)dataStr onTopic:(NSString *)topic qos:(int )qos retained:(BOOL)retained;
//关闭mqtt
- (void)closeMqtt;
//重连mqtt
- (void)reconnectMqtt;

@end

NS_ASSUME_NONNULL_END
