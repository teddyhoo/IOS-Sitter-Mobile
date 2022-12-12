//
//  VisitTableCell.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/25/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "VisitTableCell.h"
#import "VisitsAndTracking.h"
#import "PharmaStyle.h"
#import "DataClient.h"
#import "VisitDetails.h"
#import "ClientListViewController.h"
#import <tgmath.h>
#import "PetProfile.h"

@interface VisitTableCell () {

    DataClient *currentClient;
    ClientListViewController  *parentView;
    VisitDetails *visitInfo;
    UIView *backgroundIV;
    UILabel *petName;
	UILabel *clientName;
	UILabel *serviceName;
    UILabel *timerForVisitLabel;
    UILabel *sentVisitReportTime;
    
    UIButton *petImageDeck;
    UIImageView *petProfilePic;
    UIButton *managerVisitNote;
    UIButton *statusButton;
    
    NSMutableArray *multiPetImages;
    NSMutableDictionary *colorPalette;
    NSMutableArray *petIDs;

    NSTimer *stopWatchTimer;
	NSDateFormatter *arriveCompleteConvertTimeFormat;
	NSDateFormatter *completeTimeFormat;
	NSDateFormatter *fullDate;
	NSDateFormatter *timerFormat;
    NSDateFormatter *noAMPM;
    
    BOOL isLargeText;
}

@end

@implementation VisitTableCell

VisitsAndTracking *sharedVisits;
CGSize cellSize;

-(instancetype) initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                      andSize:(CGSize)theCellSize
         parentViewController:(ClientListViewController*)parent {
    
    
    cellSize = CGSizeMake(theCellSize.width,  theCellSize.height);
    parentView = parent;    
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

-(instancetype) initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        sharedVisits = [VisitsAndTracking sharedInstance];
        colorPalette = [sharedVisits getColorPalette];
        backgroundIV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
		[self.contentView addSubview:backgroundIV];
        completeTimeFormat  =[[NSDateFormatter alloc]init];
        [completeTimeFormat setDateFormat:@"h:mm a"];
        fullDate = [[NSDateFormatter alloc]init];
        [fullDate setDateFormat:@"HH:mm:ss MMM dd yyyy"];
        timerFormat = [[NSDateFormatter alloc]init];
        [timerFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
         isLargeText = NO;
    }
    return self;
}

-(void) startVisitTimer {
	if (sharedVisits.showTimer) {
        arriveCompleteConvertTimeFormat  =[[NSDateFormatter alloc]init];
        [arriveCompleteConvertTimeFormat setDateFormat:@"h:mm a"];
        noAMPM = [[NSDateFormatter alloc]init];
        [noAMPM setDateFormat:@"h:mm"];
        
        if (!stopWatchTimer.isValid && timerForVisitLabel == nil) {
            timerForVisitLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 54, 100, 21)];
            [timerForVisitLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
			[timerForVisitLabel setTextColor:[colorPalette objectForKey:@"dangerDark"]];
            [timerForVisitLabel setTextAlignment:NSTextAlignmentRight];
			[timerForVisitLabel setText:@"00:00"];
            [backgroundIV addSubview:timerForVisitLabel];

			stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
															  target:self
															selector:@selector(updateTimer)
															userInfo:nil
															 repeats:YES];
            }
	}
}
-(void) updateTimer {    
    //NSLog(@"Visit cell -- > UPDATE visit timer");
	NSDate *currentDate = [NSDate date];
    NSString *dateTimeString = visitInfo.arrived;
    //NSLog(@"VISIT DATA INFO DATE TIME MARK ARRIVE: %@", dateTimeString);
	NSDate *timerBeginDate = [timerFormat dateFromString:dateTimeString];
	NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:timerBeginDate];
	int seconds = (int)timeInterval;
	int minutes;
	int hours;
	NSString *displayTextTimer;
	
	if (seconds >= 60) {
		int local_seconds = seconds % 60;
		minutes = seconds / 60;
		if (minutes > 59) {
			hours = minutes / 60;
			minutes = hours % 60;
			seconds = minutes%60;
            if (minutes < 10) {
                if (local_seconds < 10) {
                    displayTextTimer = [NSString stringWithFormat:@"%i:0%i:0%i",hours,minutes, local_seconds];
                } else  {
                    displayTextTimer = [NSString stringWithFormat:@"%i:0%i:%i",hours,minutes, local_seconds];
                }
            } else {
                displayTextTimer = [NSString stringWithFormat:@"%i:0%i:%i",hours,minutes, local_seconds];
            }
        } else {
            if (local_seconds < 10) {
                displayTextTimer = [NSString stringWithFormat:@"%i:0%i",minutes, local_seconds];
            }  else {
                displayTextTimer = [NSString stringWithFormat:@"%i:%i",minutes, local_seconds];
            }
        }
	}  else {
		if (seconds < 10) {
            
			displayTextTimer = [NSString stringWithFormat:@"00:0%i",seconds];
            
		} else {
            
			displayTextTimer = [NSString stringWithFormat:@"00:%i",seconds];

		}
	}
	[timerForVisitLabel setText:displayTextTimer];
}
-(void) stopVisitTimer {
	[timerForVisitLabel setText:@""];

	if (stopWatchTimer.isValid) {
		[stopWatchTimer invalidate];
        stopWatchTimer = nil;
		[timerForVisitLabel removeFromSuperview];
	}
	
	stopWatchTimer = nil;
	timerForVisitLabel = nil;

}

-(void) setBackgroundColorModulus:(int)colorIndex {
    
    int colorModulus = colorIndex % 2;
    
    if (colorModulus == 0) {
        [backgroundIV setBackgroundColor:[colorPalette objectForKey:@"default"]];
    } else {
        [backgroundIV setBackgroundColor:[colorPalette objectForKey:@"defaultDark"]];
    }

    
}
-(void) setVisitDetail:(VisitDetails*)currentVisit withIndexPath:(NSIndexPath*)indexPath {
    NSArray *cellSubviews = [self.contentView subviews];
    for (id sub in cellSubviews) {
        if ([sub isKindOfClass:[UIView class]]) {
            UIView *backSubView = (UIView *) sub;
            NSArray *backSub = [backSubView subviews];
            for (id backSubSub in backSub) {
                if ([backSubSub isKindOfClass:[UILabel class]]) {
                    UILabel *subLabel = (UILabel*) backSubSub;
                    [subLabel removeFromSuperview];
                    subLabel = nil;
                } else if ([backSubSub isKindOfClass:[UIButton class]]) {
                    UIButton *removeButton = (UIButton*)backSubSub;
                    [removeButton removeFromSuperview];
                    removeButton = nil;
                }
            }
            //[backSubView removeFromSuperview];
            //backSubView = nil;
        }
    }
    visitInfo = currentVisit;
    [self setBackgroundColorModulus:(int)indexPath.row];

	int xOffset = 80;
    int rightXOffset = 0;
    int yOffset = 4;
	int fontSizeSmall = 16;
	int fontSizeBig = 20;
	
    
    petName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, backgroundIV.frame.size.width - rightXOffset, 24)];
    clientName = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y + petName.frame.size.height, backgroundIV.frame.size.width - rightXOffset, 24)];
    serviceName = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x, clientName.frame.origin.y + clientName.frame.size.height, backgroundIV.frame.size.width, 24)];

    [petName setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeBig]];
    [clientName setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeBig]];
    [serviceName setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeBig]];
     
    float whiteScale = 0.0;
    UIColor *whiteTextColor = [UIColor colorWithRed:whiteScale green:whiteScale blue:whiteScale alpha:1.0];

    [petName setTextColor:whiteTextColor];
    [clientName setTextColor:whiteTextColor];
    [serviceName setTextColor:whiteTextColor];

    if ([visitInfo.petName length] > 27) {
        petName.frame = CGRectMake(petName.frame.origin.x, petName.frame.origin.y - 4, petName.frame.size.width-18, 35);
        petName.numberOfLines = 2;
        [petName setFont:[UIFont fontWithName:@"Lato-Regular"  size:16]];
    }
    petName.text = visitInfo.petName;
    [clientName setText:visitInfo.clientname];
    
    if ([visitInfo.petName isEqual:[NSNull null]] && [visitInfo.petName length] == 0)  {
		petName.text = @"NO PET NAMES";
	}
    if([visitInfo.clientname isEqual:[NSNull null]] && [visitInfo.clientname length] == 0) {
        [clientName setText:@"NO CLIENT NAME"];
    }
    if ([serviceName.text length] > 32) {
        [serviceName setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeSmall]];
    }

    
    [backgroundIV addSubview:petName];
    [backgroundIV addSubview:clientName];
    [backgroundIV addSubview:serviceName];
    
    [self addTimeWindowAndService:visitInfo forLabel:serviceName];
    [self addPetProfileImagesToVisitCell:currentVisit];

    if(sharedVisits.showFlags) {
        [self addFlagIcon];
    }
    
    if (visitInfo.note != NULL && ![visitInfo.status isEqualToString:@"completed"]) {
        [self addManagerNote];
    }
}

-(void) addFlagIcon {
    
}

-(void) addTimeWindowAndService:(VisitDetails*)visit forLabel:(UILabel*)timeServiceLabel {
    
    NSString *timeString;    
        
    if ([visit.status isEqualToString:@"future"] || [visit.status isEqualToString:@"late"]) {
        if(visit.starttime != NULL && visit.endtime != NULL) {            

            NSDate *timeBegStart = [arriveCompleteConvertTimeFormat dateFromString:visit.starttime];
            NSDate *timeWindowEnd = [arriveCompleteConvertTimeFormat dateFromString:visit.endtime];
            NSString *timeBeginString = [noAMPM stringFromDate:timeBegStart];
            timeString = timeBeginString;
            NSString *timeEndNOAMPM = [noAMPM stringFromDate:timeWindowEnd];
            NSString *begEndTimeString;
            
            if([timeEndNOAMPM isEqualToString:timeString]) {
                begEndTimeString = visit.starttime;
            } else {
                begEndTimeString = [NSString stringWithFormat:@"%@-%@", visit.starttime, visit.endtime];
            }
            
            NSString *serviceAndTimeString = [NSString stringWithFormat:@"%@ (%@)", visit.service, begEndTimeString];
            //NSLog(@"Service time len: %lu",[serviceAndTimeString length]);
            if ([serviceAndTimeString length] > 32) {
                //[timeServiceLabel setAdjustsFontSizeToFitWidth:YES];
                [timeServiceLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
            }
            [timeServiceLabel setText:serviceAndTimeString];
            
        }
    } else if ([visit.status isEqualToString:@"arrived"]) {
        
        NSLog(@"ARRIVED: %@", visit.arrived);
        NSDate *arriveDateTime = [timerFormat dateFromString:visit.arrived];
        NSString *arriveFormat = [completeTimeFormat stringFromDate:arriveDateTime];
        [timeServiceLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
        [timeServiceLabel setText:arriveFormat];
        timerForVisitLabel.frame = CGRectMake(timeServiceLabel.frame.origin.x + timeServiceLabel.frame.size.width, timeServiceLabel.frame.origin.y, 100, 20);

    } else if ([visit.status isEqualToString:@"completed"]) {
        

        NSDate *arriveDateTime = [timerFormat dateFromString:visit.arrived];
        NSDate *completeDateTime = [timerFormat dateFromString:visit.completed];
        NSString *arriveFormat = [completeTimeFormat stringFromDate:arriveDateTime];
        NSString *completeFormat = [completeTimeFormat stringFromDate:completeDateTime];
        NSString *arrCompStr = [NSString stringWithFormat:@"%@ - %@", arriveFormat, completeFormat];
        [timeServiceLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
        [timeServiceLabel setText:arrCompStr];

    }
}

//-(UIButton*) 
-(void) addPetProfileImagesToVisitCell:(VisitDetails*) visit {
    //NSLog(@"PET IMAGE PROFILE ADDED TO CELL FOR CLIENT: %@", visit.clientname);
    petImageDeck = [UIButton buttonWithType:UIButtonTypeCustom];
    petImageDeck.frame = CGRectMake(0,0, cellSize.width, cellSize.height);
    
    UIButton *petPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    petPhotoButton.tag = 0;
    
    for(DataClient *client in sharedVisits.clientData) {

        if ([client.clientID isEqualToString:visitInfo.clientptr]) {        

            currentClient = client;
            NSArray *petProfiles = [currentClient getPetProfiles];
   

            if ([petProfiles count] >0) {

                petPhotoButton.frame = CGRectMake(0,0,125,self.frame.size.height);
                petIDs = [[NSMutableArray alloc]init];
                int petCount = (int)[petProfiles count];
                
                if (petCount > 1) {

                    [petPhotoButton addTarget:self 
                                       action:@selector(nextPetPhoto:) 
                             forControlEvents:UIControlEventTouchUpInside];
                    [petPhotoButton setBackgroundColor:[UIColor clearColor]];
                    
                    petProfilePic = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 66, 66)];
                    [petProfilePic setBackgroundColor:[UIColor lightGrayColor]];
                    PetProfile *firstPet = [petProfiles objectAtIndex:0];
                    UIImage *firstPetImg = [firstPet getProfilePhoto];
                    [petProfilePic setImage:firstPetImg];
                    [petProfilePic setUserInteractionEnabled:NO];
                    [petPhotoButton addSubview:petProfilePic];
                    [self.contentView addSubview:petPhotoButton];
                    
                    CAShapeLayer *circle = [CAShapeLayer layer];
                    
                    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petProfilePic.frame.size.width, petProfilePic.frame.size.height) cornerRadius:MAX(petProfilePic.frame.size.width, petProfilePic.frame.size.height)];
                    circle.path = circularPath.CGPath;
                    circle.fillColor = [UIColor blackColor].CGColor;
                    circle.strokeColor = [UIColor blackColor].CGColor;
                    circle.lineWidth = 2;
                    petProfilePic.layer.mask=circle;
                    [petPhotoButton addSubview:petProfilePic];
                    [self.contentView addSubview:petPhotoButton];
                    
                    CAShapeLayer *circle2 = [CAShapeLayer layer];

                    UIView *backBadge = [[UIView alloc]initWithFrame:CGRectMake(petPhotoButton.frame.size.width - 68, petPhotoButton.frame.size.height - 36,20,20)];
                    [backBadge setBackgroundColor:[UIColor redColor]];
                    
                    UIBezierPath *circularPath2=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, backBadge.frame.size.width, backBadge.frame.size.height) cornerRadius:MAX(backBadge.frame.size.width, backBadge.frame.size.height)];
                    circle2.path = circularPath2.CGPath;
                    circle2.fillColor = [UIColor blackColor].CGColor;
                    circle2.strokeColor = [UIColor blackColor].CGColor;
                    circle2.lineWidth = 0.11;
                    backBadge.layer.mask = circle2;
                    [petPhotoButton addSubview:backBadge];
                    
                    UILabel *multiPetBadge = [[UILabel alloc]initWithFrame:CGRectMake(6,2,16,14)];
                    [multiPetBadge setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
                    [multiPetBadge setTextColor:[UIColor whiteColor]];
                    NSString *countString = [NSString stringWithFormat:@"%i", petCount];
                    [multiPetBadge setText:countString];
                    [backBadge addSubview:multiPetBadge];
                    
                    [UIView animateWithDuration:1.45 delay:1.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        [backBadge setAlpha:0.0];
                    } completion:^(BOOL finished) {
                    
                    }];
                }
               else  if (petCount == 1) {
                   petProfilePic = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 66, 66)];
                   PetProfile *firstPet = [petProfiles objectAtIndex:0];
                   //UIImage *firstPetImg = [firstPet getProfilePhoto];
                   //NSData *postCompressImg =  UIImageJPEGRepresentation(firstPetImg, 100);
                   [petProfilePic setImage:[firstPet getProfilePhoto]];
                   [petProfilePic setUserInteractionEnabled:NO];
                   
                   CAShapeLayer *circle = [CAShapeLayer layer];
                   
                   UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petProfilePic.frame.size.width, petProfilePic.frame.size.height) cornerRadius:MAX(petProfilePic.frame.size.width, petProfilePic.frame.size.height)];
                   circle.path = circularPath.CGPath;
                   circle.fillColor = [UIColor blackColor].CGColor;
                   circle.strokeColor = [UIColor blackColor].CGColor;
                   circle.lineWidth = 2;
                   petProfilePic.layer.mask=circle;
                    [petPhotoButton addSubview:petProfilePic];
                   [self.contentView addSubview:petPhotoButton];
                                      
               }
            }
        }
    }

   //[self layoutSubviews];
}
-(void) closeAllPetViewButton:(id)sender {
    
    NSLog(@"Close all pet view");
    
    if([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *buttonPetView = (UIButton*)sender;
        NSArray *childrenPetImg = buttonPetView.subviews;

        //[buttonPetView removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];

        for(int i = 1; i < [childrenPetImg count]; i++) {
            
            UIImageView *petImg =  (UIImageView*) [childrenPetImg objectAtIndex:i];
            [UIView animateWithDuration:0.1 animations:^{
                petImg.frame = CGRectMake(0, 0, 0, 0);
            } completion:^(BOOL finished) {
                [petImg removeFromSuperview];
            }];
            //[petImg removeFromSuperview];
            
            [petImageDeck removeFromSuperview];
        }
        
    }
    
}

-(void) nextPetPhoto:(id)sender {    
    if ([sender isKindOfClass:[UIButton class]]) {
        int startAnimLocation = 0;
        [petImageDeck addTarget:self 
                         action:@selector(closeAllPetViewButton:) 
               forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:petImageDeck];
        [petImageDeck setBackgroundColor:[UIColor clearColor]];
        
        int numImages = 0;
        NSArray *petProfiles = [currentClient getPetProfiles];
        
        for (PetProfile *petIDKey in petProfiles) {
            int imgSizeX = 66;
            int imgSizeY = 66;
            int xAnim = startAnimLocation + (numImages * imgSizeX) + 4;
            UIImageView *petProfilePic = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, imgSizeX,imgSizeY)];
            [petProfilePic setImage:[petIDKey getProfilePhoto]];
            [petImageDeck addSubview:petProfilePic];
            numImages = numImages + 1;
        
            CAShapeLayer *circle = [CAShapeLayer layer];
            UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petProfilePic.frame.size.width, petProfilePic.frame.size.height) cornerRadius:MAX(petProfilePic.frame.size.width, petProfilePic.frame.size.height)];
            circle.path = circularPath.CGPath;
            circle.fillColor = [UIColor whiteColor].CGColor;
            circle.strokeColor = [UIColor whiteColor].CGColor;
            circle.lineWidth = 1;
            petProfilePic.layer.mask=circle;
            
            [UIView animateWithDuration:0.2 animations:^{
                petProfilePic.frame = CGRectMake(xAnim, petProfilePic.frame.origin.y, petProfilePic.frame.size.width, petProfilePic.frame.size.height);
            } completion:^(BOOL finished) {
            }];
        }
    }
}

-(void) setStatus:(NSString*)visitStatus 
      widthOffset:(int)widthOffset 
         fontSize:(int)fontSize {

    statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    int statButtonSize = 24;
    NSNumber *tagVal =[[[NSNumberFormatter alloc] init] numberFromString:visitInfo.appointmentid];
    statusButton.frame = CGRectMake(backgroundIV.frame.size.width - statButtonSize - 5, backgroundIV.frame.size.height - statButtonSize - 10, statButtonSize, statButtonSize);
    statusButton.tag = [tagVal integerValue];
    
    if ([visitStatus isEqualToString:@"arrived"]) {
        [backgroundIV setBackgroundColor:[colorPalette objectForKey:@"info"]];
        [petName setTextColor:[PharmaStyle colorAppBlack]];
		[serviceName setTextColor:[PharmaStyle colorAppBlack]];
		[clientName setTextColor:[PharmaStyle colorAppBlack]];
        statusButton.frame = CGRectMake(backgroundIV.frame.size.width - statButtonSize - 5, backgroundIV.frame.size.height - statButtonSize - 2, statButtonSize, statButtonSize);
        [statusButton setBackgroundImage:[UIImage imageNamed:@"btnArrive"] 
                                forState:UIControlStateNormal];
        if (visitInfo.note != NULL && ![visitInfo.status isEqualToString:@"completed"]) {

            [statusButton addTarget:parentView 
                             action:@selector(showManagerNote:) 
                   forControlEvents:UIControlEventTouchUpInside];
        }
        
        [backgroundIV addSubview:statusButton];		
	}
    else if ([visitStatus isEqualToString:@"completed"]) {

		[petName setTextColor:[UIColor blackColor]];
		[serviceName setTextColor:[UIColor blackColor]];
		[clientName setTextColor:[UIColor blackColor]];
        [backgroundIV setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
        
        if (visitInfo.dateTimeVisitReportSubmit != NULL) {
            
            [statusButton setBackgroundImage:[UIImage imageNamed:@"btnSuccess"] 
                                    forState:UIControlStateNormal];  
            [backgroundIV addSubview:statusButton];
            
            sentVisitReportTime = [[UILabel alloc]initWithFrame:CGRectMake(backgroundIV.frame.size.width-130, backgroundIV.frame.size.height - 24, 90,20)];
            [sentVisitReportTime setTextAlignment:NSTextAlignmentRight];
            [sentVisitReportTime setTextColor:[PharmaStyle colorRedShadow70]];
            [sentVisitReportTime setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
            [sentVisitReportTime setText:visitInfo.dateTimeVisitReportSubmit];
            [backgroundIV addSubview:sentVisitReportTime];
        } 
        else if (visitInfo.dateTimeVisitReportSubmit == NULL && 
                 [visitInfo.imageUploadStatus isEqualToString:@"SUCCESS"] && 
                 [visitInfo.mapSnapUploadStatus isEqualToString:@"SUCCESS"] &&
                 [visitInfo.currentArriveVisitStatus isEqualToString:@"SUCCESS"] &&
                 [visitInfo.currentCompleteVisitStatus isEqualToString:@"SUCCESS"]) {
            
            
            UILabel *unsentVisitReportLabel = [[UILabel alloc] initWithFrame:CGRectMake(backgroundIV.frame.size.width - 80, backgroundIV.frame.size.height - 44, 60, 40)];
            unsentVisitReportLabel.numberOfLines = 2;
            [unsentVisitReportLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
            [unsentVisitReportLabel setTextColor:[colorPalette objectForKey:@"dangerDark"]];
            [unsentVisitReportLabel setText:@"REPORT UNSENT"];
            [backgroundIV addSubview:unsentVisitReportLabel];
            [backgroundIV setBackgroundColor:[colorPalette objectForKey:@"successDark"]];

            [statusButton setBackgroundImage:[UIImage imageNamed:@"btnSend"] 
                                    forState:UIControlStateNormal];
            [backgroundIV addSubview:statusButton];

        }
        else {
            [statusButton setBackgroundImage:[UIImage imageNamed:@"btnErrorSmall"] 
                                    forState:UIControlStateNormal];  
            [backgroundIV addSubview:statusButton];
            
        }
        [self checkFailedUpload];
	}
    else if ([visitStatus isEqualToString:@"canceled"]) {
        [petName setTextColor:[PharmaStyle colorAppWhite]];
        [serviceName setTextColor:[PharmaStyle colorAppWhite]];
        [backgroundIV setBackgroundColor:[colorPalette objectForKey:@"dangerDark"]];
        UIImageView *cancelIcon = [[UIImageView alloc]initWithFrame:CGRectMake(backgroundIV.frame.size.width - 32,backgroundIV.frame.size.height/2 -12, 24, 24)];
        [cancelIcon setImage:[UIImage imageNamed:@"x-mark-red"]];
		[backgroundIV addSubview:cancelIcon];
	}
    else if ([visitStatus isEqualToString:@"late"]) {
        [backgroundIV setBackgroundColor:[colorPalette objectForKey:@"warning"]];

		[petName setTextColor:[UIColor blackColor]];
		[serviceName setTextColor:[UIColor blackColor]];
		[clientName setTextColor:[UIColor blackColor]];
	}

	//[self layoutSubviews];
}

-(void) checkFailedUpload {
    BOOL isBadResend = FALSE;
    if ([visitInfo.visitReportUploadStatus isEqualToString:@"FAIL"]) {
        isBadResend = TRUE;
    }
    else if ([visitInfo.mapSnapUploadStatus isEqualToString:@"FAIL"]) {
        isBadResend = TRUE;
    } 
    else if ([visitInfo.imageUploadStatus isEqualToString:@"FAIL"]) {
          isBadResend = TRUE;
    }
    else if ([visitInfo.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
        isBadResend = TRUE;
    }
    else if ([visitInfo.currentCompleteVisitStatus isEqualToString:@"FAIL"]) {
         isBadResend = TRUE;
    }
    
    if(isBadResend) {
        UIButton *failButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        failButton.tag = [[[[NSNumberFormatter alloc] init] numberFromString:visitInfo.appointmentid] integerValue];
        failButton.frame = CGRectMake(cellSize.width-50, cellSize.height - 50, 44, 44);
        [failButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] 
                              forState:UIControlStateNormal];
        [failButton addTarget:self 
                       action:@selector(resendBadRequeust:) 
             forControlEvents:UIControlEventTouchUpInside];
        //[backgroundIV addSubview:failButton];
    
    }
}

-(void) resendBadRequeust:(id)sender {
    
    NSLog(@"Called bad request method for the button resend");    
    
    UIView *badResendView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [badResendView setBackgroundColor:[UIColor blackColor]];
    [self.contentView addSubview:badResendView];
    
    if ([visitInfo.imageUploadStatus isEqualToString:@"FAIL"]) {
        
        UILabel *badPhoto = [[UILabel alloc]initWithFrame:CGRectMake(badResendView.frame.origin.x, 0, 200, 20)];
        
        [badPhoto setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [badPhoto setTextColor:[UIColor whiteColor]];
        [badPhoto setText:@"Photo upload fail"];
        [badResendView addSubview:badPhoto];
        
        [visitInfo resendImageForPet];
    } 
    if([visitInfo.mapSnapUploadStatus isEqualToString:@"FAIL"]) {
        UILabel *badMapSnap = [[UILabel alloc]initWithFrame:CGRectMake(badResendView.frame.origin.x, 20, 200, 20)];
        
        [badMapSnap setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [badMapSnap setTextColor:[UIColor whiteColor]];
        [badMapSnap setText:@"Map upload fail"];
        [badResendView addSubview:badMapSnap];
        
        if ([visitInfo isMapSnapShotImage]) {
            NSLog(@"THERE IS MAP SNAPSHOT IMAGE AND IT NEEDS TO BE RESENT");
        } else {
            NSLog(@"There is no map snapshot image... Creating... ");
            if ([visitInfo.status isEqualToString:@"completed"]) {
                [visitInfo createMapSnapshot];
            }
        }
    }
    if([visitInfo.visitReportUploadStatus isEqualToString:@"FAIL"]) {
        UILabel *badReportUpload = [[UILabel alloc]initWithFrame:CGRectMake(badResendView.frame.origin.x, 40, 200, 20)];
        
        [badReportUpload setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [badReportUpload setTextColor:[UIColor whiteColor]];
        [badReportUpload setText:@"Report upload fail"];
        [badResendView addSubview:badReportUpload];
        
        [parentView sendVisitReportNoButton:visitInfo.appointmentid];
    }
    if([visitInfo.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
        
        UILabel *badArriveUpload = [[UILabel alloc]initWithFrame:CGRectMake(badResendView.frame.origin.x, 20, 200, 20)];
        
        [badArriveUpload setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [badArriveUpload setTextColor:[UIColor whiteColor]];
        [badArriveUpload setText:@"Arrive upload fail"];
        [badResendView addSubview:badArriveUpload];
        
        [parentView resendArrive:sender];
    }
    if([visitInfo.currentCompleteVisitStatus isEqualToString:@"FAIL"]) { 
        
        UILabel *badCompleteUpload = [[UILabel alloc]initWithFrame:CGRectMake(badResendView.frame.origin.x, 20, 200, 20)];
        
        [badCompleteUpload setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [badCompleteUpload setTextColor:[UIColor whiteColor]];
        [badCompleteUpload setText:@"Photo upload fail"];
        [badResendView addSubview:badCompleteUpload];
        
        [parentView resendComplete:sender];
    }
        
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *resendButton = (UIButton*)sender;
        
        [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            resendButton.frame = CGRectMake(resendButton.frame.origin.x + 10, resendButton.frame.origin.y - 20, resendButton.frame.size.width - 20, resendButton.frame.size.height - 20);
        } completion:^(BOOL finished) {
            resendButton.frame = CGRectMake(resendButton.frame.origin.x - 10, resendButton.frame.origin.y + 20, resendButton.frame.size.width + 20, resendButton.frame.size.height + 20);
        }];

        [UIView animateWithDuration:0.5 animations:^{

            
        }];
    }
}

-(void) addManagerNote {
    //NSLog(@"Adding manager note");
    if ([visitInfo.status isEqualToString:@"future"] || 
        [visitInfo.status isEqualToString:@"late"] || 
        [visitInfo.status isEqualToString:@"arrived"]) {
        
        managerVisitNote = [UIButton buttonWithType:UIButtonTypeCustom];
        managerVisitNote.frame = CGRectMake(cellSize.width - 60,cellSize.height - 80, 128,128);
        [managerVisitNote setAlpha:1.0];
        [managerVisitNote setBackgroundImage:[UIImage imageNamed:@"message-icon-white"] 
                                    forState:UIControlStateNormal];
        [managerVisitNote addTarget:self 
                             action:@selector(showManagerNote:) 
                   forControlEvents:UIControlEventTouchUpInside];
        NSNumber *tagVal =[[[NSNumberFormatter alloc] init] numberFromString:visitInfo.appointmentid];
        managerVisitNote.tag = [tagVal intValue];
        
        UIButton *moveButton = managerVisitNote;
        [backgroundIV addSubview:managerVisitNote];
        
        
        [UIView animateWithDuration:1.35 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            moveButton.frame = CGRectMake(cellSize.width - 34, cellSize.height-80 , 24, 24);
            [moveButton setAlpha:0.25];
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void) showManagerNote:(id)sender {
    if ([sender isKindOfClass:[UIButton class] ] ) {
        [parentView showManagerNote:sender];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
}
@end
