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
#import "TaxiCompanyViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, MKMapViewDelegate, UISearchBarDelegate, LocateSelfDelegate, CompanySelectDelegate, UIAlertViewDelegate> {
@private
    UITextField *_startPointTextField;  //出发地textfield
    UITextField *_targetPointTextField; //目的地textfield
    UITextField *_telTextField; //用户电话textfield
    MKMapView *_mapView;    //地图
    UISearchBar *_searchBar;    //搜索栏
    UISegmentedControl *_mapStyleSwitch;    //地图切换
    UISegmentedControl *_locationTypeSwitch;    //地点性质切换
    
    NSString *_searchString;    //搜索的内容
    
    CLLocationCoordinate2D _startCoordinate;     //出发点坐标
    CLLocationCoordinate2D _targetCoordinate;    //目的地坐标
    
    NSString *_userTel; //用户电话
    
    UIButton *_companyButton;   //出租车公司选择按钮
}

@property (nonatomic, retain) IBOutlet UITextField *startPointTextField;
@property (nonatomic, retain) IBOutlet UITextField *targetPointTextField;
@property (nonatomic, retain) IBOutlet UITextField *telTextField;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *mapStyleSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *locationTypeSwitch;
@property (nonatomic, retain) IBOutlet UIButton *companyButton;
@property (nonatomic, retain) NSString *searchString;

@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D targetCoordinate;


- (IBAction)closeKeyboard:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;
- (IBAction)mapTypeSwitched:(id)sender;
- (IBAction)locationTypeSwitched:(id)sender;
- (IBAction)commit:(id)sender;
- (IBAction)companyButtonPressed:(id)sender;
@end
