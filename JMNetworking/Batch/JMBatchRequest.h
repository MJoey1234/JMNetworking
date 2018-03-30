//
//  JMBatchRequest.h
//  JMNetworking
//
//  Created by Joey on 2018/2/17.
//  Copyright © 2018年 joey. All rights reserved.
//

#import "JMBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, JMBatchRequestMode) {
    /** 普通模式 直至所有请求都结束才回调结果 */
    JMBatchRequestModeNormal   = 0,
    /** 严格模式 失败任何一个请求都立即回调结果，并终止请求 */
    JMBatchRequestModeStrict
};

/// 请求组结束的block error仅当严格模式下或者超时有值
typedef void(^JMBatchRequestCompletionBlock)(__kindof NSArray<__kindof JMBaseRequest *> *_Nullable requests, NSError *_Nullable error);

/// 请求组进度的block
typedef void(^JMBatchRequestProgressBlock)(NSInteger totals, NSInteger completions);

/// 单个请求完成的block
typedef void(^JMBatchRequestOneProgressBlock)(__kindof JMBaseRequest *_Nonnull request, NSError *_Nullable error);



@interface JMBatchRequest : NSObject
/**
 一次发起多个请求 所有请求完成后回调
 maxTime使用每个请求的默认超时之和
 注意：JMRequestCacheOptionCachePriority的两次回调，这里只支持网络部分的回调
 
 @param requests 请求数组
 @param mode 请求组处理模式
 @param progress 进度
 @param completion 完成
 @reJMrn JMBatchRequest
 */
+ (instancetype)sendRequests:(nonnull NSArray<__kindof JMBaseRequest *> *)requests
                 requestMode:(JMBatchRequestMode)mode
                    progress:(nullable JMBatchRequestProgressBlock)progress
                  completion:(nullable JMBatchRequestCompletionBlock)completion;

/**
 一次发起多个请求 所有请求完成后回调
 注意：JMRequestCacheOptionCachePriority的两次回调，这里只支持网络部分的回调
 
 @param requests 请求数组
 @param mode 请求组处理模式
 @param maxTime 总共最大时间限制 如果 maxTime = 0 则取每个请求的默认超时之和
 @param progress 总进度
 @param oneProgress 单个request完成的回调
 @param completion 完成
 */
- (void)sendRequests:(nonnull NSArray<__kindof JMBaseRequest *> *)requests
         requestMode:(JMBatchRequestMode)mode
             maxTime:(NSTimeInterval)maxTime
            progress:(nullable JMBatchRequestProgressBlock)progress
         oneProgress:(nullable JMBatchRequestOneProgressBlock)oneProgress
          completion:(nullable JMBatchRequestCompletionBlock)completion;

/**
 *  取消请求
 */
- (void)cancelRequest;

@end

NS_ASSUME_NONNULL_END



