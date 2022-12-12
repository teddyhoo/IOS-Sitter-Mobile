
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
}

-(void)showScreen:(id)sender {
    
    UIButton *button;
    
    if([sender isKindOfClass:[UIButton class]]) {
        
        button = (UIButton*)sender;
        if(button.isSelected) {
			[button setSelected:NO];
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.frame = self->originRect;
                             } completion:^(BOOL finished) {
                             }];
        } else {
            [button setSelected:YES];
			int viewSize;
			if ( [[VisitsAndTracking sharedInstance].tellDeviceType isEqualToString:@"iPhone5"]) {
				viewSize = self.frame.origin.y - (originRect.size.height - 220);
			} else {
				viewSize = self.frame.origin.y - (originRect.size.height - 160);

			}
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
	self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        
		originRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        
        isShowing = YES;
		onScreen = YES;
		visitData = [VisitsAndTracking sharedInstance];
        self.backgroundColor = [UIColor clearColor];
		int counter = 1;
		int yDistance = 36;
		int fontSize = 15;
		int diagnosticY = self.frame.size.height;
		int showScreenButtonSize = 24;
		
		if ([visitData.tellDeviceType isEqualToString:@"iPhone5"]) {
			yDistance = 32;
			fontSize = 13;
			showScreenButtonSize = 16;
			diagnosticY = self.frame.size.height - 80;
		} else if ([visitData.tellDeviceType isEqualToString:@"iPhone6"]) {
			yDistance = 36;
			fontSize = 14;
			diagnosticY = self.frame.size.height;
			showScreenButtonSize = 20;
		}  
        backForDiagnostics = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,diagnosticY)];
        UIImage *backImage = [JzStyleKit imageOfJzCardWithJzCardFrame:CGRectMake(0, 0, self.frame.size.width,diagnosticY)
                                                           rectangle2:CGRectMake(0,0, self.frame.size.width,diagnosticY)];
        [backForDiagnostics setImage:backImage];
        backForDiagnostics.alpha = 0.95;
        [self addSubview:backForDiagnostics];
		
        for (VisitDetails *visitID in visitData.visitData) {
			
			NSString *petNameStr = [visitID.petName uppercaseString];
			UIButton *petNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[petNameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			petNameButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:fontSize];
			petNameButton.titleLabel.textAlignment = NSTextAlignmentLeft;
			[petNameButton setTitle:petNameStr forState:UIControlStateNormal];
			[petNameButton addTarget:self 
							  action:@selector(track1tap:) 
					forControlEvents:UIControlEventTouchUpInside];
			petNameButton.tag = [visitID.sequenceID integerValue];
			int yPos = (yDistance * counter) - 20;
            if(![petNameStr isEqual:[NSNull null]] && [petNameStr length] > 0) {
                if ([petNameStr length] > 26) {
					petNameButton.frame = CGRectMake(90,yPos, self.frame.size.width-130, 40);
                } else {
					petNameButton.frame = CGRectMake(90,yPos, self.frame.size.width-130, 40);
                }
            } else {
                petNameStr = @"NO PET NAME";
				petNameButton.frame = CGRectMake(90,yPos, self.frame.size.width-130, 50);
            }
			
			[petNameButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
			[petNameButton setTitle:petNameStr forState:UIControlStateSelected];
			[self addSubview:petNameButton];

			UIButton *visitTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
			visitTrackButton.frame = CGRectMake(petNameButton.frame.origin.x - 20, petNameButton.frame.origin.y, 20, 20);
			
			UILabel *startTime = [[UILabel alloc]initWithFrame:CGRectMake(petNameButton.frame.origin.x -65, petNameButton.frame.origin.y+10, 270, 20)];
			startTime.numberOfLines = 2;
			[startTime setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
			[startTime setTextColor:[UIColor whiteColor]];
			[startTime setText:visitID.starttime];
			if ([visitData.onWhichVisitID isEqualToString:visitID.appointmentid]) {
				[startTime setTextColor:[PharmaStyle colorYellow]];
			} else {
				[startTime setTextColor:[PharmaStyle colorBlueLight]];
			}
			
			if([visitID.status isEqualToString:@"completed"]) {
				[visitTrackButton setImage:[UIImage imageNamed:@"check-mark-green"] forState:UIControlStateNormal];
			} else if ([visitID.status isEqualToString:@"canceled"]) {
				[visitTrackButton setImage:[UIImage imageNamed:@"x-mark-red"] forState:UIControlStateNormal];
			} else if ([visitID.status isEqualToString:@"arrived"]) {
				[visitTrackButton setImage:[UIImage imageNamed:@"yellow-arrive"] forState:UIControlStateNormal];
				[self addSubview:startTime];
			} else if ([visitID.status isEqualToString:@"future"] || [visitID.status isEqualToString:@"late"]) {
				[self addSubview:startTime];
			}
			
			[backForDiagnostics addSubview:visitTrackButton];
		
            UIImageView *lineDivide = [[UIImageView alloc]initWithFrame:CGRectMake(petNameButton.frame.origin.x, petNameButton.frame.origin.y+yDistance-5, backForDiagnostics.frame.size.width-60, 1)];
            [lineDivide setImage:[UIImage imageNamed:@"white-line-1px"]];
            lineDivide.alpha = 0.15;
            [self addSubview:lineDivide];
			
            if(![visitID.note isEqual:[NSNull null]] && [visitID.note length] > 0) {
                UIImageView *noteIcon = [[UIImageView alloc]initWithFrame:CGRectMake(petNameButton.frame.origin.x - 5, petNameButton.frame.origin.y+10, 16, 16)];
                [noteIcon setImage:[UIImage imageNamed:@"manager-note-icon-128x128"]];
                [self addSubview:noteIcon];
            }
			counter++;
        }
		
		UIButton *showScreen = [UIButton buttonWithType:UIButtonTypeCustom];
		showScreen.frame = CGRectMake(backForDiagnostics.frame.size.width/2-16,yDistance * counter-10,showScreenButtonSize,showScreenButtonSize);
		[showScreen setBackgroundImage:[UIImage imageNamed:@"down-arrow-thick"] forState:UIControlStateSelected];
		[showScreen setBackgroundImage:[UIImage imageNamed:@"up-arrow-thick"] forState:UIControlStateNormal];
		[showScreen addTarget:self action:@selector(showScreen:) forControlEvents:UIControlEventTouchUpInside];
		showScreen.alpha = 0.77;
		[self addSubview:showScreen];
    }
    return self;
}

-(void) track1tap:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *pawPrintButton = (UIButton*)sender;
        NSString *routeID = [NSString stringWithFormat:@"%li",(long)pawPrintButton.tag];
        [visitInfo removeFromSuperview];
        [currentArriveTime removeFromSuperview];
        [currentCompleteTime removeFromSuperview];
        visitNote.text = @"";
        [visitNote removeFromSuperview];

        for (VisitDetails *visit in visitData.visitData) {
            if ([visit.sequenceID isEqualToString:routeID]) {
                visitInfo = [[UILabel alloc]initWithFrame:CGRectMake(25, backForDiagnostics.frame.size.height -90, 300, 20)];
                [visitInfo setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
                [visitInfo setText:visit.petName];
                [visitInfo setTextColor:[UIColor yellowColor]];
                
                currentArriveTime = [[UILabel alloc]initWithFrame:CGRectMake(backForDiagnostics.frame.size.width - 140 ,visitInfo.frame.origin.y-20, 140, 14)];
                [currentArriveTime setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
                [currentArriveTime setTextColor:[UIColor yellowColor]];
                
                currentCompleteTime = [[UILabel alloc]initWithFrame:CGRectMake(backForDiagnostics.frame.size.width - 140,visitInfo.frame.origin.y, 140, 14)];
                [currentCompleteTime setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
                [currentCompleteTime setTextColor:[UIColor yellowColor]];
                
				if(![visit.note isEqual:[NSNull null]] && [visit.note length] > 0) {
					
					visitNote = [[UILabel alloc]initWithFrame:CGRectMake(visitInfo.frame.origin.x,  visitInfo.frame.origin.y + 22, self.frame.size.width-25, 60)];
					visitNote.numberOfLines = 6;
					[visitNote setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
					[visitNote setTextColor:[UIColor yellowColor]];
					[visitNote setText:visit.note];
					[self addSubview:visitNote];
				}
				
                if (visit.dateTimeMarkArrive == NULL) {
                    [currentArriveTime setText:@"NOT STARTED"];
                } else if (visit.dateTimeMarkArrive != NULL) {
                    [currentArriveTime setText:visit.arrived];
					[currentArriveTime setTextColor:[UIColor orangeColor]];
					[visitInfo setTextColor:[UIColor orangeColor]];
					[visitNote setTextColor:[UIColor orangeColor]];
					currentCompleteTime.alpha = 0.0;
                }
                
                if (visit.dateTimeMarkComplete == NULL) {
                    [currentCompleteTime setText:@"NOT DONE"];
                } else if (visit.dateTimeMarkComplete != NULL) {
                    [currentCompleteTime setText:visit.completed];
					[currentCompleteTime setTextColor:[UIColor greenColor]];
					[currentArriveTime setTextColor:[UIColor greenColor]];
					currentCompleteTime.alpha = 1.0;
					[visitInfo setTextColor:[UIColor greenColor]];
					[visitNote setTextColor:[UIColor greenColor]];
                }
                [self addSubview:visitInfo];
                [self addSubview:currentArriveTime];
                [self addSubview:currentCompleteTime];
			}
        }
        [_delegate drawRoute:routeID];
    }
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

-(void)updateVisitDetailInfo:(VisitDetails*)visit {
	
	[currentArriveTime removeFromSuperview];
	[currentCompleteTime removeFromSuperview];
	[visitInfo removeFromSuperview];
	[visitNote removeFromSuperview];
	
	currentArriveTime = nil;
	currentCompleteTime = nil;
	visitInfo = nil;
	visitNote = nil;
	
	visitInfo = [[UILabel alloc]initWithFrame:CGRectMake(45, backForDiagnostics.frame.size.height - 150, 300, 16)];
	[visitInfo setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
	[visitInfo setText:visit.petName];
	[visitInfo setTextColor:[UIColor yellowColor]];
	
	currentArriveTime = [[UILabel alloc]initWithFrame:CGRectMake(45, self.frame.size.height-70, 300, 18)];
	[currentArriveTime setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
	[currentArriveTime setTextColor:[UIColor yellowColor]];
	
	currentCompleteTime = [[UILabel alloc]initWithFrame:CGRectMake(185, self.frame.size.height-70, 300, 18)];
	[currentCompleteTime setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
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

-(void)moveDiagnosticView {	
}

-(void)setDelegate:(id)delegate {
	_delegate = delegate;
}

@end
