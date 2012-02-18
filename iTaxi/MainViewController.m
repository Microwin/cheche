//
//  MainViewController.m
//  iTaxi
//
//  Created by Wu Jianjun on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"

#define kDataFile @"Data.plist"
#define SHEET_START_BTN_INDEX     0
#define SHEET_TARGET_BTN_INDEX    1

@interface MainViewController(private)
- (void)addTapGestureFromMapView:(MKMapView *)mapView;
- (void)removeTapGestureFromMapView:(MKMapView *)mapView;
- (void)mapView:(MKMapView *)mapView moveToCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@implementation MainViewController(private)

- (void)addTapGestureFromMapView:(MKMapView *)mapView {
    if (!_tapGesture && mapView) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
        [mapView addGestureRecognizer:_tapGesture];
        [_tapGesture release];
    }
}

- (void)removeTapGestureFromMapView:(MKMapView *)mapView {
    if (_tapGesture && mapView) {
        [mapView removeGestureRecognizer:_tapGesture];
        _tapGesture = nil;
    }
}


//地图缩放并跟踪到指定坐标
- (void)mapView:(MKMapView *)mapView moveToCoordinate:(CLLocationCoordinate2D)coordinate {
    if (mapView) {
        MKCoordinateRegion ragionCoor = MKCoordinateRegionMake(coordinate,
                                                               MKCoordinateSpanMake(0.005, 0.005));
        [mapView setRegion:ragionCoor animated:YES];
    }
}
@end

@implementation MainViewController

@synthesize startPointTextField = _startPointTextField;
@synthesize targetPointTextField = _targetPointTextField;
@synthesize telTextField = _telTextField;
@synthesize searchBar = _searchBar;
@synthesize mapView = _mapView;
@synthesize mapStyleSwitch = _mapStyleSwitch;
@synthesize locationTypeSwitch = _locationTypeSwitch;
@synthesize searchString = _searchString;
@synthesize startCoordinate = _startCoordinate;
@synthesize targetCoordinate = _targetCoordinate;
@synthesize companyButton = _companyButton;
static NSString *kGoogleGeoApi = @"http://maps.google.com/maps/api/geocode/json?address=";
static NSString *kGoogleDecApi = @"http://maps.google.com/maps/api/geocode/json?latlng=";
static ASIHTTPRequest *kRequest = nil;


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)itemDataFilePath {
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"google.plist"];
    NSLog(@"%@", storeURL);
    return storeURL;
}

- (NSString *)histroyDataFilePath {
    NSString *p = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kDataFile];
    return p;
}

//删除除当前位置蓝点的大头针
- (void)removeAnnotations {
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10]; 
    for (id annotation in _mapView.annotations) 
        if (annotation != _mapView.userLocation) 
            [toRemove addObject:annotation];
    [_mapView removeAnnotations:toRemove]; 
}


//根据地图坐标下载位置信息
- (NSDictionary *)getAddressFromCoordinate:(CLLocationCoordinate2D)coordinate {
    NSMutableString *url = [NSMutableString stringWithString:kGoogleDecApi];
    [url appendString:[NSString stringWithFormat:@"%@,%@&language=zh-CN&sensor=true", [NSNumber numberWithDouble:coordinate.latitude], [NSNumber numberWithDouble:coordinate.longitude]]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        NSData *responseData = [request responseData];
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:NULL];
        [dict writeToURL:[self itemDataFilePath] atomically:YES];
        return dict;
    }
    else
        return nil;
}


//长按地图上的一个点，获取坐标和位置信息
- (void)mapLongPressed:(UILongPressGestureRecognizer *)touch {

    CGPoint touchPoint = [touch locationInView:_mapView];
    PlaceAnnotation *anno = [[PlaceAnnotation alloc] init];
    anno.title = NSLocalizedString(@"User Selected Place", @"User Selected Place");
    anno.subtitle = @"";
    anno.coordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    NSDictionary *resultDic = [self getAddressFromCoordinate:anno.coordinate];
    if (resultDic) {
        if ([[resultDic valueForKey:@"results"] count]) {
            NSString *add = [[[resultDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"formatted_address"];
            anno.address = add;
            anno.subtitle = add;
            anno.title = @"用户选择的地点";
            [self removeAnnotations];
            [_mapView addAnnotation:anno];
        }
    }
}

bool mapTapped = NO;
- (void)mapTapped:(UITapGestureRecognizer *)tap {
    if ([_searchBar isFirstResponder]) {
        CGPoint point = self.view.center;
        point.y += 210;
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationDuration:.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
        self.view.transform = CGAffineTransformIdentity;
        self.view.center = point;
        [_searchBar resignFirstResponder];
        _mapStyleSwitch.hidden = !_mapStyleSwitch.hidden;
        [self removeTapGestureFromMapView:_mapView];
        [UIView commitAnimations];
    }
}

- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
																		   (CFStringRef)string, 
																		   NULL, 
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UILongPressGestureRecognizer *tgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPressed:)];
    [_mapView addGestureRecognizer:tgr];
    [tgr release];
    
    
//    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
//    [_mapView addGestureRecognizer:_tapGesture];
//    [_tapGesture release];
    
    LocateAndDownload *lAndD = [[LocateAndDownload alloc] init];
    lAndD.delegate = self;
    [lAndD startStandardUpdates];
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [_startPointTextField release];
    [_targetPointTextField release];
    [_telTextField release];
    [_searchBar release];
    [_mapView release];
    [_mapStyleSwitch release];
    [_locationTypeSwitch release];
    [_companyButton release];
    [super dealloc];
}



#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self addTapGestureFromMapView:_mapView];
    CGPoint point = self.view.center;
    point.y -= 210;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    self.view.transform = CGAffineTransformIdentity;
    self.view.center = point;
    [UIView commitAnimations];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self removeTapGestureFromMapView:_mapView];
    _searchString = _searchBar.text;
    [_searchBar resignFirstResponder];
    NSLog(@"Search:%@", _searchString);
    NSString *searchStr = [self _encodeString:_searchString];
    NSMutableString *url = [NSMutableString stringWithString:kGoogleGeoApi];
    [url appendString:searchStr];
    [url appendString:@"&language=zh-CN&sensor=true"];
    
    NSLog(@"%@", url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request startAsynchronous];
    
    CGPoint point = self.view.center;
    point.y += 210;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationDuration:.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    _searchBar.hidden = YES;
    self.view.transform = CGAffineTransformIdentity;
    self.view.center = point;
    [UIView commitAnimations];
}

#pragma mark - ASIHttpRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{

    if (/*!_searchBar.hidden*/1) {
        [self removeAnnotations];
//        [self.mapView removeAnnotations:self.mapView.annotations];
        // Use when fetching text data
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        // Use when fetching binary data
        NSData *responseData = [request responseData];
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:NULL];
        [dict writeToURL:[self itemDataFilePath] atomically:YES];
        NSArray *array = [dict valueForKey:@"results"];
        for (NSDictionary *dic in array) {
            
            PlaceAnnotation *anno = [[PlaceAnnotation alloc] init];
            anno.title = [[[dic valueForKey:@"address_components"] objectAtIndex:0] valueForKey:@"long_name"];
            anno.subtitle = [dic valueForKey:@"formatted_address"];
            anno.address = [dic valueForKey:@"formatted_address"];
            NSDictionary *loc = [[dic valueForKey:@"geometry"] valueForKey:@"location"];
            anno.coordinate = CLLocationCoordinate2DMake([[loc valueForKey:@"lat"] doubleValue], [[loc valueForKey:@"lng"] doubleValue]);
            [_mapView addAnnotation:anno];
            [anno release];
        }
        _searchBar.hidden = YES;

    }
    
    kRequest = nil;
    
    
    
}

#pragma mark - IBActions

- (IBAction)searchButtonPressed:(id)sender {
    _searchBar.hidden = !_searchBar.hidden;
    _mapStyleSwitch.hidden = !_mapStyleSwitch.hidden;
}

- (IBAction)mapTypeSwitched:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
        {
            _mapView.mapType = MKMapTypeStandard;
            break;
        } 
        case 1:
        {
            _mapView.mapType = MKMapTypeSatellite;
            break;
            
        }
        default:
            break;
    }
}

- (IBAction)locationTypeSwitched:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
            //出发地
        case 0:
        {
            break;
        } 
            //目的地
        case 1:
        {
            break;
            
        }
        default:
            break;
    }
}

- (IBAction)closeKeyboard:(id)sender {
    [_startPointTextField resignFirstResponder];
    [_targetPointTextField resignFirstResponder];
    [_telTextField resignFirstResponder];
}

- (IBAction)companyButtonPressed:(id)sender {
    TaxiCompanyViewController *companyViewController = [[TaxiCompanyViewController alloc] initWithStyle:UITableViewStylePlain];
    companyViewController.delegate = self;
    [self presentModalViewController:companyViewController animated:YES];
    [companyViewController release];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!_locationStr) {
        return;
    }
    switch (buttonIndex) {
        case SHEET_START_BTN_INDEX:
            _startPointTextField.text = _locationStr;
            break;
        case SHEET_TARGET_BTN_INDEX:
            _targetPointTextField.text = _locationStr;
            break;
        default:
            break;
    }
    _locationStr = nil;
}

#pragma mark - Map Delegate
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择地点类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"出发地", @"目的地", nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.view];
    [sheet release];
    NSString *str = nil;
    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
        _locationStr = ((PlaceAnnotation *)view.annotation).address;
    }
    return;
    if (_locationTypeSwitch.selectedSegmentIndex == 0) {
        if (str) {
            _startPointTextField.text = str;
        }
        
    }
    else
        if (str) {
            _targetPointTextField.text = str;
        }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (annotation == _mapView.userLocation) {
        return nil;
    }
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        pinView = [[[MKPinAnnotationView alloc]
                    initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        pinView.draggable = YES;
        if (_locationTypeSwitch.selectedSegmentIndex == 0) {
            pinView.pinColor = MKPinAnnotationColorPurple;
        }
        // add a detail disclosure button to the callout which will open a new view controller page
        //
        // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
        //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
        //
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
        
    }
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        PlaceAnnotation *anno = view.annotation;
        if (anno) {
            NSDictionary *resultDic = [self getAddressFromCoordinate:anno.coordinate];
            if (resultDic) {
                if ([[resultDic valueForKey:@"results"] count]) {
                    NSString *add = [[[resultDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"formatted_address"];
                    anno.address = add;
                    anno.subtitle = add;
                    anno.title = @"用户选择的地点";
                }
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

    //[self mapView:mapView moveToCoordinate:userLocation.coordinate];
}

#pragma LocateAndDownload Delegate

- (void)locateSelfFinishedWithCood:(CLLocationCoordinate2D)coordinate {
    _startPointTextField.text = @"现在的位置";
}




//提交信息
- (IBAction)commit:(id)sender {
    NSString *startString = _startPointTextField.text;  //出发地
    NSString *targetString = _targetPointTextField.text;    //目的地
    NSString *userTel = _telTextField.text; //电话
    NSString *taxiCompany = _companyButton.titleLabel.text;
    //出发地和目的地坐标
    NSNumber *startLat = [NSNumber numberWithDouble:_startCoordinate.latitude];
    NSNumber *startLon = [NSNumber numberWithDouble:_startCoordinate.longitude];
    NSNumber *targetLat = [NSNumber numberWithDouble:_targetCoordinate.latitude];
    NSNumber *targetLon = [NSNumber numberWithDouble:_targetCoordinate.longitude];
    if ([startString isEqualToString:@""] || [targetString isEqualToString:@""] || [userTel isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"不能生成订单" message:@"请完善必要的信息" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        NSString *order = [NSString stringWithFormat:@"您的出发地为：%@\n您的目的地为：%@\n您选择的出租车公司为：%@\n您的联系电话为：%@", startString, targetString, taxiCompany, userTel];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"生成订单" message:order delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"提交！", nil];
        [alert show];
        [alert release];
    }
}

//清空当前输入的订单数据
- (void)clear {
    _startPointTextField.text = @"";
    _targetPointTextField.text = @"";
    _telTextField.text = @"";
    [_companyButton setTitle:@"出租公司选择" forState:UIControlStateNormal];
    _locationTypeSwitch.selectedSegmentIndex = 0;
    _mapStyleSwitch.selectedSegmentIndex = 0;
    _searchBar.text = @"";
    _searchBar.hidden = YES;
    [self removeAnnotations];
//    [_mapView removeAnnotations:_mapView.annotations];
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *startString = _startPointTextField.text;  //出发地
        NSString *targetString = _targetPointTextField.text;    //目的地
        NSString *taxiCompany = _companyButton.titleLabel.text;
        
        /*
        NSString *userTel = _telTextField.text; //电话
        //出发地和目的地坐标
        NSNumber *startLat = [NSNumber numberWithDouble:_startCoordinate.latitude];
        NSNumber *startLon = [NSNumber numberWithDouble:_startCoordinate.longitude];
        NSNumber *targetLat = [NSNumber numberWithDouble:_targetCoordinate.latitude];
        NSNumber *targetLon = [NSNumber numberWithDouble:_targetCoordinate.longitude];
        */
        NSString *path = [self histroyDataFilePath];
        NSLog(@"HISTORY:%@", path);
        NSMutableArray *dataArray = [[NSMutableArray arrayWithContentsOfFile:[self histroyDataFilePath]] retain];
        if (!dataArray) {
            dataArray = [[NSMutableArray alloc] initWithCapacity:1];
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:startString, @"Start", targetString, @"Target", taxiCompany, @"Company", nil];
        [dataArray addObject:dic];
        [dataArray writeToFile:[self histroyDataFilePath] atomically:YES];
        [dataArray release];
        //清空当前数据
        [self clear];
    }
}

#pragma mark - CompanySelect Delegate
- (void)companySelected:(NSString *)name {
    [_companyButton setTitle:name forState:UIControlStateNormal];
}
@end
