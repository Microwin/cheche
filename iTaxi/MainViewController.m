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

@implementation MainViewController

@synthesize startPointTextField = _startPointTextField;
@synthesize targetPointTextField = _targetPointTextField;

@synthesize mapView = _mapView;
@synthesize searchBar = _searchBar;
@synthesize mapStyleSwitch = _mapStyleSwitch;
@synthesize searchString = _searchString;

@synthesize startCoordinate = _startCoordinate;
@synthesize targetCoordinate = _targetCoordinate;

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

- (void)mapLongPressed:(UILongPressGestureRecognizer *)touch {

    CGPoint touchPoint = [touch locationInView:_mapView];
    PlaceAnnotation *anno = [[PlaceAnnotation alloc] init];
    anno.title = NSLocalizedString(@"User Selected Place", @"User Selected Place");
    anno.subtitle = @"";
    anno.coordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];

    
    //如果有一个请求，先取消这个请求
//    if (kRequest) {
//        [kRequest clearDelegatesAndCancel];
//    }
    NSMutableString *url = [NSMutableString stringWithString:kGoogleDecApi];
    
    [url appendString:[NSString stringWithFormat:@"%@,%@&language=zh-CN&sensor=true", [NSNumber numberWithDouble:anno.coordinate.latitude], [NSNumber numberWithDouble:anno.coordinate.longitude]]];
    
    NSLog(@"%@", url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        NSData *responseData = [request responseData];
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:NULL];
        [dict writeToURL:[self itemDataFilePath] atomically:YES];
        
        if ([[dict valueForKey:@"results"] count]) {
            NSString *add = [[[dict valueForKey:@"results"] objectAtIndex:0] valueForKey:@"formatted_address"];
            anno.address = add;
            anno.subtitle = add;
            anno.title = @"用户选择的地点";
            [self removeAnnotations];
//            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotation:anno];
        }
    }
}

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
        [UIView commitAnimations];
        _searchBar.hidden = YES; //触摸地图就要将searchbar本身也消失掉

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
    [_mapView addGestureRecognizer:tap];
    [tap release];
    
    _locationManager = [[LocateAndDownload alloc] init];
    _locationManager.delegate = self;
    [_locationManager startStandardUpdates];
    
    
    //MKMapView跟踪用户位置
    MKCoordinateRegion ragionCoor = MKCoordinateRegionMake([[[_mapView userLocation] location] coordinate], MKCoordinateSpanMake(1, 1));
    
    [_mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [_mapView setRegion:ragionCoor animated:YES];
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
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
    [_locationManager release];
    [_startPointTextField release];
    [_targetPointTextField release];
    [_searchBar release];
    [_mapView release];
    [_mapStyleSwitch release];
    [super dealloc];
}



#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
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
    //这里需要考虑如果通过搜索地点反馈解析回来有多个选项，则以搜索栏下出现tableview方式罗列出来让用户选择。
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


#pragma mark - IBActions for multiple style sharing
//sms sharing
- (IBAction)smsSharingButtonPressed:(id)sender
{
    
    NSString *message = [NSString stringWithFormat:@"the location is:%@", "12345"];
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate= self;
    picker.navigationBar.tintColor= [UIColor blackColor];
    picker.body = message; // 默认信息内容
    // 默认收件人(可多个)
    //picker.recipients = [NSArray arrayWithObject:@"12345678901", nil];
    [self presentModalViewController:picker animated:YES];
    [picker release];
}
    
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
        
        [self dismissModalViewControllerAnimated:YES]; 
}

//email sharing
- (IBAction)emailSharingButtonPressed:(id)sender
{
        
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
    picker.mailComposeDelegate = self;
    [picker setSubject:[NSString stringWithFormat:@"分享位置"]];
        
    [picker setMessageBody:@"I share you my current location from iAlmondz." isHTML:NO];
        
    //[picker addAttachmentData:UIImagePNGRepresentation([self image]) mimeType:@"image/png" fileName:@"sharePictures.png"];
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:picker animated:YES];
    [picker release];
        
}
    
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    
    [self dismissModalViewControllerAnimated:YES];
}

//societynetwork sharing, like weibo etc.
- (IBAction)societySharingButtonPressed:(id)sender
{

}

#pragma mark - IBActions for bottom button

//刷新按钮动作：用户移动过程中，手动刷新当前位置定位
- (IBAction)refreshButtonPressed:(id)sender{

    [_locationManager startStandardUpdates];

}

//搜索按钮动作：在搜索栏显示和隐藏间切换
- (IBAction)searchButtonPressed:(id)sender {
    _searchBar.hidden = !_searchBar.hidden;
}

//位置历史信息显示
- (IBAction)historyInfoButtonPressed:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

//程序设置按钮动作
- (IBAction)settingButtonPressed:(id)sender
{

}

//地图模式切换按钮
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


- (IBAction)closeKeyboard:(id)sender {
    [_startPointTextField resignFirstResponder];
    [_targetPointTextField resignFirstResponder];
}



#pragma mark - Map Delegate
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    NSString *str = nil;
    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
        str = ((PlaceAnnotation *)view.annotation).address;
    }
    
    _startPointTextField.text = str;
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
        
//        if (_locationTypeSwitch.selectedSegmentIndex == 0) {
//            pinView.pinColor = MKPinAnnotationColorPurple;
//        }
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"%@", userLocation.location);
}

#pragma LocateAndDownload Delegate

- (void)locateSelfFinishedWithCood:(CLLocationCoordinate2D)coordinate {
    _startPointTextField.text = @"现在的位置";
}




//提交信息
- (IBAction)commit:(id)sender {
    NSString *startString = _startPointTextField.text;  //出发地
    NSString *targetString = _targetPointTextField.text;    //目的地
    //出发地和目的地坐标
    NSNumber *startLat = [NSNumber numberWithDouble:_startCoordinate.latitude];
    NSNumber *startLon = [NSNumber numberWithDouble:_startCoordinate.longitude];
    NSNumber *targetLat = [NSNumber numberWithDouble:_targetCoordinate.latitude];
    NSNumber *targetLon = [NSNumber numberWithDouble:_targetCoordinate.longitude];
    if ([startString isEqualToString:@""] || [targetString isEqualToString:@""] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"不能生成订单" message:@"请完善必要的信息" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else {
        NSString *order = [NSString stringWithFormat:@"您的出发地为：%@\n您的目的地为：%@", startString, targetString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"生成订单" message:order delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"提交！", nil];
        [alert show];
        [alert release];
    }
}

//清空当前输入的订单数据
//- (void)clear {
//    _startPointTextField.text = @"";
//    _targetPointTextField.text = @"";
//    _telTextField.text = @"";
//    [_companyButton setTitle:@"出租公司选择" forState:UIControlStateNormal];
//    _locationTypeSwitch.selectedSegmentIndex = 0;
//    _mapStyleSwitch.selectedSegmentIndex = 0;
//    _searchBar.text = @"";
//    _searchBar.hidden = YES;
//    [self removeAnnotations];
////    [_mapView removeAnnotations:_mapView.annotations];
//}

//#pragma mark - Alert Delegate
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        NSString *startString = _startPointTextField.text;  //出发地
//        NSString *targetString = _targetPointTextField.text;    //目的地
//        NSString *taxiCompany = _companyButton.titleLabel.text;
//        
//        /*
//        NSString *userTel = _telTextField.text; //电话
//        //出发地和目的地坐标
//        NSNumber *startLat = [NSNumber numberWithDouble:_startCoordinate.latitude];
//        NSNumber *startLon = [NSNumber numberWithDouble:_startCoordinate.longitude];
//        NSNumber *targetLat = [NSNumber numberWithDouble:_targetCoordinate.latitude];
//        NSNumber *targetLon = [NSNumber numberWithDouble:_targetCoordinate.longitude];
//        */
//        NSString *path = [self histroyDataFilePath];
//        NSLog(@"HISTORY:%@", path);
//        NSMutableArray *dataArray = [[NSMutableArray arrayWithContentsOfFile:[self histroyDataFilePath]] retain];
//        if (!dataArray) {
//            dataArray = [[NSMutableArray alloc] initWithCapacity:1];
//        }
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:startString, @"Start", targetString, @"Target", taxiCompany, @"Company", nil];
//        [dataArray addObject:dic];
//        [dataArray writeToFile:[self histroyDataFilePath] atomically:YES];
//        [dataArray release];
//        //清空当前数据
//        [self clear];
//    }
//}


@end
