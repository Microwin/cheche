//
//  MapViewController.h
//  iTaxi
//
//  Created by 卞 中杰 on 12-4-2.
//  Copyright (c) 2012年 淘米. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PlaceAnnotation.h"
#import "LocateAndDownload.h"

@class ASIHTTPRequest;

@protocol MapDelegate <NSObject>


@end

@interface MapViewController : UIViewController<MKMapViewDelegate, LocateSelfDelegate> {
    id<MapDelegate> delegate;
    MKMapView *_mapView;
    UISearchBar *_searchBar;
}
@property (nonatomic, assign) id<MapDelegate> delegate;
@end
