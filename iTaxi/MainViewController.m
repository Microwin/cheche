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

- (void)mapLongPressed:(UILongPressGestureRecognizer *)touch {
    if (_locationTypeSwitch.selectedSegmentIndex == 1) {
        return;
    }
    CGPoint touchPoint = [touch locationInView:_mapView];
    PlaceAnnotation *anno = [[PlaceAnnotation alloc] init];
    anno.title = NSLocalizedString(@"User Selected Place", @"User Selected Place");
    anno.subtitle = @"";
    anno.coordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotation:anno];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)itemDataFilePath {
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"google.plist"];
    NSLog(@"%@", storeURL);
    return storeURL;
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
            anno.address = [[[dic valueForKey:@"address_components"] objectAtIndex:1] valueForKey:@"long_name"];
            NSDictionary *loc = [[dic valueForKey:@"geometry"] valueForKey:@"location"];
            anno.coordinate = CLLocationCoordinate2DMake([[loc valueForKey:@"lat"] doubleValue], [[loc valueForKey:@"lng"] doubleValue]);
            [_mapView addAnnotation:anno];
            [anno release];
        }
    }
    
    
    
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

#pragma LocateAndDownload Delegate

- (void)locateSelfFinishedWithCood:(CLLocationCoordinate2D)coordinate {
    
}

@end
