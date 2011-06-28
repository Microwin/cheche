//
//  FlipsideViewController.h
//  iTaxi
//
//  Created by Wu Jianjun on 11-6-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *_dataArray; //历史记录数据
    UIBarButtonItem *_editBtn;  //删除按键
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editBtn;
- (IBAction)done:(id)sender;
- (IBAction)editMode:(id)sender;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end
