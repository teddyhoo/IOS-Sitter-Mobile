//
//  ClientListViewController.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/19/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "ClientListViewController.h"
#import "LoginView.h"
#import "VisitProgressView.h"
#import "DebugHeaderView.h"
#import "SettingsViewController.h"
#import "DetailAccordionViewController.h"
#import "FloatingModalView.h"
#import "PetPicture.h"
#import "SSSnackbar.h"
#import "VisitTableCell.h"
#import "VisitsAndTracking.h"
#import "LocationShareModel.h"
#import "LocationTracker.h"
#import "DataClient.h"
#import "VisitDetails.h"

#import "math.h"
#import "PharmaStyle.h"
#import "DateTools.h"
#import "NSDate+DateTools.h"
#import "AFNetworkReachabilityManager.h"


#define kTableCellHeight 80.0f

@interface ClientListViewController() <UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate,UIImagePickerControllerDelegate>  

{
    UITableView *wTableView;
    UIView *headerView;
    UIImagePickerController *picker;
}

@end

@implementation ClientListViewController 
{
    
    VisitsAndTracking *sharedVisits;
    LoginView *loginVC;
    //DebugHeaderView *debugWindow;

    DetailAccordionViewController *detailAccordionView;
    VisitProgressView *visitProgress;
    PetPicture *petPictureView;
    UIRefreshControl * refreshControl;

    UIView *resendView;
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
	BOOL debugON;

	NSDateFormatter *timerDateFormat;
	NSDateFormatter *formatFutureDate;
    NSDateFormatter *formatterWindow;
    NSDateFormatter *dateTimeMarkArriveFormat;
    NSDateFormatter *dateFormat2;
    NSDateFormatter *dateFormat;
    
    NSMutableDictionary *flagIndex;    
    NSMutableDictionary *colorPalette;
}

-(instancetype)init {
    self = [super init];
    if(self) {
        
        NSLog(@"CLIENT LIST VIEW CONTROLLER ---- INIT");
        
        sharedVisits = [VisitsAndTracking sharedInstance];
        colorPalette = [sharedVisits getColorPalette];

        NSString *theDeviceType = [sharedVisits tellDeviceType];
		NSString *pListData = [[NSBundle mainBundle]
							   pathForResource:@"flagID"
							   ofType:@"plist"];
         
		
		flagIndex = [[NSMutableDictionary alloc] initWithContentsOfFile:pListData];

		if ([theDeviceType isEqualToString:@"iPhone6P"]) {
			isIphoneX= NO;
			isIphone6P = YES;
			isIphone5 = NO;
			isIphone6 = NO;
			isIphone4 = NO;
		} 
        else if ([theDeviceType isEqualToString:@"XR"]) {
			isIphoneX= NO;
			isIphone6 = YES;
			isIphone5 = NO;
			isIphone6P = NO;
			isIphone4 = NO;
		} 
        else if ([theDeviceType isEqualToString:@"iPhone5"]) {
			isIphoneX= NO;
			isIphone5 = YES;
			isIphone6 = NO;
			isIphone6P = NO;
			isIphone4 = NO;
		} 
        else if ([theDeviceType isEqualToString:@"iPhoneX"]) {
			isIphoneX= YES;
			isIphone5 = NO;
			isIphone6 = NO;
			isIphone6P = NO;
			isIphone4 = NO;
		} 
        else {
			isIphone5 = NO;
			isIphone6 = NO;
			isIphone6P = NO;
			isIphone4 = YES;

		}
        
        self.title = @"LeashTime Clients";      
        /*
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self
                           action:@selector(getUpdatedVisitsForToday)
                 forControlEvents:UIControlEventValueChanged];
    */
        [self addVisitListView];
        
        if (!sharedVisits.firstLogin) {
            [self addLoginView];
            /*NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];    
            [loginSetting setObject:@"dlifebri" forKey:@"username"];
            [loginSetting setObject:@"QVX992DISABLED" forKey:@"password"];
            NSDate *todayDate = [NSDate date];
            [sharedVisits networkRequest:todayDate toDate:todayDate];*/
        }
        [self setupDateFormatter];
        [self setupDateValues];        
        [self addObservers];
        

    }
     return self;
}
-(void)addVisitListView {
    //NSLog(@"CLIENT LIST VIEW - - ADD LIST VIEW TABLE VIEW");
    wTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    wTableView.delegate = self;
    wTableView.dataSource = self;
    
    [self.view addSubview:wTableView];
    
}
-(void)addLoginView {
    
    //NSLog(@"CLIENT LIST VIEW -- ADDING LOGIN VIEW");
    
    loginVC = [[LoginView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:loginVC];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(logoutButtonClick)
                                                name:@"logoutApp"
                                              object:nil];
    
    
}
-(void)logoutButtonClick {
    
    sharedVisits.firstLogin = NO;
    [self addLoginView];
    [[LocationTracker sharedLocationManager] stopLocationTracking];
}
-(void) setupDateFormatter {
    
    timerDateFormat = [[NSDateFormatter alloc]init];
    [timerDateFormat setDateFormat:@"mm:ss"];
    
    formatFutureDate = [[NSDateFormatter alloc]init];
    [formatFutureDate setDateFormat:@"MM/dd/yyyy"];
    
    formatterWindow = [[NSDateFormatter alloc] init];
    [formatterWindow setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    
    dateTimeMarkArriveFormat = [[NSDateFormatter alloc]init];
    [dateTimeMarkArriveFormat  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    dateFormat2 = [[NSDateFormatter alloc]init];
    [dateFormat2 setDateFormat:@"HH:mm:ss MMM dd yyyy"];
    
    dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"HH:mm a"];
    
}
-(void)seuptInitialView {
    //NSLog(@"Removing Login View");
    [loginVC successFullLogin];
    [loginVC removeFromSuperview];
    loginVC = nil;
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(logoutButtonClick)
                                                name:@"logoutApp"
                                              object:nil];

    
}
-(void) removeObservers {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"pollingCompletWithChanges" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"successfulResend" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reachable" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"unreachable" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"noVisits" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"comingForeground" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"loginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updateTable" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"logutApp"   object:nil];


}
-(void) viewDidAppear:(BOOL)animated {
    //NSLog(@"CLIENT VIEW CONTROLLER VIEW DID APPEAR");
    sharedVisits = [VisitsAndTracking sharedInstance];
    colorPalette = [sharedVisits getColorPalette];
    NSString *pListData = [[NSBundle mainBundle]
                           pathForResource:@"flagID"
                           ofType:@"plist"];
    flagIndex = [[NSMutableDictionary alloc] initWithContentsOfFile:pListData];

}

-(void) setupListView {
    [self setupDateValues];
    [self.view addSubview:wTableView];
}

-(void) pollingUpdates {
    NSLog(@"CLVC: LIST POLLING UPDATES TABLE VIEW");

    if (sharedVisits.firstLogin) {
        //[self addVisitListView];
        //_tableView.userInteractionEnabled = NO;
        //NSLog(@"SET UP LIST VIEW");
        //[self setupListView];
        //[updateBackground removeFromSuperview];
    }
    /*debugWindow = [[DebugHeaderView alloc]initWithFrame:CGRectMake(80, 0, self.view.frame.size.width-160, 200)];
    __block UIView *debugTemp  = debugWindow;

    debugWindow.alpha = 0.95;
    debugON = YES;
    [self.view addSubview:debugWindow];
    [UIView animateWithDuration:5.0 animations:^{
        [debugTemp setAlpha:0.0];
    } completion:^(BOOL finished) {
        [debugTemp removeFromSuperview];
        debugTemp = nil;
    }];*/
    
    [wTableView reloadData];
    wTableView.userInteractionEnabled = YES;    
}
-(void) setupDateValues {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitDay|NSCalendarUnitWeekday) fromDate:sharedVisits.showingWhichDate];
    
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
}
-(void) foregroundPollingUpdate {
    resendView = [[UIView alloc]initWithFrame:CGRectMake(40, 100, self.view.frame.size.width - 80, 220)];
    [resendView setBackgroundColor:[UIColor blackColor]];
    [resendView setAlpha:1.0];
    [self.view addSubview:resendView];
    
    if ([self checkForBadResendBeforeSync:resendView]) {
            
        @synchronized(@"yesterday") {
            wTableView .userInteractionEnabled = YES;
            showingDay = [NSDate date];
            sharedVisits.showingWhichDate = showingDay;
            sharedVisits.todayDate = showingDay;
            [sharedVisits networkRequest:showingDay toDate:showingDay];

        }
    } 
    else {
        
        UIView *resendTemp = resendView;

        
        if (sharedVisits.isReachable) {
            NSLog(@"-------------------------------------------------------------------");
            NSLog(@"-----------------CLVC NO SEND FAIL FOR VISIT-----------------");
            NSLog(@"-------------------------------------------------------------------");
            
            [wTableView setUserInteractionEnabled:YES];            
            UILabel *updateNetworkLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, resendView.frame.size.width-20, 120)];
            [updateNetworkLabel setFont:[UIFont fontWithName:@"Langdon" size:20]];
            [updateNetworkLabel setTextColor:[UIColor whiteColor]];
            [updateNetworkLabel setText:@"UPDATING VISIT DATA\n\nPLEASE WAIT"];
            updateNetworkLabel.textAlignment = NSTextAlignmentCenter;
            updateNetworkLabel.numberOfLines = 5;
            [resendView addSubview:updateNetworkLabel];
            
            
            [UIView animateWithDuration:3.0 animations:^{
                resendTemp.alpha = 0.0;
            } completion:^(BOOL finished) {
                [resendTemp removeFromSuperview];
            }];
            
            @synchronized(@"updateToday") {
                wTableView.userInteractionEnabled = YES;
                showingDay = [NSDate date];
                sharedVisits.showingWhichDate = showingDay;
                sharedVisits.todayDate = showingDay;
                [sharedVisits networkRequest:showingDay toDate:showingDay];
            }
        }
        else {
            [resendView setBackgroundColor:[UIColor redColor]];
            UILabel *noConnect  = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, resendView.frame.size.width, 40)];
            [noConnect setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
            [noConnect setTextColor:[UIColor blackColor]];
            [noConnect setText:@"NO NETWORK"];
            [resendView addSubview:noConnect];
            [UIView animateWithDuration:5.0 animations:^{
                resendTemp.alpha = 0.0;
            }];
        }
    }
}

-(void) applicationEnterBackground {    
    
    NSLog(@"REMOVE DETAIL ACCORDION VIEW CONTROLLER");

    /*if (detailAccordionView != nil) {
        [detailAccordionView removeFromParentViewController];
        detailAccordionView = nil;
    }*/

    if (visitProgress != nil) {
        [visitProgress dismissReportView:nil];
        [visitProgress removeFromSuperview];
        NSLog(@"REMOVE VISIT PROGRESS VIEW");
        visitProgress = nil;

    } else {
        visitProgress = nil;
        NSLog(@"DID NOT REMOVE VISIT PROGRESS IS NIL");
    }
    [refreshControl removeFromSuperview];
    refreshControl = nil;

    [prevDay removeFromSuperview];
    prevDay =nil;
    
    [nextDay removeFromSuperview];
    nextDay = nil;
	startDate = nil;
	showingDay = nil;
    
    [flagIndex removeAllObjects];    
	flagIndex = nil;
    timerDateFormat =nil;
    formatFutureDate = nil;
    formatterWindow = nil;
    dateTimeMarkArriveFormat= nil;
    dateFormat2 = nil;
    dateFormat =nil;
    
    [self removeObservers];
    
    NSArray *headerSub = [headerView subviews];
    for (int i = 0; i < [headerSub count]; i++) {
        id hView = [headerSub objectAtIndex:i];
        if ([hView isKindOfClass:[UIImageView class]]) {
            UIImageView *hImg = (UIImageView*)hView;
            [hImg setImage:nil];
            [hImg removeFromSuperview];
            hImg = nil;
        } else if ([hView isKindOfClass:[UIButton class]]) {
            UIButton *hBut = (UIButton*) hView;
            [hBut removeFromSuperview];
            hBut = nil;
        }
    }
    
    //[debugWindow removeFromSuperview];
    //debugWindow = nil;

    for (DataClient *client in sharedVisits.clientData) {
        client.clientID = nil;
        client.sortName = nil;
        client.clientName = nil;
        client.homePhone = nil;
        client.firstName =nil;
        client.firstName2 = nil;
        client.lastName = nil;
    }
    
    for (int i = 0; i < [sharedVisits.visitData count]; i++) {
        
    }
    //[wTableView removeFromSuperview];
    //wTableView = nil;
    

}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 100)];
    headerView.backgroundColor = [colorPalette objectForKey:@"infoDark"];
    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    headerView.layer.borderWidth = 1.0;
    
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, headerView.frame.size.width, headerView.frame.size.height)];
    [logoView setImage:[UIImage imageNamed:@"header-leashtime"]];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(5,0,62,50);
    [settingsButton setBackgroundColor:[UIColor clearColor]];
    [settingsButton addTarget:self 
                       action:@selector(openMainMenu:) 
             forControlEvents:UIControlEventTouchUpInside];

    UIImageView *mascotView = [[UIImageView alloc]initWithFrame:CGRectMake(5,0, 62 , 50)];
    [mascotView setImage:[UIImage imageNamed:@"icon-brand"]];

    UIView *dateView = [[UIView alloc]initWithFrame:CGRectMake(0,headerView.frame.size.height - 40, headerView.frame.size.width, 40)];
    [dateView setBackgroundColor:[UIColor clearColor]];

    UILabel *dateLabelDayMonthDate = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, dateView.frame.size.width, dateView.frame.size.height)];
    NSString *dateString = [NSString stringWithFormat:@"%@, %@ %@", dayOfWeek, monthDate, dayNumber];
    [dateLabelDayMonthDate setFont:[UIFont fontWithName:@"Lato-Regular" size:26]];
    [dateLabelDayMonthDate setTextColor:[UIColor whiteColor]];
    [dateLabelDayMonthDate setText:dateString];
    [dateLabelDayMonthDate setTextAlignment:NSTextAlignmentCenter];
    
    [dateView addSubview:dateLabelDayMonthDate];

    prevDay = [UIButton buttonWithType:UIButtonTypeCustom];
    prevDay.frame = CGRectMake(20, headerView.frame.size.height - 38, 36, 32);
    [prevDay setBackgroundImage:[UIImage imageNamed:@"prev-on"] forState:UIControlStateNormal];
    [prevDay setBackgroundImage:[UIImage imageNamed:@"prev-on"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    nextDay = [UIButton buttonWithType:UIButtonTypeCustom];
    nextDay.frame = CGRectMake(headerView.frame.size.width - 46, headerView.frame.size.height - 38, 36, 32);
    [nextDay setBackgroundImage:[UIImage imageNamed:@"next-on"] forState:UIControlStateNormal];
    [nextDay setBackgroundImage:[UIImage imageNamed:@"next-on"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [prevDay addTarget:self
                action:@selector(getPrevNext:)
      forControlEvents:UIControlEventTouchUpInside];
    prevDay.tag = 1;
    
    [nextDay addTarget:self
                action:@selector(getPrevNext:)
      forControlEvents:UIControlEventTouchUpInside];
    nextDay.tag = 2;
    
    if(!debugON) {
        [headerView addSubview:logoView];
    }
    
    [headerView addSubview:logoView];
    
    [headerView addSubview:mascotView];
    [headerView addSubview:dateView];
    [headerView addSubview:prevDay];
    [headerView addSubview:nextDay];
    [headerView addSubview:settingsButton];
    [self showReachabilityIcon];
	return headerView;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VisitDetails *visitDetail = [sharedVisits.visitData objectAtIndex:indexPath.row];
    DataClient *clientData;
    
    for (DataClient *client in sharedVisits.clientData) {
        if ([visitDetail.clientptr isEqualToString:client.clientID]) {
            clientData = client;
        }
    }
    
    visitProgress = [[VisitProgressView alloc]initWithFrame:CGRectMake(self.view.frame.size.width,0, self.view.frame.size.width, self.view.frame.size.height) 
                                                                     visitInfo:visitDetail 
                                                                    clientInfo:clientData 
                                                                    parentView:self];
     [self.view addSubview:visitProgress];
    
    VisitProgressView *transitionProgressView = visitProgress;
    [UIView animateWithDuration:0.4 animations:^{
        transitionProgressView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {

    }];
    
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * identifier = @"VisitCell";
    if (sharedVisits.visitData.count == 0) {
        return nil;
    }
    VisitDetails *tempVisit = (VisitDetails*)[sharedVisits.visitData objectAtIndex:indexPath.row];
    VisitTableCell *visitCell = (VisitTableCell*) [tableView dequeueReusableCellWithIdentifier:identifier];
    if (visitCell == nil) {
        //NSLog(@"Visit cell is nil for visit with ID: %@", tempVisit.appointmentid);
        visitCell = [[VisitTableCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:identifier
                                             andSize:CGSizeMake(self.view.frame.size.width, kTableCellHeight)
                                parentViewController:self];
    } 
    
    [visitCell setVisitDetail:tempVisit withIndexPath:indexPath];
    visitCell.tag  = [tempVisit.appointmentid intValue];        
    
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

    if ([tempVisit.status isEqualToString:@"arrived"]) {
        [visitCell setStatus:@"arrived" widthOffset:widthOffset fontSize:fontSize];
    }
    else if([tempVisit.status isEqualToString:@"completed"]) {
        [visitCell setStatus:@"completed" widthOffset:widthOffset fontSize:fontSize];
    }
    else if([tempVisit.status isEqualToString:@"canceled"]) {
        [visitCell setStatus:@"canceled" widthOffset:widthOffset fontSize:fontSize];
    }
    else if([tempVisit.status isEqualToString:@"late"]) {
        [visitCell setStatus:@"late" widthOffset:widthOffset fontSize:fontSize];
    }
    else if([tempVisit.status isEqualToString:@"highpriority"]) {
        
    }
    else if ([tempVisit.status isEqualToString:@"future"]) {
        [visitCell setStatus:@"future" widthOffset:widthOffset fontSize:fontSize];
    }
    if (tempVisit.note != NULL && ![tempVisit.status isEqualToString:@"completed"]) {
        [visitCell addManagerNote];
    }
    if(sharedVisits.showTimer && [tempVisit.status isEqualToString:@"arrived"]) {
        [visitCell startVisitTimer];
    }
    return visitCell;
}
- (void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    VisitTableCell *cellDidEndDisplay = (VisitTableCell*)cell;
    [cellDidEndDisplay stopVisitTimer];
}
- (CGFloat)tableView:(UITableView *)tableView  heightForHeaderInSection:(NSInteger)section{
    
    return 100.0;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sharedVisits.visitData.count;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return kTableCellHeight;
   
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
        [prevNext setSelected:YES];
    }
    
    if(prevNext.tag == 1) {

        NSDate *anotherDate = [newCal dateByAddingUnit:NSCalendarUnitDay
                                                 value:-1
                                                toDate:sharedVisits.showingWhichDate
                                               options:kNilOptions];
        
        
        [self getAnotherDay:@"yesterday" forDay:anotherDate];
        [self setupDateValues];
        
    } else if (prevNext.tag == 2) {
        CGRect newFrame = CGRectMake(nextDay.frame.origin.x+5, nextDay.frame.origin.y, nextDay.frame.size.width+5, nextDay.frame.size.height+10);
        CGRect newFrame2 = CGRectMake(nextDay.frame.origin.x, nextDay.frame.origin.y, nextDay.frame.size.width, nextDay.frame.size.height);
        VisitsAndTracking *tmpVT = sharedVisits;
        UIButton *tmpNxt = nextDay;
        [UIView animateWithDuration:0.05
                              delay:0.1
             usingSpringWithDamping:0.7
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             NSDate *anotherDate = [newCal dateByAddingUnit:NSCalendarUnitDay
                                                                      value:1
                                                                     toDate:tmpVT.showingWhichDate
                                                                    options:kNilOptions];
                             [self getAnotherDay:@"nextDay" forDay:anotherDate];
                             tmpNxt.frame = newFrame;

                         } completion:^(BOOL finished) {
                             
                             tmpNxt.frame = newFrame2;
                         }];
        
        
        [self setupDateValues];

    }
}
-(void) tapDetailView:(id)sender {
    NSLog(@"TAPPED DETAIL VIEW");
    VisitDetails *tapVisit;

    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *detailViewTap = (UITapGestureRecognizer*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)detailViewTap.view.tag];
        for(VisitDetails *visit in sharedVisits.visitData) {
            if ([tagIDString isEqualToString:visit.appointmentid]) {
                tapVisit = visit;
            }
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *detailButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)detailButton.tag];
        for(VisitDetails *visit in sharedVisits.visitData) {
            if ([tagIDString isEqualToString:visit.appointmentid]) {
                tapVisit = visit;
            }
        }
    }
    for (DataClient *clientProfile in sharedVisits.clientData) {
        if ([tapVisit.clientptr isEqualToString:clientProfile.clientID]) {
            //[visitProgress removeFromSuperview];
            //sharedVisits.onWhichVisitID = tapVisit.appointmentid;
            //detailAccordionView = [[DetailAccordionViewController alloc]init];
            //[detailAccordionView setClientAndVisitID:clientProfile visitID:tapVisit];
            //[detailAccordionView setupViews];
            //[self.view addSubview:detailAccordionView.view];
            //[self addChildViewController:detailAccordionView];
            //[detailAccordionView didMoveToParentViewController:self];
                        
        }
    }
}

-(void) goToVisitInProgress:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        NSString *appointmentNum;
        UIButton *statusButton = (UIButton*)sender;
        NSString *tagString = [NSString stringWithFormat:@"%li",(long)statusButton.tag];
        appointmentNum = tagString;
    }
}

-(void) openMainMenu:(id)sender {
    
    SettingsViewController *settings = [[SettingsViewController alloc]init];
    [self addChildViewController:settings];
    [self.view addSubview:settings.view];
    [settings didMoveToParentViewController:nil];
    
}

-(void)photoFinishShowProgressView:(id)sender {

    /*NSLog(@"Removing pet photo view controller");
    [[NSNotificationCenter defaultCenter]removeObserver:self 
                                                   name:@"photoFinishUplaod" 
                                                 object:nil];

    [petPictureView willMoveToParentViewController:nil];
    [petPictureView.view removeFromSuperview];
    [petPictureView removeFromParentViewController];*/
    
}

-(void) goToPhotoTaker:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class] ] ) {
        UIButton *statusButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)statusButton.tag]; 
        //[visitProgress setPhotoUploadStatus];
        //[visitProgress removeFromSuperview];
        /*if(petPictureView == nil) {
            petPictureView = [[PetPicture alloc]init];
        }
        [petPictureView setVisitID:tagIDString];
        [self.view addSubview:petPictureView.view];
        [self addChildViewController:petPictureView];
        [petPictureView didMoveToParentViewController:self];*/
        /*[[NSNotificationCenter defaultCenter]addObserver:self 
                                                selector:@selector(photoFinishShowProgressView:) 
                                                    name:@"photoFinishUpload" 
                                                  object:nil];*/
        
        
        picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                             UIImagePickerControllerSourceTypeCamera];
        picker.delegate = self;
        
        UIImagePickerController *tmpPicker = picker;
        
        UIButton *galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        galleryButton.frame =CGRectMake(tmpPicker.view.frame.size.width - 140, tmpPicker.view.frame.size.height - 100, 60, 60);
        [galleryButton setBackgroundImage:[UIImage imageNamed:@"btnDefault"] 
                                 forState:UIControlStateNormal];
        [galleryButton addTarget:self 
                          action:@selector(switchGallery:)
                forControlEvents:UIControlEventTouchUpInside];            
        [tmpPicker.view addSubview:galleryButton];
        
        [self presentViewController:tmpPicker animated:YES completion:^{
           

        }];
    }
}

-(void)switchGallery:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *tapButton = (UIButton*)sender;
        [self imagePickerControllerDidCancel:picker];
        [self pickPhotoFromPhotoCollection:tapButton];
    }
}
-(void) removePickerSubviews {
    
    NSArray *pickerSubviews = [picker.view subviews];
    for (id view in pickerSubviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *chooseButton = (UIButton*)view;
            [chooseButton removeFromSuperview];
            chooseButton = nil;
        }
    }
}
-(void)pickPhotoFromPhotoCollection:(UIButton *)sender {
    [self removePickerSubviews];
    picker.delegate = nil;
    [picker removeFromParentViewController];
    picker = nil;
    picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    __weak ClientListViewController *clvcDelegate = self;
    
    picker.delegate = clvcDelegate;
    UIImagePickerController *tmpPicker = picker;
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tmpPicker animated:YES completion:^{
            NSLog(@"Pick photo present view controller");

        }];
   // });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *editedImg = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
    editedImg = nil;
    //[ sharedVisits  addPictureForPet:editedImg forVisitWithID:sharedVisits.onWhichVisitID];
 
    [self removePickerSubviews];
    
    //VisitProgressView *tmpVP = visitProgress;
    [picker dismissViewControllerAnimated:YES completion:^{
        /*NSArray *pickerView = [picker.view subviews];
        for (id unView in pickerView) {
            if ([unView isKindOfClass:[UIButton class]]) {
                UIButton *item = (UIButton*) unView;
                [item removeFromSuperview];
                item = nil;
            } else   if ([unView isKindOfClass:[UILabel class]]) {
                UILabel *item = (UILabel*) unView;
                item = nil;
            }  else   if ([unView isKindOfClass:[UIImageView class]]) {
                UIImageView *item = (UIImageView*) unView;
                [item removeFromSuperview];
                item.image = nil;
                item = nil;
            }        
        }*/
        //[self.view addSubview:tmpVP];

    }];
    [picker.view removeFromSuperview];
    [picker removeFromParentViewController];
    picker.delegate = nil;
    picker.view = nil;
    picker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        picker.delegate = nil;
        [picker removeFromParentViewController];

    }];
}

-(BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

-(BOOL)doesCameraSupportTakingPhotos {
    return TRUE;
    //return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

-(BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType {
    __block BOOL result = NO;
    if([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = YES;
        *stop = YES;
    }];
    return result;
}

-(void) showDocAttach:(id)sender {
    if ([sender isKindOfClass:[UIButton class] ] ) {
        UIButton *statusButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)statusButton.tag];
        NSLog(@"tag id: %@", tagIDString);
        [self docErratButtonClick:sender];
    }
}
-(void) showMultiDocAttach:(id)sender {
    if ([sender isKindOfClass:[UIButton class] ] ) {
        UIButton *statusButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)statusButton.tag];
        NSLog(@"tag id: %@", tagIDString);
        [self multiDocErrataButtonClick:sender];
        
    }
}
-(void) multiDocErrataButtonClick:(id)sender {
    
    UIButton *tapButton = (UIButton*)sender;
    
    CGRect buttonOn = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width * 1.3, tapButton.frame.size.height * 1.3);
    
    [UIView animateWithDuration:0.4 animations:^{
        tapButton.frame = buttonOn;
    } completion:^(BOOL finished) {
        for(VisitDetails *visit in self->sharedVisits.visitData) {
            NSString *visitID = [NSString stringWithFormat:@"%li",(long)tapButton.tag];
            if ([visit.appointmentid isEqualToString:visitID]) {
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
-(void) docErratButtonClick:(id)sender {
    
    UIButton *tapButton = (UIButton*)sender;
    
    CGRect buttonOn = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width * 1.3, tapButton.frame.size.height * 1.3);
    
    [UIView animateWithDuration:0.4 animations:^{
        tapButton.frame = buttonOn;
        for(VisitDetails *visit in self->sharedVisits.visitData) {
            NSString *visitID = [NSString stringWithFormat:@"%li",(long)tapButton.tag];
            if ([visit.appointmentid isEqualToString:visitID]) {
                FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) 
                                                                      appointmentID:visitID 
                                                                           itemType:@"oneDoc"];
                [fmView show];
            }
        }

    } completion:^(BOOL finished) {
        
        tapButton.frame = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width / 1.3, tapButton.frame.size.height / 1.3);
    }];
}
-(void) showManagerNote:(id)sender {
    if ([sender isKindOfClass:[UIButton class] ] ) {
        UIButton *statusButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)statusButton.tag];
        [self managerNoteDetailView:sender];
    }
}
-(void) managerNoteDetailView:(id)sender {
    
    UIButton *tapButton = (UIButton*)sender;
    NSString *visitID = [NSString stringWithFormat:@"%li",(long)tapButton.tag];
    
    CGRect buttonOn = CGRectMake(tapButton.frame.origin.x, tapButton.frame.origin.y, tapButton.frame.size.width + 20, tapButton.frame.size.height + 20);
    
    NSString *tmpDayWeek = dayOfWeek;
    NSString *tmpMonthDate = monthDate;
    NSString *tmpDayNum = dayNumber;
    NSString *visitDateTime = [NSString stringWithFormat:@"%@, %@ %@",tmpDayWeek, tmpMonthDate, tmpDayNum];
    NSString *message;

    for(VisitDetails *visit in sharedVisits.visitData) {
        NSString *tmpClientName = visit.clientname;
        NSString *tmpVisitNote = visit.note;
        
        if ([visit.appointmentid isEqualToString:visitID]) {
            message = [NSString stringWithFormat:@"[%@] %@\n\n%@", visitDateTime,tmpClientName, tmpVisitNote];
        }
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        tapButton.frame = buttonOn;
    } completion:^(BOOL finished) {

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
-(void) showAlarmCodeDetailView:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *alarmButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)alarmButton.tag];
        FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) appointmentID:tagIDString  itemType:@"alarmInfo"];
        [fmView show];
        [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            fmView.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
-(void) showKeyHomeInfo:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *alarmButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)alarmButton.tag];
        FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) appointmentID:tagIDString  itemType:@"keyHomeInfo"];
        [fmView show];
        [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            fmView.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
-(void) showHomeInfo:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *alarmButton = (UIButton*)sender;
        NSString *tagIDString = [NSString stringWithFormat:@"%li",(long)alarmButton.tag];
        FloatingModalView *fmView = [[FloatingModalView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) appointmentID:tagIDString  itemType:@"justHome"];
        [fmView show];
        [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            fmView.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
-(void) markArriveButton:(id)sender {
    
    BOOL didFindArrive = NO;
    NSString *appointmentNum;
    
    if([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *statusButton = (UIButton*)sender;
        NSString *tagString = [NSString stringWithFormat:@"%li",(long)statusButton.tag];
        NSLog(@"CLVC - MARK ARRIVE with tag ID: %@",tagString);

        appointmentNum = tagString;        
        
        for(VisitDetails *visitInfo in sharedVisits.visitData) {
            
            if ([visitInfo.appointmentid isEqualToString:tagString] && 
                ([visitInfo.status isEqualToString:@"future"] || 
                 [visitInfo.status isEqualToString:@"late"])) {
                    
                    NSString *startDateTimeClean = [NSString stringWithFormat:@"%@ %@",visitInfo.date, visitInfo.rawStartTime];
                    NSDate *rightNow2 = [NSDate date];
                    NSDate *startTimeWindow = [formatterWindow dateFromString:startDateTimeClean];
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour  
                                                                                   fromDate:rightNow2 
                                                                                     toDate:startTimeWindow 
                                                                                    options:0];
                    
                    NSInteger numHours = [components hour];
                    NSInteger numDays = numHours / 24;
                    long numberOfMinutesBeforeVisit = numHours * 60;
                    
                    NSString *dateString2 = [dateFormat2 stringFromDate:rightNow2];
                    
                    if ([visitInfo.status isEqualToString:@""]) {
                        /*[self presentViewController:[self popupAlert:@"MARK VISIT ARRIVE" 
                                                         withMessage:@"ALREADY MARKED ARRIVE"] 
                                           animated:YES 
                                         completion:nil];*/
                    } 
                    else if ([visitInfo.status isEqualToString:@"canceled"]) {
                        /*[self presentViewController:[self popupAlert:@"MARK VISIT ARRIVE" 
                                                         withMessage:@"VISIT CANCELLED"] 
                                           animated:YES 
                                         completion:nil];*/
                    } 
                    else if ([visitInfo.status isEqualToString:@"completed"]) {
                        /*[self presentViewController:[self popupAlert:@"MARK VISIT ARRIVE" 
                                                         withMessage:@"VISIT IS ALREADY COMPLETED"] 
                                           animated:YES 
                                         completion:nil];*/
                    }  
                    else if (sharedVisits.numMinutesEarlyArrive <  numberOfMinutesBeforeVisit &&
                             numDays >= 0.00) {
                        
                        /*[self presentViewController:[self popupAlert:@"MARK VISIT ARRIVE" 
                                                         withMessage:@"TOO EARLY TO MARK ARRIVE"] 
                                           animated:YES 
                                         completion:^() {
                            [self -> wTableView setUserInteractionEnabled:YES];
                            
                                             //[self->_tableView setUserInteractionEnabled:YES];
                            
                                         
                        }];*/
                    } 
                    else {
                        
                        BOOL alreadyMarkArrived = NO;
                        
                        for (VisitDetails *otherVisit in sharedVisits.visitData) {
                            if([otherVisit.status isEqualToString:@"arrived"]) {
                                alreadyMarkArrived = YES;
                                if(sharedVisits.multiVisitArrive) {
                                    alreadyMarkArrived = NO;
                                    /*[self presentViewController:[self popupAlert:@"MARK VISIT ARRIVE" 
                                                                     withMessage:@"YOU ARE MARKING MULTIPLE VISITS ARRIVED"] 
                                                       animated:YES 
                                                     completion:nil];*/
                                } 
                                else {
                                   /* [self presentViewController:[self popupAlert:@"MARK VISIT ARRIVE" 
                                                                     withMessage:@"ONLY ONE VISIT CAN BE MARKED ARRIVED"] 
                                                       animated:YES 
                                                     completion:nil];*/
                                }
                            }
                        }
                        
                        if(!alreadyMarkArrived) {
                            NSLog(@"CLVC - SEND MARK ARRIVE");
                            LocationTracker *locationTracker = [LocationTracker sharedLocationManager];
                            if (!locationTracker.isLocationTracking) {
                                [locationTracker startLocationTracking];
                            }
                            visitInfo.arrived = dateString2;
                            visitInfo.hasArrived = YES;
                            visitInfo.status = @"arrived";
                            visitInfo.NSDateMarkArrive = rightNow2;
                            visitInfo.dateTimeMarkArrive = [dateTimeMarkArriveFormat stringFromDate:rightNow2];
                            
                            sharedVisits.onWhichVisitID = visitInfo.appointmentid;
                            sharedVisits.onSequence = visitInfo.sequenceID;
                            
                            didFindArrive = YES;
                            
                            //[_tableView reloadData];
                            
                            [self markVisitArriveOrComplete:@"arrived"
                                           andAppointmentID:visitInfo.appointmentid
                                             andVisitDetail:visitInfo];
                            
                            if(numDays <= 0.00) {
                                if(sharedVisits.multiVisitArrive) 
                                    [sharedVisits.onSequenceArray addObject:visitInfo];
                            }
                        }
                    }
                }
        }
    }
    
}
-(void) markVisitComplete:(VisitDetails*)visit 
             statusAction:(NSString*)action {
    

    NSDate *rightNow2 = [NSDate date];
    NSString *dateString2 = [dateFormat2 stringFromDate:rightNow2];
    
    if ([visit.status isEqualToString:@"completed"]) {
               /*[self presentViewController:[self popupAlert:@"MARK VISIT COMPLETE" 
                                                withMessage:@"ALREADY MARKED COMPLETE"] 
                                  animated:YES 
                                completion:nil];*/
    }
    
    else if ([visit.status isEqualToString:@"canceled"]) {
        /*[self presentViewController:[self popupAlert:@"MARK VISIT COMPLETE" 
                                         withMessage:@"VISIT IS CANCELED"] 
                           animated:YES 
                         completion:nil];*/
        
    }

    else if ([visit.status isEqualToString:@"arrived"]) {
        
        visit.completed = dateString2;
        visit.isComplete = YES;
        visit.status = @"completed";
        visit.NSDateMarkComplete = rightNow2;
        visit.dateTimeMarkComplete = [dateTimeMarkArriveFormat stringFromDate:rightNow2];
        
        sharedVisits.onWhichVisitID = @"000";
        
        if(sharedVisits.multiVisitArrive) {
            [sharedVisits.onSequenceArray removeObject:visit];
            
            if ([sharedVisits.onSequenceArray count] > 0) {
                VisitDetails *popVisit = [sharedVisits.onSequenceArray lastObject];
                sharedVisits.onSequence = popVisit.sequenceID;
            } else {
                sharedVisits.onSequence = @"000";
            }
            
        } else {
            sharedVisits.onSequence = @"000";
        }
        
        [self markVisitArriveOrComplete:@"completed"
                       andAppointmentID:visit.appointmentid
                         andVisitDetail:visit];
        }
    
}
                                                                                        
-(void) markVisitArriveOrComplete:(NSString*)visitStatus
                andAppointmentID:(NSString*)appointmentID
                  andVisitDetail:(VisitDetails*)visit {
    
    NSDate *rightNow = [NSDate date];    
    NSString *dateTimeString = [dateTimeMarkArriveFormat stringFromDate:rightNow];
    
    NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
    CLLocation *currentLocation = [LocationTracker sharedLocationManager].locationManager.location;
    
    NSString *theLatitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    NSString *theLongitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    NSString *theAccuracy = [NSString stringWithFormat:@"%f",currentLocation.horizontalAccuracy];
    
    NSString *username = [loginSetting objectForKey:@"username"];
    NSString *pass = [loginSetting objectForKey:@"password"];
    NSString *urlLoginStr = [username stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *urlPassStr = [pass stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
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
        
        UITableView *tableTemp = wTableView;
        NSString *dateTimeString2 = [dateFormat2 stringFromDate:rightNow];

        NSURLSessionConfiguration *urlConfig = [self sessionConfiguration];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig
                                                                 delegate:nil
                                                            delegateQueue:nil];
        NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:request 
                                                           completionHandler:^(NSData * _Nullable data,
                                                                               NSURLResponse * _Nullable responseDic,
                                                                               NSError * _Nullable error) {
            if(error == nil) {
                
                /*NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data 
                                                                            options:
                                             NSJSONReadingMutableContainers|
                                             NSJSONReadingAllowFragments|
                                             NSJSONWritingPrettyPrinted|
                                             NSJSONReadingMutableLeaves
                                                                              error:&error];*/
                
                
                if ([visitStatus isEqualToString:@"arrived"])
                {
                    [visit markArrive:dateTimeString2 latitude:theLatitude longitude:theLongitude];
                    [visit setMarkArriveCompleteStatus:@"arrived" andStatus:@"SUCCESS"];
                    VisitsAndTracking *sharedTemp = [VisitsAndTracking sharedInstance];
                    [sharedTemp updateArriveCompleteInTodayYesterdayTomorrow:visit withStatus:@"arrived"];
                    
                    dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL);
                    dispatch_async(myQueue, ^{

                        @synchronized (@"WriteArriveVisit") {

                            [visit writeVisitDataToFile];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"sentMarkArrive" object:self];

                        }
                    });
                } 
                else if ([visitStatus isEqualToString:@"completed"]) 
                {
                    
                    [visit markComplete:dateTimeString2 latitude:theLatitude longitude:theLongitude];
                    [visit setMarkArriveCompleteStatus:@"completed" andStatus:@"SUCCESS"];
                            
                    dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL);
                    dispatch_async(myQueue, ^{
                        @synchronized (@"WriteComplete") {
                            
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"sentVisitComplete" object:self];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"MarkComplete" object:self];
                            
                            if(![visit.homeAddress isEqualToString:@"NO ADDRESS"]) {
                                [visit createMapSnapshot];
                            } else {
                                NSLog(@"No valid home address");
                            }
                        }
                    });
                }
            } 
            else {                
                dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL); 
                dispatch_async(myQueue, ^{
                    if([visitStatus isEqualToString:@"arrived"]) {
                        [visit markArrive:dateTimeString2 latitude:theLatitude longitude:theLongitude];
                        [visit setMarkArriveCompleteStatus:@"arrived" andStatus:@"FAIL"];
                        [[VisitsAndTracking sharedInstance] logFailedUpload:@"markArrive" forVisitID:visit.appointmentid];
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"sentMarkArrive" object:self];

                    } else if([visitStatus isEqualToString:@"completed"]) {
                        [visit markComplete:dateTimeString2 latitude:theLatitude longitude:theLongitude];
                        [visit setMarkArriveCompleteStatus:@"completed" andStatus:@"FAIL"];
                        [[VisitsAndTracking sharedInstance] logFailedUpload:@"markComplete" forVisitID:visit.appointmentid];

                        [[NSNotificationCenter defaultCenter]postNotificationName:@"sentVisitComplete" object:self];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"MarkComplete" object:self];
                    }
                    [visit writeVisitDataToFile];                     
                });
                
                dispatch_async(dispatch_get_main_queue(), ^{
                     [tableTemp reloadData];
                 });
            }
        }];
        [postDataTask resume];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [urlSession finishTasksAndInvalidate];
        
        
    } 
    else if (!sharedVisits.isReachable) {
        NSLog(@"------------FAILED: %@ [NO NETWORK]------------", visitStatus);

        dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL);
        dispatch_async(myQueue, ^{
            if([visitStatus isEqualToString:@"arrived"]) {
                [visit setMarkArriveCompleteStatus:@"arrived" andStatus:@"FAIL"];
            } else if([visitStatus isEqualToString:@"completed"]) {
                [visit setMarkArriveCompleteStatus:@"completed" andStatus:@"FAIL"];
            }
            [visit writeVisitDataToFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self->_tableView reloadData];
                [self->wTableView reloadData];

            });
        });
    }
}




-(NSString*) createVisitReportMoodButtons:(VisitDetails*) currentVisit {
    
    
    NSString *moodButton = @"buttons={";
    
    if(currentVisit.didPoo) {
        moodButton = [moodButton stringByAppendingString:@"\"poo\":\"yes\""];
    } else if (!currentVisit.didPoo) {
        moodButton = [moodButton stringByAppendingString:@"\"poo\":\"no\""];
    }
    if(currentVisit.didPee) {
        moodButton = [moodButton stringByAppendingString:@",\"pee\":\"yes\""];
    } else if (!currentVisit.didPee) {
        moodButton = [moodButton stringByAppendingString:@",\"poo\":\"no\""];
    }
    if(currentVisit.gaveTreat) {
        moodButton = [moodButton stringByAppendingString:@",\"treat\":\"yes\""];
    } else if (!currentVisit.gaveTreat) {
        moodButton = [moodButton stringByAppendingString:@",\"treat\":\"no\""];
    }
    if(currentVisit.gaveWater) {
        moodButton = [moodButton stringByAppendingString:@",\"water\":\"yes\""];
    } else if (!currentVisit.gaveWater) {
        moodButton = [moodButton stringByAppendingString:@",\"water\":\"no\""];
    }
    if(currentVisit.dryTowel) {
        moodButton = [moodButton stringByAppendingString:@",\"towel\":\"yes\""];
    } else if (!currentVisit.dryTowel) {
        moodButton = [moodButton stringByAppendingString:@",\"towel\":\"no\""];
    }
    if(currentVisit.gaveInjection) {
        moodButton = [moodButton stringByAppendingString:@",\"injection\":\"yes\""];
    } else if (!currentVisit.gaveInjection) {
        moodButton = [moodButton stringByAppendingString:@",\"injection\":\"no\""];
    }
    if(currentVisit.gaveMedication) {
        moodButton = [moodButton stringByAppendingString:@",\"medication\":\"yes\""];
    } else if (!currentVisit.gaveMedication) {
        moodButton = [moodButton stringByAppendingString:@",\"medication\":\"no\""];
    }
    if(currentVisit.didFeed) {
        moodButton = [moodButton stringByAppendingString:@",\"feed\":\"yes\""];
    } else if (!currentVisit.didFeed) {
        moodButton = [moodButton stringByAppendingString:@",\"feed\":\"no\""];
    }
    if(currentVisit.didPlay) {
        moodButton = [moodButton stringByAppendingString:@",\"play\":\"yes\""];
    } else if (!currentVisit.didPlay) {
        moodButton = [moodButton stringByAppendingString:@",\"play\":\"no\""];
    }
    
    NSString *closeMood = @"}";
    moodButton = [moodButton stringByAppendingString:closeMood];
    return moodButton;
    
}
-(void) sendVisitReportNoButton:(NSString*) visitID {
    
    NSLog(@"SEND VISIT REPORT FOR visit id: %@", visitID);
    
    VisitDetails *currentVisit;
    for(VisitDetails *visitItem in sharedVisits.visitData) {
        if ([visitItem.appointmentid isEqualToString:visitID]) {
            currentVisit = visitItem;
        }
    }
    
    NSDate *rightNow = [NSDate date];
    NSString *dateTimeString = [dateFormat stringFromDate:rightNow];
    currentVisit.dateTimeVisitReportSubmit = dateTimeString;
    NSString *moodButton  =[self createVisitReportMoodButtons:currentVisit];
    
    LocationShareModel *locationShare = [LocationShareModel sharedModel];
    NSString *latSendNote = [NSString stringWithFormat:@"%f",locationShare.lastValidLocation.latitude];
    NSString *lonSendNote = [NSString stringWithFormat:@"%f",locationShare.lastValidLocation.longitude];

    NSString *consolidatedVisitNote = [NSString stringWithFormat:@"[VISIT: %@] ",dateTimeString];
    if(![currentVisit.visitNoteBySitter isEqual:[NSNull null]] && [currentVisit.visitNoteBySitter length] > 0) {
        consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.visitNoteBySitter];
    }
    consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:@"  [MGR NOTE] "];
    if(![currentVisit.note isEqual:[NSNull null]] && [currentVisit.note length] > 0) {
        consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.note];
    }
    
    NSString *arrivalTime = currentVisit.arrived;
    NSString *completionTime = currentVisit.completed;
    
    if (sharedVisits.isReachable) {
        
        [sharedVisits sendVisitNote:consolidatedVisitNote
                              moods:moodButton
                           latitude:latSendNote
                          longitude:lonSendNote
                         markArrive:arrivalTime
                       markComplete:completionTime
                   forAppointmentID:currentVisit.appointmentid];
        
    } else {
        
        currentVisit.visitReportUploadStatus = @"FAIL";
        dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
        dispatch_async(myWrite, ^{
            [currentVisit writeVisitDataToFile];
        });
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"NETWORK CONNECTION PROBLEM"
                                      message:@"REQUEST QUEUED UP FOR RESEND"
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                                 
                             }];
        
        
        UIAlertAction *cancelSend = [UIAlertAction actionWithTitle:@"CANCEL" 
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                               
                                                           }];
        [alert addAction:ok];
        [alert addAction:cancelSend];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}
-(void)ouputLogVisitStatus:(VisitDetails*) visit {
    
    NSLog(@"-------------------------------------------------------------------");
    NSLog(@"------------CLIENT: %@ ID: %@-----------------------", visit.clientname, visit.appointmentid);
    NSLog(@"-------------------------------------------------------------------");
    NSLog(@"STATUS -->   %@", visit.status);
    NSLog(@"ARRIVED --> %@", visit.arrived);
    NSLog(@"DT ARR -->   %@", visit.dateTimeMarkArrive);
    NSLog(@"COMP -->     %@", visit.completed);
    NSLog(@"DT COM --> %@", visit.dateTimeMarkComplete);
    NSLog(@"ARRIVE -->    %@, %@", visit.coordinateLatitudeMarkArrive, visit.coordinateLongitudeMarkArrive);
    NSLog(@"COMP -->     %@, %@", visit.coordinateLatitudeMarkComplete, visit.coordinateLongitudeMarkComplete);

    NSLog(@"-----------------RESEND STATS-------------------------------------------------");
    NSLog(@"ARRIVE: %@, COMPLETE: %@, MAP: %@, VISIT REPORT: %@", 
          visit.currentArriveVisitStatus, 
          visit.currentCompleteVisitStatus, 
          visit.mapSnapUploadStatus, 
          visit.visitReportUploadStatus);
    NSLog(@"ARRIVE:      %@", visit.currentArriveVisitStatus);
    NSLog(@"COMP:       %@", visit.currentCompleteVisitStatus);
    NSLog(@"MAP:          %@", visit.mapSnapUploadStatus);

    NSLog(@"-------------------------------------------------------------------");

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
-(void) showReachabilityIcon {

    if(!sharedVisits.isReachable) {
        UILabel *networkProblem = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        [networkProblem setFont:[UIFont fontWithName:@"Lato-Light" size:17]];
        [networkProblem setTextColor:[UIColor whiteColor]];
        [networkProblem setBackgroundColor:[UIColor redColor]];
        [networkProblem setTextAlignment:NSTextAlignmentCenter];
        [networkProblem setText:@"NETWORK PROBLEM"];
        [headerView addSubview:networkProblem];
    } 
        
}
-(void) noVisits {
    wTableView.userInteractionEnabled = NO;    
    [self setupDateValues];
    [self refreshCallback];
    [wTableView reloadData];

    wTableView.userInteractionEnabled = YES;

    
}



-(void) refreshCallback {
    //[refreshControl endRefreshing];
    
}
-(void) getUpdatedVisitsForToday {
    NSDate *todayDate = [NSDate date];
    sharedVisits.showingWhichDate = todayDate;
    sharedVisits.todayDate = todayDate;
    showingDay = todayDate;
    [sharedVisits networkRequest:todayDate toDate:todayDate];
    [self refreshCallback];
}





-(void) unreachableNetwork:(NSNotification *)notification {    
    [self showReachabilityIcon];
    //[_tableView setNeedsDisplay];
    //[_tableView reloadData];
    
    [wTableView setNeedsDisplay];
    [wTableView reloadData];
    
}
-(void) reachabilityStatusChanged:(NSNotification*) notification {
    
    if (sharedVisits.isReachable) {
        if (sharedVisits.isReachableViaWWAN) {
        } else if (sharedVisits.isReachableViaWiFi) {
        }
    }
    
    [self showReachabilityIcon];
    [wTableView setNeedsDisplay];
}
-(void) viewDidLoad {
    
    [super viewDidLoad];
    //NSLog(@"LIST - view did load");
    showingDay = [NSDate date];
}
-(void) didMoveToParentViewController:(UIViewController *)parent {
    //NSLog(@"ALLOC INIT DETAILACCORDIONVIEWCONTROLLER");
    
}
-(void) reloadTableView {

    //[_tableView reloadData];
    NSArray *currentVisitTemp = sharedVisits.visitData;
    NSMutableArray *tempVisits = [sharedVisits sortVisitsByStatus:currentVisitTemp];
    [sharedVisits copyTempVisitArrayToVisitData:tempVisits];
    [wTableView reloadData];
}
-(BOOL)checkForBadResendBeforeSync:(UIView*)failView {
    
    BOOL sendFail = NO;
    
    for(VisitDetails *visit in sharedVisits.visitData) {
        
        if ([visit.imageUploadStatus isEqualToString:@"FAIL"]) {
            NSLog(@"FAIL IMAGE UPLOAD STATUS");
            sendFail = YES;
            /*UILabel *resendLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, resendView.frame.size.width - 20, 20)];
            [resendLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
            [resendLabel setTextColor:[UIColor whiteColor]];
            [resendLabel setText:@"RESENDING PHOTO TO SERVER"];
            [failView addSubview:resendLabel];*/
            [visit setUploadStatusForPhoto:@"PEND"];
            [visit resendImageForPet];
            
        } 
        if ([visit.mapSnapUploadStatus isEqualToString:@"FAIL"]) {
            NSLog(@"MAP SNAPUPLOAD STATUS");

            sendFail = YES;
            
           /* UILabel *resendLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, resendView.frame.size.width - 20, 20)];
            [resendLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
            [resendLabel setTextColor:[UIColor whiteColor]];
            [resendLabel setText:@"RESENDING MAP SNAPSHOT TO SERVER"];
            
            [visit setUploadStatusForMap:@"PEND"];
            [visit createMapSnapshot];
            [failView addSubview:resendLabel];*/
        } 
        if ([visit.visitReportUploadStatus isEqualToString:@"FAIL"]) {
            NSLog(@"VISIT REPORT UPLOAD STATUS");

            sendFail = YES;
           /* UILabel *resendLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, resendView.frame.size.width - 20, 20)];
            [resendLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
            [resendLabel setTextColor:[UIColor whiteColor]];
            [resendLabel setText:@"RESENDING VISIT REPORT TO SERVER"];
            [failView addSubview:resendLabel];*/
            [self sendVisitReportNoButton:visit.appointmentid];
            
        } 
        if ([visit.currentCompleteVisitStatus isEqualToString:@"FAIL"]) {
            NSLog(@"MARK COMPLETE UPLOAD STATUS");

            sendFail = YES;
           /* UILabel *resendLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, resendView.frame.size.width - 20, 20)];
            [resendLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
            [resendLabel setTextColor:[UIColor whiteColor]];
            [resendLabel setText:@"RESENDING COMPLETE TO SERVER"];
            [failView addSubview:resendLabel];
            [visit setMarkArriveCompleteStatus:@"completed" andStatus:@"PEND"];*/
            [self resendComplete:visit.appointmentid];
            
        } 
        if ([visit.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
            NSLog(@"MARK ARRIVE UPLOAD STATUS");

            sendFail = YES;
            /*UILabel *resendLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, resendView.frame.size.width - 20, 20)];
            [resendLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
            [resendLabel setTextColor:[UIColor whiteColor]];
            [resendLabel setText:@"RESENDING ARRIVE TO SERVER"];
            [failView addSubview:resendLabel];
            [visit setMarkArriveCompleteStatus:@"arrived" andStatus:@"PEND"];*/

            [self resendArrive:visit.appointmentid];
            
        }
    }
    
    return sendFail;
    
}
-(BOOL) preferStatusBarHidden {
    
    return YES;
    
}
-(void)didRecieveMemoryWarning {
    [super didReceiveMemoryWarning];
    [sharedVisits logLowMem];
}
-(void) addObservers {
    
   [[NSNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(pollingUpdates)
                                                          name:@"pollingCompleteWithChanges"
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                                      selector:@selector(successfullResend:)
                                                          name:@"successfulResend" 
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
                                            selector:@selector(seuptInitialView)
                                                name:@"loginSuccess"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(reloadTableView)
                                                    name:@"updateTable"
                                                  object:nil];
    

    /*[[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(foregroundPollingUpdate)
                                                name:@"comingForeground"
                                              object:nil];*/
    
    /*[[NSNotificationCenter defaultCenter]addObserver:self
                                                   selector:@selector(applicationEnterBackground)
                                                       name:UIApplicationDidEnterBackgroundNotification
                                                     object:nil];*/
    

    
}
/*-(UIAlertController*) popupAlert:(NSString*)visitStatusTitle withMessage:(NSString*)message {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:visitStatusTitle
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    
    return alert;
    
}*/
-(NSURLSessionConfiguration*) sessionConfiguration {
    NSURLSessionConfiguration *config =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                    diskCapacity:0
                                                        diskPath:nil];
    
    return config;
}
-(void) successfullResend:(id)sender {
    
    
    UIView *successResendView = [[UIView alloc]initWithFrame: CGRectMake(0,0, self.view.frame.size.width, 300)];
    [successResendView setBackgroundColor:[UIColor blackColor]];
    UILabel *sendSuccessLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,100, self.view.frame.size.width, 80)];
    [sendSuccessLabel setFont:[UIFont fontWithName:@"Arial-Bold" size:20]];
    [sendSuccessLabel setTextColor:[UIColor whiteColor]];
    [sendSuccessLabel setText:@"SUCCESSFUL RESEND OF FAILED REQUEST"];
    [successResendView addSubview:sendSuccessLabel];
    [self.view addSubview: successResendView];
    [UIView animateWithDuration:1.4 animations:^{

        successResendView.alpha = 0.5;
        
    } completion:^(BOOL finished) {

        [successResendView removeFromSuperview];
        
    }];         
}
-(void) dealloc {
    
    /*[detailAccordionView dismissViewControllerAnimated:NO completion:^{
    }];*/
    [flagIndex removeAllObjects];
    //[refreshControl removeFromSuperview];
    [nextDay removeFromSuperview];
    [prevDay removeFromSuperview];
    [headerView removeFromSuperview];
    
    //detailAccordionView = nil;
    dayNumber = nil;
    dayOfWeek = nil;
    monthDate = nil;
    startDate = nil;
    showingDay = nil;
    
    nextDay = nil;
    //refreshControl = nil;
    flagIndex = nil;
    prevDay = nil;
    headerView = nil;
    
    
}
-(void) resendArrive:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *reportSendButton = (UIButton*)sender;
        NSString *visitIDString = [NSString stringWithFormat:@"%li",(long)reportSendButton.tag];
        
        VisitDetails *currentVisit;
        
        for(VisitDetails *visitItem in sharedVisits.visitData) {
            if ([visitItem.appointmentid isEqualToString:visitIDString]) {
                currentVisit = visitItem;
            }
        }
        
        [self resendMarkArriveOrComplete:currentVisit toStatus:@"arrived"];
        
    } else if ([sender isKindOfClass:[NSString class]]) {
        
        NSString *visitID = (NSString*)sender;
        VisitDetails *currentVisit;
        
        for(VisitDetails *visitItem in sharedVisits.visitData) {
            if ([visitItem.appointmentid isEqualToString:visitID]) {
                currentVisit = visitItem;
            }
        }
        
        [self resendMarkArriveOrComplete:currentVisit toStatus:@"arrived"];

    }
    
}
-(void) resendComplete:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *reportSendButton = (UIButton*)sender;
        NSString *visitIDString = [NSString stringWithFormat:@"%li",(long)reportSendButton.tag];
        
        VisitDetails *currentVisit;
        
        for(VisitDetails *visitItem in sharedVisits.visitData) {
            if ([visitItem.appointmentid isEqualToString:visitIDString]) {
                currentVisit = visitItem;
            }
        }
        
        [self resendMarkArriveOrComplete:currentVisit toStatus:@"completed"];
    } else if ([sender isKindOfClass:[NSString class]]) {
        
        NSString *visitID = (NSString*)sender;
        VisitDetails *currentVisit;
        
        for(VisitDetails *visitItem in sharedVisits.visitData) {
            if ([visitItem.appointmentid isEqualToString:visitID]) {
                currentVisit = visitItem;
            }
        }
        
        [self resendMarkArriveOrComplete:currentVisit toStatus:@"completed"];
        
    }
    
}
-(void) resendVisitReport:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *resendButton = (UIButton*)sender;
        NSString *appointmentID = [NSString stringWithFormat:@"%li",(long)resendButton.tag];
        VisitDetails *currentVisit;
        for(VisitDetails *visit in sharedVisits.visitData) {
            if ([appointmentID isEqualToString:visit.appointmentid]) {
                currentVisit = visit;
            }
        }
    }
}
-(void) resendMarkArriveOrComplete:(VisitDetails*)visit toStatus:(NSString*)status {
    
    
    NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
    NSString *username = [loginSetting objectForKey:@"username"];
    NSString *pass = [loginSetting objectForKey:@"password"];
    NSString *urlLoginStr = [username stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *urlPassStr = [pass stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *theLatitude;
    NSString *theLongitude;
    NSString *dateTimeString;
    
    if([status isEqualToString:@"arrived"]) {
        theLatitude = visit.coordinateLatitudeMarkArrive;
        theLongitude = visit.coordinateLongitudeMarkArrive;
        dateTimeString = visit.dateTimeMarkArrive;
    } else if ([status isEqualToString:@"completed"]) {
        theLatitude = visit.coordinateLatitudeMarkComplete;
        theLongitude = visit.coordinateLongitudeMarkComplete;
        dateTimeString = visit.dateTimeMarkComplete;
    }
    
    //NSLog(@"---------ACQUIRING VISIT DATA: %@, Time: %@, Coord: %@, %@ ---------------", visit.appointmentid, dateTimeString, theLatitude, theLongitude);
    
    NSString *theAccuracy = @"RESEND";
    NSString *appointmentID = visit.appointmentid;
    
    NSString *postRequest = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&coords={\"appointmentptr\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"event\":\"%@\",\"accuracy\":\"%@\"}",
                             urlLoginStr,urlPassStr,dateTimeString,appointmentID,theLatitude,theLongitude,status,theAccuracy];
    
    NSLog(@"Resending %@ with post string: %@", status, postRequest);
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
    
    if(sharedVisits.isReachable) {

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
                
                
                if ([status isEqualToString:@"arrived"])
                {
                               
                    dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL);
                    dispatch_async(myQueue, ^{
                        [visit setMarkArriveCompleteStatus:@"arrived" andStatus:@"SUCCESS"];
                        [visit writeVisitDataToFile];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self foregroundPollingUpdate];
                        });
                    });
                    
                } else if ([status isEqualToString:@"completed"]) {
                                        
                    dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL);
                    dispatch_async(myQueue, ^{
                        [visit setMarkArriveCompleteStatus:@"completed" andStatus:@"SUCCESS"];
                        [visit writeVisitDataToFile];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self foregroundPollingUpdate];
                        });
                    });
                }
            }
        }];
        [postDataTask resume];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [urlSession finishTasksAndInvalidate];
        
        
    }
}

@end
