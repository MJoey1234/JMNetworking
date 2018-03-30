//
//  JMBaseRequest.h
//  JMNetworking
//
//  Created by Joey on 2018/2/5.
//  Copyright © 2018年 joey. All rights reserved.
//

/**
 请求的基类
 需继承此类实现自定义Request
 */


#import <Foundation/Foundation.h>
#import "JMNetworkDefine.h"
#import "JMNetworkConfig.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
@import AFNetworking;
#endif

NS_ASSUME_NONNULL_BEGIN

@class JMBaseRequest;

typedef NSURL * _Nullable (^AFDownloadDestinationBlock)(NSURL *targetPath, NSURLResponse *response);
typedef void (^AFConstructingBlock)(__kindof id<AFMultipartFormData> formData);
typedef void (^AFProgressBlock)(__kindof NSProgress *progress);
typedef void (^JMRequestSuccess)(__kindof JMBaseRequest *baseRequest, id _Nullable responseObject);
typedef void (^JMRequestFailur)(__kindof JMBaseRequest *baseRequest, NSError *error);
typedef void (^JMRequestCacheCompletion)(__kindof JMBaseRequest *baseRequest, __kindof id _Nullable cacheResult, NSError *error);

/**
 *  基本请求
 */
@interface JMBaseRequest : NSObject
@property (nonatomic, strong, nullable) id responseObject; ///< 请求返回的数据
@property (nonatomic, strong, nullable) id cacheResponseObject; ///< 缓存返回的数据
@property (nonatomic,   copy, nullable) JMRequestSuccess successBlock; ///< 请求成功的回调
@property (nonatomic,   copy, nullable) JMRequestFailur failurBlock; ///< 请求失败的回调
@property (nonatomic,   copy, nullable) JMRequestCacheCompletion cacheCompletionBlcok; ///< 请求获取到cache的回调
@property (nonatomic, strong) NSURLSessionTask *requestTask; ///< 请求的Task
@property (nonatomic, assign) JMRequestPriority requestPriority;///< 请求优先级
@property (nonatomic, assign) JMRequestCacheOption cacheOption; ///< 请求的缓存选项

#pragma mark - Build JMRequest

/**
 *  请求的protocol
 *  例如："http://"
 *  @reJMrn NSString
 */
- (nullable NSString *)requesJMRLProtocol;

/**
 *  请求的Host
 *
 *  @reJMrn NSString
 */
- (nullable NSString *)requestHost;

/**
 *  请求的URL
 *
 *  @reJMrn NSString
 */
- (nullable NSString *)requesJMrl;

/**
 *  请求的连接超时时间，默认为60秒
 *
 *  @reJMrn NSTimeInterval
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  请求的参数列表
 *  POST时放在body中
 *
 *  @reJMrn NSDictionary
 */
- (nullable NSDictionary<NSString *, id> *)requestParameters;

/**
 *  请求的方法(GET,POST...)
 *
 *  @reJMrn JMRequestMethod
 */
- (JMRequestMethod)requestMethod;

/**
 *  请求的SerializerType
 *
 *  @reJMrn JMRequestSerializerType
 */
- (JMRequestSerializerType)requestSerializerType;

/**
 *  请求公参的位置
 *
 *  @reJMrn JMRequestPublicParametersType
 */
- (JMRequestPublicParametersType)requestPublicParametersType;

/**
 *  证书配置
 *
 *  @reJMrn AFSecurityPolicy
 */
- (nullable AFSecurityPolicy *)requestSecurityPolicy;

/**
 *  在HTTP报头添加的自定义参数
 *
 *  @reJMrn NSDictionary
 */
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

#pragma mark - Request Handle
/**
 *  请求的回调
 */
- (void)requestHandleResult;

/**
 *  请求缓存的回调
 *
 *  @param cacheResult 缓存的数据
 *  @param error Error
 */
- (void)requestHandleResultFromCache:(nullable id)cacheResult error:(nullable NSError *)error;

/**
 *  请求结果校验
 *
 *  @reJMrn BOOL
 */
- (BOOL)requestVerifyResult;

/**
 *  清理网络回调block
 */
- (void)clearCompletionBlock;

#pragma mark - Custom Request
/**
 *  自定义UrlRequest 忽略所有Build JMRequest方法
 *
 *  @reJMrn NSURLRequest
 */
- (nullable NSURLRequest *)buildCustomUrlRequest;

#pragma mark - Cache

/**
 *  缓存过期时间（默认-1 永远不过期）
 *
 *  @reJMrn NSTimeInterval
 */
- (NSTimeInterval)cacheExpireTimeInterval;

/**
 *  清理缓存回调block
 */
- (void)clearCacheCompletionBlock;

/**
 *  缓存需要忽略的参数
 *
 *  @reJMrn NSArray
 */
- (nullable NSArray<__kindof NSString *> *)cacheFileNameIgnoreKeysForParameters;

#pragma mark - config

/**
 *  网络配置
 *
 *  @reJMrn JMNetworkConfig
 */
- (nonnull id<JMNetworkConfigProtocol>)requestConfig;

@end

NS_ASSUME_NONNULL_END
