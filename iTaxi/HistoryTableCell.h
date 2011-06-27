//
//  HistroyTableCell.h
//  iTaxi
//
//  Created by 卞中杰 on 11-6-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HistoryTableCell : UITableViewCell {
    UILabel *_startPositon;
    UILabel *_targetPosition;
    UILabel *_companyName;
    UILabel *_date;
}
@property (nonatomic, retain) IBOutlet UILabel *startPosition;
@property (nonatomic, retain) IBOutlet UILabel *targetPosition;
@property (nonatomic, retain) IBOutlet UILabel *companyName;
@property (nonatomic, retain) IBOutlet UILabel *date;
@end
