//
//  VisitProgressMapView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 4/27/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "VisitDetails.h"

NS_ASSUME_NONNULL_BEGIN

@interface VisitProgressMapView : UIView <MKMapViewDelegate>


-(void)addVisitInfo:(VisitDetails*)visitInfo;
-(void)removeDelegate;
-(void)drivingDirections:(id)sender;

@end

NS_ASSUME_NONNULL_END
