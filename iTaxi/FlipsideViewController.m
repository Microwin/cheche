//
//  FlipsideViewController.m
//  iTaxi
//
//  Created by Wu Jianjun on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "HistoryTableCell.h"
#define kDataFile @"Data.plist"

@implementation FlipsideViewController

@synthesize delegate=_delegate;
@synthesize tableView = _tableView;

- (NSString *)histroyDataFilePath {
    NSString *p = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kDataFile];
    return p;
}

- (void)dealloc
{
    [_dataArray release];
    [_tableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];  
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _dataArray = [[NSArray arrayWithContentsOfFile:[self histroyDataFilePath]] retain];
    self.tableView.rowHeight = 100;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        static NSString *CellIdentifier = @"Cell";
        
        HistoryTableCell *cell = (HistoryTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            //        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HistoryTableCell" owner:self options:nil];
            HistoryTableCell *temp = [array objectAtIndex:0];
            if ([temp isKindOfClass:[HistoryTableCell class]]) {
                cell = temp;
            }
        }
        
        // Configure the cell...
//        cell.titleLabel.text = [[_companyArray objectAtIndex:indexPath.row] valueForKey:@"Name"];
//        cell.telephoneLabel.text = [[_companyArray objectAtIndex:indexPath.row] valueForKey:@"Telephone"];
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
    cell.startPosition.text = [dic valueForKey:@"Start"];
    cell.targetPosition.text = [dic valueForKey:@"Target"];
    cell.companyName.text = [dic valueForKey:@"Company"];
    return cell;

}
@end
