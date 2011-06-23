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

@implementation MainViewController

@synthesize startPoint = _startPoint;
@synthesize targetPoint = _targetPoint;
@synthesize searchBar = _searchBar;
@synthesize mapView = _mapView;
@synthesize mapStyleSwitch = _mapStyleSwitch;
@synthesize locationTypeSwitch = _locationTypeSwitch;
@synthesize searchString = _searchString;

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
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotation:anno];
        }

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
    [_startPoint release];
    [_targetPoint release];
    [_searchBar release];
    [_mapView release];
    [_mapStyleSwitch release];
    [_locationTypeSwitch release];
    [super dealloc];
}



#pragma mark - UISearchBar Delegate

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

}

#pragma mark - ASIHttpRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{

    if (!_searchBar.hidden) {
        [self.mapView removeAnnotations:self.mapView.annotations];
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

- (IBAction)searchButtonPressed:(id)sender {
    _searchBar.hidden = !_searchBar.hidden;
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

#pragma mark - Map Delegate
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    kSelectedAnnotation = view.annotation;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Place Selection", @"Place Selection") message:NSLocalizedString(@"Are you sure about the place?", @"Are You Sure About The Place?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//    [alert show];
//    [alert release];
    if (_locationTypeSwitch.selectedSegmentIndex == 0) {
        _startPoint.text = ((PlaceAnnotation *)view.annotation).address;
    }
    else
        _targetPoint.text = ((PlaceAnnotation *)view.annotation).address;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        pinView = [[[MKPinAnnotationView alloc]
                    initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        
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

#pragma LocateAndDownload Delegate

- (void)locateSelfFinishedWithCood:(CLLocationCoordinate2D)coordinate {
    _startPoint.text = @"现在的位置";
}

- (IBAction)closeKeyboard:(id)sender {
    _searchBar.hidden = YES;
    [_startPoint resignFirstResponder];
    [_targetPoint resignFirstResponder];
    [_searchBar resignFirstResponder];
}


//提交信息
- (IBAction)commit:(id)sender {
    
}
@end
