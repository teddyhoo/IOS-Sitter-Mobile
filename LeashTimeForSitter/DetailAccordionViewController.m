//
//  DetailAccordionViewController.m
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 12/23/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import "DetailAccordionViewController.h"
#import "VisitsAndTracking.h"
#import "DetailsMapView.h"
#import "FloatingModalView.h"
#import "EMAccordionSection.h"

#import "DataClient.h"
#import "VisitDetails.h"
#import "PetProfile.h"

#import "PharmaStyle.h"
#import "JzStyleKit.h"
#import <WebKit/WebKit.h>

#define kTableHeaderHeight 70.0f
#define kTableRowHeight 80.0f


@interface DetailAccordionViewController () <UIScrollViewDelegate,EMAccordionTableDelegate, MFMessageComposeViewControllerDelegate>

@end

@implementation DetailAccordionViewController {
    
    EMAccordionTableViewController *emTV;
    EMAccordionTableParallaxHeaderView *emParallaxHeader;
    DetailsMapView *myMapView;
    UIView *detailView;
    UIView *detailMoreDetailView;
    UIView *flagView;
    
    NSMutableArray *dataForSections;
    NSMutableArray *sections;
	NSMutableDictionary *flagIndex;
    UIButton *backButton;
    UIButton *arriveButton;

    DataClient *currentClient;
    VisitDetails *currentVisit;
    VisitsAndTracking *sharedVisits;
    
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
    BOOL isXR;
    BOOL isShowingPopup;
    BOOL mapOnScreen;
    
    CGFloat origin;
    float cellHeight;
    int onWhichSection;
    float tableRowHeight;
    
    NSString *visitIDSent;
    NSString *hasKey;
    
    int numCharAcross;
    int fontSizeGlobal;
}

-(instancetype)init {
    if(self = [super init]) {
        
        sharedVisits = [VisitsAndTracking sharedInstance];
        NSString *theDeviceType = [sharedVisits tellDeviceType];
        onWhichSection = 0;
        isShowingPopup = NO;
        numCharAcross  = 20;
        fontSizeGlobal = 18;
        
        if ([theDeviceType isEqualToString:@"iPhone6P"]) {
            isIphone6P = YES;
            isIphone6 = NO;
            isIphone5 = NO;
            isIphone4 = NO;
            isXR = NO;
            numCharAcross  = 25;
            fontSizeGlobal = 18;
            
        } 
        else if ([theDeviceType isEqualToString:@"XR"]) {
            isIphone6P = NO;
            isIphone6 = NO;
            isIphone5 = NO;
            isIphone4 = NO;
            isXR = YES;
            numCharAcross  = 30;
            fontSizeGlobal = 18;
            
        }  
        else if ([theDeviceType isEqualToString:@"iPhone5"]) {
            isIphone5 = YES;
            isIphone4 = NO;
            isIphone6P = NO;
            isIphone6 = NO;
            fontSizeGlobal = 16;
            numCharAcross  = 15;

        }
        else if([theDeviceType isEqualToString:@"iPhoneX"]) {
            isIphone4 = YES;
            isIphone5 = NO;
            isIphone6P = NO;
            isIphone6 = NO;
            fontSizeGlobal = 16;
            numCharAcross  = 15;
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

-(UIView*)createHeaderView:(float)withParallaxHeight {
    
    UIView *headerSetup = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, withParallaxHeight)];
    
    UIView *back2 = [[UIView alloc]initWithFrame:headerSetup.frame];
    headerSetup.backgroundColor = [PharmaStyle colorBlue];
    [back2 setBackgroundColor:[PharmaStyle colorBlueShadow]];
    back2.alpha = 0.2;
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([[sharedVisits tellDeviceType]isEqualToString:@"iPhoneX"]) {
        backButton.frame = CGRectMake(0,40,32,32);
    } else {
        backButton.frame = CGRectMake(0,0,32,32);
    }
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerSetup addSubview:back2];
    [headerSetup addSubview:backButton];
    
    [self addPetImages:headerSetup];
    [self addControlIcons:headerSetup];
    [self addClientFlags:flagView withHeader:headerSetup];
        
    return headerSetup;
    
}

-(void)setupViews {
    
    float parallaxHeight = 220.0;
    if([[currentClient getPetProfiles] count] > 3) {
        parallaxHeight = 290.0;
    }
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    [tableView setSectionHeaderHeight:kTableHeaderHeight];

    UIView *headerView = [self createHeaderView:parallaxHeight];
    //[[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,parallaxHeight)];
    
    emParallaxHeader = [[EMAccordionTableParallaxHeaderView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.frame.size.width,parallaxHeight)];
    [emParallaxHeader addSubview:headerView];
    
    
    emTV = [[EMAccordionTableViewController alloc]  initWithTable:tableView withAnimationType:EMAnimationTypeNone];
    [emTV setDelegate:self];
    [emTV setClosedSectionIcon:[UIImage imageNamed:@"down-arrow-thick"]];
    [emTV setOpenedSectionIcon:[UIImage imageNamed:@"up-arrow-thick"]];
    emTV.defaultOpenedSection = -1;
    emTV.parallaxHeaderView = emParallaxHeader;
    [self.view addSubview:emTV.tableView];

    [self addDataSections];
    //[self.view addSubview:backButton];
    /*[self addPetImages:headerView];
    [self addControlIcons:headerView];
    [self addClientFlags:flagView withHeader:headerView];*/
    //[self addMapView:currentVisit];'
    
}

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:YES];
    NSLog(@"View did appear");
    
}

-(void)didMoveToParentViewController:(UIViewController *)parent {
        [self setupViews];
}

-(void)addPetImages:(UIView*)headerView {
	
	UIView *petPicFrameView;
    NSArray *petProfiles = [currentClient getPetProfiles];
    int numberPets = (int)[petProfiles count];
    int xPos = 15;
    int yPos = 20;
    int dimensionSize = 108;
    int dimensionSizePicture = 98;
    int labelOffset = 70;
    int fontSize = 18;
    
	if (isIphone6P || isXR) {
        xPos = 15;
        yPos = 20;
        dimensionSize = 108;
        dimensionSizePicture = 98;
        labelOffset = 70;
        
		if (numberPets > 3) {
			labelOffset = 55;
			dimensionSize = 80;
			dimensionSizePicture = 70;
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets-80,200)];
		} else {
			petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
			
		}
    } else if (isIphone6) {
        xPos = 35;
        yPos = 30;
        dimensionSize = 94;
        dimensionSizePicture = 82;            
        if (numberPets > 3) {
            dimensionSize = 50;
            dimensionSizePicture = 44;
            petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets-60,170)];
            fontSize = 14;
        } else {
            petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
        }
    } else if (isIphone5) {
        xPos = 35;
        yPos = 50;
        dimensionSize = 76;
        dimensionSizePicture = 64;        
        if (numberPets > 3) {
            dimensionSize = 44;
            dimensionSizePicture = 36;
            petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize*4)];
        } else {
            petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
        }
    }
    else {
        
        xPos = 35;
        yPos = 50;
        dimensionSize = 76;
        dimensionSizePicture = 64;
        if (numberPets > 3) {
            dimensionSize = 44;
            dimensionSizePicture = 36;
            petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize*4)];
        } else {
            petPicFrameView = [[UIView alloc]initWithFrame:CGRectMake(xPos, yPos, dimensionSize*numberPets,dimensionSize)];
        }
    }
    
    petPicFrameView.userInteractionEnabled = YES;
    petPicFrameView.tag = 100;
    int petCounter = 0;
    
    for (PetProfile *pet in petProfiles) {
        if(petCounter == 4) {
            yPos +=100;
            xPos = 15;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *currentPicView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos,
                                                                                       yPos,
                                                                                       dimensionSizePicture,
                                                                                       dimensionSizePicture)];
            
            UIImage *petImage = [pet getProfilePhoto];
            CGSize petImgSize = [petImage size];
            
            NSLog(@"Pet image size: %f, %f", petImgSize.width, petImgSize.height);
            [currentPicView setImage:[pet getProfilePhoto]];
            
            
            CAShapeLayer *circle = [CAShapeLayer layer];
            UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, currentPicView.frame.size.width, currentPicView.frame.size.height) cornerRadius:MAX(currentPicView.frame.size.width, currentPicView.frame.size.height)];
            circle.path = circularPath.CGPath;
            circle.fillColor = [UIColor whiteColor].CGColor;
            circle.strokeColor = [UIColor whiteColor].CGColor;
            circle.lineWidth = 1;
            currentPicView.layer.mask=circle;

            int petIDTag = (int)[pet getPetID];
                    
            UIButton *petImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            petImageButton.frame = CGRectMake(xPos, yPos-labelOffset, dimensionSize, dimensionSize);
            [petImageButton setTitleColor:[PharmaStyle colorAppWhite] forState:UIControlStateNormal];
            petImageButton.titleLabel.font = [UIFont fontWithName:@"Langdon" size:20];
            [petImageButton setTitle:[[pet getPetName]uppercaseString] forState:UIControlStateNormal];
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
	[headerView addSubview:petPicFrameView];
	
}

-(void)addControlIcons:(UIView *)headerView {
	
	UIButton *keyIcon;
	UIButton *mapButton;
	UIButton *noteFromManager;
	UIButton *basicInfoNote;
	UIButton *makeCall;
	
	keyIcon = [UIButton buttonWithType:UIButtonTypeCustom];
	mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	makeCall = [UIButton buttonWithType:UIButtonTypeCustom];
	noteFromManager = [UIButton buttonWithType:UIButtonTypeCustom];
	basicInfoNote = [UIButton buttonWithType:UIButtonTypeCustom];
	arriveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
    mapButton.frame = CGRectMake(headerView.frame.size.width - 60, 0, 32, 32);
    keyIcon.frame = CGRectMake(headerView.frame.size.width - 60, 40, 20, 32);
    noteFromManager.frame = CGRectMake(headerView.frame.size.width - 60, headerView.frame.size.height - 180, 32, 32);
    basicInfoNote.frame = CGRectMake(headerView.frame.size.width - 60, headerView.frame.size.height - 140, 32, 32);
    arriveButton.frame = CGRectMake(headerView.frame.size.width - 40, headerView.frame.size.height - 40, 32, 32);
    makeCall.frame = CGRectMake(5, headerView.frame.size.height - 40, 32, 32);
    
	/*if (isIphone6P || isXR) {
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,emParallaxHeader.frame.size.height - 50,12,20);
		noteFromManager.frame = CGRectMake(10, emParallaxHeader.frame.size.height - 40, 32, 32);
		basicInfoNote.frame = CGRectMake(50,emParallaxHeader.frame.size.height - 40,32, 32);
		makeCall.frame = CGRectMake(90, emParallaxHeader.frame.size.height - 40, 20, 32);
		arriveButton.frame = CGRectMake(emParallaxHeader.frame.size.width - 40, emParallaxHeader.frame.size.height - 40, 32,32);
	} else if (isIphone6) {
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,emParallaxHeader.frame.size.height -50,12,20);
		noteFromManager.frame = CGRectMake(10, emParallaxHeader.frame.size.height - 40, 32, 32);
		basicInfoNote.frame = CGRectMake(50,emParallaxHeader.frame.size.height - 40,32, 32);
		makeCall.frame = CGRectMake(90, emParallaxHeader.frame.size.height - 40, 20, 32);
		arriveButton.frame = CGRectMake(emParallaxHeader.frame.size.width - 40, emParallaxHeader.frame.size.height - 40, 32,32);
	} else if (isIphone5) {
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,emParallaxHeader.frame.size.height - 50,12,20);
		noteFromManager.frame = CGRectMake(10, emParallaxHeader.frame.size.height - 40, 32, 32);
		basicInfoNote.frame = CGRectMake(50,emParallaxHeader.frame.size.height - 40,32, 32);		
        makeCall.frame = CGRectMake(90, emParallaxHeader.frame.size.height - 40, 20, 32);
		arriveButton.frame = CGRectMake(emParallaxHeader.frame.size.width - 40, emParallaxHeader.frame.size.height - 40, 32,32);
	} else if (isIphone4) {
		
		mapButton.frame = CGRectMake(self.view.frame.size.width - 40, 0, 32, 32);
		keyIcon.frame = CGRectMake(10,emParallaxHeader.frame.size.height - 50,12,20);
		noteFromManager.frame = CGRectMake(10, emParallaxHeader.frame.size.height - 40, 32, 32);
		makeCall.frame = CGRectMake(90, emParallaxHeader.frame.size.height - 40, 20, 32);
		basicInfoNote.frame = CGRectMake(50,emParallaxHeader.frame.size.height - 40,32, 32);
		arriveButton.frame = CGRectMake(emParallaxHeader.frame.size.width - 40, emParallaxHeader.frame.size.height - 40, 32,32);
		
	}*/
	
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
	[noteFromManager addTarget:self 
                        action:@selector(showNote) 
              forControlEvents:UIControlEventTouchUpInside];
	
	[basicInfoNote setBackgroundImage:[UIImage imageNamed:@"fileFolder-profile"] 
                             forState:UIControlStateNormal];
	[basicInfoNote addTarget:self 
                      action:@selector(showBasicInfo) 
            forControlEvents:UIControlEventTouchUpInside];
	
	[makeCall setBackgroundImage:[UIImage imageNamed:@"cell-phone-white"] 
                        forState:UIControlStateNormal];
	[makeCall addTarget:self 
                 action:@selector(makePhoneCall) 
       forControlEvents:UIControlEventTouchUpInside];
	
	[mapButton setBackgroundImage:[UIImage imageNamed:@"compass-icon"]
						 forState:UIControlStateNormal];
	[mapButton addTarget:self
				  action:@selector(showMapAndDirections:)
	 forControlEvents:UIControlEventTouchUpInside];
	
	NSString *keyIDString = currentVisit.keyID;
    UILabel *hasKeyLabel;
    
	if ([hasKey isEqualToString:@"NEED KEY"]) {
		if ([keyIDString isEqualToString:@"NO KEY"]) {
			hasKeyLabel = [[UILabel alloc]initWithFrame:CGRectMake(keyIcon.frame.origin.x-20, keyIcon.frame.origin.y+24, 100, 16)];
			[hasKeyLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:12]];
		} else {
			hasKeyLabel = [[UILabel alloc]initWithFrame:CGRectMake(keyIcon.frame.origin.x-20, keyIcon.frame.origin.y+24, 100, 16)];
			[hasKeyLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
		}
		
		[keyIcon setBackgroundImage:[UIImage imageNamed:@"key-red-4ptstroke"] forState:UIControlStateNormal];
		[hasKeyLabel setTextColor:[PharmaStyle colorYellow]];
		[hasKeyLabel setText:keyIDString];
	} else {
		hasKeyLabel = [[UILabel alloc]initWithFrame:CGRectMake(keyIcon.frame.origin.x+20, keyIcon.frame.origin.y+24, 100, 16)];
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
	
	if((![currentClient.cellphone isEqual:[NSNull null]] && [currentClient.cellphone length] > 0) ||
	   (![currentClient.cellphone2 isEqual:[NSNull null]] && [currentClient.cellphone2 length] > 0) ||
	   (![currentClient.homePhone isEqual:[NSNull null]] && [currentClient.homePhone length] > 0) ||
	   (![currentClient.workphone isEqual:[NSNull null]] && [currentClient.workphone length] > 0)){
        
        
        [headerView addSubview:makeCall];
        
	}

}

-(void)showMapAndDirections:(id)sender {

    //MKMapView *localMap = myMapView;
    DetailsMapView* localMap = myMapView;

    __block BOOL localMapOnScreenBool = mapOnScreen;
    
	if (mapOnScreen) {
		[UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
			CGRect newFrame = CGRectMake(localMap.frame.origin.x, 
										 self.view.frame.size.height, 
										 localMap.frame.size.width,
										 localMap.frame.size.height);
			localMap.frame = newFrame;
			[localMap layoutIfNeeded];
			
		} completion:^(BOOL finished) {

            localMapOnScreenBool = NO;

		}];
		
	} else {		
		[UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
			CGRect newFrame = CGRectMake(localMap.frame.origin.x, 
										 self.view.frame.origin.y+100, 
										 localMap.frame.size.width,
										 localMap.frame.size.height);
			localMap.frame = newFrame;
			[localMap layoutIfNeeded];
			
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

    UIButton *button = (UIButton*)sender;
    NSString *petIDString = [NSString stringWithFormat:@"%li",(long)button.tag];
    float fontSize = 18;
    float widthView = self.view.frame.size.width - 60;
    float dimensionXY = 150;

    if (isIphone6P || isXR) {
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
    
    PetProfile *currentPet = nil;
    
    for (PetProfile *pet in [currentClient getPetInfo]) {
        if ([[pet getPetID]isEqualToString:petIDString]) {
            currentPet = pet;
            break;
        }
    }
    
    UILabel *petLabel = [[UILabel alloc]initWithFrame:CGRectMake(180, 20, 300, 28)];
    [petLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:24]];
    [petLabel setText:[currentPet getPetName]];
    [petLabel setTextColor:[PharmaStyle colorYellow]];
    [detailView addSubview:petLabel];
    
    UIImageView *petImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, dimensionXY, dimensionXY)];
    [petImageView setImage:[currentPet getProfilePhoto]];

    CAShapeLayer *circle2 = [CAShapeLayer layer];
    UIBezierPath *circularPath2=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImageView.frame.size.width, petImageView.frame.size.height) cornerRadius:MAX(petImageView.frame.size.width, petImageView.frame.size.height)];
    circle2.path = circularPath2.CGPath;
    circle2.fillColor = [UIColor whiteColor].CGColor;
    circle2.strokeColor = [UIColor whiteColor].CGColor;
    circle2.lineWidth = 1;
    petImageView.layer.mask = circle2;
    [detailView addSubview:petImageView];
    
    NSString *breedStr = [currentPet getPetBreed];
    NSString *colorStr = [currentPet getPetColor];
    NSString *birthDaystr = [currentPet getPetBirthday];
    NSString *descriptionStr = [currentPet getPetDescription];
    NSString *notesStr = [currentPet getPetNote];
    
    UILabel *petLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(dimensionXY + 30, 50, 120, 40)];
    petLabel2.numberOfLines = 2;
    [petLabel2 setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
    [petLabel2 setTextColor:[PharmaStyle colorAppWhite]];
    [detailView addSubview:petLabel2];
    
    UILabel *petLabel5 = [[UILabel alloc]initWithFrame:CGRectMake(dimensionXY + 30, 90, widthView, 40)];
    petLabel5.numberOfLines = 2;
    [petLabel5 setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
    [petLabel5 setTextColor:[PharmaStyle colorAppWhite]];
    [detailView addSubview:petLabel5];
    
    UILabel *petLabel6 = [[UILabel alloc]initWithFrame:CGRectMake(dimensionXY + 30, 130, widthView, 40)];
    petLabel6.numberOfLines = 2;
    [petLabel6 setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
    [petLabel6 setTextColor:[PharmaStyle colorAppWhite]];
    [detailView addSubview:petLabel6];
    
    UILabel *petLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 180, widthView, 120)];
    petLabel3.numberOfLines = 5;
    [petLabel3 setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
    [petLabel3 setTextColor:[PharmaStyle colorAppWhite]];
    [detailView addSubview:petLabel3];
    
    UILabel *petLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(10, 230, widthView, 320)];
    petLabel4.numberOfLines = 14;
    [petLabel4 setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSize]];
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
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(10, 30, 32, 32);
    [doneButton setBackgroundImage:[UIImage imageNamed:@"btn-close-bright"] forState:UIControlStateNormal];
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
	
	detailView = [[UIView alloc]initWithFrame:CGRectMake(10, 30, self.view.frame.size.width-20, self.view.frame.size.height - 60)];
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
	[doneButton setBackgroundImage:[UIImage imageNamed:@"btn-close-bright"] forState:UIControlStateNormal];
	[doneButton addTarget:self
				   action:@selector(detailPopUpDismiss)
		 forControlEvents:UIControlEventTouchUpInside];
	[detailView addSubview:doneButton];
}

-(int)calcNumLines:(NSString*)term {
	
    int numLines;
    
    int termLen = (int)[term length];
    NSArray *lineArray = [term componentsSeparatedByString:@"\n"];
    int numLineCarriageReturn =(int) [lineArray count];
    numLines = termLen / numCharAcross;
    numLines = numLines + numLineCarriageReturn;
    if (numLines < 2) {
        numLines = 1;
    }
    //NSLog(@"Number of lines: %i", numLines);
	return numLines;
	
}

-(int)calcHeight:(NSString*)term {
	
	int termLen = (int)[term length];
	NSArray *lineArray = [term componentsSeparatedByString:@"\n"];
	int numLineCarriageReturn =(int) [lineArray count];
    int height = (termLen / numCharAcross) * fontSizeGlobal;
    if (height < 40) {
        height = 36;
    }
    height = height + (numLineCarriageReturn * fontSizeGlobal);
    //NSLog(@"Height: %i", height);

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
	[doneButton setBackgroundImage:[UIImage imageNamed:@"btn-close-bright"] forState:UIControlStateNormal];
	[doneButton addTarget:self
				   action:@selector(detailPopUpDismiss)
		 forControlEvents:UIControlEventTouchUpInside];
	[detailView addSubview:doneButton];
}

-(void)backButtonClicked:(id)sender {
    
    [emParallaxHeader removeFromSuperview];
    [emTV removeFromParentViewController];
    emTV.tableView.delegate = nil;
    emTV = nil;
    emParallaxHeader = nil;
    
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
    int x = 150;
    int y = headerView.frame.size.height - 40;
    int numRows = 0;
	UIButton *flagDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagDetailButton.frame = CGRectMake(flagViewForFlag.frame.origin.x, headerView.frame.size.height-60, flagViewForFlag.frame.size.width, flagViewForFlag.frame.size.height);
	[flagDetailButton addTarget:self action:@selector(flagDetailClicked:) forControlEvents:UIControlEventTouchUpInside];
	flagViewForFlag.userInteractionEnabled = YES;
	
	[headerView addSubview:flagDetailButton];
    VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];

	for (NSDictionary *flagDicClient in [currentClient getFlags]) {
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
                //NSString *petID = [petInfo objectForKey:@"petid"];
                //NSMutableDictionary *dicForID = [[NSMutableDictionary alloc]init];
                //[dicForID setObject:[petInfo objectForKey:@"name"] forKey:@"petname"];
                //[dicForID setObject:petID forKey:@"Pet ID"];
                //[orderedTerms addObject:dicForID];

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
								//[docAttach setObject:petID forKey:@"petid"];
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

-(UIView*)createCustomClientSections:(NSMutableArray*)accordionSection
                          atTableRow:(NSIndexPath*)row {
    int y = 20;
    int x = 20;
    int ySection = y;
    int yOffset = 40;
    int numFields = (int)[accordionSection count];
	int width = self.view.frame.size.width - 50;
	ySection = 20;
	
    NSMutableArray *labelArray = [[NSMutableArray alloc]init];
    NSMutableArray *iconArray = [[NSMutableArray alloc]init];

    NSArray *customClientFieldsArray =[currentClient getCustomFields];
    NSArray *clientErrataData  = [currentClient getErrataDocs];
    
    numFields = (int)[customClientFieldsArray count];
    
    if ([clientErrataData count] > 0) {
        for (NSDictionary *errataDic in clientErrataData) {
            NSString *label = [errataDic objectForKey:@"label"];
            NSString *value = [errataDic objectForKey:@"docname"];
            NSString *mimeType = [errataDic objectForKey:@"mimetype"];
            NSString *urlLink  = [errataDic objectForKey:@"url"];
            
            NSLog(@"mime type: %@, url link: %@", mimeType, urlLink);
            
            int sectionHeight = [self calcHeight:label];
            int numLines = [self calcNumLines:label];
            int  sectionHeight2 = [self calcHeight:value];
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

            UIImageView *errataDiv = [[UIImageView alloc]initWithFrame:CGRectMake(x-10, y, width-20, 1)];
            [errataDiv setImage:[UIImage imageNamed:@"white-line-1px"]];
            [iconArray addObject:errataDiv];
            [iconArray addObject:labelInfo];
            [iconArray addObject:valInfo];
            
            yOffset = y;
            y += 12;
            
        }
    }
    
    for (NSDictionary *customField in customClientFieldsArray) {
        NSString *label = [customField objectForKey:@"label"];
        NSString *value = [customField objectForKey:@"value"];
        if (![value isEqual:[NSNull null]]) {
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
            
            yOffset = y;
            y += 12;
            
        }
    }
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, y)];
    cellHeight = cellView.frame.size.height;
    cellView.backgroundColor = [PharmaStyle colorBlueLight];

    for(UILabel *label in labelArray) {
        [cellView addSubview:label];
    }
    for(UIImageView *icon in iconArray) {
        [cellView addSubview:icon];
    }
    return cellView;
}

-(UIView*) createPetProfileCellView:(NSMutableArray*)accordionSection atTableRow:(NSIndexPath*)row  {

    int y = 5;
    int x = 20;
	int width = self.view.frame.size.width - 60;
	int petImgSize = 120;
    int ySection = y;
    int yOffset = 32;
	int basicInfoSectionY = 0;

    NSMutableArray *labelArray = [[NSMutableArray alloc]init];
    NSMutableArray *iconArray = [[NSMutableArray alloc]init];
    
    int numberPets = (int)[accordionSection count];
    
    for (int i = 0; i < numberPets; i++) {
        PetProfile *pet = [accordionSection objectAtIndex:i];
        int sectionHeight = [self calcHeight:[pet getPetName]];
        int numLines2 = [self calcNumLines:[pet getPetName]];
        
        UIImageView *petImageFrame = [[UIImageView alloc]initWithFrame:CGRectMake(0,y, petImgSize,petImgSize)];
        [petImageFrame setImage:[pet getProfilePhoto]];
        [iconArray addObject:petImageFrame];
        CAShapeLayer *circle = [CAShapeLayer layer];
        UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, petImageFrame.frame.size.width, petImageFrame.frame.size.height) cornerRadius:MAX(petImageFrame.frame.size.width, petImageFrame.frame.size.height)];
        circle.path = circularPath.CGPath;
        circle.fillColor = [UIColor whiteColor].CGColor;
        circle.strokeColor = [UIColor whiteColor].CGColor;
        circle.lineWidth = 1;
        petImageFrame.layer.mask = circle;
        
        UILabel *nameLabel = [self createTermLabel:[pet getPetName] 
                                              xPos:x + petImgSize
                                              yPos:y 
                                             width:width
                                            height:sectionHeight 
                                          numLines:numLines2 
                                     withLabelType:@"petBasic"];
        
        ySection += yOffset;
        y = y + sectionHeight;
        basicInfoSectionY = basicInfoSectionY + sectionHeight;
        [labelArray addObject:nameLabel];     
        
        UILabel *breedLabel = [self createTermLabel:[pet getPetBreed] 
                                              xPos:x + petImgSize
                                              yPos:y 
                                             width:width
                                            height:sectionHeight 
                                          numLines:numLines2 
                                     withLabelType:@"petBasic"];
        
        ySection += yOffset;
        y = y + sectionHeight;
        basicInfoSectionY = basicInfoSectionY + sectionHeight;
        [labelArray addObject:breedLabel];   
        
        UILabel *petTypeLabel = [self createTermLabel:[pet getPetType] 
                                              xPos:x + petImgSize
                                              yPos:y 
                                             width:width
                                            height:sectionHeight 
                                          numLines:numLines2 
                                     withLabelType:@"petBasic"];
        
        ySection += yOffset;
        y = y + sectionHeight;
        basicInfoSectionY = basicInfoSectionY + sectionHeight;
        [labelArray addObject:petTypeLabel];         
        
        UILabel *petDescriptionLabel = [self createTermLabel:[pet getPetDescription] 
                                              xPos:x + petImgSize
                                              yPos:y 
                                             width:width
                                            height:sectionHeight 
                                          numLines:numLines2 
                                     withLabelType:@"petBasic"];
        
        ySection += yOffset;
        y = y + sectionHeight;
        basicInfoSectionY = basicInfoSectionY + sectionHeight;
        [labelArray addObject:petDescriptionLabel];        
        
        
        UILabel *petNotesLabel = [self createTermLabel:[pet getPetDescription] 
                                              xPos:x + petImgSize
                                              yPos:y 
                                             width:width
                                            height:sectionHeight 
                                          numLines:numLines2 
                                     withLabelType:@"petBasic"];
        
        ySection += yOffset;
        y = y + sectionHeight;
        basicInfoSectionY = basicInfoSectionY + sectionHeight;
        [labelArray addObject:petNotesLabel];        
        
        NSArray *customPetFields = [pet getCustomPetFields];
        
        if (y < petImgSize) {
            
            y = y + petImgSize;
            
        }
        
        /*UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(x-10, y, width, 1)];
        [divider setImage:[UIImage imageNamed:@"white-line-1px"]];
        [labelArray addObject:divider];
        */
        
        for (NSDictionary *customDic in customPetFields) {
            UILabel *customLabel = [self createTermLabel:[customDic objectForKey:@"label"]
                                                  xPos:x 
                                                  yPos:y 
                                                 width:width
                                                height:sectionHeight 
                                              numLines:numLines2 
                                         withLabelType:@"petBasic"];
            
            y = y + sectionHeight;
            [labelArray addObject:customLabel];
            
            UILabel *customVal = [self createTermLabel:[customDic objectForKey:@"value"]
                                                  xPos:x 
                                                  yPos:y 
                                                 width:width
                                                height:sectionHeight 
                                              numLines:numLines2 
                                         withLabelType:@"petBasic"];
            
            y = y + sectionHeight;
            [labelArray addObject:customVal];
            
        }        
        
    }
	
    /*for(id petField in petInfoSort) {
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
            
            }
          else {
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
                UIImage *petImage = [[currentClient getPetImages] objectForKey:[petDicItem objectForKey:@"petname"]];
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
            } 
            else {
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
    }*/

	UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, y)];
    cellHeight = cellView.frame.size.height;
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
			sectionHeight += 8; // orig val = 20
            //NSLog(@"client label field: %@", clientField);
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
    cellHeight = cellView.frame.size.height;
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
    
	//NSLog(@"Client field: %@", termText);
    UILabel *labelForKey = [[UILabel alloc]initWithFrame:CGRectMake(x, y, width, height)];
    labelForKey.numberOfLines = numLines;

    
    if([labelType isEqualToString:@"label"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeGlobal]];
        [labelForKey setTextColor:[UIColor blackColor]];
    } else if ([labelType isEqualToString:@"value"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeGlobal]];
        [labelForKey setTextColor:[UIColor blackColor]];
    } else if ([labelType isEqualToString:@"custom"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeGlobal]];
        [labelForKey setTextColor:[PharmaStyle colorRedBright]];
    } else if ([labelType isEqualToString:@"listItem"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeGlobal]];
        [labelForKey setTextColor:[UIColor blackColor]];
    } else if ([labelType isEqualToString:@"petBasic"]) {
        [labelForKey setFont:[UIFont fontWithName:@"Lato-Regular" size:fontSizeGlobal]];
        [labelForKey setTextColor:[UIColor blackColor]];
    }
    [labelForKey setText:termText];
    return labelForKey;
}

-(void)addDataSections {
    NSLog(@"adding data sections");
	EMAccordionSection *petInfo = [[EMAccordionSection alloc]init];
	[petInfo setBackgroundColor:[PharmaStyle colorBlue]];
	[petInfo setTitle:@"PETS"];
	[petInfo setTitleColor:[UIColor blackColor]];
	[petInfo setTitleFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
	
	if([currentClient getPetInfo] != NULL && [[currentClient getPetInfo]count] > 0){
		petInfo.items = [currentClient getPetInfo];
		[emTV addAccordionSection:petInfo initiallyOpened:YES];
		[dataForSections addObject:[currentClient getPetInfo]];        

	} else {
		petInfo.items = [currentClient getPetInfo];
		[emTV addAccordionSection:petInfo initiallyOpened:YES];
		[dataForSections addObject:[currentClient getPetInfo]];
	}

    EMAccordionSection *clientBasicInfo = [currentClient getAccordionSection:@"basic"];
	[emTV addAccordionSection:clientBasicInfo initiallyOpened:YES];
    [dataForSections addObject:clientBasicInfo.items];

    EMAccordionSection *altInfo = [currentClient getAccordionSection:@"alt"];
    if (altInfo != nil) {
        [emTV addAccordionSection:altInfo initiallyOpened:YES];
        [dataForSections addObject:altInfo.items];
    }
    EMAccordionSection *vetInfo = [currentClient getAccordionSection:@"vet"];

    if (vetInfo != nil) {
        [emTV addAccordionSection:vetInfo initiallyOpened:YES];
        [dataForSections addObject:vetInfo.items];
    }    
    
    EMAccordionSection *alarmInfo = [currentClient getAccordionSection:@"alarm"];
    if (alarmInfo != nil) {
        [emTV addAccordionSection:alarmInfo initiallyOpened:YES];
        [dataForSections addObject:alarmInfo.items];
    }

    EMAccordionSection *locationSupplies = [currentClient getAccordionSection:@"location"];
	[emTV addAccordionSection:locationSupplies initiallyOpened:YES];
	[dataForSections addObject:locationSupplies.items];
    
    EMAccordionSection *customClientAccordionFields = [[EMAccordionSection alloc]init];
    [customClientAccordionFields setBackgroundColor:[PharmaStyle colorBlue]];
    [customClientAccordionFields setTitleFont:[UIFont fontWithName:@"Lato-Bold" size:22.0]];
    [customClientAccordionFields setTitleColor:[PharmaStyle  colorRedShadow70]];
    [customClientAccordionFields setTitle:@"CUSTOM"];    
	if(customClientAccordionFields != nil) {
		[emTV addAccordionSection:customClientAccordionFields initiallyOpened:YES];
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
        NSLog(@"On which section %i: %@",onWhichSection, [dataForSections objectAtIndex:2]);
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
        UIView *cellViewTestx = [self createPetProfileCellView:[currentClient getPetInfo] atTableRow:indexPath];
        
		//UIView *cellViewTestx = [self createCellViewWithSubsections:[currentClient getPetInfo] atTableRow:indexPath];
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
    return cellHeight;
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
    VisitDetails *localCurrentVisit = currentVisit;
	UIAlertController * alert=   [UIAlertController
								  alertControllerWithTitle:@"CHANGE VISIT STATUS"
								  message:@"MARK THIS VISIT UNARRIVE?"
								  preferredStyle:UIAlertControllerStyleAlert];
    UIButton *arriveButtonTmp = arriveButton;
    NSString *visitTmpApptID  = currentVisit.appointmentid;
	UIAlertAction* ok = [UIAlertAction
						 actionWithTitle:@"OK"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 [alert dismissViewControllerAnimated:YES completion:nil];
							 localCurrentVisit.status = @"future";
							 localCurrentVisit.arrived = @"NO";
							 localCurrentVisit.dateTimeMarkArrive = @"";
							 localCurrentVisit.coordinateLatitudeMarkArrive = @"0.0";
							 localCurrentVisit.coordinateLongitudeMarkArrive = @"0.0";
							 sharedVisits.onSequence = @"000";
							 sharedVisits.onWhichVisitID = @"000";
							 
							 [arriveButtonTmp setBackgroundImage:[UIImage imageNamed:@"arrive-pink-button"]
													 forState:UIControlStateNormal];
							 [sharedVisits markVisitUnarrive:visitTmpApptID];
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
    
    VisitDetails *localCurrentVisit = currentVisit;

	UIAlertAction* ok = [UIAlertAction
						 actionWithTitle:@"OK"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 [alert dismissViewControllerAnimated:YES completion:nil];
                             localCurrentVisit.status = @"arrived";
                             localCurrentVisit.arrived = @"YES";
                             localCurrentVisit.dateTimeMarkArrive = @"";
                             localCurrentVisit.dateTimeMarkArrive = @"";
                             localCurrentVisit.coordinateLatitudeMarkArrive = @"0.0";
                             localCurrentVisit.coordinateLongitudeMarkArrive = @"0.0";
                             [self->arriveButton setBackgroundImage:[UIImage imageNamed:@"unarrive-pink-button"]
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
-(void)dealloc {
	[emParallaxHeader removeFromSuperview];
    emParallaxHeader = nil;
	[emTV removeFromParentViewController];
	emTV.delegate = nil;
	emTV.view = nil;
	emTV = nil;
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
		[emTV.tableView reloadData];
	} else {
		tableRowHeight = kTableRowHeight;
		[emTV.tableView reloadData];
	}
}
- (void)setClosedSectionIcon:(UIImage *)iconImg { 
    
}
- (void)setOpenedSectionIcon:(UIImage *)iconImg { 
    
}
- (void)setParallaxTableHeaderView:(EMAccordionTableParallaxHeaderView *)parallaxTable { 
    
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
	[doneButton setBackgroundImage:[UIImage imageNamed:@"btn-close-bright"] forState:UIControlStateNormal];
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
	
	for (NSDictionary *flagDicClient in [currentClient getFlags]) {
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
				[flagSrcText setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
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
		for (NSDictionary *flagDicClient in [currentClient getFlags]) {
			NSString *comparingFlagID = [flagDicClient objectForKey:@"flagid"];
			if ([comparingFlagID isEqualToString:flagIDString]) {
				detailMoreDetailView = [[UIView alloc]initWithFrame:CGRectMake(0,0, detailView.frame.size.width-30, detailView.frame.size.height-20)];
				[detailMoreDetailView setBackgroundColor:[UIColor blackColor]];
				[detailView addSubview:detailMoreDetailView];
				
				UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
				doneButton.frame = CGRectMake(10, 10, 24, 24);
				[doneButton setBackgroundImage:[UIImage imageNamed:@"btn-close-bright"] forState:UIControlStateNormal];
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
    DataClient *tmpClient = currentClient;
    if(![currentClient.cellphone isEqual:[NSNull null]] && [currentClient.cellphone length] > 0) {
		UIAlertAction* phoneCall = [UIAlertAction
									actionWithTitle:@"CALL - Cell"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action)
									{
										[alert dismissViewControllerAnimated:YES completion:nil];
										NSString *preTeleString = tmpClient.cellphone;
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
											 
                                            /*[[UIApplication sharedApplication]openURL:[NSURL URLWithString:telephoneNumFormat] options:NULL completionHandler:^(BOOL success) {
                                                
                                            }];*/
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
        NSString *homePhone = currentClient.homePhone;
		UIAlertAction* phoneCall = [UIAlertAction
									actionWithTitle:@"CALL - Home Phone"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action)
									{
										[alert dismissViewControllerAnimated:YES completion:nil];
										NSString *preTeleString = homePhone;
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
        NSString *workphone = currentClient.workphone;

		UIAlertAction* phoneCall = [UIAlertAction
									actionWithTitle:@"CALL - Home Work"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action)
									{
										[alert dismissViewControllerAnimated:YES completion:nil];
										NSString *preTeleString = workphone;
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
                                             /*[[UIApplication sharedApplication]openURL:[NSURL URLWithString:telephoneNumFormat] 
                                                                               options:nil
                                                                     completionHandler:^(BOOL success) {
                                                                         
                                                                     }];*/
											 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneNumFormat]];
											 
										 }];
										
										
									}];
		[alert addAction:phoneCall];
		
	}
    
    NSString *preTeleString = currentClient.cellphone;
    NSString *telNumStr = @"(\\d\\d\\d)(-?)\\d\\d\\d(-?)\\d\\d\\d\\d";
    NSString *telNumPattern;
    telNumPattern = [NSString stringWithFormat:telNumStr,telNumPattern];
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSError *error = NULL;
    NSRegularExpression *telRegex = [NSRegularExpression regularExpressionWithPattern:telNumStr
                                                                              options:regexOptions
                                                                                error:&error];
    MFMessageComposeViewController *textMsg = [[MFMessageComposeViewController alloc]init];

	UIAlertAction* textMessage = [UIAlertAction
								  actionWithTitle:@"TEXT"
								  style:UIAlertActionStyleDefault
								  handler:^(UIAlertAction * action)
								  {
									  [alert dismissViewControllerAnimated:YES completion:nil];

									  
									  [telRegex enumerateMatchesInString:preTeleString
																 options:0
																   range:NSMakeRange(0, [preTeleString length])
															  usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop)
									   {
										   NSRange range = [match rangeAtIndex:0];
										   NSString *regExTel = [preTeleString substringWithRange:range];
										   
										   NSString *telephoneNumFormat = [@"" stringByAppendingString:regExTel];
										   textMsg.messageComposeDelegate = self;
										   textMsg.recipients = [NSArray arrayWithObjects:telephoneNumFormat, nil];
										   
										   [self presentViewController:textMsg animated:YES completion:nil];
										   
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
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
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
