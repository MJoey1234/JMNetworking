//
//  JMBaseRequest.m
//  JMNetworking
//
//  Created by Joey on 2018/2/5.
//  Copyright © 2018年 joey. All rights reserved.
//

#import "JMBaseRequest.h"
#import "JMNetworkHelper.h"

@implementation JMBaseRequest
- (NSString *)requestURLProtocol {
    if ([[self requestConfig] respondsToSelector:@selector(requestURLProtocol)]) {
        return [[self requestConfig] requestURLProtocol];
    } else {
        return [[JMNetworkConfig config] requestURLProtocol];
    }
}

- (NSString *)requestHost {
    if ([[self requestConfig] respondsToSelector:@selector(requestHost)]) {
        return [[self requestConfig] requestHost];
    } else {
        return [[JMNetworkConfig config] requestHost];
    }
}

- (NSTimeInterval)requestTimeoutInterval {
    if ([[self requestConfig] respondsToSelector:@selector(requestTimeoutInterval)]) {
        return [[self requestConfig] requestTimeoutInterval];
    } else {
        return [[JMNetworkConfig config] requestTimeoutInterval];
    }
}

- (NSTimeInterval)cacheExpireTimeInterval {
    return -1;
}

- (TURequestMethod)requestMethod {
    if ([[self requestConfig] respondsToSelector:@selector(requestMethod)]) {
        return [[self requestConfig] requestMethod];
    } else {
        return [[JMNetworkConfig config] requestMethod];
    }
}

- (TURequestSerializerType)requestSerializerType {
    if ([[self requestConfig] respondsToSelector:@selector(requestSerializerType)]) {
        return [[self requestConfig] requestSerializerType];
    } else {
        return [[JMNetworkConfig config] requestSerializerType];
    }
}

- (TURequestPublicParametersType)requestPublicParametersType {
    if ([[self requestConfig] respondsToSelector:@selector(requestPublicParametersType)]) {
        return [[self requestConfig] requestPublicParametersType];
    } else {
        return [[JMNetworkConfig config] requestPublicParametersType];
    }
}

- (AFSecurityPolicy *)requestSecurityPolicy {
    if ([[self requestConfig] respondsToSelector:@selector(requestSecurityPolicy)]) {
        return [[self requestConfig] requestSecurityPolicy];
    } else {
        return [[JMNetworkConfig config] requestSecurityPolicy];
    }
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (NSString *)requestUrl {
    return nil;
}

- (NSDictionary *)requestParameters {
    return nil;
}

- (NSArray *)cacheFileNameIgnoreKeysForParameters {
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}

- (void)clearCompletionBlock {
    self.successBlock = nil;
    self.failurBlock = nil;
}

- (void)clearCacheCompletionBlock {
    self.cacheCompletionBlcok = nil;
}

- (void)requestHandleResult {
    
}

- (void)requestHandleResultFromCache:(id)cacheResult error:(NSError *)error {
    
}

#pragma mark - Config

- (id<JMNetworkConfigProtocol>)requestConfig {
    return [JMNetworkConfig config];
}

- (BOOL)requestVerifyResult {
    return [[self requestConfig] requestVerifyResult:self.responseObject];
}

@end
