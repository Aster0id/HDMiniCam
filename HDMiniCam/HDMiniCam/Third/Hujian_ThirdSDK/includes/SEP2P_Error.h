#ifndef _SEP2P_ERROR___INC_H_
#define _SEP2P_ERROR___INC_H_

#define P2P_STATUS_SUCCESSFUL                        0   // 连接成功
#define P2P_STATUS_NOT_INITIALIZED                    -1  // 未初始化
#define P2P_STATUS_ALREADY_INITIALIZED                -2  // 已初始化
#define P2P_STATUS_TIME_OUT                            -3  // 超时
#define P2P_STATUS_INVALID_ID                        -4  // 无效的ID
#define P2P_STATUS_INVALID_PARAMETER                -5  // 无效的参数
#define P2P_STATUS_OBJECT_NOT_ONLINE                -6  // 对象不在线
#define P2P_STATUS_FAIL_TO_RESOLVE_NAME                -7  // 无法解析名称
#define P2P_STATUS_INVALID_PREFIX                    -8  // 前缀无效
#define P2P_STATUS_ID_OUT_OF_DATE                    -9  // ID过期
#define P2P_STATUS_NO_RELAY_SERVER_AVAILABLE        -10 // 没有可用的中继服务器
#define P2P_STATUS_INVALID_SESSION_HANDLE            -11 // 无效的 session
#define P2P_STATUS_SESSION_CLOSED_REMOTE            -12 // session 关闭
#define P2P_STATUS_SESSION_CLOSED_TIMEOUT            -13 // session 关闭超时
#define P2P_STATUS_SESSION_CLOSED_CALLED            -14 // session 已关闭
#define P2P_STATUS_REMOTE_SITE_BUFFER_FULL            -15 // 远程站点缓冲区已满
#define P2P_STATUS_USER_LISTEN_BREAK                -16 // 用户监听断裂
#define P2P_STATUS_MAX_SESSION                        -17 //
#define P2P_STATUS_UDP_PORT_BIND_FAILED                -18 // UDP端口绑定失败
#define P2P_STATUS_USER_CONNECT_BREAK                -19 // 用户连接断裂
#define P2P_STATUS_SESSION_CLOSED_INSUFFICIENT_MEMORY    -20 // session 关闭的内存不足
#define P2P_STATUS_INTERNAL_FATAL_ERROR                -21 // 内部致命错误
#define P2P_STATUS_NO_CONNECTED_OBJECT                -22 // 没有连接的对象
#define P2P_STATUS_NO_WORKING_OBJECT                -23 // 没有工作的对象
#define P2P_STATUS_MEM_ALLOC_FAILED                    -24 //
#define P2P_STATUS_OBJECT_NOT_READY                    -25 // 对象未准备好
#define P2P_STATUS_INVALID_PASSWD                    -26 // 无效密码
#define P2P_STATUS_CONNECTION_LOST                    -27 // 连接丢失
#define P2P_STATUS_DATA_TOO_LOOG                    -28 // 数据太长
#define P2P_STATUS_UNKOWN                            -29 // 未知错误

#endif //// #ifndef _SEP2P_ERROR___INC_H_
