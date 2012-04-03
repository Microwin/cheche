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

@end

@implementation MainViewController(private)





@end

@implementation MainViewController

@synthesize startPointTextField = _startPointTextField;
@synthesize targetPointTextField = _targetPointTextField;
@synthesize telTextField = _telTextField;
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





- (id)init
{
    self = [super init];
    if (self) {        

    }
    return self;
}

- (void)initUIElement
{
    UIImage *img = [UIImage imageNamed:@"background.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [self.view addSubview:imgView];
    
    img = [UIImage imageNamed:@"change_btn01.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"请选择出租车公司" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(7, 287, 313, 47);
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    img = [UIImage imageNamed:@"change_btn02.png"];
    [btn setBackgroundImage:img forState:UIControlStateHighlighted];
    [self.view addSubview:btn];
    
    img = [UIImage imageNamed:@"send_btn01.png"];
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(59, 350, 202, 49);
    [btn2 setBackgroundImage:img forState:UIControlStateNormal];
    img = [UIImage imageNamed:@"send_btn02.png"];
    [btn2 setBackgroundImage:img forState:UIControlStateHighlighted];
    [btn2 addTarget:self action:@selector(commit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    img = [UIImage imageNamed:@"map_btn.png"];
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(0, 412, 320, 48);
    [btn3 setBackgroundImage:img forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    _targetPointTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 164, 197, 31)];
    _targetPointTextField.placeholder = @"请在地图上选择或输入";
    _targetPointTextField.borderStyle = UITextBorderStyleNone;
    _targetPointTextField.delegate = self;
    [self.view addSubview:_targetPointTextField];
    
    _startPointTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 114, 197, 31)];
    _startPointTextField.placeholder = @"请在地图上选择或输入";
    _startPointTextField.borderStyle = UITextBorderStyleNone;
    _startPointTextField.delegate = self;
    [self.view addSubview:_startPointTextField];
    
    _telTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 212, 197, 31)];
    _telTextField.placeholder = @"调度中心将以此与您联系";
    _telTextField.borderStyle = UITextBorderStyleNone;
    _telTextField.delegate = self;
    [self.view addSubview:_telTextField];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUIElement];
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
    [_companyButton release];
    [super dealloc];
}






#pragma mark - Selectors

- (void)closeKeyboard:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        [self.view removeGestureRecognizer:(UITapGestureRecognizer *)sender];
    }
    if ([_targetPointTextField isFirstResponder]) {
        [_targetPointTextField resignFirstResponder];
    }
    if ([_startPointTextField isFirstResponder]) {
        [_startPointTextField resignFirstResponder];
    }
    if ([_telTextField isFirstResponder]) {
        [_telTextField resignFirstResponder];
    }
}

- (void)showMap:(id)sender
{
    _mapViewController = [[MapViewController alloc] init];
    _mapViewController.delegate = self;
    _mapViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentModalViewController:_mapViewController animated:YES];
}

//- (IBAction)closeKeyboard:(id)sender {
//    [_startPointTextField resignFirstResponder];
//    [_targetPointTextField resignFirstResponder];
//    [_telTextField resignFirstResponder];
//    [_searchBar resignFirstResponder];
//}

- (IBAction)companyButtonPressed:(id)sender {
    TaxiCompanyViewController *companyViewController = [[TaxiCompanyViewController alloc] initWithStyle:UITableViewStylePlain];
    companyViewController.delegate = self;
    [self presentModalViewController:companyViewController animated:YES];
    [companyViewController release];
}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITapGestureRecognizer *reg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    [self.view addGestureRecognizer:reg];
    [reg release];
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



#pragma LocateAndDownload Delegate

- (void)locateSelfFinishedWithCood:(CLLocationCoordinate2D)coordinate {
    _startPointTextField.text = @"现在的位置";
}




//提交信息
- (void)commit:(id)sender {
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

#pragma mark - Map Delegate
- (void)setTargetLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coor
{
    _targetPointTextField.text = location;
    _targetCoordinate = coor;
}

- (void)setStartLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coor
{
    _startPointTextField.text = location;
    _startCoordinate = coor;
}

@end
