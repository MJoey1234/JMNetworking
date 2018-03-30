//
//  JMDownloadRequest.h
//  JMNetworking
//
//  Created by Joey on 2018/3/12.
//  Copyright © 2018年 joey. All rights reserved.
//


/**
 下载的基类
 */

#import "JMBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  下载请求 支持断点续传
 */
@interface JMDownloadRequest : JMBaseRequest

- (void)sendRequestWithSuccess:(nullable JMRequestSuccess)success
                        failur:(nullable JMRequestFailur)failur __attribute__((unavailable("use [-downloadWithCache:progress:success:failur:]")));

- (void)sendRequestWithCache:(nullable JMRequestCacheCompletion)cache
                     success:(nullable JMRequestSuccess)success
                      failur:(nullable JMRequestFailur)failur __attribute__((unavailable("use [-downloadWithCache:progress:success:failur:]")));

/**
 *  继续下载
 */
- (void)resume;

/**
 *  暂停下载
 */
- (void)suspend;

@end
