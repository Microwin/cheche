//
//  MainViewController.h
//  iTaxi
//
//  Created by Wu Jianjun on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

#import "PlaceAnnotation.h"
#import "LocateAndDownload.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, MKMapViewDelegate, UISearchBarDelegate, LocateSelfDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
@private
    
    UITextField *_startPointTextField;  //出发地textfield
    UITextField *_targetPointTextField; //目的地textfield

    MKMapView *_mapView;    //地图
    UISearchBar *_searchBar;    //搜索栏
    UISegmentedControl *_mapStyleSwitch;    //地图切换
    
    NSString *_searchString;    //搜索的内容
    
    CLLocationCoordinate2D _startCoordinate;     //出发点坐标
    CLLocationCoordinate2D _targetCoordinate;    //目的地坐标
    
    LocateAndDownload *_locationManager;
}

@property (nonatomic, retain) IBOutlet UITextField *startPointTextField;
@property (nonatomic, retain) IBOutlet UITextField *targetPointTextField;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *mapStyleSwitch;

@property (nonatomic, retain) NSString *searchString;

@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D targetCoordinate;


- (IBAction)mapTypeSwitched:(id)sender;//地图类型选择
- (IBAction)closeKeyboard:(id)sender;

- (IBAction)smsSharingButtonPressed:(id)sender; //短信分享按钮
- (IBAction)emailSharingButtonPressed:(id)sender;//email分享按钮
- (IBAction)societySharingButtonPressed:(id)sender;//社交网络（微博）分享

- (IBAction)refreshButtonPressed:(id)sender;//定位刷新按钮
- (IBAction)searchButtonPressed:(id)sender;//搜索栏按钮
- (IBAction)historyInfoButtonPressed:(id)sender;//历史信息按钮
- (IBAction)settingButtonPressed:(id)sender;//系统设置按钮

@end
