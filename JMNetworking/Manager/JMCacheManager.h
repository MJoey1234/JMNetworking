//
//  JMCacheManager.h
//  JMNetworking
//
//  Created by Joey on 2018/3/5.
//  Copyright © 2018年 joey. All rights reserved.
//
/**
 管理缓存的类
 注意：用户的缓存默认保存的目录是"Library/JMRequestCache/0/"下面
 这里的"0"是默认的用户userId，如果设置了userId，则根据userId确定缓存目录。
 
 例：
 设置了用户userId为"12345",
 则缓存的目录为: "Library/JMRequestCache/12345/"
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JMBaseRequest.h"
#import "JMDownloadRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMBaseRequest (JMCacheManager)

/**
 *  缓存路径 不推荐重写
 *
 *  @reJMrn NSString
 */
- (nonnull NSString *)cachePath;
@end


typedef void (^JMCacheReadCompletion)(NSError * _Nullable error, id _Nullable cacheResult);
typedef void (^JMCacheWriteCompletion)(NSError * _Nullable error, NSString * _Nullable cachePath);

@interface JMCacheManager : NSObject
/// 根据缓存路径取得缓存数据
+ (void)getCacheObjectWithCachePath:(nonnull NSString *)path completion:(nullable JMCacheReadCompletion)completion;

/// 根据缓存路径存储缓存数据
+ (void)saveCacheObject:(nonnull id)object withCachePath:(nonnull NSString *)path completion:(nullable JMCacheWriteCompletion)completion;

/// 取得某个请求的缓存
+ (void)getCacheForRequest:(nonnull JMBaseRequest *)request completion:(JMCacheReadCompletion)completion;

/// 缓存某个请求
+ (void)saveCacheForRequest:(nonnull JMBaseRequest *)request completion:(JMCacheWriteCompletion)completion;

/// 清除某个请求的缓存
+ (void)clearCacheForRequest:(nonnull JMBaseRequest *)request;

/// 清除所有缓存
+ (void)clearAllCacheWithCompletion:(nullable void(^)(void))completion;

/// 获取单个缓存文件的大小,返回多少B
+ (CGFloat)getCacheSizeWithRequest:(nonnull JMBaseRequest *)request;

/// 获取所有缓存文件的大小,返回多少B
+ (void)getCacheSizeOfAllWithCompletion:(nullable void(^)(CGFloat totalSize))completion;

/// 返回文件缓存的主目录
+ (nonnull NSString *)cacheBaseDirPath;

/// 返回下载文件缓存的主目录
+ (nonnull NSString *)cacheBaseDownloadDirPath;

+ (BOOL)checkDirPath:(nonnull NSString *)dirPath autoCreate:(BOOL)autoCreate;

@end

NS_ASSUME_NONNULL_END

