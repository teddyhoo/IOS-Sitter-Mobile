//
//  VisitAnnotation.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 12/17/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <MapKit/MapKit.h>


typedef NS_ENUM(NSUInteger, RouteType) {
    VisitDefault = 0,
    SitterLocation,
    ClientLocation,
    VetLocation,
    OfficeLocation,
    KeyEchangeLocation,
    Other
};

@interface VisitAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *sequenceID;
@property (nonatomic,copy) NSString *petName;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *finishTime;
@property (nonatomic,copy) NSString *type;
@property (nonatomic) RouteType typeOfAnnotation;


-(id)initWithLocation:(CLLocationCoordinate2D)coord withTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end
