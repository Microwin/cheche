//
//  HistroyTableCell.h
//  iTaxi
//
//  Created by 卞中杰 on 11-6-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HistoryTableCell : UITableViewCell {
    UILabel *_locationLati;
    UILabel *_locationLong;
    UILabel *_address;
    UILabel *_date;
}
@property (nonatomic, retain) IBOutlet UILabel *locationLati;
@property (nonatomic, retain) IBOutlet UILabel *locationLong;
@property (nonatomic, retain) IBOutlet UILabel *address;
@property (nonatomic, retain) IBOutlet UILabel *date;
@end
