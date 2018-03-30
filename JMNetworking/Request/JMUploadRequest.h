//
//  JMUploadRequest.h
//  JMNetworking
//
//  Created by Joey on 2018/3/12.
//  Copyright © 2018年 joey. All rights reserved.
//

/**
 上传的基类
 */


#import "JMBaseRequest.h"

/**
 *  上传请求 默认无缓存 默认请求方式POST, 也可为PUT
 */
@interface JMUploadRequest : JMBaseRequest

/**
 *  POST传送文件(默认)
 */
@property (nonatomic, readonly, nullable) AFConstructingBlock constructingBodyBlock;

/**
 *  POST传送文件Data(需自定义Request)
 */
@property (nonatomic, readonly, nullable) NSData * fileData;

/**
 *  POST传送文件URL(需自定义Request)
 */
@property (nonatomic, readonly, nullable) NSURL * fileURL;

/**
 *  当需要上传时，获得上传进度的回调
 */
@property (nonatomic, readonly, nullable) AFProgressBlock uploadProgressBlock;

- (void)sendRequestWithSuccess:(nullable JMRequestSuccess)success
                        failur:(nullable JMRequestFailur)failur __attribute__((unavailable("use [-uploadWithConstructingBody:progress:success:failur:]")));

- (void)sendRequestWithCache:(nullable JMRequestCacheCompletion)cache
                     success:(nullable JMRequestSuccess)success
                      failur:(nullable JMRequestFailur)failur __attribute__((unavailable("use [-uploadWithConstructingBody:progress:success:failur:]")));

@end
