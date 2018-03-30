//
//  JMNetworkConfig.h
//  JMNetworking
//
//  Created by Joey on 2018/2/15.
//  Copyright © 2018年 joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMNetworkConfig.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h

#else
@import AFNetworking;
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol JMNetworkConfigProtocol <NSObject>
@required

+ (nonnull id<JMNetworkConfigProtocol>)config;

/// 用户的userId，主要用来区分缓存的目录
- (nonnull NSString *)configUserId;

/// 请求的公共参数
- (nullable NSDictionary *)requestPublicParameters;

/// 校验请求结果
- (BOOL)requestVerifyResult:(nonnull id)result;

@optional
/// 请求的protocol 例如："http://"
- (nullable NSString *)requestURLProtocol;

/// 请求的Host 例如："www.douban.com:8080"
- (nullable NSString *)requestHost;

/// 请求的超时时间
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的安全选项
- (nullable AFSecurityPolicy *)requestSecurityPolicy;

/// Http请求的方法
- (JMRequestMethod)requestMethod;

/// 请求的SerializerType
- (JMRequestSerializerType)requestSerializerType;

/// 请求公参的位置
- (JMRequestPublicParametersType)requestPublicParametersType;

@end


///默认实现的config
@interface JMNetworkConfig : NSObject <JMNetworkConfigProtocol>

@property (nonatomic, copy, nonnull) NSString *userId;
@property (nonatomic, strong, nullable) NSDictionary *publicParameters;

+ (nonnull instancetype)config;

- (nonnull NSString *)configUserId;

- (nullable NSString *)requestURLProtocol;

- (nullable NSString *)requestHost;

- (NSTimeInterval)requestTimeoutInterval;

- (nullable AFSecurityPolicy *)requestSecurityPolicy;

- (JMRequestMethod)requestMethod;

- (JMRequestSerializerType)requestSerializerType;

- (nullable NSDictionary *)requestPublicParameters;

- (JMRequestPublicParametersType)requestPublicParametersType;

- (BOOL)requestVerifyResult:(nullable id)result;

@end

NS_ASSUME_NONNULL_END

