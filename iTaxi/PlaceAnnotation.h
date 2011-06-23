//
//  PlaceAnnotation.h
//  ekkk
//
//  Created by 卞中杰 on 11-6-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKAnnotation.h>

@interface PlaceAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *_title;
    NSString *_subtitle;
    NSString *_address;    //google根据coordinate提供的坐标位置返回的具体的地址信息
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *address; 
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@end
