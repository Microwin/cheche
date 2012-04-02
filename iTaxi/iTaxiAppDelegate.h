//
//  iTaxiAppDelegate.h
//  iTaxi
//
//  Created by Wu Jianjun on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface iTaxiAppDelegate : UIResponder <UIApplicationDelegate> {

}

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) MainViewController *mainViewController;

@end
