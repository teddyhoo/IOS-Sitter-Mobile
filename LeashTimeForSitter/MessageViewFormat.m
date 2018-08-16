//
//  MessageViewFormat.m
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 10/10/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import "MessageViewFormat.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"



@interface MessageViewFormat() {

    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
    VisitsAndTracking *sharedVisits;
    VisitDetails *currentVisit;
    
    
}

@end
@implementation MessageViewFormat

-(id)initWithFrame:(CGRect)frame andVisitID:(NSString*)visitID andCheckMarkCoord:(float)checkPoint {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        sharedVisits = [VisitsAndTracking sharedInstance];
        NSString *theDeviceType = [sharedVisits tellDeviceType];
        self.backgroundColor = [UIColor clearColor];
        for (VisitDetails *visits in sharedVisits.visitData) {
            if ([visits.appointmentid isEqualToString:visitID]) {
                currentVisit = visits;
                
            }
        }
        
        NSString *pListData = [[NSBundle mainBundle]
                               pathForResource:@"/6p-messageview-back-notransparency@3x"
                               ofType:@"png"];
        
        NSString *pListData2 = [[NSBundle mainBundle]
                               pathForResource:@"/doghead-frame@3x"
                               ofType:@"png"];
        
        
		CAShapeLayer *circle = [CAShapeLayer layer];
		UIImageView *backgroundView2;
		UIImageView *petPicFrame;
		UIImageView *petImage;
		UIBezierPath *circularPath;
		UILabel *petName;
		UILabel *serviceName;
		UILabel *timeOfArrival;
		UILabel *timeOfCompletion;
		UIImageView *arrivalButton;
		UIImageView *completedButton;
		
        if ([theDeviceType isEqualToString:@"iPhone6P"]) {
            
            //NSLog(@"is 6p");
            isIphone6P = YES;
            
            backgroundView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
            petPicFrame = [[UIImageView alloc]initWithFrame:CGRectMake(10, 3, 120, 120)];
			petImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7,111,111)];
			circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImage.frame.size.width, petImage.frame.size.height) cornerRadius:MAX(petImage.frame.size.width, petImage.frame.size.height)];
            petName = [[UILabel alloc]initWithFrame:CGRectMake(155, 10, 209, 30)];
            serviceName = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+25, 280, 20)];
            timeOfArrival = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x+20, petName.frame.origin.y+50, 100, 24)];
            timeOfCompletion = [[UILabel alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x+90, timeOfArrival.frame.origin.y, 100, 24)];
            arrivalButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x-20,timeOfArrival.frame.origin.y, 20, 20)];
            completedButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfCompletion.frame.origin.x-20, timeOfCompletion.frame.origin.y, 20, 20)];
            
            

        }
        else if ([theDeviceType isEqualToString:@"iPhone6"]) {
            isIphone6 = YES;
            UIImage *tempImg = [UIImage imageWithContentsOfFile:pListData];
            backgroundView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
            tempImg = nil;
            
            petPicFrame = [[UIImageView alloc]initWithFrame:CGRectMake(10, 3, 120, 120)];
			petImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7,111,111)];
           	circle = [CAShapeLayer layer];
            circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImage.frame.size.width, petImage.frame.size.height) cornerRadius:MAX(petImage.frame.size.width, petImage.frame.size.height)];
			petName = [[UILabel alloc]initWithFrame:CGRectMake(155, 10, 209, 30)];
            serviceName = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+25, 280, 20)];
            timeOfArrival = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x+20, petName.frame.origin.y+50, 100, 24)];
            timeOfCompletion = [[UILabel alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x+100, timeOfArrival.frame.origin.y, 100, 24)];
		 	arrivalButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x-20,timeOfArrival.frame.origin.y, 20, 20)];
			completedButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfCompletion.frame.origin.x-20, timeOfCompletion.frame.origin.y, 20, 20)];

		}
        else if ([theDeviceType isEqualToString:@"iPhone5"]) {
            isIphone5 = YES;
            UIImage *tempImg = [UIImage imageWithContentsOfFile:pListData];
	   		backgroundView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
            tempImg = nil;
            petPicFrame = [[UIImageView alloc]initWithFrame:CGRectMake(10, 3, 80, 80)];
			petImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7,72,72)];
            circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImage.frame.size.width, petImage.frame.size.height) cornerRadius:MAX(petImage.frame.size.width, petImage.frame.size.height)];
            petName = [[UILabel alloc]initWithFrame:CGRectMake(125, 5, 209, 18)];
            serviceName = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y + 20, 280,18)];
            timeOfArrival = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x+20, petName.frame.origin.y+36, 100, 24)];
            timeOfCompletion = [[UILabel alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x+100, timeOfArrival.frame.origin.y, 100, 24)];

		 	arrivalButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x-20,timeOfArrival.frame.origin.y, 16, 16)];
		 	completedButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfCompletion.frame.origin.x-20, timeOfCompletion.frame.origin.y, 16, 16)];
	
        }
        else if ([theDeviceType isEqualToString:@"iPhone4"]) {
            isIphone4 = YES;
            UIImage *tempImg = [UIImage imageWithContentsOfFile:pListData];
            backgroundView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
            tempImg = nil;
            
            petPicFrame = [[UIImageView alloc]initWithFrame:CGRectMake(10, 3, 90, 90)];
 			petImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7,81,81)];
            circle = [CAShapeLayer layer];
            circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImage.frame.size.width, petImage.frame.size.height) cornerRadius:MAX(petImage.frame.size.width, petImage.frame.size.height)];
			petName = [[UILabel alloc]initWithFrame:CGRectMake(125, 10, 209, 30)];
            serviceName = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+25, 280, 20)];
            timeOfArrival = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x+20, petName.frame.origin.y+50, 100, 24)];
            timeOfCompletion = [[UILabel alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x+100, timeOfArrival.frame.origin.y, 100, 24)];
			arrivalButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfArrival.frame.origin.x-20,timeOfArrival.frame.origin.y, 20, 20)];
            completedButton = [[UIImageView alloc]initWithFrame:CGRectMake(timeOfCompletion.frame.origin.x-20, timeOfCompletion.frame.origin.y, 20, 20)];
        }
		
		
		[backgroundView2 setImage:[UIImage imageWithContentsOfFile:pListData]];
		[self addSubview:backgroundView2];
		[petPicFrame setImage:[UIImage imageNamed:@"doghead-frame"]];
		[petPicFrame setImage:[UIImage imageWithContentsOfFile:pListData2]];
		[self addSubview:petPicFrame];
		[petImage setImage:currentVisit.currentPetImage];
		[self addSubview:petImage];
		
		circle.path = circularPath.CGPath;
		circle.fillColor = [UIColor blackColor].CGColor;
		circle.strokeColor = [UIColor blackColor].CGColor;
		circle.lineWidth = 0;
		petImage.layer.mask=circle;
		
		[petName setFont:[UIFont fontWithName:@"CompassRoseCPC-Bold" size:18]];
		[serviceName setFont:[UIFont fontWithName:@"CompassRoseCPC-Bold" size:16]];
		[timeOfArrival setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];
		[timeOfCompletion setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];
		
		[petName setText:currentVisit.petName];
		[petName setTextColor:[UIColor blackColor]];
		[serviceName setText:currentVisit.service];
		[arrivalButton setImage:[UIImage imageNamed:@"yellow-arrive"]];
		[completedButton setImage:[UIImage imageNamed:@"white-checkmark-noback"]];
		
		[self addSubview:petName];
		[self addSubview:serviceName];
		[self addSubview:timeOfArrival];
		[self addSubview:timeOfCompletion];
		[self addSubview:arrivalButton];
		[self addSubview:completedButton];
		
		NSTimeZone *timeZone = [NSTimeZone localTimeZone];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
		[dateFormatter setTimeZone:timeZone];
		[dateFormatter setDateFormat:@"HH:mm"];
		
		
		NSDateFormatter *dateTimeMarkArriveFormat = [[NSDateFormatter alloc]init];
		[dateTimeMarkArriveFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
		
		NSDate *arriveDateTime = [dateTimeMarkArriveFormat dateFromString:currentVisit.dateTimeMarkArrive];
		NSString *arriveTimeString = [dateFormatter stringFromDate:arriveDateTime];

		NSDate *completeDateTime = [dateTimeMarkArriveFormat dateFromString:currentVisit.dateTimeMarkComplete];
		NSString *completeTimeString = [dateFormatter stringFromDate:completeDateTime];
		
		if (currentVisit.dateTimeMarkArrive != NULL) {
			[timeOfArrival setText:arriveTimeString];
		} else {
			[timeOfArrival setText:@"Not started"];
		}
		
		if (currentVisit.dateTimeMarkComplete != NULL) {
			[timeOfCompletion setText:completeTimeString];
		} else {
			[timeOfCompletion setText:@"Incomplete"];
		}

		[timeOfCompletion setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];
        
    }
    
    return self;
}
@end
