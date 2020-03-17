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
        return KHJLocalizedString(@"设备连接成功", nil);
    }
    else if (code == -1) {
        return KHJLocalizedString(@"设备未初始化", nil);
    }
    else if (code == -2) {
        return KHJLocalizedString(@"设备已初始化", nil);
    }
    else if (code == -3) {
        return KHJLocalizedString(@"操作超时", nil);
    }
    else if (code == -4) {
        return KHJLocalizedString(@"ID无效", nil);
    }
    else if (code == -5) {
        return KHJLocalizedString(@"参数无效", nil);
    }
    else if (code == -6) {
        return KHJLocalizedString(@"设备离线", nil);
    }
    else if (code == -7) {
        return KHJLocalizedString(@"无法解析名称", nil);
    }
    else if (code == -8) {
        return KHJLocalizedString(@"前缀无效", nil);
    }
    else if (code == -9) {
        return KHJLocalizedString(@"设备id过期", nil);
    }
    else if (code == -10) {
        return KHJLocalizedString(@"没有可用的中继服务器", nil);
    }
    else if (code == -11) {
        return KHJLocalizedString(@"无效的 session", nil);
    }
    else if (code == -12) {
        return KHJLocalizedString(@"session 关闭", nil);
        
    }
    else if (code == -13) {
        return KHJLocalizedString(@"session 关闭超时", nil);
        
    }
    else if (code == -14) {
        return KHJLocalizedString(@"session 已关闭", nil);
        
    }
    else if (code == -15) {
        return KHJLocalizedString(@"远程站点缓冲区已满", nil);
        
    }
    else if (code == -16) {
        return KHJLocalizedString(@"用户监听断裂", nil);
        
    }
    else if (code == -17) {
        return KHJLocalizedString(@"session 数量达到最大", nil);
        
    }
    else if (code == -18) {
        return KHJLocalizedString(@"UDP端口绑定失败", nil);
        
    }
    else if (code == -19) {
        return KHJLocalizedString(@"用户连接断裂", nil);
        
    }
    else if (code == -20) {
        return KHJLocalizedString(@"session 关闭的内存不足", nil);
        
    }
    else if (code == -21) {
        return KHJLocalizedString(@"内部致命错误", nil);
        
    }
    else if (code == -22) {
        return KHJLocalizedString(@"没有连接的对象", nil);
        
    }
    else if (code == -23) {
        return KHJLocalizedString(@"没有工作的对象", nil);
        
    }
    else if (code == -24) {
        return KHJLocalizedString(@"初始化失败", nil);
        
    }
    else if (code == -25) {
        return KHJLocalizedString(@"对象未准备好", nil);
        
    }
    else if (code == -26) {
        return KHJLocalizedString(@"密码错误", nil);
        
    }
    else if (code == -27) {
        return KHJLocalizedString(@"连接丢失", nil);
        
    }
    else if (code == -28) {
        return KHJLocalizedString(@"数据太长", nil);
        
    }
    else if (code == -29) {
        return KHJLocalizedString(@"未知错误", nil);
    }
    return KHJLocalizedString(@"未知错误", nil);
}

@end
