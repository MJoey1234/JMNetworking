//
//  JMNetworkCinfig.m
//  JMNetworking
//
//  Created by Joey on 2018/2/15.
//  Copyright © 2018年 joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMNetworkConfig.h"

@implementation JMNetworkConfig

+ (JMNetworkConfig *)config {
    static JMNetworkConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset {
    _publicParameters = @{};
    _userId = @"0";
}

- (NSString *)configUserId {
    return self.userId;
}

/// 请求的protocol
- (NSString *)requestURLProtocol {
    return @"http://";
}

/// 请求的Host
- (NSString *)requestHost {
    return @"";
}

/// 请求的超时时间
- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

/// 请求的安全选项
- (AFSecurityPolicy *)requestSecurityPolicy {
    return [AFSecurityPolicy defaultPolicy];
}

/// Http请求的方法
- (JMRequestMethod)requestMethod {
    return JMRequestMethodGet;
}

/// 请求的SerializerType
- (JMRequestSerializerType)requestSerializerType {
    return JMRequestSerializerTypeHTTP;
}

- (NSDictionary *)requestPublicParameters {
    return self.publicParameters;
}

/// 请求公参的位置
- (JMRequestPublicParametersType)requestPublicParametersType {
    return JMRequestPublicParametersTypeBody;
}

/// 请求校验
- (BOOL)requestVerifyResult:(id)result {
    if (result) {
        return YES;
    }
    return NO;
}

@end
