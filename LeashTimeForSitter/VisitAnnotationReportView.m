//
//  VisitAnnotationReportView.m
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 8/28/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import "VisitAnnotationReportView.h"

@implementation VisitAnnotationReportView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        CGRect  viewRect = CGRectMake(0, 0, 32, 64);
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:viewRect];
        
        //imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _imageView = imageView;
        
        [self addSubview:imageView];
    }
    return self;
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.frame = CGRectMake(0,0, 30,30);
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
    }
    return self;
}



- (void)setImage:(UIImage *)image
{
    // when an image is set for the annotation view,
    // it actually adds the image to the image view
    _imageView.image = image;
}



@end
