//
//  JMNetworkDefine.h
//  JMNetworking
//
//  Created by Joey on 2018/2/15.
//  Copyright © 2018年 joey. All rights reserved.
//

#ifndef JMNetworkDefine_h
#define JMNetworkDefine_h

// is ios system version >= ?
#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#endif

FOUNDATION_EXPORT void JMLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

typedef NS_ENUM(NSInteger , JMRequestMethod) {
    JMRequestMethodGet = 0,
    JMRequestMethodPost,
    JMRequestMethodHead,
    JMRequestMethodPut,
    JMRequestMethodDelete,
    JMRequestMethodPatch,
};

typedef NS_ENUM(NSInteger , JMRequestSerializerType) {
    JMRequestSerializerTypeHTTP = 0,
    JMRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger , JMRequestPublicParametersType) {
    /// 公参放在Body (Default)
    JMRequestPublicParametersTypeBody = 0,
    
    /// 公参拼接在Url后面
    JMRequestPublicParametersTypeUrl,
    
    /// 公参放在Header
    JMRequestPublicParametersTypeHeader,
    
    /// 不需要公参
    JMRequestPublicParametersTypeNone,
};

///设置请求的优先级，仅iOS8及以后有效
typedef NS_ENUM(NSInteger , JMRequestPriority) {
    JMRequestPriorityDefault = 0,
    JMRequestPriorityLow,
    JMRequestPriorityHigh,
};

typedef NS_ENUM(NSUInteger, JMRequestCacheOption) {
    /// 不缓存
    JMRequestCacheOptionNone = 0,
    
    /// 优先读取网络,成功会缓存,失败才会读取本地缓存,(一次网络成功回调)或者(一次网络失败回调和一次缓存读取回调)
    JMRequestCacheOptionRefreshPriority,
    
    /// 优先读取本地缓存,读取缓存结束访问网络,访问网络成功会缓存,有两次回调
    JMRequestCacheOptionCachePriority,
    
    /// 优先读取本地缓存,没有本地缓存时才访问网络,访问网络成功会缓存,(一次缓存读取成功回调)或者(一次缓存读取失败回调和一次网络回调)
    JMRequestCacheOptionCacheSaveFlow,
    
    /// 只读取本地,离线模式
    JMRequestCacheOptionCacheOnly,
};


#endif /* JMNetworkDefine_h */
