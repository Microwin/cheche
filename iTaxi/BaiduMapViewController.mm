//
//  BaiduMapViewController.m
//  iTaxi
//
//  Created by 卞 中杰 on 12-3-2.
//  Copyright (c) 2012年 淘米. All rights reserved.
//

#import "BaiduMapViewController.h"

@implementation BaiduMapViewController



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    BMKMapView *mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.view = mapView;
    [mapView setMapType:BMKMapTypeTraffic];
    mapView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - baidu map delegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *view = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Identifier"] autorelease];
        view.pinColor = BMKPinAnnotationColorRed;
        view.animatesDrop = YES;
        return view;
    }
    else
        return nil;
}


@end
