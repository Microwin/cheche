//
//  MainViewController.h
//  iTaxi
//
//  Created by Wu Jianjun on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import <MapKit/MapKit.h>
#import "PlaceAnnotation.h"
#import "LocateAndDownload.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, MKMapViewDelegate, UISearchBarDelegate, LocateSelfDelegate> {

    UITextField *_startPoint;
    UITextField *_targetPoint;
    MKMapView *_mapView;
    UISearchBar *_searchBar;
    UISegmentedControl *_mapStyleSwitch;
    UISegmentedControl *_locationTypeSwitch;
    
    NSString *_searchString;    //搜索的内容
    
}

@property (nonatomic, retain) IBOutlet UITextField *startPoint;
@property (nonatomic, retain) IBOutlet UITextField *targetPoint;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *mapStyleSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *locationTypeSwitch;
@property (nonatomic, retain) NSString *searchString;

- (IBAction)showInfo:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;
- (IBAction)mapTypeSwitched:(id)sender;
- (IBAction)locationTypeSwitched:(id)sender;
- (IBAction)commit:(id)sender;
@end
