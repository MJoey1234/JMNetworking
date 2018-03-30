//
//  JMRequestManager.m
//  JMNetworking
//
//  Created by Joey on 2018/2/7.
//  Copyright © 2018年 joey. All rights reserved.
//

#import "JMRequestManager.h"
#import "JMBaseRequest.h"
#import "JMDownloadRequest.h"
#import "JMUploadRequest.h"
#import "JMNetworkHelper.h"
#import "JMCacheManager.h"

@implementation JMBaseRequest (JMRequestManager)

- (void)sendRequestWithSuccess:(JMRequestSuccess)success
                        failur:(JMRequestFailur)failur {
    [self sendRequestWithCache:nil success:success failur:failur];
}

- (void)sendRequestWithCache:(JMRequestCacheCompletion)cache
                     success:(JMRequestSuccess)success
                      failur:(JMRequestFailur)failur {
    self.successBlock = success;
    self.failurBlock = failur;
    self.cacheCompletionBlcok = cache;
    self.responseObject = nil;
    self.cacheResponseObject = nil;
    [[JMRequestManager manager] sendRequest:self];
}

- (void)cancelRequest {
    [[JMRequestManager manager] cancelRequest:self];
}

- (NSString *)description {
    NSURLRequest *request = [[self requestTask] currentRequest];
    reJMrn [NSString stringWithFormat:@"<%@: %p, url: %@, parameters: %@, NSURLRequest:%@, allHTTPHeaderFields: %@, HTTPBody: %@>", NSStringFromClass([self class]), self, [JMRequestManager buildRequesJMrl:self], [JMRequestManager buildRequestParameters:self], request, [request allHTTPHeaderFields], [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]];
}

@end

@interface JMDownloadRequest ()

/**
 *  下载文件进度
 *
 *  @reJMrn AFProgressBlock
 */
@property (nonatomic, copy, nullable) AFProgressBlock downloadProgressBlock;

@end

@implementation JMRequestManager
- (void)downloadWithCache:(JMRequestCacheCompletion)cache
                 progress:(AFProgressBlock)downloadProgressBlock
                  success:(JMRequestSuccess)success
                   failur:(JMRequestFailur)failur {
    self.downloadProgressBlock = downloadProgressBlock;
    [super sendRequestWithCache:cache success:success failur:failur];
}

/**
 *  下载文件所在地址
 *
 *  @reJMrn AFDownloadDestinationBlock
 */
- (AFDownloadDestinationBlock)downloadDestinationBlock {
    AFDownloadDestinationBlock blcok = ^NSURL * _Nullable(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        reJMrn [NSURL fileURLWithPath:[self cachePath]];
    };
    reJMrn blcok;
}

- (void)cancelRequest {
    NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)self.requestTask ;
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        [self producingResumeData:resumeData];
    }];
}

- (void)producingResumeData:(NSData *)resumeData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [resumeData writeToFile:[self resumeDataPath] atomically:YES];
    });
}


/**
 *  断点下载时存储的文件信息
 */
- (nullable NSData *)resumeData {
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:[self resumeDataPath] options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        JMLog(@"Error get resume data error:%@", error.description);
        return nil;
    } else {
        return data;
    }
}

- (nonnull NSString *)resumeDataPath {
    NSString *resumeDataPath = [[self cachePath] stringByAppendingPathExtension:@"_temp"];
    return resumeDataPath;
}

@end

@interface JMUploadRequest ()
/**
 *  POST传送文件文件
 */
@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

/**
 *  POST传送文件Data(自定义Request)
 */
@property (nonatomic, strong, nullable) NSData *fileData;

/**
 *  POST传送文件Data(自定义Request)
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;

/**
 *  当需要上传时，获得上传进度的回调
 */
@property (nonatomic, copy, nullable) AFProgressBlock uploadProgressBlock;

@end

@implementation JMUploadRequest (JMRequestManager)

- (void)uploadWithConstructingBody:(AFConstructingBlock)constructingBody progress:(AFProgressBlock)uploadProgress success:(JMRequestSuccess)success failur:(JMRequestFailur)failur {
    self.constructingBodyBlock = constructingBody;
    self.uploadProgressBlock = uploadProgress;
    [super sendRequestWithSuccess:success failur:failur];
}

- (void)uploadCustomRequestWithFileData:(NSData *)fileData progress:(AFProgressBlock)uploadProgress success:(JMRequestSuccess)success failur:(JMRequestFailur)failur {
    self.fileData = fileData;
    self.uploadProgressBlock = uploadProgress;
    [super sendRequestWithSuccess:success failur:failur];
}

- (void)uploadCustomRequestWithFileURL:(NSURL *)fileURL progress:(AFProgressBlock)uploadProgress success:(JMRequestSuccess)success failur:(JMRequestFailur)failur {
    self.fileURL = fileURL;
    self.uploadProgressBlock = uploadProgress;
    [super sendRequestWithSuccess:success failur:failur];
}

@end

@implementation JMRequestManager {
    AFHTTPSessionManager *_sessionManager;
    NSMutableDictionary *_requestsRecord;
}

+ (JMRequestManager *)manager {
    static JMRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _sessionManager = [AFHTTPSessionManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        _sessionManager.operationQueue.maxConcurrentOperationCount = 4;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                     @"application/json",
                                                                     @"text/json",
                                                                     @"text/javascript",
                                                                     @"text/html",
                                                                     @"text/plain",
                                                                     nil];
    }
    return self;
}

- (void)sendRequest:(JMBaseRequest *)request {
    // check cache option
    JMRequestCacheOption cacheOption = [request cacheOption];
    
    if (cacheOption == JMRequestCacheOptionCacheOnly || cacheOption == JMRequestCacheOptionCachePriority || cacheOption == JMRequestCacheOptionCacheSaveFlow) {
        // get cache
        [JMCacheManager getCacheForRequest:request completion:^(NSError *error, id cacheResult) {
            [self handleCacheRequestResultCompletion:request error:error cacheResult:cacheResult];
        }];
        
        return;
    }
    
    [self sendRequestToNet:request];
}

- (void)sendRequestToNet:(JMBaseRequest *)request {
    JMRequestMethod method = [request requestMethod];
    NSString *url = [JMRequestManager buildRequesJMrl:request];
    NSDictionary *param = [JMRequestManager buildRequestParameters:request];
    
    if (request.requestSerializerType == JMRequestSerializerTypeHTTP) {
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == JMRequestSerializerTypeJSON) {
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    _sessionManager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    // security
    _sessionManager.securityPolicy = [request requestSecurityPolicy];
    
    // custom request
    NSURLRequest *customUrlRequest = [request buildCustomUrlRequest];
    if (customUrlRequest) {
        AFProgressBlock downloadProgressBlock = nil;
        if ([request isKindOfClass:[JMDownloadRequest class]]) {
            downloadProgressBlock = [(JMDownloadRequest *)request downloadProgressBlock];
        }
        
        AFProgressBlock uploadProgressBlock = nil;
        NSData *fileData = nil;
        NSURL *fileURL = nil;
        
        if ([request isKindOfClass:[JMUploadRequest class]]) {
            downloadProgressBlock = [(JMUploadRequest *)request uploadProgressBlock];
            fileData = [(JMUploadRequest *)request fileData];
            fileURL = [(JMUploadRequest *)request fileURL];
        }
        
        if (fileData != nil) {
            request.requestTask = [_sessionManager uploadTaskWithRequest:customUrlRequest fromData:fileData progress:uploadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (!error) {
                    [self handleRequestResultSuccess:request.requestTask responseObject:responseObject];
                } else {
                    [self handleRequestResultFailur:request.requestTask error:error];
                }
            }];
        } else if (fileURL != nil) {
            request.requestTask = [_sessionManager uploadTaskWithRequest:customUrlRequest fromFile:fileURL progress:uploadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (!error) {
                    [self handleRequestResultSuccess:request.requestTask responseObject:responseObject];
                } else {
                    [self handleRequestResultFailur:request.requestTask error:error];
                }
            }];
        } else {
            request.requestTask = [_sessionManager dataTaskWithRequest:customUrlRequest uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if (!error) {
                    [self handleRequestResultSuccess:request.requestTask responseObject:responseObject];
                } else {
                    [self handleRequestResultFailur:request.requestTask error:error];
                }
            }];
        }
        
        [request.requestTask resume];
    } else {
        // add custom value to HTTPHeaderField
        NSDictionary *headerFieldValueDictionary = [JMRequestManager buildRequestHeader:request];
        if (headerFieldValueDictionary != nil && [[headerFieldValueDictionary allKeys] count]) {
            for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
                id value = headerFieldValueDictionary[httpHeaderField];
                if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                    [_sessionManager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
                } else {
                    JMLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
                }
            }
        }
        
        if (method == JMRequestMethodGet) {
            AFProgressBlock downloadProgressBlock = nil;
            AFDownloadDestinationBlock downloadDestinationBlock = nil;
            if ([request isKindOfClass:[JMDownloadRequest class]]) {
                downloadProgressBlock = [(JMDownloadRequest *)request downloadProgressBlock];
                downloadDestinationBlock = [(JMDownloadRequest *)request downloadDestinationBlock];
            }
            
            if (downloadDestinationBlock) {
                // add parameters to URL;
                NSString *filteredUrl = [JMNetworkHelper urlStringWithOriginUrlString:url appendParameters:param];
                NSURLRequest *requesJMrl = [NSURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
                NSData *resumeData = [(JMDownloadRequest *)request resumeData];
                
                if (resumeData.length) {
                    request.requestTask = [_sessionManager downloadTaskWithResumeData:resumeData progress:downloadProgressBlock destination:downloadDestinationBlock completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                        [self handleDownloadRequest:(JMDownloadRequest *)request response:response filePath:filePath error:error
                         ];
                    }];
                } else {
                    request.requestTask = [_sessionManager downloadTaskWithRequest:requesJMrl progress:downloadProgressBlock destination:downloadDestinationBlock completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                        [self handleDownloadRequest:(JMDownloadRequest *)request response:response filePath:filePath error:error];
                    }];
                }
                
                [request.requestTask resume];
            } else {
                request.requestTask = [_sessionManager GET:url parameters:param progress:downloadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self handleRequestResultSuccess:task responseObject:responseObject];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self handleRequestResultFailur:task error:error];
                }];
            }
        } else if (method == JMRequestMethodPost) {
            
            AFConstructingBlock constructingBlock = nil;
            AFProgressBlock uploadProgressBlock = nil;
            if ([request isKindOfClass:[JMUploadRequest class]]) {
                constructingBlock = [(JMUploadRequest *)request constructingBodyBlock];
                uploadProgressBlock = [(JMUploadRequest *)request uploadProgressBlock];
            }
            
            if (constructingBlock != nil) {
                request.requestTask = [_sessionManager POST:url parameters:param constructingBodyWithBlock:constructingBlock progress:uploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self handleRequestResultSuccess:task responseObject:responseObject];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self handleRequestResultFailur:task error:error];
                }];
            } else {
                request.requestTask = [_sessionManager POST:url parameters:param progress:uploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self handleRequestResultSuccess:task responseObject:responseObject];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self handleRequestResultFailur:task error:error];
                }];
            }
        } else if (method == JMRequestMethodHead) {
            request.requestTask = [_sessionManager HEAD:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task) {
                [self handleRequestResultSuccess:task responseObject:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestResultFailur:task error:error];
            }];
        } else if (method == JMRequestMethodPut) {
            // added the "PUT" way to upload files
            AFConstructingBlock constructingBlock = nil;
            AFProgressBlock uploadProgressBlock = nil;
            if ([request isKindOfClass:[JMUploadRequest class]]) {
                constructingBlock = [(JMUploadRequest *)request constructingBodyBlock];
                uploadProgressBlock = [(JMUploadRequest *)request uploadProgressBlock];
            }
            
            if (constructingBlock != nil) {
                NSError *serializationError = nil;
                NSMutableURLRequest *tempRequest = [_sessionManager.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:[[NSURL URLWithString:url] absoluteString] parameters:param constructingBodyWithBlock:constructingBlock error:&serializationError];
                if (serializationError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handleRequestResultFailur:nil error:serializationError];
                    });
                    return;
                }
                
                __block NSURLSessionDataTask *task = nil;
                task = [_sessionManager uploadTaskWithStreamedRequest:tempRequest progress:uploadProgressBlock completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                    if (error == nil) {
                        [self handleRequestResultSuccess:task responseObject:responseObject];
                    } else {
                        [self handleRequestResultFailur:task error:error];
                    }
                }];
                
                request.requestTask = task;
                [task resume];
            } else {
                request.requestTask = [_sessionManager PUT:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self handleRequestResultSuccess:task responseObject:responseObject];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self handleRequestResultFailur:task error:error];
                }];
            }
        } else if (method == JMRequestMethodDelete) {
            request.requestTask = [_sessionManager DELETE:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestResultSuccess:task responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestResultFailur:task error:error];
            }];
        } else if (method == JMRequestMethodPatch) {
            request.requestTask = [_sessionManager PATCH:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestResultSuccess:task responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestResultFailur:task error:error];
            }];
        } else {
            JMLog(@"Error, Unsupport method type");
            return;
        }
    }
    
    // the priority of the task, NSURLSessionTaskPriorityDefault not support
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        switch (request.requestPriority) {
            case JMRequestPriorityHigh:
                request.requestTask.priority = 1.0;
                break;
            case JMRequestPriorityLow:
                request.requestTask.priority = 0.1;
                break;
            case JMRequestPriorityDefault:
            default:
                request.requestTask.priority = 0.5;
                break;
        }
    }
    
    JMLog(@"Sent Request: %@", request);
    [self addTaskWithRequest:request];
}

- (void)cancelRequest:(JMBaseRequest *)request {
    [request.requestTask cancel];
    [self removeTask:request.requestTask];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        JMBaseRequest *request = copyRecord[key];
        [request cancelRequest];
    }
}

- (void)handleDownloadRequest:(nonnull JMDownloadRequest *)request response:(NSURLResponse *)response filePath:(NSURL *)filePath error:(NSError *)error {
    JMLog(@"Finished Download For Request: %@ filePath:%@", NSStringFromClass([request class]), filePath);
    if (error) {
        [self handleRequestResultFailur:request.requestTask error:error];
    } else {
        [self handleRequestResultSuccess:request.requestTask responseObject:response];
    }
}

- (void)handleCacheRequestResultCompletion:(nonnull JMBaseRequest *)request error:(NSError *)error cacheResult:(nullable id)cacheResult {
    JMLog(@"Finished Get Cache For Request: %@", NSStringFromClass([request class]));
    request.cacheResponseObject = cacheResult;
    [request requestHandleResultFromCache:cacheResult error:error];
    
    if (request.cacheCompletionBlcok) {
        request.cacheCompletionBlcok(request, cacheResult, error);
    }
    [request clearCacheCompletionBlock];
    
    if ([request cacheOption] == JMRequestCacheOptionCachePriority || ([request cacheOption] == JMRequestCacheOptionCacheSaveFlow && error)) {
        [self sendRequestToNet:request];
    }
}

- (void)handleRequestResultSuccess:(nonnull NSURLSessionTask *)task responseObject:(nullable id)responseObject {
    NSString *key = [self requestHashKey:task];
    JMBaseRequest *request = _requestsRecord[key];
    JMLog(@"Succeed Finished Request: %@", NSStringFromClass([request class]));
    
    if (!request) {
        return;
    }
    
    request.responseObject = responseObject;
    [request requestHandleResult];
    
    BOOL isRealSuccess = [request requestVerifyResult];
    
    if (isRealSuccess) {
        if (request.successBlock) {
            request.successBlock(request, responseObject);
        }
        JMRequestCacheOption cacheOption = [request cacheOption];
        if (cacheOption == JMRequestCacheOptionCachePriority || cacheOption == JMRequestCacheOptionRefreshPriority || cacheOption == JMRequestCacheOptionCacheSaveFlow) {
            [JMCacheManager saveCacheForRequest:request completion:^(NSError *error, NSString *cachePath) {
                if (error) {
                    JMLog(@"Save Cache Error:%@!", error.description);
                } else {
                    JMLog(@"Succeed Save Cache For Request:%@ path:%@", NSStringFromClass([request class]), cachePath);
                }
            }];
        }
    } else {
        if (request.failurBlock) {
            request.failurBlock(request, [NSError errorWithDomain:@"请求结果校验失败！" code:-1 userInfo:responseObject]);
        }
        if ([request cacheOption] == JMRequestCacheOptionRefreshPriority) {
            [JMCacheManager getCacheForRequest:request completion:^(NSError *error, id cacheResult) {
                [self handleCacheRequestResultCompletion:request error:error cacheResult:cacheResult];
            }];
        }
    }
    [self removeTask:task];
    [request clearCompletionBlock];
}

- (void)handleRequestResultFailur:(nullable NSURLSessionTask *)task error:(nonnull NSError *)error {
    NSString *key = [self requestHashKey:task];
    JMBaseRequest *request = _requestsRecord[key];
    JMLog(@"Failed Finished Request: %@", NSStringFromClass([request class]));
    if (!request) {
        return;
    }
    
    [request requestHandleResult];
    
    if (request.failurBlock) {
        request.failurBlock(request, error);
    }
    
    if ([request cacheOption] == JMRequestCacheOptionRefreshPriority) {
        [JMCacheManager getCacheForRequest:request completion:^(NSError *error, id cacheResult) {
            [self handleCacheRequestResultCompletion:request error:error cacheResult:cacheResult];
        }];
    }
    
    [self removeTask:task];
    [request clearCompletionBlock];
}

- (NSString *)requestHashKey:(nullable NSURLSessionTask *)task {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[task hash]];
    return key;
}

- (void)addTaskWithRequest:(JMBaseRequest *)request {
    if (request.requestTask != nil) {
        NSString *key = [self requestHashKey:request.requestTask];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeTask:(nullable NSURLSessionTask *)task {
    NSString *key = [self requestHashKey:task];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
        JMLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
    }
}

#pragma mark - tools build URL

+ (NSMutableDictionary *)buildRequestHeader:(JMBaseRequest *)request {
    NSDictionary *param = [request requestHeaderFieldValueDictionary];
    NSMutableDictionary *mutiDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if ([request requestPublicParametersType] == JMRequestPublicParametersTypeHeader) {
        [mutiDict setValuesForKeysWithDictionary:[[request requestConfig] requestPublicParameters]];
    }
    
    [mutiDict setValuesForKeysWithDictionary:param];
    return mutiDict;
}

+ (NSMutableDictionary *)buildRequestParameters:(JMBaseRequest *)request {
    NSDictionary *param = [request requestParameters];
    NSMutableDictionary *mutiDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if ([request requestPublicParametersType] == JMRequestPublicParametersTypeBody) {
        [mutiDict setValuesForKeysWithDictionary:[[request requestConfig] requestPublicParameters]];
    }
    
    [mutiDict setValuesForKeysWithDictionary:param];
    return mutiDict;
}

+ (NSString *)buildRequesJMrl:(JMBaseRequest *)request {
    NSString *detailUrl = [request requesJMrl];
    if ([detailUrl hasPrefix:@"http"]) {
        if ([request requestPublicParametersType] == JMRequestPublicParametersTypeUrl) {
            detailUrl = [JMNetworkHelper urlStringWithOriginUrlString:detailUrl appendParameters:[[request requestConfig] requestPublicParameters]];
        }
        return detailUrl;
    }
    
    NSMutableString *baseUrl = [NSMutableString string];
    
    if ([request requesJMRLProtocol].length > 0) {
        [baseUrl appendString:[request requesJMRLProtocol]];
    }
    if ([request requestHost].length > 0) {
        [baseUrl appendString:[request requestHost]];
    }
    if (detailUrl.length > 0) {
        [baseUrl appendString:detailUrl];
    }
    if ([request requestPublicParametersType] == JMRequestPublicParametersTypeUrl) {
        baseUrl = (NSMutableString *)[JMNetworkHelper urlStringWithOriginUrlString:baseUrl appendParameters:[[request requestConfig] requestPublicParameters]];
    }
    
    return baseUrl;
}

@end
