//
//  VisitAnnotation.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 12/17/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "VisitAnnotation.h"

@implementation VisitAnnotation

-(id)initWithLocation:(CLLocationCoordinate2D)coord withTitle:(NSString *)title andSubtitle:(NSString *)subtitle{
    
    self = [super init];
    if(self) {
        
        self.coordinate = coord;
        self.title = title;
        self.subtitle = subtitle;
        
    }
    
    return self;
    
}
@end
