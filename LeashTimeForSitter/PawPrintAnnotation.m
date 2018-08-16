//
//  PawPrintAnnotation.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/7/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "PawPrintAnnotation.h"
#import "UIImage+Resize.h"

@implementation PawPrintAnnotation

-(id)initWithLocation:(CLLocationCoordinate2D)coord andTagID:(NSString*)tagID {
    self = [super init];
    if (self) {
        self.coordinate = coord;
        self.tagID = tagID;
        
        if([tagID isEqualToString:@"100"]) {
            _imageForAnnotation = [UIImage imageNamed:@"paw-red-100"];
        }
        else if ([tagID isEqualToString:@"101"]) {
            _imageForAnnotation = [UIImage imageNamed:@"paw-lime-100"];
        }
        else if ([tagID isEqualToString:@"102"]) {
            _imageForAnnotation = [UIImage imageNamed:@"paw-purple-100"];
        }
        else if ([tagID isEqualToString:@"103"]) {
            _imageForAnnotation = [UIImage imageNamed:@"paw-dark-blue-100"];
        }
        else if ([tagID isEqualToString:@"104"]) {
            _imageForAnnotation = [UIImage imageNamed:@"paw-orange-100"];
        }
        else if ([tagID isEqualToString:@"105"]) {
            _imageForAnnotation = [UIImage imageNamed:@"paw-pine-100"];
            
        } else if ([tagID isEqualToString:@"visitLocation"]) {
            
            _imageForAnnotation = [UIImage imageNamed:@"dog-silhoutette"];
            
            
        }
    }
    return self;
}


-(MKAnnotationView *)annotationView:(NSString*)currentTagID {
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:@"PawPrintAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    if([currentTagID isEqualToString:@"100"]) {
        annotationView.image = [[UIImage imageNamed:@"paw-red-100"] resizedImageToFitInSize:CGSizeMake(15, 15) scaleIfSmaller:YES];
    }
    else if ([currentTagID isEqualToString:@"101"]) {
        annotationView.image = [[UIImage imageNamed:@"paw-lime-100"] resizedImageToFitInSize:CGSizeMake(15, 15) scaleIfSmaller:YES];
    }
    else if ([currentTagID isEqualToString:@"102"]) {
        annotationView.image = [[UIImage imageNamed:@"paw-purple-100"] resizedImageToFitInSize:CGSizeMake(15, 15) scaleIfSmaller:YES];
    }
    else if ([currentTagID isEqualToString:@"103"]) {
        annotationView.image = [[UIImage imageNamed:@"paw-dark-blue-100"] resizedImageToFitInSize:CGSizeMake(15, 15) scaleIfSmaller:YES];
    }
    else if ([currentTagID isEqualToString:@"104"]) {
        annotationView.image = [[UIImage imageNamed:@"paw-orange-100"] resizedImageToFitInSize:CGSizeMake(15, 15) scaleIfSmaller:YES];
    }
    else if ([currentTagID isEqualToString:@"105"]) {
        annotationView.image = [[UIImage imageNamed:@"paw-pine-100"] resizedImageToFitInSize:CGSizeMake(15, 15) scaleIfSmaller:YES];
        
    } else if ([currentTagID isEqualToString:@"visitLocation"]) {
        annotationView.image = [[UIImage imageNamed:@"dog-silhoutette"] resizedImageToFitInSize:CGSizeMake(15, 15) scaleIfSmaller:YES];

        
    }
    return annotationView;
    
}
@end
