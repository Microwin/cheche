//
//  MapViewController.h
//  iTaxi
//
//  Created by 卞 中杰 on 12-4-2.
//  Copyright (c) 2012年 淘米. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocateAndDownload.h"

@class ASIHTTPRequest;
@class PlaceAnnotation;

@protocol MapDelegate <NSObject>
- (void)setStartLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coor;
- (void)setTargetLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coor;
@end

@interface MapViewController : UIViewController<MKMapViewDelegate,  LocateSelfDelegate, UISearchBarDelegate, UIActionSheetDelegate> {
    id<MapDelegate> delegate;
    MKMapView *_mapView;
    UISearchBar *_searchBar;
    UISegmentedControl *_mapStyleControl;
    UITapGestureRecognizer *_tapGesture;
    PlaceAnnotation *_selectedAnnotation;                                                
}
@property (nonatomic, assign) id<MapDelegate> delegate;
@end
