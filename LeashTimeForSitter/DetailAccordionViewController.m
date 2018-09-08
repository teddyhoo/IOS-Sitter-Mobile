//
//  DetailAccordionViewController.m
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 12/23/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import "DetailAccordionViewController.h"
#import "VisitsAndTracking.h"
#import "DataClient.h"
#import "VisitDetails.h"
#import "EMAccordionSection.h"
#import "PharmaStyle.h"
#import "DetailsMapView.h"
#import "FloatingModalView.h"
#import "JzStyleKit.h"
#import "FloatingModalView.h"
#define kTableHeaderHeight 70.0f
#define kTableRowHeight 80.0f


@interface DetailAccordionViewController () <UIScrollViewDelegate>

@end

@implementation DetailAccordionViewController {
    
    NSMutableArray *dataForSections;
    NSMutableArray *sections;
	NSMutableDictionary *flagIndex;
    UIButton *backButton;
    UIView *detailView;
	UIView *detailMoreDetailView;
    UIView *flagView;
    UIButton *arriveButton;
	DetailsMapView *myMapView;  

    DataClient *currentClient;
    VisitDetails *currentVisit;
    
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
    BOOL isShowingPopup;
    BOOL mapOnScreen;
    
    CGFloat origin;
    int onWhichSection;
    float tableRowHeight;
    
    NSString *visitIDSent;
    NSString *hasKey;
}

-(instancetype)init {
    if(self = [super init]) {
        
        VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
        NSString *theDeviceType = [sharedVisits tellDeviceType];
        onWhichSection = 0;
        isShowingPopup = NO;
        
        if ([theDeviceType isEqualToString:@"iPhone6P"]) {
            isIphone6P = YES;
            isIphone6 = NO;
            isIphone5 = NO;
            isIphone4 = NO;
            
        } else if ([theDeviceType isEqualToString:@"iPhone6"]) {
            isIphone6P = NO;

            isIphone6 = YES;
            isIphone5 = NO;
            isIphone4 = NO;
            
        } else if ([theDeviceType isEqualToString:@"iPhone5"]) {
            isIphone5 = YES;
            isIphone4 = NO;
            isIphone6P = NO;
            isIphone6 = NO;

        } else {
            isIphone4 = YES;
            isIphone5 = NO;
            isIphone6P = NO;
            isIphone6 = NO;
        }
        
        sections = [[NSMutableArray alloc]initWithCapacity:100];
        dataForSections = [[NSMutableArray alloc]initWithCapacity:100];    
		NSString *pListData = [[NSBundle mainBundle]
							   pathForResource:@"flagID"
							   ofType:@"plist"];
		
		flagIndex = [[NSMutableDictionary alloc] initWithContentsOfFile:pListData];
		
	}
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:YES];
	
	UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height-60) style:UITableViewStylePlain];
	[tableView setSectionHeaderHeight:kTableHeaderHeight];
	_emTV = [[EMAccordionTableViewController alloc] initWithTable:tableView withAnimationType:EMAnimationTypeNone];
	[_emTV setDelegate:self];
	[_emTV setClosedSectionIcon:[UIImage imageNamed:@"down-arrow-thick"]];
	[_emTV setOpenedSectionIcon:[UIImage imageNamed:@"up-arrow-thick"]];
	_emTV.defaultOpenedSection = -1;
		
	if([currentClient.petImages count] > 3) {
		_emParallaxHeaderView = [[EMAccordionTableParallaxHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 290)];
	} else {
		_emParallaxHeaderView = [[EMAccordionTableParallaxHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 220)];
	}
	
	UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _emParallaxHeaderView.frame.size.width, _emParallaxHeaderView.frame.size.height)];
	headerView.backgroundColor = [PharmaStyle colorBlue];

	UIView *back2 = [[UIView alloc]initWithFrame:_emParallaxHeaderView.frame];
	[back2 setBackgroundColor:[PharmaStyle colorBlueShadow]];
	[headerView addSubview:back2];
	back2.alpha = 0.2;
	
	flagView = [[UIView alloc]initWithFrame:CGRectMake(100, headerView.frame.size.height-40, self.view.frame.size.width-140, 60)];
	flagView.backgroundColor = [UIColor redColor];
	
	_emTV.parallaxHeaderView = _emParallaxHeaderView;
	
	backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0,0,32,32);
	[backButton setBackgroundImage:[UIImage imageNamed:@"left-arrow256"]
						  forState:UIControlStateNormal];
	[backButton addTarget:self
				   action:@selector(backButtonClicked:)
		 forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:_emTV.tableView];
	[self.view addSubview:backButton];
	[_emParallaxHeaderView addSubview:headerView];
	[self addDataSections];
	[self addPetImages:headerView];
	
	dispatch_async(dispatch_get_main_queue(), ^{

		[self addControlIcons:headerView];
	});
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self addClientFlags:flagView withHeader:headerView];
	});
	
	dispatch_async(dispatch_get_main_queue(), ^ {
		[self addMapView:currentVisit];
	});
}

-(void)addPetImages:(UIView*)headerView {
	
	UIView *petPicFrameView;
	
	if (isIphone6P) {
				
		int xPos = 15;
		int yPos = 20;
		int dimensionSize = 108;
		int dimensionSizePicture = 98;
		int labelOffset = 70;
		int numberPets = (int)[currentClient.petImages count];
		
		
		if (numberPets > 3) {
			labelOffset = 55;
			dimensionSize = 80;
			dimensionSizePicture = 70;
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets-80,200)];
			
		} else {
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
			
		}
		petPicFrameView.userInteractionEnabled = YES;
		petPicFrameView.tag = 100;
		
		int petCounter = 0;
		
		for (NSString *petID in currentClient.petImages) {
			
			if(petCounter == 4) {
				yPos +=100;
				xPos = 15;
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				UIImageView *currentPicView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSizePicture, dimensionSizePicture)];
				[currentPicView setImage:[currentClient.petImages objectForKey:petID]];
				CAShapeLayer *circle = [CAShapeLayer layer];
				UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, currentPicView.frame.size.width, currentPicView.frame.size.height) cornerRadius:MAX(currentPicView.frame.size.width, currentPicView.frame.size.height)];
				circle.path = circularPath.CGPath;
				circle.fillColor = [UIColor whiteColor].CGColor;
				circle.strokeColor = [UIColor whiteColor].CGColor;
				circle.lineWidth = 1;
				currentPicView.layer.mask=circle;

				int petIDTag = 0;
				for (NSDictionary *petKey in currentClient.petInfo) {
					if ([[petKey objectForKey:@"name"]isEqualToString:petID]) {
						petIDTag = [[petKey objectForKey:@"petid"]intValue];
					}
				}
				
				NSString *petIDupper = [petID uppercaseString];
				UIButton *petImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
				petImageButton.frame = CGRectMake(xPos, yPos-labelOffset, dimensionSize, dimensionSize);
				[petImageButton setTitleColor:[PharmaStyle colorAppWhite] forState:UIControlStateNormal];
				petImageButton.titleLabel.font = [UIFont fontWithName:@"Langdon" size:20];
				[petImageButton setTitle:petIDupper forState:UIControlStateNormal];
				petImageButton.tag = petIDTag;
				[petImageButton addTarget:self
								   action:@selector(petImageClick:)
						 forControlEvents:UIControlEventTouchUpInside];
				
				[petPicFrameView addSubview:petImageButton];
				[petPicFrameView addSubview:currentPicView];
			});
			
			if (numberPets > 3) {
				xPos += 80;
			} else {
				xPos += 110;
			}
			petCounter++;
			
		}
	}
	
	else if (isIphone6) {
		int xPos = 35;
		int yPos = 30;
		int dimensionSize = 94;
		int dimensionSizePicture = 82;
		int fontSize = 18;
		
		int numberPets = (int)[currentClient.petImages count];
		
		if (numberPets > 3) {
			dimensionSize = 50;
			dimensionSizePicture = 44;
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets-60,170)];
			fontSize = 14;
			
		} else {
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
		}
		petPicFrameView.userInteractionEnabled = YES;
		petPicFrameView.tag = 100;
		
		xPos = 0;
		yPos = 0;
		int petCounter = 0;
		
		for (NSString *petID in currentClient.petImages) {
			if(petCounter == 4) {
				yPos +=70;
				xPos = 0;
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				UIImageView *currentPicView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSizePicture, dimensionSizePicture)];
				[currentPicView setImage:[currentClient.petImages objectForKey:petID]];
				
				CAShapeLayer *circle = [CAShapeLayer layer];
				UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, currentPicView.frame.size.width, currentPicView.frame.size.height) cornerRadius:MAX(currentPicView.frame.size.width, currentPicView.frame.size.height)];
				circle.path = circularPath.CGPath;
				circle.fillColor = [UIColor whiteColor].CGColor;
				circle.strokeColor = [UIColor whiteColor].CGColor;
				circle.lineWidth = 1;
				currentPicView.layer.mask=circle;
				int petIDTag = 0;
				for (NSDictionary *petKey in currentClient.petInfo) {
					if ([[petKey objectForKey:@"name"]isEqualToString:petID]) {
						petIDTag = [[petKey objectForKey:@"petid"]intValue];
					}
				}
				
				UIButton *petImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
				petImageButton.frame = CGRectMake(xPos-20, yPos, dimensionSize+30, dimensionSize*2);
				[petImageButton setTitleColor:[PharmaStyle colorAppWhite] forState:UIControlStateNormal];
				petImageButton.titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:fontSize];
				[petImageButton setTitle:petID forState:UIControlStateNormal];
				petImageButton.tag = petIDTag;
				[petImageButton addTarget:self
								   action:@selector(petImageClick:)
						 forControlEvents:UIControlEventTouchUpInside];
				
				
				[petPicFrameView addSubview:currentPicView];
				[petPicFrameView addSubview:petImageButton];

			});

			if (numberPets > 3) {
				xPos += 80;
			} else {
				xPos += 94;
			}
			petCounter++;
		}
	}
	
	else if (isIphone5) {
				
		int xPos = 35;
		int yPos = 50;
		int dimensionSize = 76;
		int dimensionSizePicture = 64;
		int numberPets = (int)[currentClient.petImages count];
		
		if (numberPets > 3) {
			dimensionSize = 44;
			dimensionSizePicture = 36;
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize*4)];
			
		} else {
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
			
		}
		
		petPicFrameView.userInteractionEnabled = YES;
		petPicFrameView.tag = 100;
		
		xPos = 0;
		yPos = 0;
		int petCounter = 0;
		
		for (NSString *petID in currentClient.petImages) {
			if(petCounter == 4) {
				
				yPos +=70;
				xPos = 0;
				
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				UIImageView *currentPicView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSizePicture, dimensionSizePicture)];
				[currentPicView setImage:[currentClient.petImages objectForKey:petID]];
				
				CAShapeLayer *circle = [CAShapeLayer layer];
				UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, currentPicView.frame.size.width, currentPicView.frame.size.height) cornerRadius:MAX(currentPicView.frame.size.width, currentPicView.frame.size.height)];
				circle.path = circularPath.CGPath;
				circle.fillColor = [UIColor whiteColor].CGColor;
				circle.strokeColor = [UIColor whiteColor].CGColor;
				circle.lineWidth = 1;
				
				currentPicView.layer.mask=circle;
				int petIDTag = 0;
				for (NSDictionary *petKey in currentClient.petInfo) {
					if ([[petKey objectForKey:@"name"]isEqualToString:petID]) {
						petIDTag = [[petKey objectForKey:@"petid"]intValue];
					}
				}
								
				UIButton *petImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
				petImageButton.frame = CGRectMake(xPos, yPos, dimensionSize, dimensionSize*2);
				[petImageButton setTitleColor:[PharmaStyle colorAppWhite] forState:UIControlStateNormal];
				petImageButton.titleLabel.font = [UIFont fontWithName:@"Langdon" size:16];
				[petImageButton setTitle:petID forState:UIControlStateNormal];
				petImageButton.tag = petIDTag;
				[petImageButton addTarget:self
								   action:@selector(petImageClick:)
						 forControlEvents:UIControlEventTouchUpInside];
				
				
				[petPicFrameView addSubview:currentPicView];
				[petPicFrameView addSubview:petImageButton];
			});
			
			if (numberPets > 3) {
				xPos +=70;
			} else {
				xPos += 70;
			}
			petCounter++;
		}
	}
	
	else if (isIphone4) {
		
		int xPos = 35;
		int yPos = 50;
		int dimensionSize = 76;
		int dimensionSizePicture = 64;
		
		int numberPets = (int)[currentClient.petImages count];
		
		if (numberPets > 3) {
			dimensionSize = 44;
			dimensionSizePicture = 36;
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize*4)];
		} else {
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
		}
		
		petPicFrameView.userInteractionEnabled = YES;
		petPicFrameView.tag = 100;
		
		xPos = 0;
		yPos = 0;
		int petCounter = 0;
		
		for (NSString *petID in currentClient.petImages) {
			if(petCounter == 4) {
				yPos +=70;
				xPos = 0;
				
			}
			dispatch_async(dispatch_get_main_queue(), ^{

				UIImageView *currentPicView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSizePicture, dimensionSizePicture)];
				[currentPicView setImage:[currentClient.petImages objectForKey:petID]];
				CAShapeLayer *circle = [CAShapeLayer layer];
				UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, currentPicView.frame.size.width, currentPicView.frame.size.height) cornerRadius:MAX(currentPicView.frame.size.width, currentPicView.frame.size.height)];
				circle.path = circularPath.CGPath;
				circle.fillColor = [UIColor whiteColor].CGColor;
				circle.strokeColor = [UIColor whiteColor].CGColor;
				circle.lineWidth = 1;
				
				currentPicView.layer.mask=circle;
				
				int petIDTag = 0;
				for (NSDictionary *petKey in currentClient.petInfo) {
					if ([[petKey objectForKey:@"name"]isEqualToString:petID]) {
						petIDTag = [[petKey objectForKey:@"petid"]intValue];
					}
				}
				
				UIButton *petImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
				petImageButton.frame = CGRectMake(xPos, yPos, dimensionSize, dimensionSize*2);
				[petImageButton setTitleColor:[PharmaStyle colorAppWhite] forState:UIControlStateNormal];
				petImageButton.titleLabel.font = [UIFont fontWithName:@"Langdon" size:16];
				[petImageButton setTitle:petID forState:UIControlStateNormal];
				petImageButton.tag = petIDTag;
				[petImageButton addTarget:self
								   action:@selector(petImageClick:)
						 forControlEvents:UIControlEventTouchUpInside];
				
				
				[petPicFrameView addSubview:currentPicView];
				[petPicFrameView addSubview:petImageButton];
			});
			
			if (numberPets > 3) {
				xPos +=70;
			} else {
				xPos += 70;
			}
			petCounter++;
		} 
	}
	
	[headerView addSubview:petPicFrameView];
	
}
-(void)addControlIcons:(UIView *)headerView {
	
	UIButton *keyIcon;
	UIButton *mapButton;
	UIButton *noteFromManager;
	UIButton *basicInfoNote;
	UIButton *makeCall;
	UILabel *hasKeyLabel;
	
	keyIcon = [UIButton buttonWithType:UIButtonTypeCustom];
	mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	makeCall = [UIButton buttonWithType:UIButtonTypeCustom];
	noteFromManager = [UIButton buttonWithType:UIButtonTypeCustom];
	basicInfoNote = [UIButton buttonWithType:UIButtonTypeCustom];
	arriveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	if (isIphone6P) {
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,_emParallaxHeaderView.frame.size.height - 80,16,32);
		noteFromManager.frame = CGRectMake(10, _emParallaxHeaderView.frame.size.height - 40, 32, 32);
		basicInfoNote.frame = CGRectMake(50,_emParallaxHeaderView.frame.size.height - 40,32, 32);
		makeCall.frame = CGRectMake(90, _emParallaxHeaderView.frame.size.height - 40, 20, 32);
		arriveButton.frame = CGRectMake(_emParallaxHeaderView.frame.size.width - 40, _emParallaxHeaderView.frame.size.height - 40, 32,32);
	} else if (isIphone6) {
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,_emParallaxHeaderView.frame.size.height -80,16,32);
		noteFromManager.frame = CGRectMake(10, _emParallaxHeaderView.frame.size.height - 40, 32, 32);
		basicInfoNote.frame = CGRectMake(50,_emParallaxHeaderView.frame.size.height - 40,32, 32);
		makeCall.frame = CGRectMake(90, _emParallaxHeaderView.frame.size.height - 40, 20, 32);
		arriveButton.frame = CGRectMake(_emParallaxHeaderView.frame.size.width - 40, _emParallaxHeaderView.frame.size.height - 40, 32,32);
	} else if (isIphone5) {
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,_emParallaxHeaderView.frame.size.height - 80,16,32);
		noteFromManager.frame = CGRectMake(10, _emParallaxHeaderView.frame.size.height - 40, 32, 32);
		basicInfoNote.frame = CGRectMake(50,_emParallaxHeaderView.frame.size.height - 40,32, 32);
		makeCall.frame = CGRectMake(90, _emParallaxHeaderView.frame.size.height - 40, 20, 32);
		arriveButton.frame = CGRectMake(_emParallaxHeaderView.frame.size.width - 40, _emParallaxHeaderView.frame.size.height - 40, 32,32);
	} else if (isIphone4) {
		
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,_emParallaxHeaderView.frame.size.height - 80,16,32);
		noteFromManager.frame = CGRectMake(10, _emParallaxHeaderView.frame.size.height - 40, 32, 32);
		makeCall.frame = CGRectMake(90, _emParallaxHeaderView.frame.size.height - 40, 20, 32);
		basicInfoNote.frame = CGRectMake(50,_emParallaxHeaderView.frame.size.height - 40,32, 32);
		arriveButton.frame = CGRectMake(_emParallaxHeaderView.frame.size.width - 40, _emParallaxHeaderView.frame.size.height - 40, 32,32);
		
	}
	
	if([currentVisit.status isEqualToString:@"arrived"]){
		[arriveButton setBackgroundImage:[UIImage imageNamed:@"unarrive-button-pink"]
								forState:UIControlStateNormal];
		[arriveButton addTarget:self
						 action:@selector(markUnarrive)
			   forControlEvents:UIControlEventTouchUpInside];
	}
	else if ([currentVisit.status isEqualToString:@"future"]) {
		[arriveButton setBackgroundImage:[UIImage imageNamed:@"arrive-pink-button"]
								forState:UIControlStateNormal];
		[arriveButton addTarget:self
						 action:@selector(markArrive)
			   forControlEvents:UIControlEventTouchUpInside];
		arriveButton.alpha = 0.8;
	}
	else if ([currentVisit.status isEqualToString:@"canceled"]) {
		[arriveButton setBackgroundImage:[UIImage imageNamed:@"x-mark-red"]
								forState:UIControlStateNormal];
	}
	else if ([currentVisit.status isEqualToString:@"completed"]) {
		[arriveButton setBackgroundImage:[UIImage imageNamed:@"check-mark-green"]
								forState:UIControlStateNormal];
	}
	
	[noteFromManager setBackgroundImage:[UIImage imageNamed:@"manager-note-icon-128x128"] forState:UIControlStateNormal];
	[noteFromManager addTarget:self action:@selector(showNote) forControlEvents:UIControlEventTouchUpInside];
	
	[basicInfoNote setBackgroundImage:[UIImage imageNamed:@"fileFolder-profile"] forState:UIControlStateNormal];
	[basicInfoNote addTarget:self action:@selector(showBasicInfo) forControlEvents:UIControlEventTouchUpInside];
	
	[makeCall setBackgroundImage:[UIImage imageNamed:@"cell-phone-white"] forState:UIControlStateNormal];
	[makeCall addTarget:self action:@selector(makePhoneCall) forControlEvents:UIControlEventTouchUpInside];
	
	[mapButton setBackgroundImage:[UIImage imageNamed:@"compass-icon"]
						 forState:UIControlStateNormal];
	[mapButton addTarget:self
				  action:@selector(showMapAndDirections:)
	 forControlEvents:UIControlEventTouchUpInside];
	
	NSString *keyIDString = currentVisit.keyID;
	
	if ([hasKey isEqualToString:@"NEED KEY"]) {
		if ([keyIDString isEqualToString:@"NO KEY"]) {
			hasKeyLabel = [[UILabel alloc]initWithFrame:CGRectMake(keyIcon.frame.origin.x+20, keyIcon.frame.origin.y+14, 100, 16)];
			[hasKeyLabel setFont:[UIFont fontWithName:@"Lato-Heavy" size:12]];
		} else {
			hasKeyLabel = [[UILabel alloc]initWithFrame:CGRectMake(keyIcon.frame.origin.x+20, keyIcon.frame.origin.y+14, 100, 16)];
			[hasKeyLabel setFont:[UIFont fontWithName:@"Lato-Heavy" size:16]];
		}
		
		[keyIcon setBackgroundImage:[UIImage imageNamed:@"key-red-4ptstroke"] forState:UIControlStateNormal];
		[hasKeyLabel setTextColor:[PharmaStyle colorYellow]];
		[hasKeyLabel setText:keyIDString];
	} else {
		hasKeyLabel = [[UILabel alloc]initWithFrame:CGRectMake(keyIcon.frame.origin.x+20, keyIcon.frame.origin.y+14, 100, 16)];
		[hasKeyLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
		[keyIcon setBackgroundImage:[UIImage imageNamed:@"key-gold-stroke2pt"] forState:UIControlStateNormal];
		[hasKeyLabel setTextColor:[PharmaStyle colorYellow]];
		[hasKeyLabel setText:keyIDString];
	}
	
	[headerView addSubview:keyIcon];
	[headerView addSubview:hasKeyLabel];
	if ([currentVisit.note isEqual:[NSNull null]] && [currentVisit.note length] > 0  ) { 
		[headerView addSubview:noteFromManager];
	}
	if (![currentClient.basicInfoNotes isEqual:[NSNull null]] && [currentClient.basicInfoNotes length] > 0) {
		[headerView addSubview:basicInfoNote];
	}
	[headerView addSubview:noteFromManager];
	[headerView addSubview:makeCall];
	[headerView addSubview:arriveButton];	
	[headerView addSubview:mapButton];
	
	/*if((![currentClient.cellphone isEqual:[NSNull null]] && [currentClient.cellphone length] > 0) ||
	   (![currentClient.cellphone2 isEqual:[NSNull null]] && [currentClient.cellphone2 length] > 0) ||
	   (![currentClient.homePhone isEqual:[NSNull null]] && [currentClient.homePhone length] > 0) ||
	   (![currentClient.workphone isEqual:[NSNull null]] && [currentClient.workphone length] > 0)){*/
	//}

}
-(void)showMapAndDirections:(id)sender {

	if (mapOnScreen) {
		[UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
			CGRect newFrame = CGRectMake(myMapView.frame.origin.x, 
										 self.view.frame.size.height, 
										 myMapView.frame.size.width,
										 myMapView.frame.size.height);
			myMapView.frame = newFrame;
			[myMapView layoutIfNeeded];
			
		} completion:^(BOOL finished) {

			mapOnScreen = NO;	

		}];
		
	} else {		
		[UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
			CGRect newFrame = CGRectMake(myMapView.frame.origin.x, 
										 self.view.frame.origin.y+100, 
										 myMapView.frame.size.width,
										 myMapView.frame.size.height);
			myMapView.frame = newFrame;
			[myMapView layoutIfNeeded];
			
		} completion:^(BOOL finished) {
			mapOnScreen = YES;
		}];
	}
}

-(void)addMapView:(VisitDetails*)visitDetails {

    float latitude = [visitDetails.latitude floatValue];
    float longitude = [visitDetails.longitude floatValue];
    CLLocationCoordinate2D clientLocation = CLLocationCoordinate2DMake(latitude,longitude);
	
	float latVet = [currentClient.vetLat floatValue];
	float lonVet = [currentClient.vetLon floatValue];
	CLLocationCoordinate2D vetLocation = CLLocationCoordinate2DMake(latVet, lonVet);
	
	myMapView = [[DetailsMapView alloc]initWithClientLocation:clientLocation 
																  vetLocation:vetLocation 
																	withFrame:CGRectMake(self.view.frame.origin.x, 
																						 self.view.frame.size.height, 
																						 self.view.frame.size.width, 
																						 self.view.frame.size.height-100)];
	

	[self.view addSubview:myMapView];
}
-(void)petImageClick:(id)sender {
    
    if (isShowingPopup) {
        [detailView removeFromSuperview];
        detailView = nil;
    }
    
    isShowingPopup = YES;

    UIButton *button = (UIButton*)sender;
    NSString *petIDString = [NSString stringWithFormat:@"%li",(long)button.tag];
    float fontSize = 18;
    float widthView = self.view.frame.size.width - 60;
    float dimensionXY = 150;

    if (isIphone6P) {
        detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 60, self.view.frame.size.width-40, 590)];
    } else if (isIphone6) {
        detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 60, self.view.frame.size.width-40, 520)];
    } else if (isIphone5) {
        detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, 480)];
        fontSize = 16;
        dimensionXY = 120;
    } else if (isIphone4) {
        detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 50, self.view.frame.size.width-40, 450)];
        fontSize = 14;
        dimensionXY = 120;
    }
    
    detailView.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
    UIImage *backImg = [JzStyleKit imageOfJzCardWithJzCardFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height) rectangle2:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
    [backgroundImg setImage:backImg];
    
    [detailView addSubview:backgroundImg];
    for (NSDictionary *petDic in currentClient.petInfo) {
        if ([[petDic objectForKey:@"petid"]isEqualToString:petIDString]) {
            UILabel *petLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 20, 300, 28)];
            [petLabel setFont:[UIFont fontWithName:@"CompassRoseCPC-Bold" size:24]];
            [petLabel setText:[petDic objectForKey:@"name"]];
            [petLabel setTextColor:[PharmaStyle colorYellow]];
            [detailView addSubview:petLabel];
            
            UIImageView *petImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, dimensionXY, dimensionXY)];
            [petImageView setImage:[currentClient.petImages objectForKey:[petDic objectForKey:@"name"]]];
            CAShapeLayer *circle2 = [CAShapeLayer layer];
            UIBezierPath *circularPath2=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImageView.frame.size.width, petImageView.frame.size.height) cornerRadius:MAX(petImageView.frame.size.width, petImageView.frame.size.height)];
            circle2.path = circularPath2.CGPath;
            circle2.fillColor = [UIColor whiteColor].CGColor;
            circle2.strokeColor = [UIColor whiteColor].CGColor;
            circle2.lineWidth = 1;
            
            petImageView.layer.mask = circle2;
            [detailView addSubview:petImageView];
            
            NSString *breedStr = [petDic objectForKey:@"breed"];
            NSString *colorStr = [petDic objectForKey:@"color"];
            NSString *birthDaystr = [petDic objectForKey:@"birthday"];
            NSString *descriptionStr = [petDic objectForKey:@"description"];
            NSString *notesStr = [petDic objectForKey:@"notes"];

            UILabel *petLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(dimensionXY + 30, 50, 120, 40)];
            petLabel2.numberOfLines = 2;
            [petLabel2 setFont:[UIFont fontWithName:@"CompassRoseCPC-Bold" size:14]];
            [petLabel2 setTextColor:[PharmaStyle colorAppWhite]];
            [detailView addSubview:petLabel2];
            
            UILabel *petLabel5 = [[UILabel alloc]initWithFrame:CGRectMake(dimensionXY + 30, 90, widthView, 40)];
            petLabel5.numberOfLines = 2;
            [petLabel5 setFont:[UIFont fontWithName:@"CompassRoseCPC-Bold" size:fontSize]];
            [petLabel5 setTextColor:[PharmaStyle colorAppWhite]];
            [detailView addSubview:petLabel5];
            
            UILabel *petLabel6 = [[UILabel alloc]initWithFrame:CGRectMake(dimensionXY + 30, 130, widthView, 40)];
            petLabel6.numberOfLines = 2;
            [petLabel6 setFont:[UIFont fontWithName:@"CompassRoseCPC-Bold" size:fontSize]];
            [petLabel6 setTextColor:[PharmaStyle colorAppWhite]];
            [detailView addSubview:petLabel6];
            
            
            UILabel *petLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 180, widthView, 120)];
            petLabel3.numberOfLines = 5;
            [petLabel3 setFont:[UIFont fontWithName:@"CompassRoseCPC-Regular" size:fontSize]];
            [petLabel3 setTextColor:[PharmaStyle colorAppWhite]];
            [detailView addSubview:petLabel3];
            
            UILabel *petLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(10, 230, widthView, 320)];
            petLabel4.numberOfLines = 14;
            [petLabel4 setFont:[UIFont fontWithName:@"CompassRoseCPC-Regular" size:fontSize]];
            [petLabel4 setTextColor:[PharmaStyle colorAppWhite]];
            [detailView addSubview:petLabel4];
            
            if (![breedStr isEqual:[NSNull null]] && [breedStr length] > 0) {
                [petLabel2 setText:breedStr];
                
            }
            if (![colorStr isEqual:[NSNull null]] && [colorStr length] > 0) {
                [petLabel5 setText:colorStr];
                
            }
            if (![birthDaystr isEqual:[NSNull null]] && [birthDaystr length] > 0) {
                [petLabel6 setText:birthDaystr];
                
            }
            if (![descriptionStr isEqual:[NSNull null]] && [descriptionStr length] > 0) {
                
                [petLabel3 setText:descriptionStr];
            }
            if (![notesStr isEqual:[NSNull null]] && [notesStr length] > 0) {
                
                [petLabel4 setText:notesStr];
            }
        }
    }
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(10, 10, 24, 24);
    [doneButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [doneButton addTarget:self
                   action:@selector(detailPopUpDismiss)
         forControlEvents:UIControlEventTouchUpInside];
    
    [detailView addSubview:doneButton];
    [self.view addSubview:detailView];
}

-(void)showBasicInfo {
	if (isShowingPopup) {
		[detailView removeFromSuperview];
		detailView = nil;
	}
	
	isShowingPopup = YES;
	
	detailView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height - 80)];
	detailView.backgroundColor = [UIColor clearColor];

	
	UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
	UIImage *backImg = [JzStyleKit imageOfJzCardWithJzCardFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height) rectangle2:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
	[backgroundImg setImage:backImg];
	[detailView addSubview:backgroundImg];
	
	NSString *basicInfoNote = currentClient.basicInfoNotes;
	int basicInfoNoteNumLines = [self calcNumLines:basicInfoNote];
	int basicInfoNoteHeight = [self calcHeight:basicInfoNote];
	int fontNoteSize = 18;
	
 	UILabel *basicOfficeNoteLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, detailView.frame.size.width - 40, 18)];
	basicOfficeNoteLabel.numberOfLines = basicInfoNoteNumLines;
	[basicOfficeNoteLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
	[basicOfficeNoteLabel setTextColor:[PharmaStyle colorRedBright]];
	[basicOfficeNoteLabel setText:@"CLIENT PROFILE  NOTE"];
	basicOfficeNoteLabel.textAlignment = NSTextAlignmentCenter;
	[detailView addSubview:basicOfficeNoteLabel];
	
	UILabel *basicOfficeNoteTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, basicOfficeNoteLabel.frame.origin.y + 22, detailView.frame.size.width - 30, basicInfoNoteHeight)];
	basicOfficeNoteTextLabel.numberOfLines = basicInfoNoteNumLines;
	[basicOfficeNoteTextLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:fontNoteSize]];
	[basicOfficeNoteTextLabel setTextColor:[PharmaStyle colorAppWhite]];
	[basicOfficeNoteTextLabel setText:basicInfoNote];
	
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 27, detailView.frame.size.width-52, detailView.frame.size.height)];
	UIEdgeInsets inset = UIEdgeInsetsMake(10, 10, 10,10);
	scrollView.contentInset = inset;
	scrollView.contentSize = CGSizeMake(detailView.frame.size.width-52, basicInfoNoteHeight);
	scrollView.contentOffset = CGPointZero;
	
	[scrollView setScrollEnabled:YES];
	scrollView.showsVerticalScrollIndicator = YES;
	scrollView.delegate = self;
	[scrollView addSubview:basicOfficeNoteTextLabel];
	[detailView addSubview:scrollView];
	[self.view addSubview:detailView];

	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(10, 10, 24, 24);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
	[doneButton addTarget:self
				   action:@selector(detailPopUpDismiss)
		 forControlEvents:UIControlEventTouchUpInside];
	[detailView addSubview:doneButton];
}

-(int)calcNumLines:(NSString*)term {
	
	int numLines = 1;

	if ([term length] > 48) {
		numLines = (int)[term length] / 1.2;
	} else if ([term length] > 28 && [term length] < 48) {
		numLines = 2;
	}
	return numLines;
	
}
-(int)calcHeight:(NSString*)term {
	
	int termLen = [term length];
	NSArray *lineArray = [term componentsSeparatedByString:@"\n"];
	int numLineCarriageReturn =(int) [lineArray count];
	int height = (int)[term length]/2.2;
	
	
	if (termLen < 75 && termLen> 43) {
		height = 45;
	} else if (termLen> 28 && termLen< 44) {
		height = 26;
	} else if (termLen < 29) {
		height = 20;
	} else if (termLen < 104 && termLen >75 ) {
		height = 90;
	}
	height = height + (numLineCarriageReturn * 24);
	//NSLog(@"TERM: %@ -- > Term length: %lu, num carriage return: %i, height: %i", term, (unsigned long)[term length], numLineCarriageReturn, height);

	return height;	
}

-(void)showNote {
    if (isShowingPopup) {
        [detailView removeFromSuperview];
        detailView = nil;
    }
    
    isShowingPopup = YES;
    
    detailView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height - 20)];
    detailView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
    UIImage *backImg = [JzStyleKit imageOfJzCardWithJzCardFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height) rectangle2:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
    [backgroundImg setImage:backImg];
    [detailView addSubview:backgroundImg];
    
    NSString *noteString = currentVisit.note;
	int numLineCarriageReturn = 0;
	NSArray *wordArray = [noteString componentsSeparatedByString:@"\n"];
	numLineCarriageReturn =(int) [wordArray count];
	
	int mgrNoteLines = [self calcNumLines:noteString];
	int fontNoteSize = 16;
	int numberOfLines = 16;
	int yHeight = detailView.frame.size.height/ 2;
	
	if (mgrNoteLines < numLineCarriageReturn) {
		mgrNoteLines = numLineCarriageReturn;
	}
	
	if (mgrNoteLines > 22) {
		yHeight = detailView.frame.size.height- 60;
		fontNoteSize = 14;
		numberOfLines = 34;	
	} 
	
    UILabel *noteLabelMgr = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, detailView.frame.size.width - 40, 22)];
    noteLabelMgr.numberOfLines =3;
    [noteLabelMgr setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [noteLabelMgr setTextColor:[PharmaStyle colorRedBright]];
    [noteLabelMgr setText:@"MANAGER NOTE"];
    noteLabelMgr.textAlignment = NSTextAlignmentCenter;
    [detailView addSubview:noteLabelMgr];
    
    UILabel *noteLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(10, noteLabelMgr.frame.origin.y + 40, detailView.frame.size.width - 10, yHeight)];
    noteLabel1.numberOfLines = mgrNoteLines;
    [noteLabel1 setFont:[UIFont fontWithName:@"Lato-Regular" size:fontNoteSize]];
    [noteLabel1 setTextColor:[PharmaStyle colorAppWhite]];
    [noteLabel1 setText:noteString];
    [detailView addSubview:noteLabel1];
    
    [self.view addSubview:detailView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(10, 10, 24, 24);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
	[doneButton addTarget:self
				   action:@selector(detailPopUpDismiss)
		 forControlEvents:UIControlEventTouchUpInside];
	[detailView addSubview:doneButton];
}
-(void)backButtonClicked:(id)sender {
    [_emParallaxHeaderView removeFromSuperview];
    [_emTV removeFromParentViewController];

    _emTV.tableView.delegate = nil;
    _emTV = nil;
    
    _emParallaxHeaderView = nil;
    
    currentVisit = nil;

    [detailView removeFromSuperview];
    detailView = nil;
    
    [flagView removeFromSuperview];
    flagView = nil;
    
    [arriveButton removeFromSuperview];
    arriveButton = nil;
    
    [dataForSections removeAllObjects];
    [sections removeAllObjects];
    
    [backButton removeFromSuperview];
    backButton = nil;
	[self.view removeFromSuperview];
}

-(void) addClientFlags:(UIView*)flagViewForFlag
            withHeader:(UIView*)headerView {
    int x = 110;
    int y = headerView.frame.size.height - 40;
    int numRows = 0;
	UIButton *flagDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagDetailButton.frame = CGRectMake(flagViewForFlag.frame.origin.x, headerView.frame.size.height-60, flagViewForFlag.frame.size.width, flagViewForFlag.frame.size.height);
	[flagDetailButton addTarget:self action:@selector(flagDetailClicked:) forControlEvents:UIControlEventTouchUpInside];
	flagViewForFlag.userInteractionEnabled = YES;
	
	[headerView addSubview:flagDetailButton];
    VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];

	for (NSDictionary *flagDicClient in currentClient.clientFlagsArray) {
		NSString *comparingFlagID = [flagDicClient objectForKey:@"flagid"];

        for (NSDictionary *flagTableItem in sharedVisits.flagTable) {
			
            NSString *flagID = [flagTableItem objectForKey:@"flagid"];
            NSString *flagSrcString = [flagTableItem objectForKey:@"src"];

			if ([flagID isEqualToString:comparingFlagID]) {
				
                UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
                flagButton.frame  = CGRectMake(x, y, 32,32);
				UIImage *flagImg =[UIImage imageNamed:flagSrcString];
				[flagButton setImage:flagImg forState:UIControlStateNormal];
                [flagButton addTarget:self
                               action:@selector(flagDetailClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
                
                int flagTag = [flagID intValue];
                flagButton.tag = flagTag;

                x += 32;
                
                if (x > self.view.frame.size.width - 40) {
                    x = 110;
                    y -= 32;
                    numRows++;
                    
                }
                if (numRows <= 2) {
                    [headerView addSubview:flagButton];
                }
            }
        }
        
    }
    int clientIDTag = [currentClient.clientID intValue];
	flagDetailButton.tag = clientIDTag;
}

-(NSMutableArray*)orderTermsForDetails:(NSMutableArray*)accordionSection
                               forType:(NSString*)type {

    NSMutableArray *orderedTerms = [[NSMutableArray alloc]init];
	
    if ([type isEqualToString:@"petInfo"]) {
        int numPets = (int)[accordionSection count];
        
        if(numPets == 1) {
            NSDictionary *petInfo = [accordionSection objectAtIndex:0];
            NSString *petID = [petInfo objectForKey:@"petid"];
            NSMutableDictionary *dicForID = [[NSMutableDictionary alloc]init];
            [dicForID setObject:petID forKey:@"Pet ID"];
            [dicForID setObject:[petInfo objectForKey:@"name"] forKey:@"petname"];
            [orderedTerms addObject:dicForID];
            
			if(![[petInfo objectForKey:@"name"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"name"]length] > 0){
                [orderedTerms addObject:[petInfo objectForKey:@"name"]];
			} else {
				[orderedTerms addObject:@"              "];
			}
            
			if(![[petInfo objectForKey:@"type"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"type"]length] > 0) {
                [orderedTerms addObject:[petInfo objectForKey:@"type"]];
			} else {
				[orderedTerms addObject:@"              "];
			}
            
			if(![[petInfo objectForKey:@"breed"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"breed"]length] > 0) {
                [orderedTerms addObject:[petInfo objectForKey:@"breed"]];
			} else {
				[orderedTerms addObject:@"              "];
			}
		
			if(![[petInfo objectForKey:@"color"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"color"]length] > 0) {
                [orderedTerms addObject:[petInfo objectForKey:@"color"]];
			} else {
				[orderedTerms addObject:@"              "];
			}
            
			if(![[petInfo objectForKey:@"sex"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"sex"]length] > 0) {
				NSString *genderString = @"";
				if([[petInfo objectForKey:@"sex"] isEqualToString:@"m"]) {
					genderString = @"MALE";
				} else {
					genderString = @"FEMALE";
				}
				if(![[petInfo objectForKey:@"fixed"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"fixed"]length] > 0) {
					NSString *fixString = [NSString stringWithFormat:@"Fixed: %@",[petInfo objectForKey:@"fixed"]];
					genderString = [genderString stringByAppendingString:@"       "];
					genderString = [genderString stringByAppendingString:fixString];
					[orderedTerms addObject:genderString];
				} else {
					[orderedTerms addObject:genderString];
				}
			} else {
				[orderedTerms addObject:@"              "];
			}
			
            if(![[petInfo objectForKey:@"birthday"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"birthday"]length] > 0)
                [orderedTerms addObject:[petInfo objectForKey:@"birthday"]];

			if(![[petInfo objectForKey:@"notes"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"notes"]length] > 0) {
				[orderedTerms addObject:[petInfo objectForKey:@"notes"]];
			}
			if(![[petInfo objectForKey:@"description"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"description"]length] > 0) {
				[orderedTerms addObject:[petInfo objectForKey:@"description"]];
			}
		
            NSMutableArray *customFieldBool = [[NSMutableArray alloc]init];
			NSMutableArray *docArray = [[NSMutableArray alloc]init];

            for (id keyVal in petInfo) {

                if ([[petInfo objectForKey:keyVal]isKindOfClass:[NSDictionary class]]) {
					NSDictionary *petCustomDic = [petInfo objectForKey:keyVal];
					id fieldEval = [petCustomDic objectForKey:@"value"];
					if(![[petCustomDic objectForKey:@"value"]isEqual:[NSNull null]]) {
						if ([fieldEval isKindOfClass:[NSDictionary class]]) {
							NSMutableDictionary *docAttach = (NSMutableDictionary*)[petCustomDic objectForKey:@"value"];
							[docAttach setObject:@"docAttach" forKey:@"type"];
							[docAttach setObject:petID forKey:@"petid"];
							[docArray addObject:docAttach];
						} else if ([fieldEval isKindOfClass:[NSString class]]) {
							NSString *fieldVal = [petCustomDic objectForKey:@"value"];
							if([fieldVal isEqualToString:@"1"] ||
							   [fieldVal isEqualToString:@"0"]) {
								[customFieldBool addObject:petCustomDic];
							} else {
								[orderedTerms addObject:petCustomDic];
							}
						}
					}
                }
            }
            [orderedTerms addObject:customFieldBool];
            
        } else if(numPets > 1) {
            
            for(int i = 0; i < numPets; i++) {
                
                NSDictionary *petInfo = [accordionSection objectAtIndex:i];
                NSString *petID = [petInfo objectForKey:@"petid"];
                NSMutableDictionary *dicForID = [[NSMutableDictionary alloc]init];
                [dicForID setObject:[petInfo objectForKey:@"name"] forKey:@"petname"];
                [dicForID setObject:petID forKey:@"Pet ID"];
                [orderedTerms addObject:dicForID];

				if(![[petInfo objectForKey:@"name"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"name"]length] > 0){
					[orderedTerms addObject:[petInfo objectForKey:@"name"]];
				} else {
					[orderedTerms addObject:@"              "];
				}
				
				if(![[petInfo objectForKey:@"type"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"type"]length] > 0) {
					[orderedTerms addObject:[petInfo objectForKey:@"type"]];
				} else {
					[orderedTerms addObject:@"              "];
				}
				
				if(![[petInfo objectForKey:@"breed"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"breed"]length] > 0) {
					[orderedTerms addObject:[petInfo objectForKey:@"breed"]];
				} else {
					[orderedTerms addObject:@"              "];
				}
				
				if(![[petInfo objectForKey:@"color"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"color"]length] > 0) {
					[orderedTerms addObject:[petInfo objectForKey:@"color"]];
				} else {
					[orderedTerms addObject:@"              "];
				}

				if(![[petInfo objectForKey:@"sex"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"sex"]length] > 0) {
					NSString *genderString = @"";

					if([[petInfo objectForKey:@"sex"]isEqualToString:@"m"]) {
						genderString = @"Male";
					} else {
						genderString = @"Female";
					}
					
					if(![[petInfo objectForKey:@"birthday"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"birthday"]length] > 0)
						[orderedTerms addObject:[petInfo objectForKey:@"birthday"]];
					
					
					if(![[petInfo objectForKey:@"fixed"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"fixed"]length] > 0) {
						
						NSString *fixString = [NSString stringWithFormat:@"Fixed: %@",[petInfo objectForKey:@"fixed"]];
						genderString = [genderString stringByAppendingString:@"    "];
						genderString = [genderString stringByAppendingString:fixString];
						[orderedTerms addObject:genderString];
						
					} else {
						[orderedTerms addObject:genderString];
					}
				} else {
					[orderedTerms addObject:@"              "];
				}
				
				if(![[petInfo objectForKey:@"notes"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"notes"]length] > 0) {
					[orderedTerms addObject:[petInfo objectForKey:@"notes"]];
				}
				
				if(![[petInfo objectForKey:@"description"]isEqual:[NSNull null]] && [[petInfo objectForKey:@"description"]length] > 0) {
					[orderedTerms addObject:[petInfo objectForKey:@"description"]];					
				}
				
                NSMutableArray *customFieldBool = [[NSMutableArray alloc]init];
				NSMutableArray *docArray = [[NSMutableArray alloc]init];
				
                for (id keyVal in petInfo) {
                    if ([[petInfo objectForKey:keyVal]isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *petCustomDic = [petInfo objectForKey:keyVal];
						id fieldEval = [petCustomDic objectForKey:@"value"];
                        if(![[petCustomDic objectForKey:@"value"]isEqual:[NSNull null]]) {
							if ([fieldEval isKindOfClass:[NSDictionary class]]) {
								NSMutableDictionary *docAttach = (NSMutableDictionary*)[petCustomDic objectForKey:@"value"];
								[docAttach setObject:@"docAttach" forKey:@"type"];
								[docAttach setObject:petID forKey:@"petid"];
								[docArray addObject:docAttach];
							} else if ([fieldEval isKindOfClass:[NSString class]]) {
								NSString *fieldVal = [petCustomDic objectForKey:@"value"];
								if([fieldVal isEqualToString:@"1"] ||
								   [fieldVal isEqualToString:@"0"]) {
									[customFieldBool addObject:petCustomDic];
								} else {
									[orderedTerms addObject:petCustomDic];
								}
							}
                        }
                    }
                }
                [orderedTerms addObject:customFieldBool];
				[orderedTerms addObject:docArray];
            }
        }
    }
    return orderedTerms;
}

-(UIView*)createCustomClientSections:(NSMutableArray*)accordionSection atTableRow:(NSIndexPath*)row {
    int y = 20;
    int x = 20;
    int ySection = y;
    int yOffset = 40;
    int numFields = (int)[accordionSection count];
	int width = self.view.frame.size.width - 50;
	ySection = 20;
	
    NSMutableArray *labelArray = [[NSMutableArray alloc]init];
    NSMutableArray *iconArray = [[NSMutableArray alloc]init];

    for(int i = 0; i < numFields; i++) {
        NSDictionary *customField = [accordionSection objectAtIndex:i];
		if ([[customField objectForKey:@"type"] isEqualToString:@"docAttach"]) {
			NSString *fieldLabel = [customField objectForKey:@"fieldlabel"];
			NSString *label = [customField objectForKey:@"label"];
			//NSString *url = [customField objectForKey:@"url"];
			NSString *docAttachIndex = [customField objectForKey:@"errataIndex"];
			int docIndex = (int)[docAttachIndex integerValue];
				
			UIButton *docAttachButton = [UIButton buttonWithType:UIButtonTypeCustom];
			docAttachButton.frame = CGRectMake(5, y, 32, 32);
			[docAttachButton setBackgroundImage:[UIImage imageNamed:@"file-folder-line"]
									   forState:UIControlStateNormal];
			[docAttachButton addTarget:self 
								action:@selector(tapDocView:) 
					  forControlEvents:UIControlEventTouchUpInside];

			docAttachButton.tag = docIndex;
			[iconArray addObject:docAttachButton];
			
			UILabel *docLabel = [[UILabel alloc]initWithFrame:CGRectMake(x + 40, y, width-40, 40)];
			[docLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
			[docLabel setNumberOfLines:2];
			[docLabel setTextColor:[UIColor blackColor]];
			[docLabel setText:fieldLabel];
			[labelArray addObject:docLabel];
			
			y = y + 40;
			
			UILabel *docLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(x + 40, y, width-40, 40)];
			[docLabel2 setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
			[docLabel2 setNumberOfLines:2];
			[docLabel2 setTextColor:[UIColor blackColor]];
			[docLabel2 setText:label];
			[labelArray addObject:docLabel2];
			
			y = y + 40;
			
			
		} else {
			
			NSString *label = [customField objectForKey:@"label"];
			NSString *value = [customField objectForKey:@"value"];
			
			int sectionHeight = [self calcHeight:label]+20;
			int numLines = [self calcNumLines:label];
			
			int sectionHeight2 = [self calcHeight:value]+20;
			int numLines2 = [self calcNumLines:value];
						
			UILabel *labelInfo = [self createTermLabel:label
												  xPos:x
												  yPos:y
												 width:width
												height:sectionHeight
											  numLines:numLines withLabelType:@"custom"];
			
			y += sectionHeight;
			
			UILabel *valInfo = [self createTermLabel:value
												xPos:x
												yPos:y
											   width:width-x
											  height:sectionHeight2
											numLines:numLines2 withLabelType:@"value"];
			
			ySection += yOffset;
			y = y + sectionHeight2;
			
			UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(x-10, y, width-20, 1)];
			[divider setImage:[UIImage imageNamed:@"white-line-1px"]];
			[iconArray addObject:divider];
			[labelArray addObject:labelInfo];
			[labelArray addObject:valInfo];
		}
    }
    
    yOffset = y;

    y +=50;
    x = 40;
    
    for(NSDictionary *checkDic in currentClient.customClientCheckBox) {
        ySection += y;
		int numLines = [self calcNumLines:[checkDic objectForKey:@"label"]];
		int heightLabel = [self calcHeight:[checkDic objectForKey:@"label"]];
        UIImageView *iconFor = [[UIImageView alloc]initWithFrame:CGRectMake(x-30, y+5, 20, 20)];
        UILabel *titleLbl2 = [[UILabel alloc ]initWithFrame:CGRectMake(x, y, self.view.bounds.size.width - 80, heightLabel)];
        
        y += heightLabel;
        
        [titleLbl2 setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [titleLbl2 setText:[checkDic objectForKey:@"label"]];
        titleLbl2.numberOfLines = numLines;
        [labelArray addObject:titleLbl2];
        
        if ([[checkDic objectForKey:@"value"] isEqualToString:@"0"]) {
            [iconFor setImage:[UIImage imageNamed:@"x-mark-red"]];
        } else if ([[checkDic objectForKey:@"value"] isEqualToString:@"1"]) {
            [iconFor setImage:[UIImage imageNamed:@"check-mark-green"]];
        }
        
        [iconArray addObject:iconFor];
        y +=10;
        UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(x-10, y, width-20, 1)];
        [divider setImage:[UIImage imageNamed:@"white-line-1px"]];
        [iconArray addObject:divider];
        y += 10;
    }
    
    
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, y)];
    _cellHeight = cellView.frame.size.height;
    cellView.backgroundColor = [PharmaStyle colorBlueLight];

    for(UILabel *label in labelArray) {
        [cellView addSubview:label];
    }
    for(UIImageView *icon in iconArray) {
        [cellView addSubview:icon];
    }
    return cellView;
}

-(UIView*)createCellViewWithSubsections:(NSMutableArray*)accordionSection 
							 atTableRow:(NSIndexPath*)row {
    
    int y = 5;
    int x = 20;
	int width = self.view.frame.size.width - 60;
	int petImgSize = 120;
    int ySection = y;
    int yOffset = 40;
	int basicInfoSectionY = 0;

    
    NSMutableArray *petInfoSort = [self orderTermsForDetails:accordionSection forType:@"petInfo"];
    NSMutableArray *labelArray = [[NSMutableArray alloc]init];
    NSMutableArray *iconArray = [[NSMutableArray alloc]init];

	int basicFieldCounter = 0;
	
    for(id petField in petInfoSort) {
        if([petField isKindOfClass:[NSString class]]) {
            int sectionHeight = [self calcHeight:petField];
			int numLines2 = [self calcNumLines:petField];
			if  (basicFieldCounter / 5 == 1 || basicFieldCounter / 6 == 1 ) {
				UILabel *valInfo = [self createTermLabel:petField
													xPos:x
													yPos:y
												   width:width
												  height:sectionHeight
												numLines:numLines2 
										   withLabelType:@"petBasic"];
				ySection += yOffset;
				y = y + sectionHeight;
				basicInfoSectionY = basicInfoSectionY + sectionHeight;
				[labelArray addObject:valInfo];
				
			} else {
				
				UILabel *valInfo = [self createTermLabel:petField
													xPos:petImgSize + 15
													yPos:y
												   width:width - petImgSize
												  height:sectionHeight
												numLines:numLines2
										   withLabelType:@"petBasic"];
				ySection += yOffset;
				y = y + sectionHeight;
				basicInfoSectionY = basicInfoSectionY + sectionHeight;
				[labelArray addObject:valInfo];
			}
			basicFieldCounter = basicFieldCounter  + 1;
        } 
		else if ([petField isKindOfClass:[NSDictionary class]]) {
            NSDictionary *petDicItem = (NSDictionary*) petField;            
            if([petDicItem objectForKey:@"Pet ID"] != NULL) {
                UIImage *petImage = [currentClient.petImages objectForKey:[petDicItem objectForKey:@"petname"]];
                UIImageView *petImageFrame = [[UIImageView alloc]initWithFrame:CGRectMake(0,y, petImgSize,petImgSize)];
                [petImageFrame setImage:petImage];
                [iconArray addObject:petImageFrame];
				CAShapeLayer *circle = [CAShapeLayer layer];
                UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImageFrame.frame.size.width, petImageFrame.frame.size.height) cornerRadius:MAX(petImageFrame.frame.size.width, petImageFrame.frame.size.height)];
                circle.path = circularPath.CGPath;
                circle.fillColor = [UIColor whiteColor].CGColor;
                circle.strokeColor = [UIColor whiteColor].CGColor;
                circle.lineWidth = 1;
                petImageFrame.layer.mask = circle;
				basicFieldCounter = 0;
            } else {
                if(![[petDicItem objectForKey:@"label"] isEqual:[NSNull null]] &&
                   ![[petDicItem objectForKey:@"value"] isEqual:[NSNull null]]) {
					if(basicInfoSectionY < 161){
						y = y + (161 - basicInfoSectionY);
						basicInfoSectionY = 162;
					}
                    int sectionHeight = [self calcHeight:[petDicItem objectForKey:@"label"]];
                    int numLines = [self calcNumLines:[petDicItem objectForKey:@"label"]];
                    
                    int sectionHeight2 = [self calcHeight:[petDicItem objectForKey:@"value"]];
                    int numLines2 = [self calcNumLines:[petDicItem objectForKey:@"value"]];
                    
                    UILabel *labelInfo = [self createTermLabel:[petDicItem objectForKey:@"label"]
                                                          xPos:x
                                                          yPos:y
                                                         width:width
                                                        height:sectionHeight
                                                      numLines:numLines withLabelType:@"custom"];
                    
                    y += sectionHeight;
                    
                    UILabel *valInfo = [self createTermLabel:[petDicItem objectForKey:@"value"]
                                                        xPos:x
                                                        yPos:y
                                                       width:width
                                                      height:sectionHeight2
                                                    numLines:numLines2 withLabelType:@"value"];
                    
                    y = y + sectionHeight2;
                    [labelArray addObject:labelInfo];
                    [labelArray addObject:valInfo];
                    UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(x-10, y, width, 1)];
                    [divider setImage:[UIImage imageNamed:@"white-line-1px"]];
                    [iconArray addObject:divider];
                } 
			}
		} 
		else if ([petField isKindOfClass:[NSArray class]]) {

            NSArray *arrayBool = (NSArray*)petField;
            yOffset = y;
		
            if(![arrayBool isEqual:nil]) {
                for(NSDictionary *onOff in arrayBool) {
					if([[onOff objectForKey:@"type"]isEqualToString:@"docAttach"]) {
						if(basicInfoSectionY < 161){
							y = y + (161 - basicInfoSectionY);
							basicInfoSectionY = 162;
						}
						y+= 40;						
						NSString *docAttachLabel = [onOff objectForKey:@"label"];
						int docIndex = 0;
						for (NSDictionary *docAttachDic in currentClient.errataDoc) {
							if ([docAttachLabel isEqualToString:[docAttachDic objectForKey:@"label"]]) {
								NSString *docIndexString = [docAttachDic objectForKey:@"errataIndex"];
								docIndex = (int)[docIndexString integerValue];
							}
						}
						
						UIButton *petDocAttachButton = [UIButton buttonWithType:UIButtonTypeCustom];
						petDocAttachButton = [[UIButton alloc]initWithFrame:CGRectMake(x, y, 32, 32)];
						[petDocAttachButton setBackgroundImage:[UIImage imageNamed:@"file-folder-line"] 
													  forState:UIControlStateNormal];
						[petDocAttachButton addTarget:self 
											   action:@selector(petDocButton:) 
									 forControlEvents:UIControlEventTouchUpInside];
						petDocAttachButton.tag = docIndex;
						
						UILabel *titleLbl2 = [[UILabel alloc ]initWithFrame:CGRectMake(x + 36, y-20, self.view.bounds.size.width - 80, 50)];
						[titleLbl2 setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
						[titleLbl2 setText:[onOff objectForKey:@"label"]];
						[labelArray addObject:titleLbl2];
						[iconArray addObject:petDocAttachButton];
					} else {
						if(basicInfoSectionY < 161){
							y = y + (161 - basicInfoSectionY);
							basicInfoSectionY = 162;
						}
						y+= 40;
						UIImageView *iconFor = [[UIImageView alloc]initWithFrame:CGRectMake(x-20, y, 20, 20)];
						UILabel *titleLbl2 = [[UILabel alloc ]initWithFrame:CGRectMake(x, y-20, self.view.bounds.size.width - 80, 50)];
						[titleLbl2 setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
						[titleLbl2 setText:[onOff objectForKey:@"label"]];
						[labelArray addObject:titleLbl2];
						
						if ([[onOff objectForKey:@"value"] isEqualToString:@"0"]) {
							[iconFor setImage:[UIImage imageNamed:@"x-mark-red"]];
						} else if ([[onOff objectForKey:@"value"] isEqualToString:@"1"]) {
							[iconFor setImage:[UIImage imageNamed:@"check-mark-green"]];
						}
						[iconArray addObject:iconFor];
					}
                }
			}
            y+=40;
			basicInfoSectionY  = 0;          
            UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(x-10, y-10, width-20, 1)];
            [divider setImage:[UIImage imageNamed:@"white-line-1px"]];
            [iconArray addObject:divider];
        }
    }

	UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, y)];
    _cellHeight = cellView.frame.size.height;
    cellView.backgroundColor = [PharmaStyle colorBlueLight];
    
    for(UIImageView *icon in iconArray) {
        [cellView addSubview:icon];
    }
    for(UILabel *label in labelArray) {
        [cellView addSubview:label];
    }
    return cellView;
}

-(UIView*)createClientCellViewWithSubsections:(NSMutableArray*)accordionSection 
								   atTableRow:(NSIndexPath*)row {
    
    int y = 5;
    int x = 30;
	int width = self.view.frame.size.width - 60;
    int ySection = 20;
    int yOffset = 40;
    NSMutableArray *labelArray = [[NSMutableArray alloc]init];
    NSMutableArray *iconArray = [[NSMutableArray alloc]init];
    
	if([accordionSection count] > 0) {
		
		for (NSString *clientField in accordionSection) {
			int sectionHeight = [self calcHeight:clientField];
			int numberLinesClientField = [self calcNumLines:clientField];
			int numLineCarriageReturn = 0;
			sectionHeight += 20;
			UILabel *valInfo = [self createTermLabel:clientField
												xPos:x
												yPos:y
											   width:width - 20
											  height:sectionHeight+16
											numLines:numberLinesClientField
									   withLabelType:@"label"];
			
			UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(x-20, y, width-20, 1)];
			[divider setImage:[UIImage imageNamed:@"white-line-1px"]];
			[iconArray addObject:divider];
			
			ySection += yOffset;
			y = y + sectionHeight;
			[labelArray addObject:valInfo];
		}
	}
    
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, y)];
    _cellHeight = cellView.frame.size.height;
    cellView.backgroundColor = [PharmaStyle colorBlueLight];

    
    for(UIImageView *icon in iconArray) {
        [cellView addSubview:icon];
    }
    for(UILabel *label in labelArray) {
        [cellView addSubview:label];
    }
    
    return cellView;
    
}

-(UILabel *)createTermLabel:(NSString*)termText
                       xPos:(int)x
                       yPos:(int)y
                      width:(int)width
                     height:(int)height
                   numLines:(int)numLines
              withLabelType:(NSString*)labelType {
    
    UILabel *labelForKey = [[UILabel alloc]initWithFrame:CGRectMake(x, y, width, height)];
    labelForKey.numberOfLines = numLines;
    
    int fontSize = 20;
    if(isIphone6P) {
        fontSize = 18;
    } else if (isIphone6) {
        fontSize = 16;
    } else if (isIphone5) {
        fontSize = 14;
    } else if (isIphone4) {
        fontSize = 16;
    }
    
    if([labelType isEqualToString:@"label"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
        [labelForKey setTextColor:[UIColor blackColor]];
    } else if ([labelType isEqualToString:@"value"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize-2]];
        [labelForKey setTextColor:[UIColor blackColor]];
    } else if ([labelType isEqualToString:@"custom"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize-2]];
        [labelForKey setTextColor:[PharmaStyle colorRedBright]];
    } else if ([labelType isEqualToString:@"listItem"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize-2]];
        [labelForKey setTextColor:[UIColor blackColor]];
    } else if ([labelType isEqualToString:@"petBasic"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
        [labelForKey setTextColor:[UIColor blackColor]];
    }
    [labelForKey setText:termText];
    return labelForKey;
}

-(void)addDataSections {
	EMAccordionSection *petInfo = [[EMAccordionSection alloc]init];
	[petInfo setBackgroundColor:[PharmaStyle colorBlue]];
	[petInfo setTitle:@"PETS"];
	[petInfo setTitleColor:[UIColor blackColor]];
	[petInfo setTitleFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
	
	if(currentClient.petsDataRaw != NULL && [currentClient.petsDataRaw count] > 0){
		petInfo.items = currentClient.petInfo;
		[_emTV addAccordionSection:petInfo initiallyOpened:YES];
		[dataForSections addObject:currentClient.petInfo];
	} else {
		petInfo.items = currentClient.petInfo;
		[_emTV addAccordionSection:petInfo initiallyOpened:YES];
		[dataForSections addObject:currentClient.petInfo];
	}

	[_emTV addAccordionSection:currentClient.basicClientInfo initiallyOpened:YES];
	[_emTV addAccordionSection:currentClient.altClientInfo initiallyOpened:YES];
	[_emTV addAccordionSection:currentClient.vetInfo initiallyOpened:YES];
	[_emTV addAccordionSection:currentClient.alarmInfoAccordion initiallyOpened:YES];
	[_emTV addAccordionSection:currentClient.locationSupplies initiallyOpened:YES];

	[dataForSections addObject:currentClient.basicClientInfo.items];
	[dataForSections addObject:currentClient.altClientInfo.items];
	[dataForSections addObject:currentClient.vetInfo.items];
	[dataForSections addObject:currentClient.alarmInfoAccordion.items];
	[dataForSections addObject:currentClient.locationSupplies.items];
	
	if(currentClient.customClientAccordionFields != nil) {
		[_emTV addAccordionSection:currentClient.customClientAccordionFields initiallyOpened:YES];
		[dataForSections addObject:currentClient.customClientAccordionFields.items];
	}
}

- (NSMutableArray *) dataFromIndexPath: (NSIndexPath *)indexPath {

	if (indexPath.section == 0) {
		onWhichSection = 0;
		return [dataForSections objectAtIndex:0];
	}
	else if (indexPath.section == 1) {
		onWhichSection = 1;
		return [dataForSections objectAtIndex:1];
	}
	else if (indexPath.section == 2){
		onWhichSection = 2;
		return [dataForSections objectAtIndex:2];
	}
	else if (indexPath.section == 3){
		onWhichSection = 3;
		return [dataForSections objectAtIndex:3];
	}
	else if (indexPath.section == 4){
		onWhichSection = 4;
		return [dataForSections objectAtIndex:4];
	}
	else if (indexPath.section == 5){
		onWhichSection = 5;
		return [dataForSections objectAtIndex:5];
	} else if (indexPath.section == 6){
		onWhichSection = 6;
		return [dataForSections objectAtIndex:6];
	 }
	return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emCell"];
    cell.backgroundColor = [UIColor clearColor];
    NSMutableArray *items = [self dataFromIndexPath:indexPath];

    if(onWhichSection == 0) {
		UIView *cellViewTestx = [self createCellViewWithSubsections:currentClient.petsDataRaw atTableRow:indexPath];
        cell.frame = cellViewTestx.frame;
        [cell.contentView addSubview:cellViewTestx];
        return cell;
    } else if (onWhichSection == 1) {
        UIView *cellViewTestx = [self createClientCellViewWithSubsections:items atTableRow:indexPath];
        cell.frame = cellViewTestx.frame;
        [cell.contentView addSubview:cellViewTestx];
        return cell;
    } else if (onWhichSection == 2) {
        UIView *cellViewTestx = [self createClientCellViewWithSubsections:items atTableRow:indexPath];
        cell.frame = cellViewTestx.frame;
        [cell.contentView addSubview:cellViewTestx];
        return cell;
    } else if (onWhichSection == 3) {
        UIView *cellViewTestx = [self createClientCellViewWithSubsections:items atTableRow:indexPath];
        cell.frame = cellViewTestx.frame;
        [cell.contentView addSubview:cellViewTestx];
        return cell;
    } else if (onWhichSection == 4) {
        UIView *cellViewTestx = [self createClientCellViewWithSubsections:items atTableRow:indexPath];
        cell.frame = cellViewTestx.frame;
        [cell.contentView addSubview:cellViewTestx];
        return cell;
    } else if (onWhichSection == 5) {
        UIView *cellViewTestx = [self createClientCellViewWithSubsections:items atTableRow:indexPath];
        cell.frame = cellViewTestx.frame;
        [cell.contentView addSubview:cellViewTestx];
        return cell;
    } else if (onWhichSection == 6) {
		UIView *cellViewTestx = [self createCustomClientSections:items atTableRow:indexPath];
		cell.frame = cellViewTestx.frame;
		[cell.contentView addSubview:cellViewTestx];
		return cell;	
    }
		
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { 
	UIView *newView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
	return newView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return kTableHeaderHeight;
}

-(void)markUnarrive {
	
	VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
	UIAlertController * alert=   [UIAlertController
								  alertControllerWithTitle:@"CHANGE VISIT STATUS"
								  message:@"MARK THIS VISIT UNARRIVE?"
								  preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* ok = [UIAlertAction
						 actionWithTitle:@"OK"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 [alert dismissViewControllerAnimated:YES completion:nil];
							 currentVisit.status = @"future";
							 currentVisit.arrived = @"NO";
							 currentVisit.dateTimeMarkArrive = @"";
							 currentVisit.coordinateLatitudeMarkArrive = @"0.0";
							 currentVisit.coordinateLongitudeMarkArrive = @"0.0";
							 sharedVisits.onSequence = @"000";
							 sharedVisits.onWhichVisitID = @"000";
							 
							 [arriveButton setBackgroundImage:[UIImage imageNamed:@"arrive-pink-button"]
													 forState:UIControlStateNormal];
							 [sharedVisits markVisitUnarrive:currentVisit.appointmentid];
						 }];
	[alert addAction:ok];
	
	UIAlertAction* cancel = [UIAlertAction
							 actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleDefault
							 handler:^(UIAlertAction * action)
							 {
								 [alert dismissViewControllerAnimated:YES completion:nil];
							 }];
	
	[alert addAction:ok];
	[alert addAction:cancel];
	[self presentViewController:alert animated:YES completion:nil];
}
-(void)markArrive {
	UIAlertController * alert=   [UIAlertController
								  alertControllerWithTitle:@"CHANGE VISIT STATUS"
								  message:@"MARK ARRIVE?"
								  preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* ok = [UIAlertAction
						 actionWithTitle:@"OK"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 [alert dismissViewControllerAnimated:YES completion:nil];
							 currentVisit.status = @"arrived";
							 currentVisit.arrived = @"YES";
							 currentVisit.dateTimeMarkArrive = @"";
							 currentVisit.dateTimeMarkArrive = @"";
							 currentVisit.coordinateLatitudeMarkArrive = @"0.0";
							 currentVisit.coordinateLongitudeMarkArrive = @"0.0";
							 [arriveButton setBackgroundImage:[UIImage imageNamed:@"unarrive-pink-button"]
													 forState:UIControlStateNormal];
						 }];
	[alert addAction:ok];
	
	
	UIAlertAction* cancel = [UIAlertAction
							 actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleDefault
							 handler:^(UIAlertAction * action)
							 {
								 [alert dismissViewControllerAnimated:YES completion:nil];
							 }];
	
	[alert addAction:ok];
	[alert addAction:cancel];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)dealloc
{
	[_emParallaxHeaderView removeFromSuperview];
	_emParallaxHeaderView = nil;
	[_emTV removeFromParentViewController];
	_emTV.delegate = nil;
	_emTV.view = nil;
	_emTV = nil;
	[myMapView cleanDetailMapView];
	[myMapView removeFromSuperview];
	[detailView removeFromSuperview];
	[flagView removeFromSuperview];
	[backButton  removeFromSuperview];
	[arriveButton removeFromSuperview];
	detailView = nil;
	flagView = nil;
	arriveButton = nil;
	dataForSections = nil;
	sections = nil;
	myMapView = nil;
}

-(void)setClientAndVisitID:(DataClient*)clientID visitID:(VisitDetails*)visitID {
	
	currentClient = clientID;
	currentVisit = visitID;
	
}
-(BOOL)prefersStatusBarHidden {
	return YES;
}
-(void)detailPopUpDismiss {
	[detailView removeFromSuperview];
	detailView = nil;
	isShowingPopup = NO;
}

- (void) latestSectionOpened {
}

- (void) latestSectionOpenedID:(int)sectionNum {
	if (sectionNum == 0 || sectionNum == 6) {
		tableRowHeight = 260.0;
		[self.emTV.tableView reloadData];
	} else {
		tableRowHeight = kTableRowHeight;
		[self.emTV.tableView reloadData];
	}
}

-(void)flagDetailClicked:(id)sender {
	
	if (isShowingPopup) {
		[detailView removeFromSuperview];
		detailView = nil;
	}
	isShowingPopup = YES;
	
	float labelWidth = 340;
	float fontSize = 16;
	float yIncrement = 100;
	int x = 10;
	int y = 60;
	
	
	if (isIphone6P) {
		detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 40, self.view.frame.size.width-40, self.view.frame.size.height - 80)];
	} else if (isIphone6) {
		labelWidth = 290;
		detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 40, self.view.frame.size.width-40, self.view.frame.size.height - 80)];
	} else if (isIphone5) {
		detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, self.view.frame.size.height - 20)];
		labelWidth = 230;
		fontSize = 14;
	} else if (isIphone4) {
		detailView = [[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, self.view.frame.size.height - 20)];
		labelWidth = 220;
		fontSize = 14;
		yIncrement = 85;
	}
	
	
	detailView.backgroundColor = [PharmaStyle colorAppBlack20];
	
	UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
	
	UIImage *backImg = [JzStyleKit imageOfJzCardWithJzCardFrame:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height) rectangle2:CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height)];
	[backgroundImg setImage:backImg];
	[detailView addSubview:backgroundImg];
	
	UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0,0, detailView.frame.size.width, detailView.frame.size.height)];
	backView.backgroundColor = [PharmaStyle colorBlueLight];
	backView.alpha = 0.3;
	[detailView addSubview:backView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(10, 10, 24, 24);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
	[doneButton addTarget:self
				   action:@selector(detailPopUpDismiss)
		 forControlEvents:UIControlEventTouchUpInside];
	[detailView addSubview:doneButton];
	
	UILabel *titleFlags = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, detailView.frame.size.width, 24)];
	titleFlags.textAlignment = NSTextAlignmentCenter;
	[titleFlags setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
	[titleFlags setTextColor:[PharmaStyle colorAppWhite]];
	[titleFlags setText:@"FLAGS"];
	[detailView addSubview:titleFlags];
	
	[self.view addSubview:detailView];
	
	VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
	
	for (NSDictionary *flagDicClient in currentClient.clientFlagsArray) {
		NSString *comparingFlagID = [flagDicClient objectForKey:@"flagid"];
		
		for (NSDictionary *flagTableItem in sharedVisits.flagTable) {
			
			NSString *flagID = [flagTableItem objectForKey:@"flagid"];
			NSString *flagSrcString = [flagTableItem objectForKey:@"src"];
			NSString *flagTitle;
			NSString *flagLabel;
			
			
			if ([flagID isEqualToString:comparingFlagID]) {
				
				UIImage *flagImg =[UIImage imageNamed:flagSrcString];
				
				flagTitle = [flagDicClient objectForKey:@"note"];
				flagLabel = [flagTableItem objectForKey:@"title"];
				
				UIImageView *flagItem = [[UIImageView alloc]initWithFrame:CGRectMake(x,y, 40, 40)];
				[flagItem setImage:flagImg];
				flagItem.userInteractionEnabled = YES;
				[detailView addSubview:flagItem];
				
				UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
				flagButton.frame = CGRectMake(x, y, 40, 40);
				[flagButton setBackgroundImage:flagImg forState:UIControlStateNormal];
				[flagButton addTarget:self action:@selector(flagDetailOverflow:) forControlEvents:UIControlEventTouchUpInside];
				int flagIDInteger = [flagID intValue];
				flagButton.tag = flagIDInteger;
				[detailView addSubview:flagButton];
				
				NSString *upperFlagTxt = [flagLabel uppercaseString];
				UILabel *flagSrcText = [[UILabel alloc]initWithFrame:CGRectMake(flagItem.frame.origin.x +50, flagItem.frame.origin.y, 280, 24)];
				[flagSrcText setFont:[UIFont fontWithName:@"Langdon" size:20]];
				flagSrcText.numberOfLines = 1;
				[flagSrcText setTextColor:[PharmaStyle colorAppWhite]];
				[flagSrcText setText:upperFlagTxt];
				[detailView addSubview:flagSrcText];
				
				
				UILabel *flagText = [[UILabel alloc]initWithFrame:CGRectMake(flagItem.frame.origin.x +50, flagItem.frame.origin.y+20, labelWidth-50, 80)];
				[flagText setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
				flagText.numberOfLines = 8;
				[flagText setTextColor:[PharmaStyle colorAppWhite50]];
				if (![flagTitle isEqual:[NSNull null]] && [flagTitle length] >0) {
					[flagText setText:flagTitle];
					
				} else  {
					[flagText setText:@"NONE"];
					
				}
				[detailView addSubview:flagText];
				
				if (y<detailView.frame.size.height) [detailView addSubview:flagText];
				y += yIncrement;
			}
		}
	}
}

-(void)flagDetailOverflow:(id)sender {
	
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *flagTapButon = (UIButton*)sender;
		int flagID = (int)flagTapButon.tag;		
		NSString *flagIDString = [NSString stringWithFormat:@"%i",flagID];
		for (NSDictionary *flagDicClient in currentClient.clientFlagsArray) {
			NSString *comparingFlagID = [flagDicClient objectForKey:@"flagid"];
			if ([comparingFlagID isEqualToString:flagIDString]) {
				detailMoreDetailView = [[UIView alloc]initWithFrame:CGRectMake(0,0, detailView.frame.size.width-30, detailView.frame.size.height-20)];
				[detailMoreDetailView setBackgroundColor:[UIColor blackColor]];
				[detailView addSubview:detailMoreDetailView];
				
				UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
				doneButton.frame = CGRectMake(10, 10, 24, 24);
				[doneButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
				[doneButton addTarget:self
							   action:@selector(detailMoreDetailDismiss)
					 forControlEvents:UIControlEventTouchUpInside];
				[detailMoreDetailView addSubview:doneButton];
				
				UILabel *flagNoteLabel =[[UILabel alloc] initWithFrame:CGRectMake(30, 40, detailMoreDetailView.frame.size.width - 40, detailMoreDetailView.frame.size.height)];
				[flagNoteLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
				[flagNoteLabel setTextColor:[UIColor whiteColor]];
				flagNoteLabel.numberOfLines = 20;
				[flagNoteLabel setText:[flagDicClient objectForKey:@"note"]];
				[detailMoreDetailView addSubview:flagNoteLabel];
				
			}
		}
	}
}

-(void)detailMoreDetailDismiss {
	[detailMoreDetailView removeFromSuperview];	
}

-(void)petDocButton:(id)sender {
	UIButton *tappedDocButton = (UIButton*)sender;
	FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height) 
														  appointmentID:currentVisit.appointmentid 
															   itemType:@"oneDoc" 
															  andTagNum:(int)tappedDocButton.tag];	
	[fmView show];
}

-(void)tapDocView:(id)sender {
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *tappedDocButton = (UIButton*)sender;
		FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height) 
															  appointmentID:currentVisit.appointmentid 
																   itemType:@"oneDoc" 
																  andTagNum:(int)tappedDocButton.tag];	
		[fmView show];
	}
}

-(void)makePhoneCall {
	UIAlertController * alert=   [UIAlertController
								  alertControllerWithTitle:@"CONTACT CUSTOMER"
								  message:@"CHOOSE METHOD"
								  preferredStyle:UIAlertControllerStyleAlert];
	
	if(![currentClient.cellphone isEqual:[NSNull null]] && [currentClient.cellphone length] > 0) {
		UIAlertAction* phoneCall = [UIAlertAction
									actionWithTitle:@"CALL - Cell"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action)
									{
										[alert dismissViewControllerAnimated:YES completion:nil];
										NSString *preTeleString = currentClient.cellphone;
										NSString *telNumStr = @"(\\d\\d\\d)(-?)\\d\\d\\d(-?)\\d\\d\\d\\d";
										NSString *telNumPattern;
										telNumPattern = [NSString stringWithFormat:telNumStr,telNumPattern];
										
										NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
										NSError *error = NULL;
										
										NSRegularExpression *telRegex = [NSRegularExpression regularExpressionWithPattern:telNumStr
																												  options:regexOptions
																													error:&error];
										
										[telRegex enumerateMatchesInString:preTeleString
																   options:0
																	 range:NSMakeRange(0, [preTeleString length])
																usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop)
										 {
											 NSRange range = [match rangeAtIndex:0];
											 NSString *regExTel = [preTeleString substringWithRange:range];
											 NSString *telephoneNumFormat = [@"tel://" stringByAppendingString:regExTel];
											 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneNumFormat]];
											 
										 }];
										
										
									}];
		[alert addAction:phoneCall];
		
	}
	
	if(![currentClient.cellphone2 isEqual:[NSNull null]] && [currentClient.cellphone2 length] > 0) {
		UIAlertAction* phoneCall = [UIAlertAction
									actionWithTitle:@"CALL - 2nd Cell"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action)
									{
										[alert dismissViewControllerAnimated:YES completion:nil];
										NSString *preTeleString = currentClient.cellphone2;
										NSString *telNumStr = @"(\\d\\d\\d)(-?)\\d\\d\\d(-?)\\d\\d\\d\\d";
										NSString *telNumPattern;
										telNumPattern = [NSString stringWithFormat:telNumStr,telNumPattern];
										
										NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
										NSError *error = NULL;
										
										NSRegularExpression *telRegex = [NSRegularExpression regularExpressionWithPattern:telNumStr
																												  options:regexOptions
																													error:&error];
										
										[telRegex enumerateMatchesInString:preTeleString
																   options:0
																	 range:NSMakeRange(0, [preTeleString length])
																usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop)
										 {
											 NSRange range = [match rangeAtIndex:0];
											 NSString *regExTel = [preTeleString substringWithRange:range];
											 NSString *telephoneNumFormat = [@"tel://" stringByAppendingString:regExTel];
											 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneNumFormat]];
											 
										 }];
										
										
									}];
		[alert addAction:phoneCall];
		
	}
	
	if(![currentClient.homePhone isEqual:[NSNull null]] && [currentClient.homePhone length] > 0) {
		UIAlertAction* phoneCall = [UIAlertAction
									actionWithTitle:@"CALL - Home Phone"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action)
									{
										[alert dismissViewControllerAnimated:YES completion:nil];
										NSString *preTeleString = currentClient.homePhone;
										NSString *telNumStr = @"(\\d\\d\\d)(-?)\\d\\d\\d(-?)\\d\\d\\d\\d";
										NSString *telNumPattern;
										telNumPattern = [NSString stringWithFormat:telNumStr,telNumPattern];
										
										NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
										NSError *error = NULL;
										
										NSRegularExpression *telRegex = [NSRegularExpression regularExpressionWithPattern:telNumStr
																												  options:regexOptions
																													error:&error];
										
										[telRegex enumerateMatchesInString:preTeleString
																   options:0
																	 range:NSMakeRange(0, [preTeleString length])
																usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop)
										 {
											 NSRange range = [match rangeAtIndex:0];
											 NSString *regExTel = [preTeleString substringWithRange:range];
											 NSString *telephoneNumFormat = [@"tel://" stringByAppendingString:regExTel];
											 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneNumFormat]];
											 
										 }];
										
										
									}];
		[alert addAction:phoneCall];
		
	}
	
	if(![currentClient.workphone isEqual:[NSNull null]] && [currentClient.workphone length] > 0) {
		UIAlertAction* phoneCall = [UIAlertAction
									actionWithTitle:@"CALL - Home Work"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action)
									{
										[alert dismissViewControllerAnimated:YES completion:nil];
										NSString *preTeleString = currentClient.workphone;
										NSString *telNumStr = @"(\\d\\d\\d)(-?)\\d\\d\\d(-?)\\d\\d\\d\\d";
										NSString *telNumPattern;
										telNumPattern = [NSString stringWithFormat:telNumStr,telNumPattern];
										
										NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
										NSError *error = NULL;
										
										NSRegularExpression *telRegex = [NSRegularExpression regularExpressionWithPattern:telNumStr
																												  options:regexOptions
																													error:&error];
										
										[telRegex enumerateMatchesInString:preTeleString
																   options:0
																	 range:NSMakeRange(0, [preTeleString length])
																usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop)
										 {
											 NSRange range = [match rangeAtIndex:0];
											 NSString *regExTel = [preTeleString substringWithRange:range];
											 NSString *telephoneNumFormat = [@"tel://" stringByAppendingString:regExTel];
											 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneNumFormat]];
											 
										 }];
										
										
									}];
		[alert addAction:phoneCall];
		
	}
	
	UIAlertAction* textMessage = [UIAlertAction
								  actionWithTitle:@"TEXT"
								  style:UIAlertActionStyleDefault
								  handler:^(UIAlertAction * action)
								  {
									  [alert dismissViewControllerAnimated:YES completion:nil];
									  NSString *preTeleString = currentClient.cellphone;
									  NSString *telNumStr = @"(\\d\\d\\d)(-?)\\d\\d\\d(-?)\\d\\d\\d\\d";
									  NSString *telNumPattern;
									  telNumPattern = [NSString stringWithFormat:telNumStr,telNumPattern];
									  
									  NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
									  NSError *error = NULL;
									  
									  NSRegularExpression *telRegex = [NSRegularExpression regularExpressionWithPattern:telNumStr
																												options:regexOptions
																												  error:&error];
									  
									  [telRegex enumerateMatchesInString:preTeleString
																 options:0
																   range:NSMakeRange(0, [preTeleString length])
															  usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop)
									   {
										   NSRange range = [match rangeAtIndex:0];
										   NSString *regExTel = [preTeleString substringWithRange:range];
										   
										   NSString *telephoneNumFormat = [@"" stringByAppendingString:regExTel];
										   MFMessageComposeViewController *textMsg = [[MFMessageComposeViewController alloc]init];
										   textMsg.messageComposeDelegate = self;
										   textMsg.recipients = [NSArray arrayWithObjects:telephoneNumFormat, nil];
										   //if (MFMessageComposeViewController.canSendText) {
										   
										   [self presentViewController:textMsg animated:YES completion:nil];
										   
										   // }
										   
										   
									   }];
									  
								  }];
	
	UIAlertAction* cancel = [UIAlertAction
							 actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleDefault
							 handler:^(UIAlertAction * action)
							 {
								 [alert dismissViewControllerAnimated:YES completion:nil];
								 
							 }];
	
	
	[alert addAction:textMessage];
	[alert addAction:cancel];
	
	[self presentViewController:alert animated:YES completion:nil];
	
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller
				didFinishWithResult:(MessageComposeResult)result
{
	
	
	[controller dismissViewControllerAnimated:YES completion:nil];
	controller.delegate = nil;
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder { 
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection { 
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize { 
	return CGSizeMake(0, 0);
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator { 
}

- (void)setNeedsFocusUpdate { 
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
	return TRUE;
}

- (void)updateFocusIfNeeded { 
}

@end
