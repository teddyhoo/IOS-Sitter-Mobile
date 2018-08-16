
//  MapHUD.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/10/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "MapHUD.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"
#import "JzStyleKit.h"
#import "PharmaStyle.h"


@implementation MapHUD {
    
    VisitsAndTracking *visitData;
    UILabel *currentArriveTime;
    UILabel *currentCompleteTime;
    UILabel *visitInfo;
    UILabel *visitNote;
	bool onScreen;
    
    UIImageView *backForDiagnostics;
    
    BOOL isShowing;
    
    CGRect originRect;
    int moveBack;
    int yValOffset;
}

-(void)showScreen:(id)sender {
    
    UIButton *button;
    
    if([sender isKindOfClass:[UIButton class]]) {
        
        button = (UIButton*)sender;
        if(button.isSelected) {
			[button setSelected:NO];
            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self.frame = originRect;
                                 
                             } completion:^(BOOL finished) {

                                 
                             }];
            
            
        } else {
            [button setSelected:YES];
            int viewSize = self.frame.origin.y - (originRect.size.height - 180);
            moveBack = -viewSize;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.frame = CGRectMake(0,viewSize,self.frame.size.width,self.frame.size.height);
                                 
                             } completion:^(BOOL finished) {
 
                             }];
            
            
            
        }
    }
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        originRect = frame;
        
        isShowing = YES;
        self.backgroundColor = [UIColor clearColor];
        
        backForDiagnostics = [[UIImageView alloc]initWithFrame:CGRectMake(0, -10, self.frame.size.width,self.frame.size.height)];
        UIImage *backImage = [JzStyleKit imageOfJzCardWithJzCardFrame:CGRectMake(0, -10, self.frame.size.width,self.frame.size.height)
                                                           rectangle2:CGRectMake(0,-10, self.frame.size.width,self.frame.size.height)];
        [backForDiagnostics setImage:backImage];
        backForDiagnostics.alpha = 0.95;
        
        [self addSubview:backForDiagnostics];
        
        
        UIButton *showScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        showScreen.frame = CGRectMake(backForDiagnostics.frame.size.width-40,backForDiagnostics.frame.size.height-160,32,32);
        [showScreen setBackgroundImage:[UIImage imageNamed:@"down-arrow-thick"] forState:UIControlStateSelected];
        [showScreen setBackgroundImage:[UIImage imageNamed:@"up-arrow-thick"] forState:UIControlStateNormal];
        [showScreen addTarget:self action:@selector(showScreen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showScreen];
        
        onScreen = YES;
        visitData = [VisitsAndTracking sharedInstance];
        
        int pawDim = 32;
        
        
        for (VisitDetails *visitID in visitData.visitData) {
            
            UIButton *visitTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
			//NSLog(@"visit track button tag id: %@",visitID.sequenceID);
            visitTrackButton.tag = [visitID.sequenceID integerValue];
            [visitTrackButton addTarget:self
                                 action:@selector(track1tap:)
                       forControlEvents:UIControlEventTouchUpInside];
            
            if ([visitID.sequenceID isEqualToString:@"100"]) {

                [visitTrackButton setImage:[UIImage imageNamed:@"red-paw"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15,5,pawDim,pawDim);

            }
            else if ([visitID.sequenceID isEqualToString:@"101"]) {
                [visitTrackButton setImage:[UIImage imageNamed:@"teal-paw"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15, 40, pawDim,pawDim);

            }
            else if ([visitID.sequenceID isEqualToString:@"102"]) {
            
                [visitTrackButton setImage:[UIImage imageNamed:@"orange-paw"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15, 75, pawDim, pawDim);
                
            }
            else if ([visitID.sequenceID isEqualToString:@"103"]) {
                
                [visitTrackButton setImage:[UIImage imageNamed:@"purple-paw"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15, 110, pawDim, pawDim);

                
            }
            else if ([visitID.sequenceID isEqualToString:@"104"]) {
                
                [visitTrackButton setImage:[UIImage imageNamed:@"lightBlue-paw"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15, 145, pawDim, pawDim);
                
            }
            else if ([visitID.sequenceID isEqualToString:@"105"]) {

                [visitTrackButton setImage:[UIImage imageNamed:@"dark-green-paw"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15, 180, pawDim, pawDim);

            }
            else if ([visitID.sequenceID isEqualToString:@"106"]) {

                
                [visitTrackButton setImage:[UIImage imageNamed:@"magenta-paw"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15,215, pawDim, pawDim);

                
            }
            else if ([visitID.sequenceID isEqualToString:@"107"]) {
               
               [visitTrackButton setImage:[UIImage imageNamed:@"brown-paw"] forState:UIControlStateNormal];
               visitTrackButton.frame = CGRectMake(15,250, pawDim, pawDim);

               
               
            } else if ([visitID.sequenceID isEqualToString:@"108"]) {

               [visitTrackButton setImage:[UIImage imageNamed:@"pink-paw"] forState:UIControlStateNormal];
               visitTrackButton.frame = CGRectMake(15,285, pawDim, pawDim);
   
               
            }
            else if ([visitID.sequenceID isEqualToString:@"109"]) {

                
                [visitTrackButton setImage:[UIImage imageNamed:@"light-green"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15,320, pawDim, pawDim);
  
            }
            else if ([visitID.sequenceID isEqualToString:@"110"]) {
                
                
                [visitTrackButton setImage:[UIImage imageNamed:@"paw-powder-blue-100"] forState:UIControlStateNormal];
                visitTrackButton.frame = CGRectMake(15,355, pawDim, pawDim);

                
            }
            
            else if ([visitID.sequenceID isEqualToString:@"111"]) {

                
                //[visitTrackButton setImage:[UIImage imageNamed:@"paw-powder-blue-100"] forState:UIControlStateNormal];
                //visitTrackButton.frame = CGRectMake(15,390, pawDim, pawDim);
                
            }
            
            yValOffset = visitTrackButton.frame.origin.y;
            
            
            NSString *petNameStr = [visitID.petName uppercaseString];
            UILabel *petName;
            
            if(![petNameStr isEqual:[NSNull null]] && [petNameStr length] > 0) {
                
                if ([petNameStr length] > 26) {
                    petName = [[UILabel alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x + 80, visitTrackButton.frame.origin.y, 270, 18)];
                    petName.numberOfLines = 2;
                    [petName setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
                    if ([visitData.onWhichVisitID isEqualToString:visitID.appointmentid]) {
                        [petName setTextColor:[PharmaStyle colorYellow]];
                    } else {
                        [petName setTextColor:[UIColor whiteColor]];
                        
                    }
                    [petName setText:petNameStr];
                    [self addSubview:petName];
                    
                } else {
                    
                    petName = [[UILabel alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x + 80, visitTrackButton.frame.origin.y, 270, 18)];
                    petName.numberOfLines = 2;
                    [petName setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
                    if ([visitData.onWhichVisitID isEqualToString:visitID.appointmentid]) {
                        [petName setTextColor:[PharmaStyle colorYellow]];
                    } else {
                        [petName setTextColor:[UIColor whiteColor]];
                        
                    }
                    [petName setText:petNameStr];
                    [self addSubview:petName];
                    
                }
                
                
                if([visitID.status isEqualToString:@"completed"]) {
                    
                    [visitTrackButton setImage:[UIImage imageNamed:@"check-mark-green"] forState:UIControlStateNormal];
                    
                } else if ([visitID.status isEqualToString:@"canceled"]) {
                    
                    [visitTrackButton setImage:[UIImage imageNamed:@"x-mark-red"] forState:UIControlStateNormal];
                    UILabel *startTime = [[UILabel alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x + 30, visitTrackButton.frame.origin.y, 270, 20)];
                    startTime.numberOfLines = 2;
                    [startTime setFont:[UIFont fontWithName:@"Langdon" size:12]];
                    [startTime setTextColor:[UIColor colorWithRed:0.82 green:0.11 blue:0.3 alpha:1.0]];
                    [startTime setText:@"CANCEL"];
                    [self addSubview:startTime];
                    [petName setTextColor:[PharmaStyle colorRed]];
                    petName.alpha = 0.76;
                    
                } else if ([visitID.status isEqualToString:@"arrived"]) {
                    
                    [visitTrackButton setImage:[UIImage imageNamed:@"yellow-arrive"] forState:UIControlStateNormal];
                    
                } else {
                    
                    UILabel *startTime = [[UILabel alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x + 30, visitTrackButton.frame.origin.y, 270, 20)];
                    startTime.numberOfLines = 2;
                    [startTime setFont:[UIFont fontWithName:@"Langdon" size:12]];
                    if ([visitData.onWhichVisitID isEqualToString:visitID.appointmentid]) {
                        [startTime setTextColor:[PharmaStyle colorYellow]];
                        
                    } else {
                        [startTime setTextColor:[PharmaStyle colorBlueLight]];
                        
                        
                    }
                    [startTime setText:visitID.starttime];
                    [self addSubview:startTime];
                    
                    
                    if(![visitID.street1 isEqual:[NSNull null]] && [visitID.street1 length] > 0) {
                    
                        UILabel *addressClient = [[UILabel alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x + 80, visitTrackButton.frame.origin.y+20, 270, 20)];
                        addressClient .numberOfLines = 2;
                        [addressClient  setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
                        if ([visitData.onWhichVisitID isEqualToString:visitID.appointmentid]) {
                            [addressClient  setTextColor:[PharmaStyle colorYellow]];
                        } else {
                            [addressClient  setTextColor:[UIColor whiteColor]];
                        }
                        
                        [addressClient  setText:visitID.street1];
                        [self addSubview:addressClient ];
                        
                    }
                }
                
            } else {
                
                
                petNameStr = @"NO PET NAME";
                
                petName = [[UILabel alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x + 80, visitTrackButton.frame.origin.y, 270, 18)];
                petName.numberOfLines = 2;
                [petName setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
                if ([visitData.onWhichVisitID isEqualToString:visitID.appointmentid]) {
                    [petName setTextColor:[PharmaStyle colorYellow]];
                } else {
                    [petName setTextColor:[UIColor whiteColor]];
                    
                }
                [petName setText:petNameStr];
                [self addSubview:petName];
                
                
            }
            

            
            UIImageView *lineDivide = [[UIImageView alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x, visitTrackButton.frame.origin.y+30, backForDiagnostics.frame.size.width-60, 1)];
            [lineDivide setImage:[UIImage imageNamed:@"white-line-1px"]];
            lineDivide.alpha = 0.15;
            [self addSubview:lineDivide];
            
            [self addSubview:visitTrackButton];
            
            if(![visitID.note isEqual:[NSNull null]] && [visitID.note length] > 0) {
                UIImageView *noteIcon = [[UIImageView alloc]initWithFrame:CGRectMake(visitTrackButton.frame.origin.x - 10, visitTrackButton.frame.origin.y+15, 12, 12)];
                [noteIcon setImage:[UIImage imageNamed:@"manager-note-icon-128x128"]];
                [self addSubview:noteIcon];
            }
            
            
        }
    }
    return self;
}


-(void)removeView {
    [currentArriveTime removeFromSuperview];
    [currentCompleteTime removeFromSuperview];
    [visitInfo removeFromSuperview];
	[visitNote removeFromSuperview];
    
    currentArriveTime = nil;
    currentCompleteTime = nil;
    visitInfo = nil;
	visitNote = nil;
	_delegate = nil;


}

-(void)createVisitItem:(NSString *)pawPrintID {
    
    
}

-(void) updateVisitStatus:(NSString *)sequenceID andStatus:(NSString*)status {
    
    UIImage *statusImage;
    
    if ([status isEqualToString:@"completed"]) {
        
        statusImage = [UIImage imageNamed:@"checkMarkButton49x49-2"];
        
    } else if ([status isEqualToString:@"arrived"]) {
        
        statusImage = [UIImage imageNamed:@"arrive-arrow-green"];
        
    } else if ([status isEqualToString:@"late"]) {
        
        statusImage = [UIImage imageNamed:@"alarm-bell-64x64"];
        
    } else if ([status isEqualToString:@"canceled"]) {
        
        statusImage = [UIImage imageNamed:@"cross"];
    }

}

-(void)moveDiagnosticView {

}

-(void)setDelegate:(id)delegate {
    _delegate = delegate;
}

-(void)updateVisitDetailInfo:(VisitDetails*)visit {
	
	[currentArriveTime removeFromSuperview];
	[currentCompleteTime removeFromSuperview];
	[visitInfo removeFromSuperview];
	[visitNote removeFromSuperview];

	currentArriveTime = nil;
	currentCompleteTime = nil;
	visitInfo = nil;
	visitNote = nil;

    visitInfo = [[UILabel alloc]initWithFrame:CGRectMake(45, self.frame.size.height-60, 300, 16)];
    [visitInfo setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [visitInfo setText:visit.petName];
    [visitInfo setTextColor:[UIColor yellowColor]];
    
    currentArriveTime = [[UILabel alloc]initWithFrame:CGRectMake(45, self.frame.size.height-40, 300, 18)];
    [currentArriveTime setFont:[UIFont fontWithName:@"Langdon" size:14]];
    [currentArriveTime setTextColor:[UIColor yellowColor]];
    
    currentCompleteTime = [[UILabel alloc]initWithFrame:CGRectMake(185, self.frame.size.height-40, 300, 18)];
    [currentCompleteTime setFont:[UIFont fontWithName:@"Langdon" size:14]];
    [currentCompleteTime setTextColor:[UIColor yellowColor  ]];
    
    if (visit.dateTimeMarkArrive == NULL) {
        [currentArriveTime setText:@"Not Start"];
    } else if (visit.dateTimeMarkArrive != NULL) {
        [currentArriveTime setText:visit.dateTimeMarkArrive];
    }
    
    if (visit.dateTimeMarkComplete == NULL) {
        
        [currentCompleteTime setText:@"Incomplete"];
    } else if (visit.dateTimeMarkComplete != NULL) {
        [currentCompleteTime setText:visit.dateTimeMarkComplete];
    }
    
    [self addSubview:visitInfo];
    [self addSubview:currentArriveTime];
    [self addSubview:currentCompleteTime];
}




-(void) track1tap:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *pawPrintButton = (UIButton*)sender;
        
        NSString *routeID = [NSString stringWithFormat:@"%li",(long)pawPrintButton.tag];
		//NSLog(@"route id: %@",routeID);
		
        [visitInfo removeFromSuperview];
        [currentArriveTime removeFromSuperview];
        [currentCompleteTime removeFromSuperview];
        visitNote.text = @"";
        [visitNote removeFromSuperview];

        for (VisitDetails *visit in visitData.visitData) {
            if ([visit.sequenceID isEqualToString:routeID]) {
                visitInfo = [[UILabel alloc]initWithFrame:CGRectMake(25, yValOffset+50, 300, 16)];
                [visitInfo setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
                [visitInfo setText:visit.petName];
                [visitInfo setTextColor:[UIColor yellowColor]];
                
                currentArriveTime = [[UILabel alloc]initWithFrame:CGRectMake(originRect.size.width - 120 ,yValOffset+50, 80, 14)];
                [currentArriveTime setFont:[UIFont fontWithName:@"Langdon" size:12]];
                [currentArriveTime setTextColor:[UIColor yellowColor]];
                
                currentCompleteTime = [[UILabel alloc]initWithFrame:CGRectMake(originRect.size.width - 120, yValOffset+70, 80, 14)];
                [currentCompleteTime setFont:[UIFont fontWithName:@"Langdon" size:12]];
                [currentCompleteTime setTextColor:[UIColor yellowColor]];
                
                if (visit.dateTimeMarkArrive == NULL) {
                    [currentArriveTime setText:@"NOT STARTED"];
                } else if (visit.dateTimeMarkArrive != NULL) {
                    [currentArriveTime setText:visit.dateTimeMarkArrive];
                }
                
                if (visit.dateTimeMarkComplete == NULL) {
                    [currentCompleteTime setText:@"NOT DONE"];
                } else if (visit.dateTimeMarkComplete != NULL) {
                    [currentCompleteTime setText:visit.dateTimeMarkComplete];
                }
                
                [self addSubview:visitInfo];
                [self addSubview:currentArriveTime];
                [self addSubview:currentCompleteTime];
                
                if(![visit.note isEqual:[NSNull null]] && [visit.note length] > 0) {

                    visitNote = [[UILabel alloc]initWithFrame:CGRectMake(currentArriveTime.frame.origin.x, self.frame.size.height - 160, self.frame.size.width-45, 180)];
                    visitNote.numberOfLines = 6;
                    [visitNote setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
                    [visitNote setTextColor:[UIColor yellowColor]];
                    [visitNote setText:visit.note];
                    [self addSubview:visitNote];
 
                }
            }
        }
        [_delegate drawRoute:routeID];

    }
}

@end
