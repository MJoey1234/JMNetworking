//
//  JMUploadRequest.m
//  JMNetworking
//
//  Created by Joey on 2018/3/12.
//  Copyright © 2018年 joey. All rights reserved.
//

#import "JMUploadRequest.h"

@interface JMUploadRequest ()

/**
 *  POST传送文件文件
 */
@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

/**
 *  POST传送文件Data(自定义Request)
 */
@property (nonatomic, strong, nullable) NSData * fileData;

/**
 *  POST传送文件Data(自定义Request)
 */
@property (nonatomic, strong, nullable) NSURL * fileURL;

/**
 *  当需要上传时，获得上传进度的回调
 */
@property (nonatomic, copy, nullable) AFProgressBlock uploadProgressBlock;


@end


@implementation JMUploadRequest

- (JMRequestCacheOption)cacheOption {
    return JMRequestCacheOptionNone;
}

- (JMRequestMethod)requestMethod {
    return JMRequestMethodPost;
}


@end
