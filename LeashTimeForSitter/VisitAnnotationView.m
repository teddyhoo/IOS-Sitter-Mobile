//
//  VisitAnnotationView.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 12/17/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "VisitAnnotationView.h"
#import "VisitAnnotation.h"

@implementation VisitAnnotationView


- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {

        CGRect  viewRect = CGRectMake(0, 0, 32, 32);
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:viewRect];

        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView = imageView;
        
        [self addSubview:imageView];
    }
    return self;
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if(self) {
        
        VisitAnnotation *visitAnnotation = self.annotation;
        
        switch (visitAnnotation.typeOfAnnotation) {
                
            case VisitDefault:
                [self setImage:[UIImage imageNamed:@"location-icon"]];
                break;
            case SitterLocation:
                [self setImage:[UIImage imageNamed:@"location-icon"]];
                break;
            case ClientLocation:
                [self setImage:[UIImage imageNamed:@"location-icon"]];
                break;
            case VetLocation:
                [self setImage:[UIImage imageNamed:@"location-icon"]];
                break;
            case OfficeLocation:
                [self setImage:[UIImage imageNamed:@"location-icon"]];
                break;
            case KeyEchangeLocation:
                [self setImage:[UIImage imageNamed:@"location-icon"]];
                break;
            default:
                [self setImage:[UIImage imageNamed:@"location-icon"]];
                break;
        }
        
    }
    return self;
}



- (void)setImage:(UIImage *)image
{
    // when an image is set for the annotation view,
    // it actually adds the image to the image view
    //NSLog(@"setting annotation image view");
    _imageView.image = image;
}

@end
