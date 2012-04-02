//
//  MapViewController.m
//  iTaxi
//
//  Created by 卞 中杰 on 12-4-2.
//  Copyright (c) 2012年 淘米. All rights reserved.
//

#import "MapViewController.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"


#define kDataFile @"Data.plist"
#define SHEET_START_BTN_INDEX     0
#define SHEET_TARGET_BTN_INDEX    1
#define kGoogleGeoApi   @"http://maps.google.com/maps/api/geocode/json?address="
#define kGoogleDecApi   @"http://maps.google.com/maps/api/geocode/json?latlng="

@interface MapViewController ()
- (NSString *)_encodeString:(NSString *)string;
- (void)addTapGestureFromMapView:(MKMapView *)mapView;
- (void)removeTapGestureFromMapView:(MKMapView *)mapView;
- (void)mapView:(MKMapView *)mapView moveToCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@implementation MapViewController
@synthesize delegate;

#pragma mark - Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [self.view addSubview:_mapView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UILongPressGestureRecognizer *tgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPressed:)];
    [_mapView addGestureRecognizer:tgr];
    [tgr release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Public Methods

#pragma makr - Private Methods
//- (void)addTapGestureFromMapView:(MKMapView *)mapView {
//    if (!_tapGesture && mapView) {
//        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
//        [mapView addGestureRecognizer:_tapGesture];
//        [_tapGesture release];
//    }
//}
//
//- (void)removeTapGestureFromMapView:(MKMapView *)mapView {
//    if (_tapGesture && mapView) {
//        [mapView removeGestureRecognizer:_tapGesture];
//        _tapGesture = nil;
//    }
//}


#pragma mark - Map Methods
//地图缩放并跟踪到指定坐标
- (void)mapView:(MKMapView *)mapView moveToCoordinate:(CLLocationCoordinate2D)coordinate {
    if (mapView) {
        MKCoordinateRegion ragionCoor = MKCoordinateRegionMake(coordinate,
                                                               MKCoordinateSpanMake(0.005, 0.005));
        [mapView setRegion:ragionCoor animated:YES];
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

//异步获取指定坐标的位置信息描述
- (void)getAddressFromAnnoation:(PlaceAnnotation *)annotation 
{
    NSMutableString *url = [NSMutableString stringWithString:kGoogleDecApi];
    [url appendString:[NSString stringWithFormat:@"%@,%@&language=zh-CN&sensor=true", [NSNumber numberWithDouble:annotation.coordinate.latitude], [NSNumber numberWithDouble:annotation.coordinate.longitude]]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        NSData *responseData = [request responseData];
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:NULL];
        [dict writeToURL:[self itemDataFilePath] atomically:YES];
        [self performSelector:@selector(updateAnnotation:withDict:) withObject:annotation withObject:dict];
    }
}

- (void)updateAnnotation:(PlaceAnnotation *)anno withDict:(NSDictionary *)resultDic 
{
    if ([[resultDic valueForKey:@"results"] count]) {
        NSString *add = [[[resultDic valueForKey:@"results"] objectAtIndex:0] valueForKey:@"formatted_address"];
        anno.address = add;
        anno.subtitle = add;
        anno.title = @"用户选择的地点";
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)itemDataFilePath 
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"google.plist"];
    return storeURL;
}

- (NSString *)histroyDataFilePath 
{
    NSString *p = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kDataFile];
    return p;
}

//删除除当前位置蓝点的大头针
- (void)removeAnnotations 
{
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10]; 
    for (id annotation in _mapView.annotations) 
        if (annotation != _mapView.userLocation) 
            [toRemove addObject:annotation];
    [_mapView removeAnnotations:toRemove]; 
}

#pragma mark - Selectors
//长按地图上的一个点，获取坐标和位置信息
- (void)mapLongPressed:(UILongPressGestureRecognizer *)touch 
{
    CGPoint touchPoint = [touch locationInView:_mapView];
    PlaceAnnotation *anno = [[PlaceAnnotation alloc] init];
    anno.title = NSLocalizedString(@"User Selected Place", @"User Selected Place");
    anno.subtitle = @"地址加载中...";
    anno.coordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    [self removeAnnotations];
    [_mapView addAnnotation:anno];
    [_mapView selectAnnotation:anno animated:YES];
    [self performSelectorInBackground:@selector(getAddressFromAnnoation:) withObject:anno];
    
}

- (void)mapTapped:(UITapGestureRecognizer *)tap {
    if ([_searchBar isFirstResponder]) {
        //        CGPoint point = _baseView.center;
        //        point.y += 210;
        //        CGContextRef context = UIGraphicsGetCurrentContext();
        //        [UIView beginAnimations:nil context:context];
        //        [UIView setAnimationDuration:.3f];
        //        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        //        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_baseView cache:YES];
        //        _baseView.transform = CGAffineTransformIdentity;
        //        _baseView.center = point;
        [_searchBar resignFirstResponder];
        [self removeTapGestureFromMapView:_mapView];
        //        [UIView commitAnimations];
    }
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

#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self addTapGestureFromMapView:_mapView];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self removeTapGestureFromMapView:_mapView];
//    _searchString = _searchBar.text;
//    [_searchBar resignFirstResponder];
//    NSLog(@"Search:%@", _searchString);
//    NSString *searchStr = [self _encodeString:_searchString];
//    NSMutableString *url = [NSMutableString stringWithString:kGoogleGeoApi];
//    [url appendString:searchStr];
//    [url appendString:@"&language=zh-CN&sensor=true"];
    
//    NSLog(@"%@", url);
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
//    [request setDelegate:self];
//    [request startAsynchronous];
    
}

#pragma mark - MKMapView Delegate
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择地点类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"出发地", @"目的地", nil];
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.view];
    [sheet release];
    NSString *str = nil;
//    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
//        _locationStr = ((PlaceAnnotation *)view.annotation).address;
//    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
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
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
        
    }
    return pinView;
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
    if (newState == MKAnnotationViewDragStateEnding) {
        PlaceAnnotation *anno = view.annotation;
        if (anno) {
            [self getAddressFromAnnoation:anno];
        }
    }
}


bool showSelf = NO;
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation 
{
    if (!showSelf) {
        [self mapView:mapView moveToCoordinate:userLocation.coordinate];
        showSelf = YES;
    }
}

#pragma mark - LocateSelf Delegate
- (void)locateSelfFinishedWithCood:(CLLocationCoordinate2D)coordinate {
    //_startPointTextField.text = @"现在的位置";
}



#pragma mark - ASIHttpRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if (/*!_searchBar.hidden*/1) {
        [self removeAnnotations];
        // Use when fetching text data
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        // Use when fetching binary data
        NSData *responseData = [request responseData];
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:NULL];
        [dict writeToURL:[self itemDataFilePath] atomically:YES];
        NSArray *array = [dict valueForKey:@"results"];
        PlaceAnnotation *firstAnno = nil;
        for (NSDictionary *dic in array) {
            
            PlaceAnnotation *anno = [[PlaceAnnotation alloc] init];
            anno.title = [[[dic valueForKey:@"address_components"] objectAtIndex:0] valueForKey:@"long_name"];
            anno.subtitle = [dic valueForKey:@"formatted_address"];
            anno.address = [dic valueForKey:@"formatted_address"];
            NSDictionary *loc = [[dic valueForKey:@"geometry"] valueForKey:@"location"];
            anno.coordinate = CLLocationCoordinate2DMake([[loc valueForKey:@"lat"] doubleValue], [[loc valueForKey:@"lng"] doubleValue]);
            [_mapView addAnnotation:anno];
            [anno release];
            firstAnno = anno;
        }
        _searchBar.hidden = YES;
        if (firstAnno) {
            [self mapView:_mapView moveToCoordinate:firstAnno.coordinate];
        }
    }
    
    //kRequest = nil;
    
    
    
}



@end
