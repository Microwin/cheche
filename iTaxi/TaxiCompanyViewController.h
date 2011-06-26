//
//  TaxiCompanyViewController.h
//  iTaxi
//
//  Created by 卞中杰 on 11-6-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CompanySelectDelegate <NSObject>

- (void)companySelected:(NSString *)name;

@end
@interface TaxiCompanyViewController : UITableViewController {
    NSArray *_companyArray;
    id <CompanySelectDelegate> delegate;
}
@property (nonatomic, assign) id <CompanySelectDelegate> delegate;

@end
