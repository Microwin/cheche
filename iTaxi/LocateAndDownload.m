//
//  LocateAndDownload.m
//  ekkk
//
//  Created by 卞中杰 on 11-6-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LocateAndDownload.h"

#define kLocationFileName           @"location.plist"
#define kDataBackupFileName         @"DataBackup.plist"
#define kDataFileName               @"Data.plist"
#define kUserCardsFileName          @"UserCards.plist"

@implementation LocateAndDownload
@synthesize locationManager;
@synthesize interConnectOperationQueue;
@synthesize parsedItems = _parsedItems;
@synthesize interconnectOperation;
@synthesize coodToLocate = _coodToLocate;
@synthesize locateCustomPosition;
@synthesize delegate;

- (id)init {
    if ((self = [super init])) {
        _coodToLocate = [[NSMutableDictionary alloc] init];
        locateCustomPosition = NO;

        
        //开始定位
        [self startStandardUpdates];
    }
    return self;
}

- (void)dealloc {
    [_coodToLocate release];
    [_parsedItems release];
    [locationManager release];
    [super dealloc];
}

- (NSURL *)userCardsFilePath {
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kUserCardsFileName];
    NSLog(@"%@", storeURL);
    return storeURL;
}

- (NSURL *)locationDataFilePath {
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kLocationFileName];
    NSLog(@"%@", storeURL);
    return storeURL;
}

- (NSURL *)itemDataFilePath {
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kDataFileName];
    NSLog(@"%@", storeURL);
    return storeURL;
}






- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = kCLHeadingFilterNone;
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
    // If it's a relatively recent event, turn off updates to save power
    //    NSDate* eventDate = newLocation.timestamp;
    //    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //    if (abs(howRecent) < 15.0)
    //    {
    //        NSLog(@"latitude %+.6f, longitude %+.6f\n",
    //              newLocation.coordinate.latitude,
    //              newLocation.coordinate.longitude);
    //    }
    // else skip the event and process the next one.
    [locationManager stopUpdatingLocation];
    
    NSMutableDictionary *ddd = [NSMutableDictionary dictionaryWithCapacity:2];
    NSNumber *lat = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
    NSNumber *log = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
    [ddd setValue:lat forKey:@"latitude"];
    [ddd setValue:log forKey:@"longitude"];
    [ddd writeToURL:[self locationDataFilePath] atomically:YES];
    
    
    
    [delegate locateSelfFinishedWithCood:newLocation.coordinate];
//    //新建线程
//    interConnectOperationQueue = [NSOperationQueue new];
//    
//    //定位完成开始和服务器交互
//    interconnectOperation = [[[InterconnectWithServer alloc] initWithCoordinate:ddd] autorelease];
//    [self.interConnectOperationQueue addOperation: interconnectOperation];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    NSLog(@"Error:%@", [error userInfo]);
}



#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
