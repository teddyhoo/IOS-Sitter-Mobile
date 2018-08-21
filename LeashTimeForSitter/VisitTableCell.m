//
//  VisitTableCell.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/25/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "VisitTableCell.h"
#import "UIImageView+Rotate.h"
#import "VisitsAndTracking.h"
#import "PharmaStyle.h"
#import "DataClient.h"
#import <tgmath.h>

@interface VisitTableCell () {

	NSObject <MGSwipeTableCellDelegate> *cellDelegate;
	UIView *flagView;
	UIButton *petPicView;
	UILabel *petName;
	UILabel *clientName;
	UILabel *serviceName;
	UILabel *timeBegin;
	UILabel *timeEnd;
	UILabel *arriveMessagesStatus;
	UILabel *completeMessageStatus;
	UIImageView *hasSentMessageIcon;
	UIImageView *hasKeyIcon;
	UILabel *keyIDLabel;
	UIButton *managerVisitNote;
	UIButton *buttonDetail;
	UIButton *profileUpdateButton;
	UIButton *docErrataButton;
	NSDateFormatter *arriveCompleteTimeFormat;
	NSDateFormatter *arriveCompleteConvertTimeFormat;
	NSDateFormatter *completeTimeFormat;
	NSDateFormatter *fullDate;
	NSDateFormatter *timerFormat;
	NSDateFormatter *displayTimerFormat;
	NSTimer *stopWatchTimer;
	UILabel *timerForVisitLabel;
}

@end

@implementation VisitTableCell

VisitsAndTracking *sharedVisits;
BOOL isIphone6P;
BOOL isIphone6;
BOOL isIphone5;
BOOL isIphone4;
CGSize cellSize;

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andSize:(CGSize)theCellSize {
    
    cellSize = CGSizeMake(theCellSize.width,  theCellSize.height - 1);
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        sharedVisits = [VisitsAndTracking sharedInstance];
		
        NSString *theDeviceType = [sharedVisits tellDeviceType];
        
        if ([theDeviceType isEqualToString:@"iPhone6P"]) {
            isIphone6P = YES;
            isIphone6 = NO;
            isIphone5 = NO;
            isIphone4 = NO;
        } else if ([theDeviceType isEqualToString:@"iPhone6"]) {
            isIphone6 = YES;
            isIphone5 = NO;
            isIphone4 = NO;
            isIphone6P = NO;
        } else if ([theDeviceType isEqualToString:@"iPhone5"]) {
            isIphone5 = YES;
            isIphone6 = NO;
            isIphone4 = NO;
            isIphone6P = NO;
        } else {
            isIphone4 = YES;
            isIphone4 = NO;
            isIphone6P = NO;
            isIphone5 = NO;
        }
		arriveCompleteTimeFormat =[[NSDateFormatter alloc]init];
		[arriveCompleteTimeFormat setDateFormat:@"H:mm:ss a"];
		arriveCompleteConvertTimeFormat  =[[NSDateFormatter alloc]init];
		[arriveCompleteConvertTimeFormat setDateFormat:@"h:mm a"];
		completeTimeFormat  =[[NSDateFormatter alloc]init];
		[completeTimeFormat setDateFormat:@"HH:mm a"];
		fullDate = [[NSDateFormatter alloc]init];
		[fullDate setDateFormat:@"HH:mm:ss MMM dd yyyy"];
		timerFormat = [[NSDateFormatter alloc]init];
		[timerFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
		displayTimerFormat = [[NSDateFormatter alloc]init];
		[displayTimerFormat setDateFormat:@"h:mm:ss"];
		
		_backgroundIV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
        [_backgroundIV setBackgroundColor:[PharmaStyle colorBlueShadow]];
        _backgroundIV.alpha = 1.0;
		[self.contentView addSubview:_backgroundIV];
    }
    return self;
}

-(void) startVisitTimer {
	
	if (sharedVisits.showTimer) {
		if (!stopWatchTimer.isValid && timerForVisitLabel == nil) {
			//NSLog(@"Adding visit timer");
			
			timerForVisitLabel = [[UILabel alloc]initWithFrame:CGRectMake(cellSize.width - 60, 40, 60, 30)];
			[timerForVisitLabel setFont:[UIFont fontWithName:@"Landgon" size:16]];
			[timerForVisitLabel setTextColor:[PharmaStyle colorRedHighlight]];
			[timerForVisitLabel setText:@"00:00"];
			
			stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
															  target:self
															selector:@selector(updateTimer)
															userInfo:nil
															 repeats:YES];
			
			[_backgroundIV addSubview:timerForVisitLabel];
			
		}
	}
}

-(void) updateTimer { 
	NSDate *currentDate = [NSDate date];

	NSString *dateTimeString = _visitInfo.dateTimeMarkArrive;
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
			displayTextTimer = [NSString stringWithFormat:@"%i:%i:%i",hours,minutes, local_seconds];
		} else   {
			if (local_seconds < 10) {
				displayTextTimer = [NSString stringWithFormat:@"%i:0%i",minutes, local_seconds];

			} else {
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
		[timerForVisitLabel removeFromSuperview];

	} else {
		//NSLog(@"stop watch timer is alread invalidated");
	}
	
	stopWatchTimer = nil;
	timerForVisitLabel = nil;

}
-(void)setVisitDetail:(VisitDetails*)visitInfo {
	
	_visitInfo = visitInfo;
	int widthOffset = 0;
	int xOffset = 100;
	int fontSizeSmall = 18;
	int fontSizeBig = 22;
	
	if(isIphone6P) {
		widthOffset = -20;
		xOffset = 120;
	} else if (isIphone6) {
		widthOffset = -50;
		xOffset = 120;
	} else if (isIphone5) {
		widthOffset = -100;
		fontSizeSmall = 16;
		fontSizeBig = 20;
	} else if (isIphone4) {
		widthOffset = -100;
	}
	
	if (![_visitInfo.petName isEqual:[NSNull null]] && [_visitInfo.petName length] > 0)  {
		
		if([_visitInfo.petName length] > 24) {
			petName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 0, self.frame.size.width-100, 38)];
			[petName setFont:[UIFont fontWithName:@"Lato-Bold" size:fontSizeSmall]];
			petName.numberOfLines = 2;
		} else {
			petName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 0, self.frame.size.width-100, 32)];
			[petName setFont:[UIFont fontWithName:@"Lato-Bold" size:fontSizeBig]];
		}
		
		[petName setTextColor:[PharmaStyle colorAppWhite]];
		petName.text = _visitInfo.petName;
		
	}
	else {
		petName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 0, self.frame.size.width-100, 32)];
		[petName setFont:[UIFont fontWithName:@"Lato-Bold" size:24]];
		petName.numberOfLines = 1;
		[petName setTextColor:[PharmaStyle colorAppWhite]];
		petName.text = @"NO PET NAMES";
		
	}

	if(sharedVisits.showClientName) {
		
		if(![_visitInfo.clientname isEqual:[NSNull null]] && [_visitInfo.clientname length] > 0) {
			
			clientName = [[UILabel alloc]initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+32, self.frame.size.width-50, 32)];
			[clientName setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeBig]];
			[clientName setTextColor:[PharmaStyle colorAppWhite]];
			[clientName setText:_visitInfo.clientname];
		}
	}
	if (_visitInfo.service != NULL) {
		
		int lenServiceName = (int)[_visitInfo.service length];
		
		if (sharedVisits.showClientName) {
			if (lenServiceName > 24) {
				serviceName = [[UILabel alloc] initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+65, cellSize.width-xOffset-10, 40)];
				serviceName.numberOfLines = 2;
				[serviceName setFont:[UIFont fontWithName:@"Lato-Light" size:16]];

			} else {
				serviceName = [[UILabel alloc] initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+65, cellSize.width-xOffset-10, 28)];
				serviceName.numberOfLines = 1;
				[serviceName setFont:[UIFont fontWithName:@"Lato-Light" size:20]];

			}
		} else {
			if (lenServiceName > 24) {
				serviceName = [[UILabel alloc] initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+48, cellSize.width-xOffset-10, 40)];
				serviceName.numberOfLines = 2;
				[serviceName setFont:[UIFont fontWithName:@"Lato-Light" size:16]];

				
			} else {
				serviceName = [[UILabel alloc] initWithFrame:CGRectMake(petName.frame.origin.x, petName.frame.origin.y+48, cellSize.width-xOffset-10, 28)];
				serviceName.numberOfLines = 2;
				[serviceName setFont:[UIFont fontWithName:@"Lato-Light" size:20]];

			}
		}
		
		[serviceName setTextColor:[PharmaStyle colorAppWhite]];
		serviceName.text = _visitInfo.service;
		
	}
	if(_visitInfo.starttime != NULL) {

		timeBegin = [[UILabel alloc] initWithFrame:CGRectMake(petName.frame.origin.x, serviceName.frame.origin.y + 36,100, 26)];
		[timeBegin setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
		[timeBegin setTextColor:[PharmaStyle colorYellow]];
		timeBegin.textAlignment = NSTextAlignmentLeft;
		NSDate *timeBegStart = [arriveCompleteConvertTimeFormat dateFromString:_visitInfo.starttime];
		NSString *timeBeginString = [arriveCompleteConvertTimeFormat stringFromDate:timeBegStart];
		timeBegin.text = timeBeginString;
	}
	if(_visitInfo.endtime != NULL)  {
		if(isIphone6P) {
			widthOffset =40;
		} else if (isIphone6) {
			widthOffset =0;
		} else if (isIphone5) {
			widthOffset = -50;
		} else if (isIphone4) {
			widthOffset = -30;
		}
		
		timeEnd = [[UILabel alloc] initWithFrame:CGRectMake(timeBegin.frame.origin.x + 80, serviceName.frame.origin.y + 36, 100, 26)];
		[timeEnd setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
		[timeEnd setTextColor:[PharmaStyle colorYellow]];
		timeEnd.textAlignment = NSTextAlignmentLeft;
		NSDate *timeWindowEnd = [arriveCompleteConvertTimeFormat dateFromString:_visitInfo.endtime];
		NSString *timeEndString = [arriveCompleteConvertTimeFormat stringFromDate:timeWindowEnd];
		timeEnd.text = timeEndString;
	}
	
	[self.contentView addSubview:petName];
	[self.contentView addSubview:clientName];
	[self.contentView addSubview:serviceName];
	[self.contentView addSubview:timeBegin];
	[self.contentView addSubview:timeEnd];
	
	for(NSDictionary *visitStatus in sharedVisits.arrivalCompleteQueueItems) {
		if([[visitStatus objectForKey:@"appointmentptr"]isEqualToString:_visitInfo.appointmentid] &&
		   [[visitStatus objectForKey:@"event"]isEqualToString:@"arrived"] &&
		  [visitInfo.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
			
			[self setBadArrivalStatus];

		}
	}
	for(NSDictionary *visitStatus in sharedVisits.arrivalCompleteQueueItems) {
		if([[visitStatus objectForKey:@"appointmentptr"]isEqualToString:_visitInfo.appointmentid] &&
		   [[visitStatus objectForKey:@"event"]isEqualToString:@"completed"] &&
		   [visitInfo.currentCompleteVisitStatus isEqualToString:@"FAIL"]) {
		
			[self setBadCompleteStatus];
		
		}
	}
}


-(void)setStatus:(NSString*)visitStatus widthOffset:(int)widthOffset fontSize:(int)fontSize {
	
	if ([visitStatus isEqualToString:@"arrived"]) {
		[petName setTextColor:[PharmaStyle colorRedShadow70]];
		[serviceName setTextColor:[PharmaStyle colorRedShadow70]];
		[clientName setTextColor:[PharmaStyle colorRedShadow70]];
		
		timeBegin.font = [UIFont fontWithName:@"Lato-Regular" size:fontSize];
		[timeBegin setTextColor:[PharmaStyle colorRedHighlight]];
		NSDate *timeBegStart = [fullDate dateFromString:_visitInfo.arrived];
		NSString *timeBeginString = [arriveCompleteConvertTimeFormat stringFromDate:timeBegStart];
		timeBegin.text = timeBeginString;
		
		[timeEnd setTextColor:[PharmaStyle colorRedShadow70]];
		timeEnd.alpha = 0.0;
		
		UIView *arriveBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
		arriveBack.backgroundColor = [PharmaStyle colorGreenHightlight];
		arriveBack.alpha = 0.9;
		[_backgroundIV addSubview:arriveBack];
		
		UIImageView *arriveIcon = [[UIImageView alloc]initWithFrame:CGRectMake(timeBegin.frame.origin.x - 30, timeBegin.frame.origin.y, 24, 24)];
		[arriveIcon setImage:[UIImage imageNamed:@"arrive-pink-button"]];
		[arriveBack addSubview:arriveIcon];
	
		[self layoutSubviews];
		
	} else if ([visitStatus isEqualToString:@"completed"]) {
		
		hasKeyIcon.alpha = 0.0;
		keyIDLabel.alpha = 0.0;
		
		hasSentMessageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(38, cellSize.height-32, 20,16)];
		[hasSentMessageIcon setImage:[UIImage imageNamed:@"envelope-icon-allwhite"]];
		
		NSString *timeComplete = _visitInfo.dateTimeVisitReportSubmit;
		
		if (![timeComplete isEqual:[NSNull null]]
			&& [timeComplete length] > 0
			&& [_visitInfo.status isEqualToString:@"completed"]) {
			hasSentMessageIcon.alpha = 1.0;
		}
		else {
			hasSentMessageIcon.alpha = 0.0;
		}
		
		UIView *arriveBack2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
		arriveBack2.backgroundColor = [PharmaStyle colorGreenHightlight];
		arriveBack2.alpha = 0.75;
		
		UIView *arriveBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
		arriveBack.backgroundColor = [UIColor greenColor];
		arriveBack.alpha = 0.9;
		
		UIImageView *completeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, cellSize.height-32, 24, 24)];
		[completeIcon setImage:[UIImage imageNamed:@"check-mark-green"]];
		[arriveBack addSubview:completeIcon];
		
		[petName setTextColor:[UIColor blackColor]];
		[serviceName setTextColor:[UIColor blackColor]];
		[clientName setTextColor:[UIColor blackColor]];
		[timeBegin setTextColor:[UIColor blackColor]];
		[timeEnd setTextColor:[UIColor blackColor]];
		

		NSDate *timeBegStart = [fullDate dateFromString:_visitInfo.arrived];
		NSString *timeBeginString = [arriveCompleteConvertTimeFormat stringFromDate:timeBegStart];
		NSDate *timeWindowEnd = [fullDate dateFromString:_visitInfo.completed];
		NSString *timeEndString = [arriveCompleteConvertTimeFormat stringFromDate:timeWindowEnd];
		
		[timeBegin setText:timeBeginString]; //_visitInfo.dateTimeMarkArrive];
		[timeEnd setText:timeEndString]; //_visitInfo.dateTimeMarkComplete];
		[_backgroundIV addSubview:arriveBack];
		[_backgroundIV insertSubview:arriveBack2 belowSubview:arriveBack];
		[_backgroundIV addSubview:hasSentMessageIcon];

		[self layoutSubviews];

	} else if ([visitStatus isEqualToString:@"canceled"]) {
		
		UIView *arriveBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
		arriveBack.backgroundColor = [PharmaStyle colorRedHighlight];
		[_backgroundIV addSubview:arriveBack];
		UIView *arriveBack2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
		arriveBack2.backgroundColor = [PharmaStyle colorAppWhite50];
		arriveBack2.alpha=0.5;
		[_backgroundIV addSubview:arriveBack2];
		
		[petName setTextColor:[PharmaStyle colorAppWhite]];
		[serviceName setTextColor:[PharmaStyle colorAppWhite]];
		timeBegin.alpha = 0.0;
		timeEnd.alpha = 0.0;
		flagView.alpha = 0.0;
		hasKeyIcon.alpha = 0.0;
		keyIDLabel.alpha = 0.0;
		
		UIImageView *cancelIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 24, 24)];
		[cancelIcon setImage:[UIImage imageNamed:@"x-mark-red"]];
		[arriveBack addSubview:cancelIcon];
		
	} else if ([visitStatus isEqualToString:@"late"]) {
		UIView *arriveBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
		arriveBack.backgroundColor = [PharmaStyle colorYellow];
		[_backgroundIV addSubview:arriveBack];
		[timeBegin setTextColor:[PharmaStyle colorRedHighlight]];
		[timeEnd setTextColor:[PharmaStyle colorRedHighlight]];
		[petName setTextColor:[PharmaStyle colorAppBlack]];
		[serviceName setTextColor:[PharmaStyle colorAppBlack]];
		[clientName setTextColor:[PharmaStyle colorAppBlack]];
		[self layoutSubviews];
		
	} else if ([visitStatus isEqualToString:@"future"]) {
		
		buttonDetail = [UIButton buttonWithType:UIButtonTypeCustom];
		buttonDetail.frame = CGRectMake(0,0,94,cellSize.height);
		[buttonDetail setBackgroundImage:[UIImage imageNamed:@"assetmonographcellBacklarge"]
								forState:UIControlStateNormal];
		[buttonDetail addTarget:self
						 action:@selector(visitCellTap:)
			   forControlEvents:UIControlEventTouchUpInside];
		
		buttonDetail.userInteractionEnabled = YES;
		buttonDetail.alpha = 0.1;		
	}
	[self layoutSubviews];
}

-(void)showKeyInfo {
	UIImageView *hasKeyIcon = [[UIImageView alloc]initWithFrame:CGRectMake(timeBegin.frame.origin.x-95,cellSize.height - 30, 24, 24)];
	UILabel *keyIDLabel = [[UILabel alloc]initWithFrame:CGRectMake(hasKeyIcon.frame.origin.x+20, hasKeyIcon.frame.origin.y+10, 220, 22)];
	[keyIDLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
	[keyIDLabel setTextColor:[PharmaStyle colorAppWhite50]];
	
	if(_visitInfo.noKeyRequired) {
		[hasKeyIcon setImage:[UIImage imageNamed:@"key-icon-60by60"]];
		keyIDLabel.textColor = [PharmaStyle colorAppWhite];
		[keyIDLabel setText:@"NO KEY REQUIRED"];
	}
	else {
		if (_visitInfo.hasKey  &&
			!_visitInfo.useKeyDescriptionInstead) {
			[hasKeyIcon setImage:[UIImage imageNamed:@"key-icon-60by60"]];
			keyIDLabel.text = _visitInfo.keyID;
			keyIDLabel.textColor = [PharmaStyle colorAppWhite];
		} else if (_visitInfo.hasKey &&
				   _visitInfo.useKeyDescriptionInstead) {
			[hasKeyIcon setImage:[UIImage imageNamed:@"key-icon-60by60"]];
			
			if(![_visitInfo.keyDescriptionText isEqual:[NSNull null]] && [_visitInfo.keyDescriptionText length] > 0) {
				keyIDLabel.text = _visitInfo.keyDescriptionText;
			} else {
				keyIDLabel.text = @"NO DESCRIPTION";
			}
			
			keyIDLabel.textColor = [PharmaStyle colorAppWhite];
			
		} else {
			NSString *needKey;
			if([_visitInfo.keyID isEqualToString:@"NO KEY"]) {
				needKey  = @"NO KEY SET";
			} else {
				if(_visitInfo.useKeyDescriptionInstead) {
					needKey = [NSString stringWithFormat:@"NEED: %@",_visitInfo.keyDescriptionText];
				} else {
					needKey = [NSString stringWithFormat:@"NEED: %@",_visitInfo.keyID];
				}
				
			}
			[hasKeyIcon setImage:[UIImage imageNamed:@"need-key-icon-60by60"]];
			keyIDLabel.text = needKey;
			keyIDLabel.textColor = [PharmaStyle colorRedLight];
		}
		
	}
	[_backgroundIV addSubview:keyIDLabel];
	[_backgroundIV addSubview:hasKeyIcon];
	
}

-(void)showFlags {
	
	flagView = [[UIView alloc]initWithFrame:CGRectMake(120, cellSize.height - 50, cellSize.width-160, 50)];
	flagView.alpha = 1.0;
	[flagView setBackgroundColor:[UIColor clearColor]];
	[_backgroundIV addSubview:flagView];

	int xFlag = 10;
	int yFlag = 10;
		
	for (DataClient *clientProfile in sharedVisits.clientData) {
		
		if ([_visitInfo.clientptr isEqualToString:clientProfile.clientID]) {
			
			for (NSDictionary *flagDicClient in clientProfile.clientFlagsArray) {
				
				NSString *comparingFlagID = [flagDicClient objectForKey:@"flagid"];

				for (NSDictionary *flagTableItem in sharedVisits.flagTable) {

					NSString *flagID = [flagTableItem objectForKey:@"flagid"];
					NSString *flagSrcString = [flagTableItem objectForKey:@"src"];					
					
					if ([flagID isEqualToString:comparingFlagID]) {
						UIImageView *flagItem = [[UIImageView alloc]initWithFrame:CGRectMake(xFlag,yFlag, 32, 32)];
						flagItem.alpha = 1.0;
						UIImage *flagImg =[UIImage imageNamed:flagSrcString];
						[flagItem setImage:flagImg];
						[flagView addSubview:flagItem];
						xFlag+= 36;

					}
				}
			}
		}
	}
	
	[self setNeedsDisplay];
}
-(void)showPetPicInCell{
	
	UIButton *imagePetButton = [UIButton buttonWithType:UIButtonTypeCustom];

	if(isIphone6P) {
		imagePetButton.frame = CGRectMake(5,20, 90, 90);
	} else if (isIphone6) {
		imagePetButton.frame = CGRectMake(5,20, 80, 80);
	} else if (isIphone5) {
		imagePetButton.frame = CGRectMake(5,20, 80, 80);
	} else if (isIphone4) {
		imagePetButton.frame = CGRectMake(5,20, 70, 70);

	}
	
	petPicView = [UIButton buttonWithType:UIButtonTypeCustom];
	petPicView.frame = CGRectMake(10, 30, imagePetButton.frame.size.width, imagePetButton.frame.size.width);
	[petPicView setBackgroundImage:[UIImage imageNamed:@"doghead-frame@3x"] 
						  forState:UIControlStateNormal];
	[petPicView addTarget:self 
				   action:@selector(tapPetPic:) 
		 forControlEvents:UIControlEventTouchUpInside];
	
	
	CAShapeLayer *circle2 = [CAShapeLayer layer];
	UIBezierPath *circularPath2=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, imagePetButton.frame.size.width, imagePetButton.frame.size.height) cornerRadius:MAX(imagePetButton.frame.size.width, imagePetButton.frame.size.height)];
	circle2.path = circularPath2.CGPath;
	circle2.fillColor = [UIColor whiteColor].CGColor;
	circle2.strokeColor = [UIColor whiteColor].CGColor;
	circle2.lineWidth = 1;
	
	
	for (DataClient *client in sharedVisits.clientData) {
		if ([client.clientID isEqualToString:_visitInfo.clientptr]){
			NSArray *imgKeys = [client.petImages allKeys];
			if ([imgKeys count] > 0) {
				if (_visitInfo.currentPetImage != NULL){
					[imagePetButton setBackgroundImage:[client.petImages objectForKey:[imgKeys objectAtIndex:0]] forState:UIControlStateNormal];
					[imagePetButton addTarget:self action:@selector(tapPetPic:) forControlEvents:UIControlEventTouchUpInside];
					imagePetButton.layer.mask = circle2;
					
					[_backgroundIV addSubview:imagePetButton];
				} else {
					if ([imgKeys count] > 0) {
						[imagePetButton setBackgroundImage:[client.petImages objectForKey:[imgKeys objectAtIndex:0]] forState:UIControlStateNormal];
						[imagePetButton addTarget:self action:@selector(tapPetPic:) forControlEvents:UIControlEventTouchUpInside];
						imagePetButton.layer.mask = circle2;
						
						[_backgroundIV addSubview:imagePetButton];
					} else {
						[_backgroundIV addSubview:petPicView];
					}
				}
			}
		}
	}
}

-(void)addManagerNote:(UIButton *)managerNoteButton {
	managerNoteButton.frame = CGRectMake(_backgroundIV.frame.size.width - 32, _backgroundIV.frame.size.height - 32, 24, 24);
	[_backgroundIV addSubview:managerNoteButton];
}

-(void)visitCellTap:(id)sender {
}
-(void)tapPetPic:(id)sender {
}

-(void) setBadArrivalStatus {
	NSLog(@"Adding bad arrival label");
	arriveMessagesStatus = [[UILabel alloc]initWithFrame:CGRectMake(timeBegin.frame.origin.x + 100, timeBegin.frame.origin.y+20, 140, 40)];
	arriveMessagesStatus.numberOfLines = 2;
	[arriveMessagesStatus setFont: [UIFont fontWithName:@"Lato-Light" size:12]];
	[arriveMessagesStatus setTextColor:[UIColor redColor]];
	[arriveMessagesStatus setText:@"FAIL-RETRYING"];
	[self.contentView addSubview:arriveMessagesStatus];
}

-(void) setBadCompleteStatus {
	NSLog(@"Adding bad arrival label");
	completeMessageStatus = [[UILabel alloc]initWithFrame:CGRectMake(timeBegin.frame.origin.x + 100, timeBegin.frame.origin.y + 40, 140, 40)];
	completeMessageStatus.numberOfLines = 2;
	[completeMessageStatus setFont: [UIFont fontWithName:@"Lato-Light" size:12]];
	[completeMessageStatus setTextColor:[UIColor redColor]];
	[completeMessageStatus setText:@"FAIL-RETRYING"];
	[self.contentView addSubview:completeMessageStatus];
	
}
-(void) layoutSubviews
{
    [super layoutSubviews];
}
@end
