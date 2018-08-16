//
//  ClientListViewController.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/19/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "ClientListViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "MGSwipeButton.h"
#import "VisitTableCell.h"
#import "DataClient.h"
#import "VisitDetails.h"
#import "VisitsAndTracking.h"
#import "LocationShareModel.h"
#import "LocationTracker.h"
#import "DetailAccordionViewController.h"
#import "PharmaStyle.h"
#import "DateTools.h"
#import "NSDate+DateTools.h"
#import "ViewController.h"
#import "math.h"
#import "SSSnackbar.h"
#import "FloatingModalView.h"

//@import UserNotifications;

#define kTableCellHeight 170.0f

@implementation ClientListViewController
{
    UIRefreshControl * refreshControl;
    VisitsAndTracking *sharedVisits;
    NSMutableDictionary *flagIndex;
    UIImageView *calendarDay;
    UIView *headerView;
	UIView *updateBackground;
    UIButton *prevDay;
    UIButton *nextDay;

    NSDate *startDate;
    NSDate *showingDay;
    NSString *dayNumber;
    NSString *dayOfWeek;
    NSString *monthDate;
    
    BOOL isIphone6P;
    BOOL isIphone6;
    BOOL isIphone5;
    BOOL isIphone4;
	BOOL isIphoneX;
	
	UILabel* dateLabel;
	UILabel* dayOfWeekLabel;
	UILabel* monthLabel;
	
	UILabel *debugGPSStart;
	UILabel *debugGPSStop;
	UILabel *debugGPS;

	Boolean debugON;

	NSDateFormatter *timerDateFormat;
	NSDateFormatter *formatFutureDate;
	
	
    DetailAccordionViewController *detailAccordionView;
}

-(instancetype)init {
    self = [super init];
    if(self) {
        
        sharedVisits = [VisitsAndTracking sharedInstance];
		debugON = NO;
		updateBackground = [[UIView alloc]initWithFrame:CGRectMake(40, 40, self.view.frame.size.width - 80, 160)];
		[updateBackground setBackgroundColor:[UIColor blackColor]];
		[updateBackground setAlpha:0.65];
		
		UILabel *updateNetworkLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, updateBackground.frame.size.width-20, 120)];
		[updateNetworkLabel setFont:[UIFont fontWithName:@"Langdon" size:20]];
		[updateNetworkLabel setTextColor:[UIColor whiteColor]];
		[updateNetworkLabel setText:@"UPDATING VISIT DATA\n\nPLEASE WAIT"];
		updateNetworkLabel.textAlignment = NSTextAlignmentCenter;
		updateNetworkLabel.numberOfLines = 5;
		[updateBackground addSubview:updateNetworkLabel];
		
		//detailAccordionView = [[DetailAccordionViewController alloc]init];
		prevDay = [UIButton buttonWithType:UIButtonTypeCustom];
		[prevDay addTarget:self
					action:@selector(getPrevNext:)
		  forControlEvents:UIControlEventTouchUpInside];
		prevDay.tag = 1;
		nextDay = [UIButton buttonWithType:UIButtonTypeCustom];
		[nextDay addTarget:self
					action:@selector(getPrevNext:)
		  forControlEvents:UIControlEventTouchUpInside];
		nextDay.tag = 2;
		
		NSString *theDeviceType = [sharedVisits tellDeviceType];
		NSString *pListData = [[NSBundle mainBundle]
							   pathForResource:@"flagID"
							   ofType:@"plist"];
		
		flagIndex = [[NSMutableDictionary alloc] initWithContentsOfFile:pListData];
		
		timerDateFormat = [[NSDateFormatter alloc]init];
		[timerDateFormat setDateFormat:@"mm:ss"];
		[timerDateFormat setTimeZone:[NSTimeZone localTimeZone]];
		
		formatFutureDate = [[NSDateFormatter alloc]init];
		[formatFutureDate setDateFormat:@"MM/dd/yyyy"];
		[formatFutureDate setTimeZone:[NSTimeZone localTimeZone]];
		
		if ([theDeviceType isEqualToString:@"iPhone6P"]) {
			isIphoneX= NO;
			isIphone6P = YES;
			isIphone5 = NO;
			isIphone6 = NO;
			isIphone4 = NO;
			_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
			prevDay.frame = CGRectMake(5, 50, 32, 32);
			nextDay.frame = CGRectMake(75, 50, 32, 32);
		} else if ([theDeviceType isEqualToString:@"iPhone6"]) {
			isIphoneX= NO;
			isIphone6 = YES;
			isIphone5 = NO;
			isIphone6P = NO;
			isIphone4 = NO;
			_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
			prevDay.frame = CGRectMake(0, 42, 36, 42);
			nextDay.frame = CGRectMake(66, 42, 36, 42);
		} else if ([theDeviceType isEqualToString:@"iPhone5"]) {
			isIphoneX= NO;
			isIphone5 = YES;
			isIphone6 = NO;
			isIphone6P = NO;
			isIphone4 = NO;
			_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
			prevDay.frame = CGRectMake(3, 40, 32, 32);
			nextDay.frame = CGRectMake(60, 40, 32, 32);
		} else if ([theDeviceType isEqualToString:@"iPhone X"]) {
			isIphoneX= YES;
			isIphone5 = NO;
			isIphone6 = NO;
			isIphone6P = NO;
			isIphone4 = NO;
			_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
			prevDay.frame = CGRectMake(3, 40, 32, 32);
			nextDay.frame = CGRectMake(60, 40, 32, 32);
		} else {
			isIphone5 = NO;
			isIphone6 = NO;
			isIphone6P = NO;
			isIphone4 = YES;
			_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
			prevDay.frame = CGRectMake(5, 10, 16, 16);
			nextDay.frame = CGRectMake(70, 10, 16, 16);
		}
		
		prevDay.alpha = 0.4;
		nextDay.alpha = 0.4;
		
		[prevDay setBackgroundImage:[UIImage imageNamed:@"prev-day"] forState:UIControlStateNormal];
		[nextDay setBackgroundImage:[UIImage imageNamed:@"next-day-button"] forState:UIControlStateNormal];
		
		_tableView.delegate = self;
		_tableView.dataSource = self;
		[self.view addSubview:_tableView];
		
		
		refreshControl = [[UIRefreshControl alloc] init];
		[refreshControl addTarget:self
						   action:@selector(getUpdatedVisitsForToday)
				 forControlEvents:UIControlEventValueChanged];
		
		[self setupDateValues];
		
		self.title = @"LeashTime Clients";
		
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pollingUpdates)
                                                     name:@"pollingCompleteWithChanges"
                                                   object:nil];

			
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(reachabilityStatusChanged:)
                                                    name:@"reachable"
                                                  object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(unreachableNetwork:)
                                                    name:@"unreachable"
                                                  object:nil];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(noVisits)
                                                    name:@"noVisits"
                                                  object:nil];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(applicationEnterBackground)
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
	
		[[NSNotificationCenter defaultCenter]addObserver:self
												selector:@selector(reloadTableView)
													name:@"updateTable"
												  object:nil];
		
		
	    [[NSNotificationCenter defaultCenter]addObserver:self
								  selector:@selector(resendUpdateTable)
									name:@"resendArriveCompleteSuccess"
								    object:nil];
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(debugGPS) name:@"debugGPS" object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startGPSDebug) name:@"startGPS" object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopGPSDebug) name:@"stopGPS" object:nil];
    }
     return self;
}

-(void) debugGPS {

	LocationShareModel *sharedLocation = [LocationShareModel sharedModel];
	int numberCoordinates = (int)[sharedLocation.allCoordinates count];
	
	NSString *gpsStat = [NSString stringWithFormat:@"Current num coord: %i ",numberCoordinates];
	[debugGPS setText:gpsStat];
	[debugGPS setTextColor:[UIColor blackColor]];
	if (debugON) {
		[debugGPS setText:gpsStat];	
	} else {
		[debugGPS setText:@""];
		[debugGPSStart setText:@""];
		[debugGPSStop setText:@""];
	}
	
	NSDictionary *pauseLocation = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
	for (id  dicItem in pauseLocation) {
		if ([dicItem isKindOfClass:[NSString class]]) {
			NSString *dicString = (NSString*)dicItem;
			id dicVal = [pauseLocation objectForKey:dicString];
			if ([dicVal isKindOfClass:[NSString class]]) {
				NSString *dicValString = (NSString*) dicVal;
				NSString *dicValConsolidated = [NSString stringWithFormat:@"%@ at %@", dicValString, dicString];
				if ([dicValString isEqualToString:@"LOCATION PAUSE"]) {
					[debugGPSStop setText:dicValConsolidated];
				}
			}
		}
	}
}

-(void) startGPSDebug {

	LocationTracker *locTrack = [LocationTracker sharedLocationManager];
	
	if (debugON) {
		if (locTrack.isLocationTracking) {
			[debugGPSStart setText:@"LOCATION TRACKER ON"];
			[debugGPSStart setTextColor:[UIColor colorWithRed:128 green:256 blue:128 alpha:1]];
			[debugGPSStop setText:@""];
		}
	}
	if (locTrack.isLocationTracking) {
		[debugGPSStart setText:@"LOCATION TRACKER ON"];
		[debugGPSStart setTextColor:[UIColor colorWithRed:128 green:256 blue:128 alpha:1]];
		[debugGPSStop setText:@""];
	}

}
-(void) stopGPSDebug {
	LocationTracker *locTrack = [LocationTracker sharedLocationManager];

	if (debugON) {
		if (!locTrack.isLocationTracking) {
			[debugGPSStop setText:@"LOCATION TRACKER OFF"];
			[debugGPSStop setTextColor:[UIColor redColor]];
			[debugGPSStart setText:@""];
		}
	}
}

-(void) foregroundPollingUpdate {
	//NSLog(@"foreground polling update");
	if (sharedVisits.isReachable) {

		[self.view addSubview:updateBackground];
		updateBackground.alpha = 1.0;
		[UIView animateWithDuration:3.0 animations:^{
			updateBackground.alpha = 0.0;
		}];
		
		@synchronized(@"yesterday") {
			_tableView.userInteractionEnabled = NO;
			showingDay = [NSDate date];
			sharedVisits.showingWhichDate = showingDay;
			sharedVisits.todayDate = showingDay;
			[sharedVisits networkRequest:showingDay toDate:showingDay];
		}
	} else {
		_tableView.userInteractionEnabled = YES;
		showingDay = [NSDate date];
		sharedVisits.showingWhichDate = showingDay;
		sharedVisits.todayDate = showingDay;
		dateLabel = [[UILabel alloc]init];
		dayOfWeekLabel = [[UILabel alloc]init];
		monthLabel = [[UILabel alloc]init];
	}
}
-(void) setupListView {
	//NSLog(@"LIST setting up list view table view controller");
	[self setupDateValues];
	[self.view addSubview:_tableView];
	[_tableView addSubview:refreshControl];
}

-(void) viewDidLoad {
	
	[super viewDidLoad];
	//NSLog(@"LIST - view did load");
	showingDay = [NSDate date];
}

-(void) didMoveToParentViewController:(UIViewController *)parent {
	//NSLog(@"ALLOC INIT DETAILACCORDIONVIEWCONTROLLER");

}
-(void) viewDidAppear:(BOOL)animated {
	//NSLog(@"LIST TABLE DID APPEAR");
	[_tableView reloadData];	
	detailAccordionView = [[DetailAccordionViewController alloc]init];
}
	
-(void) reloadTableView {
	[_tableView reloadData];
}
-(void) pollingUpdates {
	//NSLog(@"LIST polling updates table view");
	_tableView.userInteractionEnabled = NO;
	dateLabel = [[UILabel alloc]init];
	dayOfWeekLabel = [[UILabel alloc]init];
	monthLabel = [[UILabel alloc]init];
	debugGPS = [[UILabel alloc]init];
	debugGPSStart = [[UILabel alloc]init];
	debugGPSStop = [[UILabel alloc]init];
	
	[self setupListView];
	
	[updateBackground removeFromSuperview];
	[_tableView reloadData];
	_tableView.userInteractionEnabled = YES;
}
-(void) setupDateValues {
	//NSLog(@"LIST- set up date");
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:sharedVisits.showingWhichDate];
	NSInteger day = [weekdayComponents day];
	NSDateFormatter *monthFormatter = [[NSDateFormatter alloc]init];
	[monthFormatter setDateFormat:@"MMM"];
	
	monthDate = [[monthFormatter stringFromDate:sharedVisits.showingWhichDate]uppercaseString];
	dayNumber = [NSString stringWithFormat:@"%ld",(long)day];
	
	NSInteger weekday = [weekdayComponents weekday];
	if(weekday == 1) {
		dayOfWeek = @"SUN";
	} else if (weekday == 2) {
		dayOfWeek = @"MON";
		
	} else if (weekday == 3) {
		dayOfWeek = @"TUE";
		
	} else if (weekday == 4) {
		dayOfWeek = @"WED";
		
	} else if (weekday == 5) {
		dayOfWeek = @"THU";
		
	} else if (weekday == 6) {
		dayOfWeek = @"FRI";
		
	} else if (weekday == 7) {
		dayOfWeek = @"SAT";
	}
	
	//NSLog(@"DATE Values: %@ %@", monthDate, dayNumber);
}
-(void) applicationEnterBackground {
	//NSLog(@"LIST CLIENT VC ENTER BACKGROUND");
	
	int numVisits = (int)[sharedVisits.visitData count];
	for (int i = 0; i < numVisits; i++) {
	
		//NSUInteger cellIndex = (NSUInteger)i;
		NSIndexPath *pathID = [NSIndexPath indexPathForRow:0 inSection:i];
		VisitTableCell *cell = [_tableView cellForRowAtIndexPath:pathID];
		[cell stopVisitTimer];
		
	}
	[detailAccordionView dismissViewControllerAnimated:NO completion:^{
		
	}];
	[detailAccordionView removeFromParentViewController];

	[dateLabel removeFromSuperview];
	[dayOfWeekLabel removeFromSuperview];
	[monthLabel removeFromSuperview];
	[refreshControl removeFromSuperview];
	[flagIndex removeAllObjects];

	detailAccordionView = nil;
	dateLabel = nil;
	dayOfWeekLabel = nil;
	monthLabel = nil;
	startDate = nil;
	showingDay = nil;
	flagIndex = nil;

}
-(void) dealloc {
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"HH:mm:ss MM dd YYYY"];
	[dateFormat setTimeZone:[NSTimeZone localTimeZone]];
	NSString *dateString = [dateFormat stringFromDate:date];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:@"CLIENT LIST VIEW CONTROLLER DEALLOCATED" forKey:dateString];

	[detailAccordionView dismissViewControllerAnimated:NO completion:^{
	}];

	[flagIndex removeAllObjects];
	[refreshControl removeFromSuperview];
	[calendarDay removeFromSuperview];
	[nextDay removeFromSuperview];
	[prevDay removeFromSuperview];
	[dateLabel removeFromSuperview];
	[dayOfWeekLabel removeFromSuperview];
	[monthLabel removeFromSuperview];
	[headerView removeFromSuperview];

	detailAccordionView = nil;
	dateLabel = nil;
	dayOfWeekLabel = nil;
	monthLabel = nil;
	dayNumber = nil;
	dayOfWeek = nil;
	monthDate = nil;
	startDate = nil;
	showingDay = nil;

	nextDay = nil;
	calendarDay = nil;
	refreshControl = nil;
	flagIndex = nil;
	prevDay = nil;
	headerView = nil;


}

-(void) getAnotherDay:(NSString*)lockID forDay:(NSDate*)forDayDate {
	@synchronized(lockID) {
		[sharedVisits getNextPrevDay:forDayDate];
		showingDay = forDayDate;
	}
	
	//NSString *todayDate = [formatFutureDate stringFromDate:sharedVisits.todayDate];
	//NSString *dateOn = [formatFutureDate stringFromDate:forDayDate];
}

-(void) getPrevNext:(id)sender {
	
	NSCalendar *newCal = [NSCalendar currentCalendar];
	UIButton *prevNext;
	if([sender isKindOfClass:[UIButton class]]) {
		prevNext = (UIButton*)sender;
	}
	
	if(prevNext.tag == 1) {
		CGRect newFrame = CGRectMake(prevDay.frame.origin.x-20, prevDay.frame.origin.y, prevDay.frame.size.width-20, prevDay.frame.size.height+20);
		CGRect newFrame2 = CGRectMake(prevDay.frame.origin.x, prevDay.frame.origin.y, prevDay.frame.size.width, prevDay.frame.size.height);
		[UIView animateWithDuration:0.05
							  delay:0.0
			 usingSpringWithDamping:0.7
			  initialSpringVelocity:1.0
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 prevDay.frame = newFrame;							 
						 } completion:^(BOOL finished) {
							 prevDay.frame = newFrame2;
						 }];
		NSDate *anotherDate = [newCal dateByAddingUnit:NSCalendarUnitDay
												 value:-1
												toDate:sharedVisits.showingWhichDate
											   options:kNilOptions];
		
		
		[self getAnotherDay:@"yesterday" forDay:anotherDate];


	} else if (prevNext.tag == 2) {
		CGRect newFrame = CGRectMake(nextDay.frame.origin.x+5, nextDay.frame.origin.y, nextDay.frame.size.width+5, nextDay.frame.size.height+10);
		CGRect newFrame2 = CGRectMake(nextDay.frame.origin.x, nextDay.frame.origin.y, nextDay.frame.size.width, nextDay.frame.size.height);
		
		[UIView animateWithDuration:0.05
							  delay:0.0
			 usingSpringWithDamping:0.7
			  initialSpringVelocity:1.0
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
        
							 nextDay.frame = newFrame;
        
						 } completion:^(BOOL finished) {
        
        nextDay.frame = newFrame2;
							 
        
						 }];
		
		NSDate *anotherDate = [newCal dateByAddingUnit:NSCalendarUnitDay
												 value:1
												toDate:sharedVisits.showingWhichDate
											   options:kNilOptions];
		//NSLog(@"another date: %@",anotherDate);
		[self getAnotherDay:@"nextDay" forDay:anotherDate];

	}
}
#pragma mark Table Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	
	if (isIphone6P || isIphone6) {
		return 120.0;
	} else if (isIphone5) {
		return 100.0;
	} else {
		return 100.0;
	}
	
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	
	//NSLog(@"LIST - view for header");
	UIImageView *logoView;
	UIImageView *logoView2;

	if (isIphone6P) {
		
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 120)];
		calendarDay = [[UIImageView alloc]initWithFrame:CGRectMake(5,0,100,115)];
		logoView = [[UIImageView alloc]initWithFrame:CGRectMake(headerView.frame.size.width - 50, headerView.frame.size.height - 120, 48, 48)];
		logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(120,0, 180,42)];
		
	}
	else if (isIphone6) {
		
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 120)];
		calendarDay = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,100,115)];
		logoView = [[UIImageView alloc]initWithFrame:CGRectMake(headerView.frame.size.width - 40, headerView.frame.size.height - 120, 32, 32)];
		logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(120,0, 180,42)];
		
	}
	else if (isIphone5) {
		
		
		calendarDay = [[UIImageView alloc]initWithFrame:CGRectMake(5,0,85,85)];
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 100)];
		logoView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, headerView.frame.size.height - 100, 32, 32)];
		logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(100,0, 140,32)];
		
		
	}
	else if (isIphone4) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 100)];
		logoView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-70, 70, 60, 60)];
		logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100,0, 100,32)];
		calendarDay = [[UIImageView alloc]initWithFrame:CGRectMake(5,0,85,85)];
		
	}

	headerView.backgroundColor = [PharmaStyle colorBlueHighlight];
	headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
	headerView.layer.borderWidth = 1.0;
	
	UIView *LheaderBack = [[UIView alloc]initWithFrame:headerView.frame];
	[LheaderBack setBackgroundColor:[PharmaStyle colorBlueLight]];
	LheaderBack.alpha = 0.7;
	[headerView addSubview:LheaderBack];
	
	if (isIphone6P) {
		dateLabel.frame = CGRectMake(0, 50, 110,40);
		dateLabel.textAlignment = NSTextAlignmentCenter;
		dayOfWeekLabel.frame = CGRectMake(0,10,100,32);
		dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
		monthLabel.frame = CGRectMake(0,90,110,20);
		monthLabel.textAlignment = NSTextAlignmentCenter;
		
		LocationShareModel *shareModel = [LocationShareModel sharedModel];
		NSString *numCoordString = [NSString stringWithFormat:@"%lu", (unsigned long)[shareModel.allCoordinates count]];
		LocationTracker *locTrack = [LocationTracker sharedLocationManager];
		
		debugGPS.frame = CGRectMake(120, 40, 300, 20);
		[debugGPS setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
		[debugGPS setTextColor:[UIColor blackColor]];
		[debugGPS setText:numCoordString];
		
		debugGPSStart.frame = CGRectMake(120, 60, 300, 20);
		[debugGPSStart setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
		[debugGPSStart setTextColor:[UIColor blackColor]];
		
		debugGPSStop.frame = CGRectMake(debugGPSStart.frame.origin.x, 80, 300, 20);
		[debugGPSStop setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
		[debugGPSStop setTextColor:[UIColor blackColor]];
		
		
		if (locTrack.isLocationTracking) {
			[debugGPSStart setText:@"GPS START"];
			[debugGPSStop setText:@""];
		} else {
			[debugGPSStart setText:@""];
			[debugGPSStop setText:@"GPS STOP"];
		}
	} else if (isIphone6) {
		dateLabel.frame = CGRectMake(0, 40, 100,40);
		dateLabel.textAlignment = NSTextAlignmentCenter;
		dayOfWeekLabel.frame = CGRectMake(0,10,100,32);
		dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
		monthLabel.frame = CGRectMake(0,90,100,20);
		monthLabel.textAlignment = NSTextAlignmentCenter;

	} else if (isIphone5) {
		dateLabel.frame = CGRectMake(0, 28, 90,40);
		dateLabel.textAlignment = NSTextAlignmentCenter;
		dayOfWeekLabel.frame = CGRectMake(0,0,90,32);
		dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
		monthLabel.frame = CGRectMake(0,60,90,20);
		monthLabel.textAlignment = NSTextAlignmentCenter;

		
	} else if (isIphone4) {
		dateLabel.frame = CGRectMake(0, 28, 80,40);
		dateLabel.textAlignment = NSTextAlignmentCenter;
		dayOfWeekLabel.frame = CGRectMake(0,0,80,32);
		dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
		monthLabel.frame = CGRectMake(0,30,110,40);
		monthLabel.textAlignment = NSTextAlignmentCenter;

		
	}
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.textColor = [UIColor blackColor];
	dateLabel.font = [UIFont fontWithName:@"Lato-Bold" size:28];
	dateLabel.text = dayNumber;
	
	dayOfWeekLabel.backgroundColor = [UIColor clearColor];
	dayOfWeekLabel.textColor = [UIColor blackColor];
	dayOfWeekLabel.font = [UIFont fontWithName:@"Lato-Bold" size:22];
	dayOfWeekLabel.text = dayOfWeek;
	dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
	
	monthLabel.backgroundColor = [UIColor clearColor];
	monthLabel.textColor = [UIColor blackColor];
	monthLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
	monthLabel.text = monthDate;
	monthLabel.textAlignment = NSTextAlignmentCenter;

	logoView.image = [UIImage imageNamed:@"leashtime-logo-big"];
	logoView.backgroundColor = [UIColor clearColor];
	
	logoView2.image = [UIImage imageNamed:@"leashtime-logo-text"];
	logoView2.backgroundColor = [UIColor clearColor];
	logoView2.alpha = 1.0;
	
	int numVisitsForDay = (int)[sharedVisits.visitData count];
	int numVisitsCompletedForDay = 0;
	
	NSString *clientOn;
	NSString *serviceOn;
	NSString *petName;
	
	for(VisitDetails *visit in sharedVisits.visitData) {
		if([visit.status isEqualToString:@"completed"]) {
			numVisitsCompletedForDay++;
		} else if([visit.status isEqualToString:@"canceled"]) {
			numVisitsForDay--;
		}
		
		if([sharedVisits.onSequence isEqualToString:visit.sequenceID]) {
			clientOn = visit.clientname;
			serviceOn = visit.service;
			petName = visit.petName;
		}
	}
	
	int yOffset = 22;
	int fontSize = 16;
	int xOffset = 290;
	
	if(isIphone6P) {
		yOffset = 22;
		
	} else if (isIphone6) {
		
		yOffset = 22;
		fontSize = 14;
		xOffset = 250;
		
	} else if (isIphone5) {
		
		yOffset = 22;
		fontSize = 14;
		xOffset = 220;
		
	} else if (isIphone4) {
		
		yOffset = 22;
		
	}
	
	UILabel *visitCompleted = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-xOffset,headerView.frame.size.height-yOffset, 180, 20)];
	visitCompleted.font = [UIFont fontWithName:@"Langdon" size:fontSize];
	visitCompleted.numberOfLines = 1;
	visitCompleted.textColor = [PharmaStyle colorRedShadow70];
	NSString *visitString = [NSString stringWithFormat:@"%i COMPLETE, %i VISITS",numVisitsCompletedForDay, numVisitsForDay];
	visitCompleted.text = visitString;
	
	UILabel *clientOnLabel;
	
	if(clientOn != NULL) {
		
		int xOffset = 120;
		int widthSize = 240;
		int fontSize = 18;
		int yPos = 50;
		
		if(isIphone6P) {
			xOffset = 120;
			widthSize = 240;
			fontSize = 16;
			
		} else if (isIphone6) {
			xOffset = 120;
			widthSize = 240;
			fontSize = 14;
		} else if (isIphone5) {
			xOffset = 100;
			widthSize = 180;
			fontSize = 14;
			yPos = 30;
		} else if (isIphone4) {
			xOffset = 70;
			widthSize = 160;
			yPos = 30;
			fontSize = 14;
		}
		clientOnLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset, yPos, widthSize, 50)];
		clientOnLabel.font = [UIFont fontWithName:@"Lato-Regular" size:fontSize];
		clientOnLabel.numberOfLines = 3;
		clientOnLabel.textColor = [PharmaStyle colorRedShadow70];
		NSString *clientService = [NSString stringWithFormat:@"%@\n(%@)",petName,clientOn];
		clientOnLabel.text = clientService;
	}
	
	calendarDay.image = [UIImage imageNamed:@"cal-icon-nohooks"];
	calendarDay.alpha = 0.9;
	calendarDay.backgroundColor = [UIColor clearColor];
	
	if(!debugON) 
		[headerView addSubview:clientOnLabel];
	[headerView addSubview:visitCompleted];
	[headerView addSubview:calendarDay];
	
	[headerView addSubview:logoView2];
	[headerView addSubview:logoView];
	
	[headerView addSubview:dateLabel];
	[headerView addSubview:dayOfWeekLabel];
	[headerView addSubview:monthLabel];
	[headerView addSubview:prevDay];
	[headerView addSubview:nextDay];
	
	if(debugON) {
		NSLog(@"DEBUG ON");
		[headerView addSubview:debugGPS];
		[headerView addSubview:debugGPSStart];
		[headerView addSubview:debugGPSStop];
	} 

	if (sharedVisits.showReachabilityIcon) {
		[self showReachabilityIcon];
	}
	
	UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	helpButton.frame = CGRectMake(headerView.frame.size.width-30, logoView.frame.origin.y + 40, 24, 24);
	[helpButton setImage:[UIImage imageNamed:@"help-icon"] forState:UIControlStateNormal];
	[helpButton addTarget:self action:@selector(clickHelp) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:helpButton];
	return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sharedVisits.visitData.count;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
	
	VisitTableCell *cellDidEndDisplay = (VisitTableCell*)cell;
	[cellDidEndDisplay stopVisitTimer];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    VisitDetails *visitRecord;
    if(sharedVisits.visitData != NULL) {
         visitRecord = [sharedVisits.visitData objectAtIndex:indexPath.row];
    }
	
    for (DataClient *clientProfile in sharedVisits.clientData) {
		if ([visitRecord.clientptr isEqualToString:clientProfile.clientID]) {
            sharedVisits.onWhichVisitID = visitRecord.appointmentid;
            [detailAccordionView setClientAndVisitID:clientProfile visitID:visitRecord];
			[self.view addSubview:detailAccordionView.view];
			[self addChildViewController:detailAccordionView];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString * identifier = @"MailCell";

    if (sharedVisits.visitData.count == 0) {
        return nil;
    }
    float height = kTableCellHeight;
    
	
	VisitTableCell *visitCell;
    VisitDetails *visitDetail;
	UIButton *docErrataButton;	
	
	if(sharedVisits.visitData != NULL) {
		visitDetail = [sharedVisits.visitData objectAtIndex:indexPath.row];
	}
	visitCell = [[VisitTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier andSize:CGSizeMake(self.view.frame.size.width, kTableCellHeight)];
	[visitCell setVisitDetail:visitDetail];

	
    visitCell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"MARK VISIT ARRIVE"
                                                   icon:[UIImage imageNamed:@"arrive-pink-button"]
                                        backgroundColor:[PharmaStyle colorBlue]]];
    visitCell.leftSwipeSettings.transition = MGSwipeTransition3D;
    visitCell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"MARK VISIT COMPLETE"
                                                    icon:[UIImage imageNamed:@"check-mark-green"]
                                         backgroundColor:[PharmaStyle colorYellow]]];
	visitCell.rightSwipeSettings.transition = MGSwipeTransition3D;
    visitCell.delegate = self;
	visitCell.tag = [visitDetail.appointmentid intValue];
		
	UIButton *managerVisitNote;

	int widthOffset = 0;
	int fontSize = 18;
	widthOffset = 0;
	fontSize = 16;
	
	if(isIphone6P) {
		widthOffset = 0;
	} else if (isIphone6) {
		widthOffset = 40;
		fontSize = 14;
	} else if (isIphone5) {
		widthOffset = 70;
		fontSize = 14;
	} else if (isIphone4) {
		widthOffset = 0;
		fontSize = 14;
	}

    if ([visitDetail.status isEqualToString:@"arrived"]) {
		[visitCell setStatus:@"arrived" widthOffset:widthOffset fontSize:fontSize];
	}
    else if([visitDetail.status isEqualToString:@"completed"]) {

		[visitCell setStatus:@"completed" widthOffset:widthOffset fontSize:fontSize];
       
    }
    else if([visitDetail.status isEqualToString:@"canceled"]) {

		[visitCell setStatus:@"canceled" widthOffset:widthOffset fontSize:fontSize];
    }
    else if([visitDetail.status isEqualToString:@"late"]) {

		[visitCell setStatus:@"late" widthOffset:widthOffset fontSize:fontSize];
		if(sharedVisits.showKeyIcon) {
			[visitCell showKeyInfo];
		}
    }
    else if([visitDetail.status isEqualToString:@"highpriority"]) {


    }
    else if ([visitDetail.status isEqualToString:@"future"]) {

		[visitCell setStatus:@"future" widthOffset:widthOffset fontSize:fontSize];
		if(sharedVisits.showKeyIcon) {
			[visitCell showKeyInfo];
		}
    }
	
    if(sharedVisits.showPetPicInCell) {
		[visitCell showPetPicInCell];
    }
	
	
	if (visitDetail.note != NULL) {

		managerVisitNote = [UIButton buttonWithType:UIButtonTypeCustom];
		[managerVisitNote setBackgroundImage:[UIImage imageNamed:@"manager-note-icon-128x128"] 
									forState:UIControlStateNormal];
		[managerVisitNote addTarget:self 
							 action:@selector(managerNoteDetailView:) 
				   forControlEvents:UIControlEventTouchUpInside];
		managerVisitNote.tag =  [visitDetail.appointmentid intValue];
		managerVisitNote.userInteractionEnabled = YES;
		[visitCell addManagerNote:managerVisitNote];
	}
	
	if(sharedVisits.showFlags) {
		[visitCell showFlags];
	}
	
	if(sharedVisits.showTimer && [visitDetail.status isEqualToString:@"arrived"]) {
		[visitCell startVisitTimer];
	}
	
	if(sharedVisits.showDocAttachListView) {
		
		if([visitDetail.docItems count]  == 1) {
			docErrataButton = [UIButton buttonWithType:UIButtonTypeCustom];
			docErrataButton.frame = CGRectMake(self.view.frame.size.width - 40, height/2, 32, 32);
			[docErrataButton setBackgroundImage:[UIImage imageNamed:@"file-folder-line"]
									   forState:UIControlStateNormal];
			
			[docErrataButton addTarget:self 
								action:@selector(docErratButtonClick:) 
					  forControlEvents:UIControlEventTouchUpInside];
			
			docErrataButton.tag =  [visitDetail.appointmentid intValue];
			[visitCell.contentView addSubview:docErrataButton];
			
		} else if ([visitDetail.docItems count] > 1) {
			
			docErrataButton = [UIButton buttonWithType:UIButtonTypeCustom];
			docErrataButton.frame = CGRectMake(self.view.frame.size.width - 40, height/2, 32, 32);
			[docErrataButton setBackgroundImage:[UIImage imageNamed:@"file-folder-line"]
									   forState:UIControlStateNormal];
			[docErrataButton addTarget:self 
								action:@selector(multiDocErrataButtonClick:) 
					  forControlEvents:UIControlEventTouchUpInside];
			
			docErrataButton.tag =  [visitDetail.appointmentid intValue];
			[visitCell.contentView addSubview:docErrataButton];
		}
	}
	
	return visitCell;
}

-(void) multiDocErrataButtonClick:(id)sender {
		
	UIButton *tapButton = (UIButton*)sender;
	
	CGRect buttonOn = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width * 1.3, tapButton.frame.size.height * 1.3);
	
	[UIView animateWithDuration:0.4 animations:^{
		tapButton.frame = buttonOn;
	} completion:^(BOOL finished) {
		for(VisitDetails *visit in sharedVisits.visitData) {
			NSString *visitID = [NSString stringWithFormat:@"%li",(long)tapButton.tag];
			if ([visit.appointmentid isEqualToString:visitID]) {
				//NSLog(@"Getting visit ID with String value: %@", visitID);
				//int numItems = [visit.docItems count];
				//int height = numItems * 100;
				int height = self.view.frame.size.height;
				FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, height) 
																	  appointmentID:visitID 
																		   itemType:@"multiDoc"];
				[fmView show];
			}
		}
		tapButton.frame = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width / 1.3, tapButton.frame.size.height / 1.3);
	}];
}

-(void)docErratButtonClick:(id)sender {
	
	UIButton *tapButton = (UIButton*)sender;
	
	CGRect buttonOn = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width * 1.3, tapButton.frame.size.height * 1.3);
	
	[UIView animateWithDuration:0.4 animations:^{
		tapButton.frame = buttonOn;
	} completion:^(BOOL finished) {
		for(VisitDetails *visit in sharedVisits.visitData) {
			NSString *visitID = [NSString stringWithFormat:@"%li",(long)tapButton.tag];
			if ([visit.appointmentid isEqualToString:visitID]) {
				//NSLog(@"Getting visit ID with String value: %@", visitID);
				FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height) 
																	  appointmentID:visitID 
																		   itemType:@"oneDoc"];
				[fmView show];
			}
		}
		tapButton.frame = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width / 1.3, tapButton.frame.size.height / 1.3);
	}];
}


-(void) managerNoteDetailView:(id)sender {
	
	UIButton *tapButton = (UIButton*)sender;
	NSString *visitID = [NSString stringWithFormat:@"%li",(long)tapButton.tag];
	
	CGRect buttonOn = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width + 20, tapButton.frame.size.height + 20);
	
	[UIView animateWithDuration:0.4 animations:^{
		tapButton.frame = buttonOn;
	} completion:^(BOOL finished) {
		NSString *message;
		for(VisitDetails *visit in sharedVisits.visitData) {
			if ([visit.appointmentid isEqualToString:visitID]) {
				NSString *visitDateTime = [NSString stringWithFormat:@"%@, %@ %@",dayOfWeek,monthDate,dayNumber];
				message = [NSString stringWithFormat:@"[%@] %@\n\n%@", visitDateTime, visit.clientname,  visit.note];
			}
		}
		SSSnackbar *managerNote = [[SSSnackbar alloc]initWithMessage:message
														  actionText:@"OK" 
															duration:30 
														 actionBlock:^(SSSnackbar *sender) {
														 } dismissalBlock:^(SSSnackbar *sender) {
														 }];
		[managerNote show];
		tapButton.frame = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width - 20, tapButton.frame.size.height - 20);
	}];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableCellHeight;
}


-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell
   tappedButtonAtIndex:(NSInteger) index
             direction:(MGSwipeDirection)direction
         fromExpansion:(BOOL) fromExpansion {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    VisitDetails *mail = [sharedVisits.visitData objectAtIndex:indexPath.row];
        
    if (direction == MGSwipeDirectionLeftToRight) {
	
        NSDateFormatter *formatterWindow = [[NSDateFormatter alloc] init];
		[formatterWindow setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
		NSDateFormatter *dateTimeMarkArriveFormat = [[NSDateFormatter alloc]init];
		[dateTimeMarkArriveFormat  setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
		
		NSString *startDateTimeClean = [NSString stringWithFormat:@"%@ %@",mail.date, mail.rawStartTime];
		NSDate *rightNow2 = [NSDate date];
		NSDate *startTimeWindow = [formatterWindow dateFromString:startDateTimeClean];
		
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour  fromDate:rightNow2 toDate:startTimeWindow options:0];
		NSInteger numHours = [components hour];
		NSInteger numDays = numHours / 24;
		long numberOfMinutesBeforeVisit = numHours * 60;

        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
        [dateFormat2 setDateFormat:@"HH:mm:ss MMM dd yyyy"];
        NSString *dateString2 = [dateFormat2 stringFromDate:rightNow2];


        if ([mail.status isEqualToString:@"arrived"]) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"MARK VISIT ARRIVE"
                                          message:@"ALREADY MARKED ARRIVE"
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else if ([mail.status isEqualToString:@"canceled"]) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"MARK VISIT ARRIVE"
                                          message:@"VISIT CANCELLED"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else if ([mail.status isEqualToString:@"completed"]) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"MARK VISIT ARRIVE"
                                          message:@"VISIT IS ALREADY COMPLETED"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        else if (sharedVisits.numMinutesEarlyArrive <  numberOfMinutesBeforeVisit &&
				 numDays >= 0.00) {

            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"MARK VISIT ARRIVE"
                                          message:@"TOO EARLY TO MARK ARRIVE"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
								}];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else {
            //moved outside else loop
            BOOL alreadyMarkArrived = NO;
            
            for (VisitDetails *otherVisit in sharedVisits.visitData) {
                if([otherVisit.status isEqualToString:@"arrived"]) {
                    alreadyMarkArrived = YES;
                    if(sharedVisits.multiVisitArrive) {
                        alreadyMarkArrived = NO;
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"MARK VISIT ARRIVE"
                                                      message:@"YOU ARE MARKING MULTIPLE VISITS ARRIVED"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 
                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                 
                                                 
                                             }];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    } 
					else {
                        
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"MARK VISIT ARRIVE"
                                                      message:@"ONLY ONE VISIT CAN BE MARKED ARRIVED"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 
                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                 
                                                 
                                             }];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
				}
            }

            if(!alreadyMarkArrived) {
				
                mail.arrived = dateString2;
                mail.hasArrived = YES;
                mail.status = @"arrived";
				mail.NSDateMarkArrive = rightNow2;
				mail.dateTimeMarkArrive = [dateTimeMarkArriveFormat stringFromDate:rightNow2];
				sharedVisits.onWhichVisitID = mail.appointmentid;
				sharedVisits.onSequence = mail.sequenceID;
				[[LocationTracker sharedLocationManager] startLocationTracking];
				[self startGPSDebug];
				[_tableView reloadData];
				//[cell refreshContentView];
				
				[self markVisitArriveOrComplete:@"arrived"
							   andAppointmentID:mail.appointmentid
								 andVisitDetail:mail];
								
				if(numDays <= 0.00) {
					if(sharedVisits.multiVisitArrive) 
						[sharedVisits.onSequenceArray addObject:mail];
				}
            }
        }
     
        return YES;
    }
    
    else if (direction == MGSwipeDirectionRightToLeft) {

        NSDate *rightNow2 = [NSDate date];
        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
        [dateFormat2 setDateFormat:@"HH:mm:ss MMM dd yyyy"];
        NSString *dateString2 = [dateFormat2 stringFromDate:rightNow2];
		NSDateFormatter *dateTimeMarkCompleteFormat = [[NSDateFormatter alloc]init];
		[dateTimeMarkCompleteFormat  setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        if (mail.isComplete) {
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"MARK VISIT COMPLETE"
                                          message:@"ALREADY MARKED COMPLETE"
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                     
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        else if (mail.isCanceled) {
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"MARK VISIT COMPLETE"
                                          message:@"VISIT IS CANCELED"
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                     
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        else if (mail.hasArrived) {
			mail.completed = dateString2;
            mail.isComplete = YES;
            mail.status = @"completed";
			mail.dateTimeMarkComplete = [dateTimeMarkCompleteFormat stringFromDate:rightNow2];

			if(sharedVisits.multiVisitArrive) {
				[sharedVisits.onSequenceArray removeObject:mail];
				if ([sharedVisits.onSequenceArray count] > 0) {
					VisitDetails *popVisit = [sharedVisits.onSequenceArray lastObject];
					sharedVisits.onSequence = popVisit.sequenceID;
				}
			} else {
				sharedVisits.onSequence = @"000";
			}
			
			VisitTableCell *visitCell = (VisitTableCell*)cell;
			[visitCell stopVisitTimer];
			
            @synchronized (@"completeSteps") {

                [self markVisitArriveOrComplete:@"completed"
                               andAppointmentID:mail.appointmentid
                                 andVisitDetail:mail];

                [cell refreshContentView];
            }
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[_tableView reloadData];
			});
        }
		return YES;
    }
    return NO;
}


-(void)markVisitArriveOrComplete:(NSString*)visitStatus
                 andAppointmentID:(NSString*)appointmentID
                   andVisitDetail:(VisitDetails*)visit {
    
	NSMutableDictionary *arriveCompleteDictionary = [[NSMutableDictionary alloc]init];
    LocationShareModel *locationModel = [LocationShareModel sharedModel];
    
    NSDate *rightNow = [NSDate date];
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *dateTimeString = [dateFormat stringFromDate:rightNow];
    NSDateFormatter *dateFormat2 = [NSDateFormatter new];
    [dateFormat2 setDateFormat:@"HH:mm a"];
    NSString *dateTimeString2 = [dateFormat2 stringFromDate:rightNow];
    NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
	
	CLLocation *currentLocation = [LocationTracker sharedLocationManager].locationManager.location;
	NSString *theLatitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
	NSString *theLongitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];

	NSString *theAccuracy = [NSString stringWithFormat:@"%f",locationModel.validLocationLast.horizontalAccuracy];
    NSString *username = [loginSetting objectForKey:@"username"];
    NSString *pass = [loginSetting objectForKey:@"password"];
    NSString *urlLoginStr = [username stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *urlPassStr = [pass stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    [arriveCompleteDictionary setObject:urlLoginStr forKey:@"loginid"];
    [arriveCompleteDictionary setObject:urlPassStr forKey:@"password"];
    [arriveCompleteDictionary setObject:dateTimeString forKey:@"datetime"];
    [arriveCompleteDictionary setObject:appointmentID forKey:@"appointmentptr"];
    [arriveCompleteDictionary setObject:theLatitude forKey:@"lat"];
    [arriveCompleteDictionary setObject:theLongitude forKey:@"lon"];
    [arriveCompleteDictionary setObject:visitStatus forKey:@"event"];
    [arriveCompleteDictionary setObject:theAccuracy forKey:@"accuracy"];
	if([visitStatus isEqualToString:@"arrived"]) {
		[arriveCompleteDictionary setObject:dateTimeString2 forKey:@"visitDateTimeArrive"];
		[arriveCompleteDictionary setObject:theLatitude forKey:@"visitArriveLatitude"];
		[arriveCompleteDictionary setObject:theLongitude forKey:@"visitArriveLongitude"];
	} else if ([visitStatus isEqualToString:@"completed"]) {
		[arriveCompleteDictionary setObject:dateTimeString2 forKey:@"visitDateTimeMarkComplete"];
		[arriveCompleteDictionary setObject:theLatitude forKey:@"visitCompleteLatitude"];
		[arriveCompleteDictionary setObject:theLongitude forKey:@"visitCompleteLongitude"];
	}

    NSString *postRequest = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&coords={\"appointmentptr\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"event\":\"%@\",\"accuracy\":\"%@\"}",
				     urlLoginStr,urlPassStr,dateTimeString,appointmentID,theLatitude,theLongitude,visitStatus,theAccuracy];
    
    if(sharedVisits.isReachable) {

        NSData *postData = [postRequest dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSURL *urlLogin = [NSURL URLWithString:postRequest];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
        [request setURL:[NSURL URLWithString:@"https://leashtime.com/native-visit-action.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *userAgentString = sharedVisits.userAgentLT;
        [request setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:postData];
		
		
        NSURLSessionConfiguration *urlConfig = [self sessionConfiguration];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig
                                                                 delegate:nil
                                                            delegateQueue:nil];
        NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,
                                                                                                         NSURLResponse * _Nullable responseDic,
                                                                                                         NSError * _Nullable error) {
             if(error == nil) {
                 
                 NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:
                                              NSJSONReadingMutableContainers|
                                              NSJSONReadingAllowFragments|
                                              NSJSONWritingPrettyPrinted|
                                              NSJSONReadingMutableLeaves
                                                                               error:&error];
				 
				 NSLog(@"Response dic: %@",responseDic);

                 [arriveCompleteDictionary setObject:@"SUCCESS" forKey:@"STATUS"];
				 
                 if ([visitStatus isEqualToString:@"arrived"])
                 {
					 
					 [visit markArrive:dateTimeString2 latitude:theLatitude longitude:theLongitude];
					 [sharedVisits updateArriveCompleteInTodayYesterdayTomorrow:visit withStatus:@"arrived"];
					 [arriveCompleteDictionary setObject:@"ARRIVE" forKey:@"TYPE"];
					 [sharedVisits.arrivalCompleteQueueItems addObject:arriveCompleteDictionary];
					 visit.currentArriveVisitStatus  = @"SUCCESS";
					 
					 dispatch_async(dispatch_get_main_queue(), ^{
						 [visit writeVisitDataToFile];
					 });
					 
					 
                 } else if ([visitStatus isEqualToString:@"completed"]) {

					 [visit markComplete:dateTimeString2 latitude:theLatitude longitude:theLongitude];
					 visit.NSDateMarkComplete = rightNow;
					 visit.currentCompleteVisitStatus = @"SUCCESS";
					 [visit writeVisitDataToFile];
					 [arriveCompleteDictionary setObject:@"COMPLETE" forKey:@"TYPE"];
					 [sharedVisits.arrivalCompleteQueueItems addObject:arriveCompleteDictionary];

					 [sharedVisits updateArriveCompleteInTodayYesterdayTomorrow:visit withStatus:@"completed"];
					 dispatch_async(dispatch_get_main_queue(), ^{
						 [_tableView reloadData];
					 });
										
					 [[NSNotificationCenter defaultCenter]postNotificationName:@"MarkComplete" object:self];
					 [[LocationTracker sharedLocationManager] stopLocationTracking];
				 }
             } else {
            
				 if([visitStatus isEqualToString:@"arrived"]) {
					 [arriveCompleteDictionary setObject:@"ARRIVE" forKey:@"TYPE"];
					 visit.currentArriveVisitStatus = @"FAIL";
				 } else if([visitStatus isEqualToString:@"completed"]) {
					 visit.currentCompleteVisitStatus = @"FAIL";
					 [arriveCompleteDictionary setObject:@"COMPLETE" forKey:@"TYPE"];
				 }
				 [visit writeVisitDataToFile];
				 
				 [arriveCompleteDictionary setObject:@"FAIL-NETWORK RESPONSE" forKey:@"STATUS"];
				 [sharedVisits.arrivalCompleteQueueItems addObject:arriveCompleteDictionary];

                 dispatch_async(dispatch_get_main_queue(), ^{

			     	[_tableView reloadData];
                 });
                 
             }
        }];
        [postDataTask resume];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [urlSession finishTasksAndInvalidate];


    } else if (!sharedVisits.isReachable) {
        
        [arriveCompleteDictionary setObject:@"FAIL-NOT REACHABLE" forKey:@"STATUS"];
		if([visitStatus isEqualToString:@"arrived"]) {
			[arriveCompleteDictionary setObject:@"ARRIVE" forKey:@"TYPE"];
		} else if([visitStatus isEqualToString:@"completed"]) {
			[arriveCompleteDictionary setObject:@"COMPLETE" forKey:@"TYPE"];
		}
		[visit writeVisitDataToFile];
        [sharedVisits.arrivalCompleteQueueItems addObject:arriveCompleteDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    }
    

}

#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
	//NSLog(@"swipe table cell YES");
	return YES;
}
-(void) swipeTableCell:(MGSwipeTableCell*) cell
   didChangeSwipeState:(MGSwipeState)state
	   gestureIsActive:(BOOL)gestureIsActive
{
	
	if (gestureIsActive) {
		//NSLog(@"YES");
	} else {
		// NSLog(@"NO");
	}
	NSString * str;
	switch (state) {
		case MGSwipeStateNone: str = @"None"; break;
		case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
		case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
		case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
		case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
	}
	// NSLog(@"swipe direction: %@",str);
}

-(NSString* ) dayBeforeAfter:(NSDate*)goingToDate {
	
	NSTimeInterval timeDifference = [sharedVisits.todayDate timeIntervalSinceDate:goingToDate];
	double minutes = timeDifference / 60;
	double days = minutes / 1440;
		
	if (days > 0.0 && days < 0.111111) {
		return @"today";
	} else if (days > 0.111111) {
		return @"previous";
	} else if(days < 0.001) {
		return @"next";
	}
	return @"before";
	
}

-(NSURLSessionConfiguration*) sessionConfiguration {
	NSURLSessionConfiguration *config =
	[NSURLSessionConfiguration defaultSessionConfiguration];
	
	config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0
													diskCapacity:0
														diskPath:nil];
	
	return config;
}

-(void) showReachabilityIcon {
	
	__block UIImageView *networkStatusIcon;
	
	int heightOffset = 0;
	
	if(isIphone6P) {
		heightOffset = 25;
	} else if (isIphone6) {
		heightOffset = 25;
		
	} else if (isIphone5) {
		heightOffset = 25;
		
	} else if (isIphone4) {
		heightOffset = 25;
		
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (!sharedVisits.isReachable) {
			networkStatusIcon = [[UIImageView alloc]initWithFrame:CGRectMake(headerView.frame.size.width - 25, headerView.frame.size.height - heightOffset, 32, 32)];
			networkStatusIcon.image = [UIImage imageNamed:@"nonetwork-icon"];
		}
		if (sharedVisits.isReachableViaWiFi) {
			networkStatusIcon = [[UIImageView alloc]initWithFrame:CGRectMake(headerView.frame.size.width - 25, headerView.frame.size.height - heightOffset, 24, 24)];
			networkStatusIcon.image = [UIImage imageNamed:@"network-icon"];
		}
		if (sharedVisits.isReachableViaWWAN) {
			networkStatusIcon = [[UIImageView alloc]initWithFrame:CGRectMake(headerView.frame.size.width - 20, headerView.frame.size.height - heightOffset, 18, 24)];
			networkStatusIcon.image = [UIImage imageNamed:@"cell-phone-black"];
		}
		[headerView addSubview:networkStatusIcon];
	});
}

-(void) noVisits {
	_tableView.userInteractionEnabled = NO;
	dateLabel = [[UILabel alloc]init];
	dayOfWeekLabel = [[UILabel alloc]init];
	monthLabel = [[UILabel alloc]init];
	debugGPS = [[UILabel alloc]init];
	debugGPSStart = [[UILabel alloc]init];
	debugGPSStop = [[UILabel alloc]init];
	
	[self setupDateValues];
	[self refreshCallback];
	[_tableView reloadData];

	
	_tableView.userInteractionEnabled = YES;
	
}

-(void) clickHelp {
	
	NSLog(@"Debug change with Help click");
	
	if (debugON) {
		NSLog(@"Debug TRUE");
		debugON = FALSE;
	} else {
		NSLog(@"Debug FALSE");
		debugON= TRUE;
	}
	_tableView.alpha = 0.1;
	
	UIImageView *handHelp = [[UIImageView alloc]initWithFrame:CGRectMake(_tableView.frame.origin.x + 20, _tableView.frame.origin.y + 140, 64, 64)];
	[handHelp setImage:[UIImage imageNamed:@"finger-gesture"]];
	
	UIView *arriveButHel = [[UIView alloc]initWithFrame:CGRectMake(-200, handHelp.frame.origin.y, 300, 100)];
	arriveButHel.backgroundColor = [UIColor blueColor];
	
	UILabel *arriveLab = [[UILabel alloc]initWithFrame:CGRectMake(10,30,360, 30)];
	[arriveLab setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
	[arriveLab setText:@"MARK ARRIVE"];
	[arriveLab setTextColor:[UIColor whiteColor]];
	
	UILabel *markArriveInst2 = [[UILabel alloc]initWithFrame:CGRectMake(-360, _tableView.frame.origin.y+240,390, 30)];
	[markArriveInst2 setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
	[markArriveInst2 setText:@"SWIPE    >>>>>>>>>>>>>>>>>>>>>>"];
	[markArriveInst2 setTextColor:[UIColor blackColor]];
	
	UILabel *markArriveInst = [[UILabel alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height/2, 300, 90)];
	[markArriveInst setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
	[markArriveInst setTextColor:[UIColor redColor]];
	markArriveInst.numberOfLines = 3;
	markArriveInst.text = @"ONLY ONE VISIT MAY BE MARKED ARRIVED. ONLY ARRIVED VISIT MAY BE MARKED COMPLETE.";
	
	
	[arriveButHel addSubview:arriveLab];
	[self.view addSubview:arriveButHel];
	[self.view addSubview:handHelp];
	
	[self.view addSubview:markArriveInst];
	[self.view addSubview:markArriveInst2];
	
	
	
	[UIView animateWithDuration:4.5
						  delay:0.0
		 usingSpringWithDamping:0.9
		  initialSpringVelocity:0.0
						options:UIViewAnimationOptionTransitionFlipFromLeft
					 animations:^{
						 
						 handHelp.frame = CGRectMake(handHelp.frame.origin.x + 280, handHelp.frame.origin.y, 64, 64);
						 arriveButHel.frame = CGRectMake(arriveButHel.frame.origin.x+250, handHelp.frame.origin.y, 300, 100);
						 markArriveInst2.frame = CGRectMake(self.view.frame.size.width-200, markArriveInst2.frame.origin.y, 320,30);
						 
					 } completion:^(BOOL finished) {
						 
						 [handHelp removeFromSuperview];
						 [markArriveInst2 removeFromSuperview];
						 [arriveButHel removeFromSuperview];
						 
						 
						 arriveButHel.frame = CGRectMake(self.view.frame.size.width -70, arriveButHel.frame.origin.y, 300, 100);
						 [arriveLab setText:@"MARK COMPLETE"];
						 [arriveLab setTextColor:[UIColor blackColor]];
						 arriveLab.frame = CGRectMake(80, arriveLab.frame.origin.y, 300, 30);
						 arriveButHel.backgroundColor = [UIColor yellowColor];
						 
						 handHelp.frame = CGRectMake(self.view.frame.size.width - 50, handHelp.frame.origin.y, 64, 64);
						 
						 [markArriveInst2 setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
						 [markArriveInst2 setText:@"<<<<<<<<<<<<<<<<<<<<<<     SWIPE"];
						 [markArriveInst2 setTextColor:[UIColor blackColor]];
						 
						 [self.view addSubview:arriveButHel];
						 [self.view addSubview:handHelp];
						 [self.view addSubview:markArriveInst2];
						 
						 
						 
						 [UIView animateWithDuration:4.5 animations:^{
							 
							 handHelp.frame = CGRectMake(self.view.frame.size.width - 330, handHelp.frame.origin.y, 64, 64);
							 markArriveInst2.frame = CGRectMake(self.view.frame.size.width - 400, markArriveInst2.frame.origin.y, 400,30);
							 arriveButHel.frame = CGRectMake(self.view.frame.size.width - 330, arriveButHel.frame.origin.y, 300, 100);
							 
						 } completion:^(BOOL finished) {
							 
							 [handHelp removeFromSuperview];
							 [markArriveInst2 removeFromSuperview];
							 [arriveButHel removeFromSuperview];
							 [markArriveInst removeFromSuperview];
							 
							 handHelp.frame = CGRectMake(self.view.frame.size.width/2, handHelp.frame.origin.y, 64, 64);
							 
							 markArriveInst.frame = CGRectMake(10, self.view.frame.size.height-50, 320, 40);
							 markArriveInst.text = @"WRITE & SEND VISIT REPORT";
							 
							 
							 __weak ViewController *segCon = (ViewController*)self.parentViewController;
							 segCon.segmentedControlLocal.alpha = 0.0;
							 
							 UIImageView *messageButton = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+120, self.view.frame.size.height-120, 128, 128)];
							 
							 [messageButton setImage:[UIImage imageNamed:@"messagebubble128x128"]];
							 
							 [self.view addSubview:messageButton];
							 [self.view addSubview:handHelp];
							 [self.view addSubview:markArriveInst];
							 
							 [UIView animateWithDuration:5.0
												   delay:0.0
								  usingSpringWithDamping:0.7
								   initialSpringVelocity:0.9
												 options:UIViewAnimationOptionCurveEaseInOut
											  animations:^{
												  handHelp.frame = CGRectMake(self.view.frame.size.width/2+60, self.view.frame.size.height- 60, 64, 64);
												  messageButton.frame = CGRectMake(self.view.frame.size.width/2+60, self.view.frame.size.height-60, 64, 64);
												  _tableView.alpha = 0.75;
											  } completion:^(BOOL finished) {
												  _tableView.alpha = 1.0;
												  [markArriveInst removeFromSuperview];
												  [handHelp removeFromSuperview];
												  [messageButton removeFromSuperview];
												  segCon.segmentedControlLocal.alpha = 1.0;
											  }];
						 }];
					 }];
}

-(void) resendUpdateTable {
	dispatch_async(dispatch_get_main_queue(), ^{
		[_tableView reloadData];
	});
}

-(void) refreshCallback {
	[refreshControl endRefreshing];
	
}

-(void) getUpdatedVisitsForToday {
	NSDate *todayDate = [NSDate date];
	sharedVisits.showingWhichDate = todayDate;
	sharedVisits.todayDate = todayDate;
	showingDay = todayDate;
	[sharedVisits networkRequest:todayDate toDate:todayDate];
	[self refreshCallback];
}

-(void) resendRefreshView {
	dispatch_async(dispatch_get_main_queue(), ^{
		[_tableView reloadData];
	});
}

-(void) unreachableNetwork:(NSNotification *)notification {	
	[self showReachabilityIcon];
	[_tableView setNeedsDisplay];
	[_tableView reloadData];
}

-(void) reachabilityStatusChanged:(NSNotification*) notification {
	
	if (sharedVisits.isReachable) {
		if (sharedVisits.isReachableViaWWAN) {
			/*_networkStatusView.alpha = 1.0;
			 _badNetworkView.alpha = 0.0;
			 _wwanStatusView.alpha = 1.0;*/
		} else if (sharedVisits.isReachableViaWiFi) {
			/*_networkStatusView.alpha = 0.0;
			 _badNetworkView.alpha = 0.0;
			 _wwanStatusView.alpha = 1.0;*/
		}
	}
	
	[self showReachabilityIcon];
	[_tableView setNeedsDisplay];
	//[self refreshCallback];	
}



@end
