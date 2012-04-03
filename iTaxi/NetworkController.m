//
//  NetworkController.m
//  iTaxi
//
//  Created by 卞 中杰 on 12-4-2.
//  Copyright (c) 2012年 淘米. All rights reserved.
//

#import "NetworkController.h"
#import "ASIHTTPRequest.h"
#import "NetworkOperation.h"

@implementation NetworkController

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_queue release];
    [super dealloc];
}

#pragma mark - Public Methods
- (void)addNetworkOperation:(NetworkOperation *)operation
{
    [_queue addOperation:operation];
}
@end
