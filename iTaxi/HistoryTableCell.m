//
//  HistroyTableCell.m
//  iTaxi
//
//  Created by 卞中杰 on 11-6-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HistoryTableCell.h"


@implementation HistoryTableCell
@synthesize startPosition = _startPositon;
@synthesize targetPosition = _targetPosition;
@synthesize companyName = _companyName;
@synthesize date = _date;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_startPositon release];
    [_targetPosition release];
    [_companyName release];
    [_date release];
    [super dealloc];
}

@end
