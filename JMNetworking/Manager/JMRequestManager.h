//
//  JMRequestManager.h
//  JMNetworking
//
//  Created by Joey on 2018/2/7.
//  Copyright © 2018年 joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseRequest.h"
#import "JMDownloadRequest.h"
#import "JMUploadRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMBaseRequest (JMRequestManager)

/**
 *  发送请求
 *
 *  @param success  成功的回调
 *  @param failur   失败的回调
 */
- (void)sendRequestWithSuccess:(nullable JMRequestSuccess)success
                        failur:(nullable JMRequestFailur)failur;

/**
 *  发送请求（缓存）
 *
 *  @param cache    缓存读取完的回调
 *  @param success  成功的回调
 *  @param failur   失败的回调
 */
- (void)sendRequestWithCache:(nullable JMRequestCacheCompletion)cache
                     success:(nullable JMRequestSuccess)success
                      failur:(nullable JMRequestFailur)failur;

/**
 *  取消请求
 */
- (void)cancelRequest;


@end

@interface JMDownloadRequest (JMRequestManager)

/**
 *  发送请求（缓存）
 *
 *  @param cache    缓存读取完的回调
 *  @param success  成功的回调
 *  @param failur   失败的回调
 */
- (void)downloadWithCache:(nullable JMRequestCacheCompletion)cache
                 progress:(nullable AFProgressBlock)downloadProgressBlock
                  success:(nullable JMRequestSuccess)success
                   failur:(nullable JMRequestFailur)failur;

@end

@interface JMRequestManager : NSObject

/**
 *  上传请求 POST
 *
 *  @param constructingBody 上传的数据
 *  @param uploadProgress   上传进度
 *  @param success          成功的回调
 *  @param failur           失败的回调
 */
- (void)uploadWithConstructingBody:(nullable AFConstructingBlock)constructingBody
                          progress:(nullable AFProgressBlock)uploadProgress
                           success:(nullable JMRequestSuccess)success
                            failur:(nullable JMRequestFailur)failur;
/**
 *  上传请求 POST (自定义request)
 *
 *  @param fileData         上传的数据
 *  @param uploadProgress   上传进度
 *  @param success          成功的回调
 *  @param failur           失败的回调
 */
- (void)uploadCustomRequestWithFileData:(nullable NSData *)fileData
                               progress:(nullable AFProgressBlock)uploadProgress
                                success:(nullable JMRequestSuccess)success
                                 failur:(nullable JMRequestFailur)failur;
/**
 *  上传请求 POST (自定义request)
 *
 *  @param fileURL          上传的文件URL
 *  @param uploadProgress   上传进度
 *  @param success          成功的回调
 *  @param failur           失败的回调
 */
- (void)uploadCustomRequestWithFileURL:(nullable NSURL *)fileURL
                              progress:(nullable AFProgressBlock)uploadProgress
                               success:(nullable JMRequestSuccess)success
                                failur:(nullable JMRequestFailur)failur;

@end

@interface JMRequestManager : NSObject

+ (nonnull instancetype)manager;

+ (nullable NSMutableDictionary *)buildRequestHeader:(JMBaseRequest *)request;

+ (nullable NSMutableDictionary *)buildRequestParameters:(JMBaseRequest *)request;

+ (nullable NSString *)buildRequesJMrl:(nonnull JMBaseRequest *)request;

- (void)sendRequest:(nonnull JMBaseRequest *)request;

- (void)cancelRequest:(nonnull JMBaseRequest *)request;

- (void)cancelAllRequests;


@end
