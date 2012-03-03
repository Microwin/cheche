//
//  iTaxiAppDelegate.h
//  iTaxi
//
//  Created by Wu Jianjun on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMKMapManager.h"

@class MainViewController;
@class BaiduMapViewController;
@interface iTaxiAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *_navigationController;
    BMKMapManager *_mapManager;
    BaiduMapViewController *_baiduMapViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end
