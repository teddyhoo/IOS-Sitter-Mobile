//
//  DistanceMatrix.h
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 12/23/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LocationShareModel.h"
#import "VisitsAndTracking.h"

@interface DistanceMatrix : NSObject

-(instancetype)initWithVisitData:(NSMutableArray *)visitData;

@property (nonatomic,strong) NSMutableArray *visitLocations;
@property (nonatomic,strong) NSMutableArray *optimizedVisitLocations;
@property (nonatomic,strong) NSMutableDictionary *visitLocationsDic;

@property (nonatomic,strong) NSMutableArray *stopMatrix;
@property (nonatomic,strong) NSMutableDictionary *stopMatrixDic;
@property (nonatomic,copy) NSString *sitterName;
@property int totalNumCoordinates;
@property (nonatomic,strong) VisitsAndTracking *sharedInstance;
@property CLLocationCoordinate2D sitterAddress;
@property float total_distance;
@property float total_time;

@end
