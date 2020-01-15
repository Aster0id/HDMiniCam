//
//  KHJPublicDefine.h
//  KHJCamera
//
//  Created by khj888 on 2018/12/4.
//  Copyright © 2018 khj. All rights reserved.
//

#ifndef KHJPublicDefine_h
#define KHJPublicDefine_h

#define FLAG_TAG                        9999999
#define KHJIMAGE(name)                  [UIImage imageNamed:name]
#define KHJString(...)                  [NSString stringWithFormat:__VA_ARGS__]
#define KHJLocalizedString(key,comment) [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]
/* 当前选择的 tabbar 下标 */
#define KHJNaviBarItemIndexKey  @"NaviBarItemIndexKey"


#endif /* KHJPublicDefine_h */
