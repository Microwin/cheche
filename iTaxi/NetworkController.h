//
//  NetworkController.h
//  iTaxi
//
//  Created by 卞 中杰 on 12-4-2.
//  Copyright (c) 2012年 淘米. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NetworkOperation;
@interface NetworkController : NSObject {
    NSOperationQueue *_queue;
}
- (void)addNetworkOperation:(NetworkOperation *)operation;
@end
