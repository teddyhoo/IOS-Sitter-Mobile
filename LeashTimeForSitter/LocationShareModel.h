//
//  LocationShareModel.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"
#import <CoreLocation/CoreLocation.h>
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface LocationShareModel : NSObject
//@property (nonatomic) BackgroundTaskManager * bgTask;

@property (nonatomic) CLLocationCoordinate2D lastValidLocation;
@property (nonatomic) CLLocation *validLocationLast;
@property (nonatomic) NSMutableArray *allCoordinates;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer * delay10Seconds;

@property (nonatomic) NSString *lastSendTimeStamp;
@property (nonatomic) NSString *lastSendNumCoordinates;
@property BOOL turnOffGPSTracking;


+(id)sharedModel;
@end
