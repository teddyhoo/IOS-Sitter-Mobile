//
//  PawPrintAnnotationView.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/7/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "PawPrintAnnotationView.h"

@implementation PawPrintAnnotationView

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.frame = CGRectMake(0,0, 30, 30);
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        _annotationImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        //_annotationImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.annotationImage];
        
    }
    return self;
}


@end
