//
//  DetailsMapView.h
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 12/8/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VisitsAndTracking.h"
#import "LocationShareModel.h"

@interface DetailsMapView : UIView <MKMapViewDelegate>

@property BOOL onScreen;
@property (nonatomic,strong) MKMapView* myMapView;

-(instancetype)initWithClientLocation:(CLLocationCoordinate2D)clientLoc
                          vetLocation:(CLLocationCoordinate2D)vetLoc
                            withFrame:(CGRect)frame;

-(void)cleanDetailMapView;

@end
