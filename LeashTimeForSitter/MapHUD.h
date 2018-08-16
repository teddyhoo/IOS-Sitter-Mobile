//
//  MapHUD.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/10/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitsAndTracking.h"

@class MapHUD;
@protocol MapHUDDelegate <NSObject>

@optional
-(void)drawRoute:(NSString*)routeName;


@end
@interface MapHUD : UIView {
    id <MapHUDDelegate> _delegate;
}

-(void)setDelegate:(id)delegate;
-(void)updateVisitStatus:(NSString *)sequenceID andStatus:(NSString*)status;
-(void)updateVisitDetailInfo:(VisitDetails*)visit;
-(void)removeView;

@end
