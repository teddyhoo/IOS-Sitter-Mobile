//
//  PawPrintAnnotation.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/7/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PawPrintAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *tagID;
@property (nonatomic,strong) UIImage *imageForAnnotation;

-(id)initWithLocation:(CLLocationCoordinate2D)coord
             andTagID:(NSString*) tagID;

@end
