//
//  TaxiCompanyTableCell.h
//  iTaxi
//
//  Created by 卞中杰 on 11-6-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaxiCompanyTableCell : UITableViewCell {
    UILabel *_titleLabel;   //出租公司名label
    UILabel *_telephoneLabel;   //电话label
    UIImageView *_icon;
}
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *telephoneLabel;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@end
