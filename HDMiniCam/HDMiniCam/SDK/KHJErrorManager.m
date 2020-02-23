//
//  KHJErrorManager.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/19.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJErrorManager.h"

@implementation KHJErrorManager

/// 错误代码
/// @param code 错误编码
+ (NSString *)getError_with_code:(int)code
{
    if (code == 0) {
        return @"设备连接成功";
    }
    else if (code == -1) {
        return @"设备未初始化";
    }
    else if (code == -2) {
        return @"设备已初始化";
    }
    else if (code == -3) {
        return @"操作超时";
    }
    else if (code == -4) {
        return @"ID无效";
    }
    else if (code == -5) {
        return @"参数无效";
    }
    else if (code == -6) {
        return @"设备离线";
    }
    else if (code == -7) {
        return @"无法解析名称";
    }
    else if (code == -8) {
        return @"前缀无效";
    }
    else if (code == -9) {
        return @"设备id过期";
    }
    else if (code == -10) {
        return @"没有可用的中继服务器";
    }
    else if (code == -11) {
        return @"无效的 session";
    }
    else if (code == -12) {
        return @"session 关闭";
    }
    else if (code == -13) {
        return @"session 关闭超时";
    }
    else if (code == -14) {
        return @"session 已关闭";
    }
    else if (code == -15) {
        return @"远程站点缓冲区已满";
    }
    else if (code == -16) {
        return @"用户监听断裂";
    }
    else if (code == -17) {
        return @"session 数量达到最大";
    }
    else if (code == -18) {
        return @"UDP端口绑定失败";
    }
    else if (code == -19) {
        return @"用户连接断裂";
    }
    else if (code == -20) {
        return @"session 关闭的内存不足";
    }
    else if (code == -21) {
        return @"内部致命错误";
    }
    else if (code == -22) {
        return @"没有连接的对象";
    }
    else if (code == -23) {
        return @"没有工作的对象";
    }
    else if (code == -24) {
        return @"初始化失败";
    }
    else if (code == -25) {
        return @"对象未准备好";
    }
    else if (code == -26) {
        return @"密码错误";
    }
    else if (code == -27) {
        return @"连接丢失";
    }
    else if (code == -28) {
        return @"数据太长";
    }
    else if (code == -29) {
        return @"未知错误";
    }
    return @"未知错误";
}

@end
