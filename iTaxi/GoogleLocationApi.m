//
//  GoogleLocationApi.m
//  iTaxi
//
//  Created by 卞中杰 on 11-6-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GoogleLocationApi.h"


@implementation GoogleLocationApi
static NSString *kGoogleGeoApi = @"http://maps.google.com/maps/api/geocode/json?address=";
static NSString *kGoogleDecApi = @"http://maps.google.com/maps/api/geocode/json?latlng=";

- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
																		   (CFStringRef)string, 
																		   NULL, 
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}

@end
