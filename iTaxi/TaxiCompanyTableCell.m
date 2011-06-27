//
//  TaxiCompanyTableCell.m
//  iTaxi
//
//  Created by 卞中杰 on 11-6-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TaxiCompanyTableCell.h"


@implementation TaxiCompanyTableCell
@synthesize titleLabel = _titleLabel;
@synthesize telephoneLabel = _telephoneLabel;
@synthesize icon = _icon;

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
    [_titleLabel release];
    [_telephoneLabel release];
    [_icon release];
    [super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
