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

//@property (nonatomic,weak) NSMutableArray *visitLocations;
//@property (nonatomic,weak) NSMutableArray *optimizedVisitLocations;
//@property (nonatomic,weak) NSMutableDictionary *visitLocationsDic;

//@property (nonatomic,weak) NSMutableArray *stopMatrix;
//@property (nonatomic,weak) NSMutableDictionary *stopMatrixDic;
//@property (nonatomic,weak) NSString *sitterName;
//@property int totalNumCoordinates;
//@property (nonatomic,weak) VisitsAndTracking *sharedInstance;
//@property CLLocationCoordinate2D sitterAddress;
//@property float total_distance;
//@property float total_time;

@end
