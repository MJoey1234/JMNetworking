//
//  JMDownloadRequest.m
//  JMNetworking
//
//  Created by Joey on 2018/3/12.
//  Copyright © 2018年 joey. All rights reserved.
//

#import "JMDownloadRequest.h"

@interface JMDownloadRequest()

@property (nonatomic, copy, nullable) AFProgressBlock downloadProgressBlock;

@end

@implementation JMDownloadRequest

- (void)resume {
    if (self.requestTask.state != NSURLSessionTaskStateRunning) {
        [self.requestTask resume];
    }
}

- (void)suspend {
    if (self.requestTask.state == NSURLSessionTaskStateRunning) {
        [self.requestTask suspend];
    }
}


@end
