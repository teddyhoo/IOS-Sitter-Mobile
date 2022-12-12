 //
//  VisitProgressView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 10/3/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import "VisitProgressView.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"
#import "DataClient.h"
#import "tgmath.h"
#import "LocationShareModel.h"
#import "VisitProgressMapView.h"
#import "ClientListViewController.h"
#import "MoodIconView.h"
#import "VisitReportFinalView.h"
#import "VisitNoteView.h"


@interface VisitProgressView() <UITextViewDelegate> {
    VisitDetails *visitInfo;
    DataClient *clientInfo;

    VisitsAndTracking* sharedVisits;
    ClientListViewController __weak *parentViewRef;
    VisitProgressMapView *mainMapView;
    MoodIconView *moodView;    
    
    UIView *visitInfoView;
    UIView *arriveView;
    UIView *completeView;
    UIView *photoView;
    UIView *moodButtonView;
    
    UIView *noteView;
    UIView *photoEnlargeView;
    UIView *largeMapView;
    
    UIButton *noteViewButton;
    UITextView *noteTextView;
    UILabel *timerForVisitLabel;
    UILabel *durationLabel;
    
    
    NSTimer *stopWatchTimer;
    NSMutableArray *moodButtonArray;
    NSMutableArray *placedMoodButtons;
    NSMutableDictionary *colorPalette;
    
    CGRect noteViewOldFrame;
    NSNumber *clientID;
    NSNumber *currentVisitID;
    NSDateFormatter *completeTimeFormat;
    NSDateFormatter *timeArriveFormat;

    int char_per_line;
 
}

@end

@implementation VisitProgressView

-(instancetype)initWithFrame:(CGRect)frame 
                   visitInfo:(VisitDetails*)visit 
                  clientInfo:(DataClient*)client 
                  parentView:(ClientListViewController*)parent {
    
    char_per_line = 24;
    parentViewRef = parent;
    visitInfo = visit;
    clientInfo = client;
    NSString *pListData = [[NSBundle mainBundle]
                           pathForResource:@"MoodButtons"
                           ofType:@"plist"];
    moodButtonArray = [[NSMutableArray alloc]initWithContentsOfFile:pListData];
    currentVisitID =[[[NSNumberFormatter alloc] init] numberFromString:visitInfo.appointmentid];
    clientID = [[[NSNumberFormatter alloc] init] numberFromString:clientInfo.clientID];

    return [self initWithFrame:frame];
    
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        
        [self addNotificationObservers];
        
        sharedVisits = [VisitsAndTracking sharedInstance];
        colorPalette = [sharedVisits getColorPalette];

        [self setBackgroundColor:[colorPalette objectForKey:@"default"]];
                
        [self configureDateFormatters];
        
        if ([visitInfo.visitReportUploadStatus isEqualToString:@"SUCCESS"]) {
            [self buildFinalView];
        } else {
            //
            [self updateViewsInitial];
        }
    }
    return self;
}

-(void) configureDateFormatters {
    
    completeTimeFormat = [[NSDateFormatter alloc]init];
    [completeTimeFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    timeArriveFormat = [[NSDateFormatter alloc]init];
    [timeArriveFormat setDateFormat:@"h:mm a"];

}

-(void) updateViewsInitial {

    [self removeViews];
    
    if([visitInfo.status isEqualToString:@"arrived"] ||
       [visitInfo.status isEqualToString:@"future"] || 
       [visitInfo.status isEqualToString:@"late"]) {
        
        [self createViewButtons];
        [self checkVisitTimerToUpdate];

    }
    
    else if ([visitInfo.status isEqualToString:@"completed"]) {

        [self buildFinalView];

    } else if ([visitInfo.status isEqualToString:@"canceled"]) {
        
        [self createViewButtons];
        [arriveView setBackgroundColor:[UIColor redColor]];
        [completeView setBackgroundColor:[UIColor redColor]];
        [visitInfoView setBackgroundColor:[UIColor redColor]];
        [photoView setBackgroundColor:[UIColor redColor]];
    
    }
    [self checkSendArriveStatus];
    [self checkSendCompleteStatus];
    [self checkPhotoUploadStatus];
    [self checkMoodViewStatus];
    [self checkNoteViewStatus];
}
-(void) removeObservers {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"photoFinishUpload" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"sentMarkArrive" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"sentVisitReport" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"sentVisitComplete" object:nil];
}
-(void) checkVisitTimerToUpdate {
    [timerForVisitLabel removeFromSuperview];
    
    [self configureDateFormatters];
    [stopWatchTimer invalidate];
    
    if ([visitInfo.status isEqualToString:@"arrived"]) {
        durationLabel = [self createLabel:CGRectMake(20, 10, 100, 32)
                                          withFont:[UIFont fontWithName:@"Lato-Regular" size:30]
                                           andText:@"TIME: "
                                      forTextColor:[colorPalette objectForKey:@"dangerDark"]];

        timerForVisitLabel = [[UILabel alloc]initWithFrame:CGRectMake(durationLabel.frame.origin.x + 90, durationLabel.frame.origin.y,100, 32)];
        [timerForVisitLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:30]];
        [timerForVisitLabel setTextColor:[colorPalette objectForKey:@"dangerDark"]];
        [timerForVisitLabel setText:@"00:00"];
        timerForVisitLabel.textAlignment = NSTextAlignmentLeft;
        [completeView addSubview:timerForVisitLabel];
        [completeView addSubview:durationLabel];
        stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(updateTimer)
                                                            userInfo:nil
                                                             repeats:YES];
    }

}
-(void) updateTimer {
    
    NSDate *currentDate = [NSDate date];
    NSDate *timerBeginDate = [completeTimeFormat dateFromString:visitInfo.dateTimeMarkArrive];
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
        NSDate *timeEndStart = [completeTimeFormat dateFromString:visitInfo.dateTimeMarkComplete];
        NSString *timeEndString = [timeArriveFormat stringFromDate:timeEndStart];
        [timerForVisitLabel setText:timeEndString];
        stopWatchTimer = nil;
        
    }
}

-(void) createViewButtons {
    colorPalette = [sharedVisits getColorPalette];
    int xOffset = 5;

    [self createVisitInfoView:xOffset yOffset:0];

    arriveView = [[UIView alloc]initWithFrame:CGRectMake(xOffset, visitInfoView.frame.origin.y + visitInfoView.frame.size.height +2 , self.frame.size.width - (2*xOffset), 60)];
    photoView = [[UIView alloc]initWithFrame:CGRectMake(arriveView.frame.origin.x, arriveView.frame.origin.y +  arriveView.frame.size.height + 2, self.frame.size.width -  (2*xOffset), 60)];
    moodButtonView = [[UIView alloc]initWithFrame:CGRectMake(photoView.frame.origin.x, photoView.frame.size.height + photoView.frame.origin.y + 2, self.frame.size.width - (2*xOffset), 60)];
    float noteViewHeight = self.frame.size.height - visitInfoView.frame.size.height - arriveView.frame.size.height - photoView.frame.size.height -moodButtonView.frame.size.height - 80;
    
    noteView = [[UIView alloc]initWithFrame:CGRectMake(moodButtonView.frame.origin.x, moodButtonView.frame.origin.y + moodButtonView.frame.size.height  + 2, self.frame.size.width - (2 * xOffset), noteViewHeight)];
    [noteView setBackgroundColor:[UIColor yellowColor]];
    noteView.tag = 0;
    
    UITapGestureRecognizer *tapNoteView =  [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                  action:@selector(tappedNoteView:)];
    [noteView addGestureRecognizer:tapNoteView];
    noteViewOldFrame = noteView.frame;
    
    completeView = [[UIView alloc]initWithFrame:CGRectMake(noteView.frame.origin.x, noteView.frame.origin.y + noteView.frame.size.height + 1, self.frame.size.width - (2*xOffset), 60)];
    
    moodView= [[MoodIconView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height) 
                                       visitInfo:visitInfo 
                                      clientInfo:clientInfo 
                                      parentView:self];
    
    [self createCompleteView:completeView];
    [self createArriveView:arriveView];
    [self createPhotoView:photoView];
    [self createMoodButtonView:moodButtonView];
    [self createNoteView:noteView];
    
    [self addSubview:arriveView];
    [self addSubview:photoView];
    [self addSubview:moodButtonView];
    [self addSubview:noteView];
    [self addSubview:moodView];
    [self addSubview:completeView];

}

-(void) createViewButtonsCompletedVisit {
    
    colorPalette = [sharedVisits getColorPalette];
    int xOffset = 5;
    
    [self createVisitInfoView:xOffset yOffset:0];
    
    arriveView = [[UIView alloc]initWithFrame:CGRectMake(xOffset, visitInfoView.frame.origin.y + visitInfoView.frame.size.height +2 , self.frame.size.width - (2*xOffset), 60)];
    photoView = [[UIView alloc]initWithFrame:CGRectMake(arriveView.frame.origin.x, arriveView.frame.origin.y +  arriveView.frame.size.height + 2, self.frame.size.width -  (2*xOffset), 60)];
    moodButtonView = [[UIView alloc]initWithFrame:CGRectMake(photoView.frame.origin.x, photoView.frame.size.height + photoView.frame.origin.y + 2, self.frame.size.width - (2*xOffset), 60)];
    float noteViewHeight = self.frame.size.height - visitInfoView.frame.size.height - arriveView.frame.size.height - photoView.frame.size.height -moodButtonView.frame.size.height - 190;
    noteView = [[UIView alloc]initWithFrame:CGRectMake(moodButtonView.frame.origin.x, moodButtonView.frame.origin.y + moodButtonView.frame.size.height  + 1, self.frame.size.width - (2 * xOffset), noteViewHeight)];
    noteViewOldFrame = noteView.frame;
    noteView.tag = 0;
    completeView = [[UIView alloc]initWithFrame:CGRectMake(noteView.frame.origin.x, noteView.frame.origin.y + noteView.frame.size.height + 5, noteView.frame.size.width, 90)];
    
    [self createVisitInfoView:xOffset yOffset:0];
    [self createArriveView:arriveView];
    [self createPhotoView:photoView];
    [self createMoodButtonView:moodButtonView];
    [self createNoteView:noteView];    
  
    [self createCompleteView:completeView];
    
    [self addSubview:arriveView];
    [self addSubview:photoView];
    [self addSubview:moodButtonView];
    [self addSubview:noteView];
    [self addSubview:moodView];
    [self addSubview:completeView];
}
-(void) addActionButtons:(UIView*) baseView {
    UIButton *clientDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clientDetailsButton.frame = CGRectMake(visitInfoView.frame.size.width - 52, 2, 32, 32);
    clientDetailsButton.tag = currentVisitID.integerValue;
    [clientDetailsButton setBackgroundImage:[UIImage imageNamed:@"btn-hamburger"]
                                 forState:UIControlStateNormal];
    [clientDetailsButton addTarget:self
                          action:@selector(goToClientDetails:)
                forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 5, 32,32);
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn-back"] 
                          forState:UIControlStateNormal];
    [backButton addTarget:self 
                   action:@selector(dismissReportView:) 
         forControlEvents:UIControlEventTouchUpInside];
    
    [baseView addSubview:clientDetailsButton];
    [baseView addSubview:backButton];
    
    
}
-(void) addSubmitVisitRequestButton {
    UIButton *sendVisitReportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendVisitReportButton.frame = CGRectMake(2,self.frame.size.height - 122, self.frame.size.width - 4, 112);
    [sendVisitReportButton setBackgroundImage:[UIImage imageNamed:@"longSendVisitReport"] 
                                     forState:UIControlStateNormal];
    [sendVisitReportButton addTarget:self 
                              action:@selector(sendVisitReport:) 
                    forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:sendVisitReportButton];
}
-(void) visitReportSentSuccess {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateTable" object:self];
        [self updateViewsInitial];
    });
    VisitDetails *tempVisit = visitInfo;
    dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
    dispatch_async(myWrite, ^{
        [tempVisit writeVisitDataToFile];
    });

}
-(void) goToClientDetails:(id)sender {

    [parentViewRef tapDetailView:sender];
    
}
-(void) dismissReportView:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateTable" object:self];
    
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    
    [self removeObservers];
    [moodButtonView removeFromSuperview];
    [mainMapView removeFromSuperview];
    moodButtonView = nil;
    mainMapView = nil;

    [self removeViews];

    completeTimeFormat = nil;
    timeArriveFormat = nil;
    currentVisitID = nil;
    [colorPalette removeAllObjects];
    colorPalette = nil;
    [self removeFromSuperview];
    
}


-(void) createVisitInfoView:(int)xOffset yOffset:(int)y {
    visitInfoView = [[UIView alloc]initWithFrame:CGRectMake(xOffset,2, self.frame.size.width- (2*xOffset), 200)];
    [visitInfoView setBackgroundColor:[colorPalette objectForKey:@"infoDark"]];
    [self addSubview:visitInfoView];
    
    UIView *backBanner = [[UIView alloc]initWithFrame:CGRectMake(0, 0, visitInfoView.frame.size.width, 42)];
    [backBanner setBackgroundColor:[UIColor blueColor]];
    [backBanner setAlpha:0.125];
    [visitInfoView addSubview:backBanner];
    [self addActionButtons:visitInfoView];
    
    UILabel *visitDetailsLabel = [self createLabel:CGRectMake(0,8, visitInfoView.frame.size.width, 24) 
                                          withFont:[UIFont fontWithName:@"Lato-Bold" size:22] 
                                           andText:@"VISIT DETAILS" forTextColor:[UIColor whiteColor]];
    
    visitDetailsLabel.textAlignment = NSTextAlignmentCenter;
    [visitInfoView addSubview:visitDetailsLabel];
    
    NSString *addressInfo;
    if (![clientInfo.street2 isEqual:[NSNull null]] && [clientInfo.street2 length] >0) {
        addressInfo = [NSString stringWithFormat:@"%@, %@", clientInfo.street1, clientInfo.street2];
    } else if (![clientInfo.street1 isEqual:[NSNull null]] && [clientInfo.street1 length] > 0) {
        addressInfo = clientInfo.street1;
    } else {
        addressInfo = @"NO ADDRESS";
    }
    
    UILabel *petsLabel;
    petsLabel = [self createLabel:CGRectMake(42, 50, self.frame.size.width - 80, 22)
                                  withFont:[UIFont fontWithName:@"Lato-Bold" size:20]
                                   andText:visitInfo.petName
                              forTextColor:[UIColor whiteColor]];
    
    if ([visitInfo.petName length] > 30) {
        petsLabel.numberOfLines = 2;
        petsLabel.frame = CGRectMake(petsLabel.frame.origin.x, petsLabel.frame.origin.y, petsLabel.frame.size.width, petsLabel.frame.size.height * 2);
    }

    
   
    UILabel *clientLabel = [self createLabel:CGRectMake(petsLabel.frame.origin.x, petsLabel.frame.origin.y + petsLabel.frame.size.height + 4, petsLabel.frame.size.width, 22)
                                    withFont:[UIFont fontWithName:@"Lato-Bold" size:20]
                                     andText:visitInfo.clientname
                                forTextColor:[UIColor whiteColor]];
    
    UILabel *addressLabel = [self createLabel:CGRectMake(clientLabel.frame.origin.x, 
                                                         clientLabel.frame.origin.y + clientLabel.frame.size.height + 4, 
                                                         petsLabel.frame.size.width, 22) 
                                     withFont:[UIFont fontWithName:@"Lato-Bold" size:20]
                                      andText:addressInfo 
                                 forTextColor:[UIColor whiteColor]];
    
    
    UIButton *mapTapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapTapButton.frame = CGRectMake(0, addressLabel.frame.origin.y, visitInfoView.frame.size.width, 50);
    [mapTapButton setBackgroundColor:[UIColor clearColor]];
    [mapTapButton addTarget:self 
                     action:@selector(viewLargeMap:) 
           forControlEvents:UIControlEventTouchUpInside];
    mapTapButton.tag = currentVisitID.integerValue;
    
    UIButton *mapButton = [self createButton:CGRectMake(10, addressLabel.frame.origin.y, 24, 24) 
                                      bImage:@"map-icon-100" 
                                       tagID:currentVisitID.integerValue];
    [mapButton addTarget:self 
                  action:@selector(viewLargeMap:) 
        forControlEvents:UIControlEventTouchUpInside];
    mapButton.tag = currentVisitID.integerValue;
    
    if (visitInfo.note != NULL && ![visitInfo.status isEqualToString:@"completed"]) {        
        UIButton *managerNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        managerNoteButton.frame = CGRectMake(10, clientLabel.frame.origin.y - 20, 24,24);
        [managerNoteButton setBackgroundImage:[UIImage imageNamed:@"message-icon-white"] forState:UIControlStateNormal];
        NSNumber *tagVal = [[[NSNumberFormatter alloc]init]numberFromString:visitInfo.appointmentid];
        managerNoteButton.tag = [tagVal integerValue];
        [managerNoteButton addTarget:parentViewRef 
                              action:@selector(showManagerNote:) 
                    forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *noteTap = [UIButton buttonWithType:UIButtonTypeCustom];
        noteTap.frame = CGRectMake(0, managerNoteButton.frame.origin.y - 10, visitInfoView.frame.size.width, 50);
        [noteTap setBackgroundColor:[UIColor clearColor]];
        noteTap.tag = [tagVal integerValue];

        [noteTap addTarget:parentViewRef 
                         action:@selector(showManagerNote:) 
               forControlEvents:UIControlEventTouchUpInside];
        noteTap.tag = currentVisitID.integerValue;
        
        [visitInfoView addSubview:noteTap];
        [visitInfoView addSubview:managerNoteButton];
    }

    [visitInfoView addSubview:petsLabel];
    [visitInfoView addSubview:clientLabel];
    [visitInfoView addSubview:addressLabel];
    [visitInfoView addSubview:mapTapButton];
    [visitInfoView addSubview:mapButton];
    
    [self checkKeyInfo:visitInfoView];
}
-(void) createArriveView:(UIView*)referenceView {
    
    if ([visitInfo.status isEqualToString:@"arrived"] || [visitInfo.status isEqualToString:@"completed"]) {
        NSDate *stringToDate = [completeTimeFormat dateFromString:visitInfo.arrived];
        NSString *aClean = [NSString stringWithFormat:@"%@ STARTED", [timeArriveFormat stringFromDate:stringToDate]];

        UILabel *arrivedLabel = [self createLabel:CGRectMake(42, 15, self.frame.size.width, 24) 
                                         withFont:[UIFont fontWithName:@"Lato-Light" size:20] 
                                          andText:aClean
                                     forTextColor:[UIColor blackColor]];
        [referenceView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
        [referenceView addSubview:arrivedLabel];
        
        UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkButton.frame = CGRectMake(5, 15,30,30);
        [checkButton setBackgroundImage:[UIImage imageNamed:@"btnSuccess"] forState:UIControlStateNormal];
        [referenceView addSubview:checkButton];
         
    } 
    else if ([visitInfo.status isEqualToString:@"future"] || [visitInfo.status isEqualToString:@"late"]) {

        UIButton *arriveButton = [self createButton:CGRectMake(referenceView.frame.size.width - 137, 5, 127, 50)
                                             bImage:@"walkBegin"
                                              tagID:currentVisitID.integerValue];
        
        [arriveButton addTarget:self
                         action:@selector(markArrive:)
               forControlEvents:UIControlEventTouchUpInside];
        arriveButton.tag = [[[[NSNumberFormatter alloc] init] numberFromString:visitInfo.appointmentid] integerValue];
        [referenceView addSubview:arriveButton];
            
    
        
        UILabel *timeWindow = [self createLabel:CGRectMake(42, 5, self.frame.size.width - 150, 24) 
                                       withFont:[UIFont fontWithName:@"Lato-Bold" size:22] 
                                        andText:visitInfo.timeofday 
                                   forTextColor:[UIColor whiteColor]];
        
        [referenceView addSubview:timeWindow];
        
        UILabel *serviceName = [self createLabel:CGRectMake(42, timeWindow.frame.origin.y +30, self.frame.size.width - 150, 24) 
                                       withFont:[UIFont fontWithName:@"Lato-Bold" size:22] 
                                        andText:visitInfo.service 
                                   forTextColor:[UIColor whiteColor]];
        
        [referenceView addSubview:serviceName];
    }
}

-(void)goToPhotoTaker:(id)sender {
    [parentViewRef goToPhotoTaker:sender];
}

-(void) createPhotoView:(UIView*)referenceView {
    
    NSArray *photoSub = [photoView subviews];

    for (int i = 0; i < [photoSub count]; i++) {
        UILabel *pView =[photoSub objectAtIndex:i];
        [pView removeFromSuperview];
    }
    
    UIButton *photoViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoViewButton.frame = CGRectMake(0, 0, referenceView.frame.size.width, referenceView.frame.size.height);
    photoViewButton.tag = currentVisitID.integerValue;
    [photoViewButton setBackgroundColor:[UIColor clearColor]];
    [referenceView addSubview:photoViewButton];

    UIButton *photoButton = [self createButton:CGRectMake(referenceView.frame.size.width - 40, 13, 30, 30) 
                                        bImage:@"camera-icon-100" 
                                         tagID:currentVisitID.integerValue];
    [referenceView addSubview:photoButton];

    if([visitInfo isPetImage]) {
        [photoButton setBackgroundImage:[visitInfo getPetPhoto] 
                               forState:UIControlStateNormal];
        [photoButton addTarget:self 
                        action:@selector(viewLargePhoto:) 
              forControlEvents:UIControlEventTouchUpInside];
        [photoViewButton addTarget:self 
                            action:@selector(viewLargePhoto:) 
                  forControlEvents:UIControlEventTouchUpInside];

        [referenceView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];

        if([visitInfo.imageUploadStatus isEqualToString:@"SUCCESS"]) {
            UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            checkButton.frame = CGRectMake(5, 15,30,30);
            [checkButton setBackgroundImage:[UIImage imageNamed:@"btnSuccess"] forState:UIControlStateNormal];
            [referenceView addSubview:checkButton];
            UILabel *uploadingPhotoLabel = [[UILabel alloc]initWithFrame:CGRectMake(42, 15, photoView.frame.size.width, 40)];
            [uploadingPhotoLabel setTextColor:[UIColor blackColor]];
            [uploadingPhotoLabel setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
            [uploadingPhotoLabel setText:visitInfo.photoSentDate];
            [referenceView addSubview:uploadingPhotoLabel];
            
        } 
    } 
    else {
        [photoButton addTarget:self
                        action:@selector(takePhoto:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [photoViewButton addTarget:self
                            action:@selector(takePhoto:)
                  forControlEvents:UIControlEventTouchUpInside];
        [photoViewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UILabel *addPhotoLabel = [[UILabel alloc]initWithFrame:CGRectMake(42,20,referenceView.frame.size.width, 24)];
        [addPhotoLabel setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
        [addPhotoLabel setTextColor:[UIColor blackColor]];
        [addPhotoLabel setText:@"Add photo"];
        [photoView addSubview:addPhotoLabel];
    }
}

-(void) takePhoto:(id)sender {

    [stopWatchTimer invalidate];
    
    if (stopWatchTimer.isValid)  {
        NSLog(@"Stop watch timer is valid");
    }
    [parentViewRef goToPhotoTaker:sender];
    
}
-(void) createMoodButtonView:(UIView*)referenceView {
    
    UIButton *wholeViewMoodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    wholeViewMoodButton.frame = CGRectMake(0, 0, referenceView.frame.size.width, referenceView.frame.size.height);
    wholeViewMoodButton.tag = currentVisitID.integerValue;
    [wholeViewMoodButton addTarget:self 
                       action:@selector(showMoodView:) 
             forControlEvents:UIControlEventTouchUpInside];
    [wholeViewMoodButton setBackgroundColor:[UIColor clearColor]];
    
    UIButton *moodViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moodViewButton.frame = CGRectMake(referenceView.frame.size.width -40, 13, 30, 30); 
    [moodViewButton setBackgroundImage:[UIImage imageNamed:@"btnErrorSmall"] 
                              forState:UIControlStateNormal];
    
    [moodViewButton addTarget:self 
                   action:@selector(showMoodView:) 
         forControlEvents:UIControlEventTouchUpInside];
    
    moodViewButton.tag = currentVisitID.integerValue;
    [wholeViewMoodButton addSubview:moodViewButton];    
    [self addMoodWithStatus];
        
    if ([self moodButtonsSelected]) {
        UIButton *checkMark = [UIButton buttonWithType:UIButtonTypeCustom];
        checkMark.frame = CGRectMake(5,15,30,30);
        [checkMark setBackgroundImage:[UIImage imageNamed:@"btnSuccess"] forState:UIControlStateNormal];
        [checkMark addTarget:self action:@selector(showMoodView:) forControlEvents:UIControlEventTouchUpInside];
        [referenceView addSubview:checkMark];
    } else {
        [referenceView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
        [referenceView addSubview:wholeViewMoodButton];
        UILabel *moodLabel = [[UILabel alloc]initWithFrame:CGRectMake(42,20,referenceView.frame.size.width, 24)];
        [moodLabel setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
        [moodLabel setTextColor:[UIColor blackColor]];
        [moodLabel setText:@"Add visit icons"];
        [referenceView addSubview:moodLabel];
    }
    if ([visitInfo.status isEqualToString:@"future"] || [visitInfo.status isEqualToString:@"late"]) {
        [referenceView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    }
}

-(void) createNoteView:(UIView*)referenceView {
        
    if([visitInfo.status isEqualToString:@"future"] || [visitInfo.status isEqualToString:@"late"]) {
        if (![visitInfo.visitNoteBySitter isEqual:[NSNull null]] && [visitInfo.visitNoteBySitter length]  !=  0) {            
            [referenceView setBackgroundColor:[colorPalette objectForKey:@"success"]];
        } else {
            UILabel *noteTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(42,20,referenceView.frame.size.width, 24)];
            [noteTextLabel setFont:[UIFont fontWithName:@"Lato-Light" size:20]];           
            [noteTextLabel setTextColor:[UIColor blackColor]];
            [noteTextLabel setText:@"Add note"];
            [referenceView addSubview:noteTextLabel];
            [referenceView setBackgroundColor:[colorPalette objectForKey:@"default"]] ;            
        }
        
    }  else if ([visitInfo.status isEqualToString:@"arrived"]) {
        
        if (![visitInfo.visitNoteBySitter isEqual:[NSNull null]] && [visitInfo.visitNoteBySitter length]  !=  0) {         
            [referenceView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
        } else {
            [referenceView setBackgroundColor:[colorPalette objectForKey:@"success"]]; 
            UILabel *noteTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(42,20,referenceView.frame.size.width, 24)];
            [noteTextLabel setFont:[UIFont fontWithName:@"Lato-Light" size:20]];           
            [noteTextLabel setTextColor:[UIColor blackColor]];
            [noteTextLabel setText:@"Add note"];
            [referenceView addSubview:noteTextLabel];
        }
    } else if ([visitInfo.status isEqualToString:@"completed"]) {
        
        if (![visitInfo.visitNoteBySitter isEqual:[NSNull null]] && [visitInfo.visitNoteBySitter length]  !=  0) {
            [referenceView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
            UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            checkButton.frame = CGRectMake(5, 15,30,30);
            [checkButton setBackgroundImage:[UIImage imageNamed:@"btnSuccess"] forState:UIControlStateNormal];
            [referenceView addSubview:checkButton];

        }
    }

    noteTextView = [[UITextView alloc]initWithFrame:CGRectMake(5, 60, referenceView.frame.size.width-10, referenceView.frame.size.height-64)];
    [noteTextView setBackgroundColor:[UIColor whiteColor]];
    [noteTextView setTextColor:[UIColor blackColor]];
    [noteTextView setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
    [noteTextView setDelegate:self];
    [noteTextView setText:visitInfo.visitNoteBySitter];
    [noteTextView setReturnKeyType:UIReturnKeyDone];
    UITapGestureRecognizer *tapNoteView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedNoteView:)];
    tapNoteView.delegate = (id)self;
    [noteTextView addGestureRecognizer:tapNoteView];
    [referenceView addSubview:noteTextView];        
    
    
    noteViewButton = [self createButton:CGRectMake(referenceView.frame.size.width - 40, 13, 30, 30) 
                                 bImage:@"message-icon-red" 
                                  tagID:currentVisitID.integerValue];

    noteViewButton.tag = currentVisitID.integerValue;
    [noteViewButton addTarget:self 
                       action:@selector(tappedNoteView:)
             forControlEvents:UIControlEventTouchUpInside];

    [referenceView addSubview:noteViewButton];
}

-(void) tappedNoteView:(id)sender {

    UIView *localNoteTextView = noteView;
    NSArray *viewsForNote = [noteView subviews];
    for (id view in viewsForNote) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *noteButton = (UIButton*)view;
            [noteButton removeFromSuperview];
            noteButton = nil;
            UIButton *saveCloseButton =[UIButton buttonWithType:UIButtonTypeCustom];
            saveCloseButton.frame = CGRectMake(localNoteTextView.frame.size.width -165 ,10, 160, 30);
            [saveCloseButton setBackgroundImage:[UIImage imageNamed:@"btn-small-saveclose"] forState:UIControlStateNormal];
            [saveCloseButton addTarget:self 
                                action:@selector(dismissNoteView:) 
                      forControlEvents:UIControlEventTouchUpInside];
            [noteView addSubview:saveCloseButton];
            
        } else if ([view isKindOfClass:[UITextView class]]) {
            UITextView *localText = (UITextView*)view;
            [localText becomeFirstResponder];
            [self beginTextEdit:localText];

        }
    }

    [self bringSubviewToFront:localNoteTextView];    
    [UIView animateWithDuration:0.25 animations:^{
        localNoteTextView.frame = CGRectMake(0, 40, self.frame.size.width, self.frame.size.height - 80);
    } completion:^(BOOL finished) {
    
    }];
    
}
-(void) dismissNoteView:(id)sender {
    
    CGRect moveToFrame = noteViewOldFrame;

    if ([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *dismissButtonSender = (UIButton*)sender;
        
        [dismissButtonSender removeTarget:self 
                                   action:@selector(dismissNoteView:) 
                         forControlEvents:UIControlEventAllEvents];
        dismissButtonSender.frame = CGRectMake(noteView.frame.size.width - 55, 3, 50, 50);
        [dismissButtonSender setBackgroundImage:[UIImage imageNamed:@"message-icon-white"] 
                                       forState:UIControlStateNormal];
        [dismissButtonSender addTarget:self 
                                action:@selector(tappedNoteView:) 
                      forControlEvents:UIControlEventTouchUpInside];
        
        NSString *noteText = noteTextView.text;
        visitInfo.visitNoteBySitter = noteText;
        
        UIView *localTextView = noteTextView;
        UIView *localNoteView = noteView;
        UIView *localComplete = completeView;
        
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            localNoteView.frame = moveToFrame;
            localTextView.frame = CGRectMake(2, 60, moveToFrame.size.width, moveToFrame.size.height-64);
        } completion:^(BOOL finished) {
            
            [self dismissKeyboard];
            [self checkNoteViewStatus];
            [localComplete setUserInteractionEnabled:YES];

        }];
        
    }
}

/* NOTE VIEW ACTIONS*/
-(void) beginTextEdit:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
    } else if ([sender isKindOfClass:[UITextView class]]) {
    } else if ([sender isKindOfClass:[UIView class]]) {
    } else {
    }
}
-(void) endTextEdit:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
    } else if ([sender isKindOfClass:[UITextView class]]) {
    } else if ([sender isKindOfClass:[UIView class]]) {
    } else {
    }

    VisitDetails *asyncVisitInfo = visitInfo;
    [asyncVisitInfo writeVisitDataToFile];
    
    //[self dismissKeyboard];
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)theTextField{
    NSLog(@"----TEXT FIELD SHOULD RETURN");
    [theTextField resignFirstResponder];
    return YES;
}
-(BOOL) textViewShouldBeginEditing:(UITextView *)aTextView {
    //NSLog(@"----BEGIN editing with tag Num: %li", (long)aTextView.tag);
    /*if (aTextView.tag == 1) {
        
        return YES;
        
    } else {
        
        return NO;
        
    }*/
    return YES;
}
-(BOOL) textViewShouldEndEditing:(UITextView *)aTextView {
    //NSLog(@"----END editing");
    visitInfo.visitNoteBySitter = noteTextView.text;
    //[self dismissKeyboard];
    return YES;
}
-(void) textViewDidEndEditing:(UITextView *)textView {
    //NSLog(@"----DID END EDITING");
    //visitInfo.visitNoteBySitter = textView.text;
    [textView resignFirstResponder];
    [self dismissKeyboard];    
}
-(void) keyboardWillShowNotification:(NSNotification *)notification {
    //NSLog(@"Keyboard will show notification");
    for (NSDictionary *userDic in notification.userInfo) {
        NSArray *dicKeys = [userDic allKeys];
        for (id key in dicKeys) {
            NSLog(@"key is: %@", key);
        }
    }    
}
-(void) keyboardWillHideNotification:(NSNotification *)notification {}
-(void) updateTextViewContentInset {

}
-(void) keyboardDidShow:(NSNotification *)note {
    NSValue *keyboardFrameValue = [note userInfo][UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    CGRect r = noteTextView.frame;
    //NSLog(@"KEYBOARD frame x: %f y: %f width: %f height: %f", r.origin.x, r.origin.y, r.size.width, r.size.height);
    r.size.height -= CGRectGetHeight(keyboardFrame);
    noteTextView.frame = r;        
}
-(void) textViewDidChangeSelection:(UITextView *)textView {
    //NSLog(@"DID CHANGE SELECTION ");
    [textView layoutIfNeeded];
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    caretRect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:caretRect animated:NO];
}
-(void) dismissKeyboard {
    //NSLog(@"DISMISS keyboard");
    VisitDetails *asyncVisitInfo = visitInfo;
    dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
    dispatch_async(myWrite, ^{
        [asyncVisitInfo writeVisitDataToFile];
    });    
    [self endEditing:YES];    
}

-(void) buildFinalView {
    
    VisitDetails *localVisitDetails = visitInfo;
    DataClient *localDataClient = clientInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        VisitReportFinalView *finalPreviewView = [[VisitReportFinalView alloc]initWithFrame:CGRectMake(0,self.frame.size.height, self.frame.size.width, self.frame.size.height)
                                                                                      visitInfo:localVisitDetails
                                                                                     clientInfo:localDataClient
                                                                                 parentView:self];
        
        [self addSubview:finalPreviewView];
        [UIView animateWithDuration:0.4 animations:^{
            finalPreviewView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];

    });
   
}
-(void) checkKeyInfo:(UIView*)infoView {
    
    UIButton *keyInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    keyInfoButton.frame =CGRectMake(10,infoView.frame.size.height - 60, infoView.frame.size.width - 70, 50);

    NSNumber *tagVal = [[[NSNumberFormatter alloc]init]numberFromString:visitInfo.appointmentid];
    keyInfoButton.tag = [tagVal integerValue];
    
    [keyInfoButton addTarget:parentViewRef 
                      action:@selector(showAlarmCodeDetailView:) 
             forControlEvents:UIControlEventTouchUpInside];
    UIImageView *hasKeyIcon = [[UIImageView alloc]initWithFrame:CGRectMake(keyInfoButton.frame.origin.x, keyInfoButton.frame.origin.y + 10, 26, 30)];
    UILabel *keyIDLabel = [[UILabel alloc]initWithFrame:CGRectMake(42, hasKeyIcon.frame.origin.y, keyInfoButton.frame.size.width, 36)];

    [infoView addSubview:keyInfoButton];
    [infoView addSubview:hasKeyIcon];
    [infoView addSubview:keyIDLabel];
    
    //NSLog(@"Key ID: %@", visitInfo.keyID);
    keyIDLabel.numberOfLines = 2;
    [keyInfoButton setTitleColor:[colorPalette objectForKey:@"warning"] forState:UIControlStateNormal];
    [keyInfoButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [keyInfoButton setBackgroundImage:[UIImage imageNamed:@"bgDarkDefault"] forState:UIControlStateNormal];
    
    [keyIDLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
    [keyIDLabel setTextColor:[UIColor whiteColor]];
    
    if(visitInfo.noKeyRequired) {
        [hasKeyIcon setImage:[UIImage imageNamed:@"key-icon-60by60"]];
        keyIDLabel.textColor = [colorPalette objectForKey:@"warning"];
        [keyIDLabel setText:@"NO KEY REQUIRED"];
    }
    else {
        if (visitInfo.hasKey  &&
            !visitInfo.useKeyDescriptionInstead) {
        
            NSLog(@"Has key and not use key description instead");
            [hasKeyIcon setImage:[UIImage imageNamed:@"key-icon-60by60"]];
            keyIDLabel.text = visitInfo.keyID;
            keyIDLabel.textColor = [colorPalette objectForKey:@"warning"];
            
        } else if (visitInfo.hasKey &&
                   visitInfo.useKeyDescriptionInstead) {
            
            //NSLog(@"Has key and use key description instead");
            [hasKeyIcon setImage:[UIImage imageNamed:@"key-icon-60by60"]];
            
            if(![visitInfo.keyDescriptionText isEqual:[NSNull null]] && [visitInfo.keyDescriptionText length] > 0) {
                NSString *keyIDAndDescription = [NSString stringWithFormat:@"%@\n%@",visitInfo.keyID, visitInfo.keyDescriptionText];
                keyIDLabel.text = keyIDAndDescription;
            } else {
                keyIDLabel.text = @"NO DESCRIPTION";
            }
            keyIDLabel.textColor =[colorPalette objectForKey:@"warning"];
        } else {
            NSString *needKey;
            
            if ([visitInfo.keyID isEqual:[NSNull null]]) {
                visitInfo.keyID = @"NO KEY";
            }
            if ([visitInfo.keyID isEqualToString:@"NO KEY"]) {
                needKey  = @"NO KEY SET";
            } else {
                needKey = [NSString stringWithFormat:@"NEED: %@",visitInfo.keyID];                
            }
            [hasKeyIcon setImage:[UIImage imageNamed:@"need-key-icon-60by60"]];
            keyIDLabel.text = needKey;
            keyIDLabel.textColor = [colorPalette objectForKey:@"danger"];
        }
        
    }
}
-(void) createCompleteView:(UIView*)referenceView {
    
    if ([visitInfo.status isEqualToString:@"arrived"]) {
        
            
        UIButton *markCompleteButton = [self createButton:CGRectMake(referenceView.frame.size.width - 137, 5, 127, 50)
                                                       bImage:@"markCompleteBtn"
                                                        tagID:currentVisitID.integerValue];
            
            
        [markCompleteButton addTarget:self
                               action:@selector(markVisitComplete:)
                     forControlEvents:UIControlEventTouchUpInside];

        [referenceView addSubview:markCompleteButton];
        
        
        [self checkVisitTimerToUpdate];

    } 
    else if ([visitInfo.status isEqualToString:@"completed"]) {
                
        NSDate *completeStringToDate = [completeTimeFormat dateFromString:visitInfo.completed];
        NSString *cClean = [NSString stringWithFormat:@"%@ COMPLETED",[timeArriveFormat stringFromDate:completeStringToDate]];
        UILabel *completeLabel = [self createLabel:CGRectMake(42, 30, self.frame.size.width-20, 20) 
                                          withFont:[UIFont fontWithName:@"Lato-Light" size:24] 
                                           andText:cClean
                                      forTextColor:[UIColor blackColor]];
        [referenceView addSubview:completeLabel];
        
    } 
    else if ([visitInfo.status isEqualToString:@"future"] || [visitInfo.status isEqualToString:@"late"]) {
            UIButton *markCompleteButton = [self createButton:CGRectMake(referenceView.frame.size.width - 133, 5, 127, 50)
                                                       bImage:@"markCompleteBtn"
                                                        tagID:currentVisitID.integerValue];
        
            [referenceView addSubview:markCompleteButton]; 
        
    }
}

/*******************************************************************
 *                                                                                                                                           *
 *                               ACTION MAP                                                                                    *
 *                                                                                                                                           *
 ********************************************************************/                                                                                 

/* MAP VIEW ACTIONS*/

-(void) recreateMapSnapShot:(id)sender {}
 
-(void) viewLargeMap:(id)sender {
    
    if ([visitInfo isMapSnapShotImage]) {
        
        largeMapView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
        [largeMapView setBackgroundColor:[UIColor blackColor]];
        
        UIButton *dismissLargeMap = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissLargeMap.frame = CGRectMake(10, largeMapView.frame.size.height - 60, largeMapView.frame.size.width/2, 60);
        [dismissLargeMap setTitle:@"DISMISS" forState:UIControlStateNormal];
        [dismissLargeMap.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [dismissLargeMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dismissLargeMap setBackgroundColor:[UIColor blackColor]];
        [dismissLargeMap addTarget:self action:@selector(dismissMapView:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *recreateMap = [UIButton buttonWithType:UIButtonTypeCustom];
        recreateMap.frame = CGRectMake(dismissLargeMap.frame.origin.x + dismissLargeMap.frame.size.width, largeMapView.frame.size.height - 60, largeMapView.frame.size.width/2, 60);
        [recreateMap setTitle:@"RECREATE MAP" forState:UIControlStateNormal];
        [recreateMap.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [recreateMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [recreateMap setBackgroundColor:[UIColor blackColor]];
        [recreateMap addTarget:self 
                        action:@selector(recreateMapSnapShot:) 
              forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *mapImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, largeMapView.frame.size.width - 20, largeMapView.frame.size.width - 20)];
        [mapImage setImage:[visitInfo getMapImage]];
        [largeMapView addSubview:mapImage];
        [largeMapView addSubview:dismissLargeMap];
        [largeMapView addSubview:recreateMap];
        
        UIView *largeMapViewCopy = largeMapView;
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            largeMapViewCopy.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        largeMapView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height )];
        [largeMapView setBackgroundColor:[UIColor blackColor]];
        largeMapView.tag = 106;
        
        UIButton *dismissLargeMap = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissLargeMap.frame = CGRectMake(10, largeMapView.frame.size.height - 60, largeMapView.frame.size.width/2, 60);
        [dismissLargeMap setTitle:@"DISMISS" forState:UIControlStateNormal];
        [dismissLargeMap.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [dismissLargeMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dismissLargeMap setBackgroundColor:[UIColor blackColor]];
        [dismissLargeMap addTarget:self action:@selector(dismissMapView:) forControlEvents:UIControlEventTouchUpInside];
        
        mainMapView = [[VisitProgressMapView alloc]initWithFrame:CGRectMake(0,0, largeMapView.frame.size.width, largeMapView.frame.size.height )];
        [largeMapView addSubview:mainMapView];
        [mainMapView addVisitInfo:visitInfo];
        
        UIButton *drivingDirections = [UIButton buttonWithType:UIButtonTypeCustom];
        drivingDirections.frame = CGRectMake(dismissLargeMap.frame.origin.x + dismissLargeMap.frame.size.width - 20, largeMapView.frame.size.height - 60, largeMapView.frame.size.width/2, 60);
        [drivingDirections setTitle:@"DIRECTIONS" forState:UIControlStateNormal];
        [drivingDirections.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
        [drivingDirections setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [drivingDirections setBackgroundColor:[UIColor blackColor]];
        [drivingDirections addTarget:mainMapView action:@selector(drivingDirections:) forControlEvents:UIControlEventTouchUpInside];
        [largeMapView addSubview:drivingDirections];
        [largeMapView addSubview:dismissLargeMap];
        [self addSubview:largeMapView];
        
        int frameWidth = self.frame.size.width;
        int frameHeight = self.frame.size.height;
        UIView *largeMapViewCopy = largeMapView;
        
        [UIView animateWithDuration:0.3 delay:0.1 
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             largeMapViewCopy.frame = CGRectMake(0,0,frameWidth, frameHeight);
                         } completion:^(BOOL finished) {
                             
                         }];     
    }
}
-(void) dismissMapView:(id)sender {
    [mainMapView removeDelegate];
    [mainMapView removeFromSuperview];
    [largeMapView removeFromSuperview];
    mainMapView = nil;
    largeMapView = nil;
} 

/* ARRIVE VIEW ACTIONS*/

-(void) markArrive:(id)sender {    
    if([sender isKindOfClass:[UIButton class]]) {
        [parentViewRef markArriveButton:sender];
    }
}
-(void) updateArriveView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewsInitial];
    });

}

/* COMPLETE VIEW ACTIONS*/

-(void) markVisitComplete:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *completeButton = (UIButton*) sender;
        [parentViewRef markVisitComplete:completeButton];
    }
}
-(void) visitMarkedComplete {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewsInitial];
    });
    
}
-(void) sendVisitReport:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *visitReportButton = (UIButton*)sender;
        NSString *appointmentID = visitInfo.appointmentid;
            
        UIButton *sendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendingButton.frame = CGRectMake(visitReportButton.frame.origin.x, visitReportButton.frame.origin.y, visitReportButton.frame.size.width, visitReportButton.frame.size.height);
        [visitReportButton setTitle:@"SENDING..." forState:UIControlStateNormal];
        [visitReportButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [visitReportButton addSubview:sendingButton];
        [visitReportButton setAlpha:0.0];
        
        [parentViewRef sendVisitReportNoButton:appointmentID];
        
        [UIView animateWithDuration:2.0 animations:^{
            [visitReportButton setAlpha:3.0];
        } completion:^(BOOL finished) {
            [visitReportButton removeFromSuperview];            
        }];
           
    }
}

/* PHOTO VIEW ACTIONS*/

-(void) takePhotoAgain:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        NSArray *photoPreviewChildren = [photoEnlargeView subviews];
        
        for (int i = 0; i < [photoPreviewChildren count]; i++) {
            UIButton *child = (UIButton*) [photoPreviewChildren objectAtIndex:i] ;
            [child removeFromSuperview];
            child = nil;
        }        
        [photoEnlargeView removeFromSuperview];
        photoEnlargeView = nil;
        [self removeViews];        
        [parentViewRef goToPhotoTaker:sender];

    }
}
-(void) viewLargePhoto:(id)sender {
    
    if([sender isKindOfClass:[UIButton class]]) {
        
        photoEnlargeView = [[UIView alloc]initWithFrame:CGRectMake(0,self.frame.size.height, self.frame.size.width, self.frame.size.height)];
        [photoEnlargeView setBackgroundColor:[UIColor whiteColor]];
        photoEnlargeView.alpha = 0.85;
        int photoViewWidth = photoEnlargeView.frame.size.width - 20;
        
        UIImageView *petPicPreview = [[UIImageView alloc]initWithFrame:CGRectMake(20,20, photoViewWidth-40, photoViewWidth)];
        [petPicPreview setImage:[visitInfo getPetPhoto]];
        [photoEnlargeView addSubview:petPicPreview];
        [self addSubview:photoEnlargeView];

        UIButton *takeAgain = [UIButton buttonWithType:UIButtonTypeCustom];
        takeAgain.frame = CGRectMake(photoEnlargeView.frame.origin.x, photoEnlargeView.frame.size.height-30, photoEnlargeView.frame.size.width / 2- 20, 28);
        [takeAgain.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:24]];
        [takeAgain setTitle:@"TAKE AGAIN" forState:UIControlStateNormal];
        [takeAgain setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [takeAgain setBackgroundColor:[UIColor grayColor]];
        takeAgain.tag = currentVisitID.integerValue;
        [takeAgain addTarget:self 
                      action:@selector(takePhotoAgain:) 
            forControlEvents:UIControlEventTouchUpInside];
        [photoEnlargeView addSubview:takeAgain];
        
        UIButton *quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        quitButton.frame = CGRectMake(takeAgain.frame.size.width + 20, photoEnlargeView.frame.size.height-30, photoEnlargeView.frame.size.width / 2 -20, 28);
        [quitButton setTitle:@"QUIT" forState:UIControlStateNormal];
        [quitButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:24]];
        [quitButton setBackgroundColor:[UIColor grayColor]];
        [quitButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [quitButton addTarget:self 
                       action:@selector(dismissPhotoEnlarge:) 
             forControlEvents:UIControlEventTouchUpInside];
        [photoEnlargeView addSubview:quitButton];
        UIView *tempPhotoEnlarge = photoEnlargeView;
        [UIView animateWithDuration:0.3 delay:0.1 
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
            
            tempPhotoEnlarge.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
            
                         } completion:^(BOOL finished) {
                             
                         }];                                                                        
    }
}
-(void) dismissPhotoEnlarge:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        [photoEnlargeView removeFromSuperview];
        photoEnlargeView = nil;
    }
}
-(void) updatePhotoView {
    //NSLog(@"UPDATE PHOTO VIEW. VISIT: %@",visitInfo.appointmentid);
    //[self updateViewsInitial];
    NSArray *photoViewSub = [photoView subviews];
    for (id subView in photoViewSub) {
        [subView removeFromSuperview];
    }
    [self createPhotoView:photoView];
}

/* MOOD BUTTON VIEW ACTIONS*/

-(BOOL) moodButtonsSelected {
    if(visitInfo.didPee || visitInfo.didPoo || visitInfo.didPlay || visitInfo.didFeed || visitInfo.gaveTreat || visitInfo.gaveWater || visitInfo.gaveMedication || visitInfo.gaveInjection || visitInfo.dryTowel) {
        
        return YES;
        
    } else {
        
        return NO;
    
    }
}
-(void) showMoodView:(id)sender {
    
    UIView *moveMoodView = moodView;
    [UIView animateWithDuration:0.3 animations:^{
        moveMoodView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [moveMoodView bringSubviewToFront:self];
    }];
}

-(void) addMoodWithStatus {
    [self removeChildrenForView:moodButtonView];
    [self configureDateFormatters];
    [self checkVisitTimerToUpdate];
    
    
    int yButton = 10;;
    int xButton = 42;
    int tagID = 0;
    
    BOOL isMoodSelected = FALSE;
    for (NSDictionary *moodDic in moodButtonArray) {
        NSString *moodText = [moodDic objectForKey:@"Label"];
        UIImage *buttonImage = [UIImage imageNamed:[moodDic objectForKey:@"Filename"]];
        UIImage *buttonOnImage = [UIImage imageNamed:[moodDic objectForKey:@"Color"]];
        
        UIButton *moodButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moodButton.frame = CGRectMake(xButton,yButton,35,35);
        [moodButton setImage:buttonImage forState:UIControlStateNormal];
        [moodButton setImage:buttonOnImage forState:UIControlStateSelected];
        moodButton.tag = tagID;
        [moodButton addTarget:self
                       action:@selector(showMoodView:)
             forControlEvents:UIControlEventTouchUpInside];
    
        if([self checkVisitMood:moodText]) {
            [moodButton setSelected:YES];
            [moodButtonView addSubview:moodButton];
            isMoodSelected = TRUE;
            xButton += 38;
        }
        tagID++;
    }
    
    if(isMoodSelected) {
        UIButton *moodDone = [self createButton:CGRectMake(5,15,30, 30) 
                                         bImage:@"success" 
                                          tagID:currentVisitID.integerValue];
        moodDone.tag = 324;
        [moodDone setBackgroundImage:[UIImage imageNamed:@"btnSuccess"] 
                            forState:UIControlStateNormal];
        [moodDone addTarget:self
                     action:@selector(showMoodView:)
           forControlEvents:UIControlEventTouchUpInside];
        [moodButtonView addSubview:moodDone];
        [moodButtonView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    } else {
        //[self createMoodButtonView:moodButtonView];
    }
    UIButton *wholeViewMoodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    wholeViewMoodButton.tag = 325;
    wholeViewMoodButton.frame = CGRectMake(0, 0, moodButtonView.frame.size.width, moodButtonView.frame.size.height);
    wholeViewMoodButton.tag = currentVisitID.integerValue;
    [wholeViewMoodButton addTarget:self
                       action:@selector(showMoodView:)
             forControlEvents:UIControlEventTouchUpInside];
    [wholeViewMoodButton setBackgroundColor:[UIColor clearColor]];
    [moodButtonView addSubview:wholeViewMoodButton];
}
-(BOOL) checkVisitMood:(NSString *)moodDescription {
    
    if ([moodDescription isEqualToString:@"PEE"] && visitInfo.didPee) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"POO"] && visitInfo.didPoo) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"TREAT"] && visitInfo.gaveTreat) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"WATER"] && visitInfo.gaveWater) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"TOWEL"] && visitInfo.dryTowel) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"INJECTION"] && visitInfo.gaveInjection) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"MEDICATION"] && visitInfo.gaveMedication) {
        return TRUE;;
        
    } else if ([moodDescription isEqualToString:@"FEED"] && visitInfo.didFeed) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"PLAY"] && visitInfo.didPlay) {
        return TRUE;
    } else {
        return FALSE;
    }
}   
-(void) updateMoodView:(id)sender {
    
    [self addMoodWithStatus];

}

-(void) addNotificationObservers {
    __weak VisitProgressView* weakSelf = self;
    
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"photoFinishUpload"
                                                     object:nil
                                                      queue:[NSOperationQueue mainQueue]
                                                 usingBlock:^(NSNotification * _Nonnull note) {
        
        //[weakSelf updateViewsInitial];
        [weakSelf updatePhotoView];
        
        
    }];
 
    [[NSNotificationCenter defaultCenter]addObserverForName:@"sentVisitReport"
                                                     object:nil
                                                      queue:[NSOperationQueue mainQueue]
                                                 usingBlock:^(NSNotification * _Nonnull note) {
        
        
        
        [weakSelf updateViewsInitial];
        
    }];

    [[NSNotificationCenter defaultCenter]addObserverForName:@"sentMarkArrive"
                                                     object:nil
                                                      queue:[NSOperationQueue mainQueue]
                                                 usingBlock:^(NSNotification * _Nonnull note) {
        
        [weakSelf updateViewsInitial];
        
    }];
    /*[[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(visitMarkedComplete) 
                                                name:@"sentVisitComplete"
                                              object:nil];*/
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"sentVisitComplete"
                                                     object:nil
                                                      queue:[NSOperationQueue mainQueue]
                                                 usingBlock:^(NSNotification * _Nonnull note) {
        
        [weakSelf updateViewsInitial];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MarkComplete" object:self];

    }];
}

-(void) removeFinalView {
    
    [self removeFromSuperview];
    
}

-(UILabel*) createLabel:(CGRect) frameSize 
               withFont:(UIFont*)fontInfo 
                andText:(NSString*) textInfo 
           forTextColor:(UIColor*) colorText 
{
    
    UILabel *newLabel = [[UILabel alloc]initWithFrame:frameSize];
    [newLabel setFont:fontInfo];
    [newLabel setText:textInfo];
    [newLabel setTextColor:colorText];
    return newLabel;
    
}

-(UIButton*) createButton:(CGRect)frameSize 
                   bImage:(id)backgroundImage 
                    tagID:(long)tag 
{
    
    UIImage *backImage;
    if ([backgroundImage isKindOfClass:[UIImage class]]) {
        backImage  =(UIImage*)backgroundImage;
    } else if ([backgroundImage isKindOfClass:[NSString class]]) { 
        backImage = [UIImage imageNamed:(NSString*)backgroundImage];
    }
    UIButton *buttonCreated = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCreated.frame = frameSize;
    [buttonCreated setBackgroundImage:backImage forState:UIControlStateNormal];
    buttonCreated.tag = tag;
    
    return buttonCreated;
    
}
-(void) removeViews {
    
    [timerForVisitLabel removeFromSuperview];
    timerForVisitLabel = nil;
    [durationLabel removeFromSuperview];
    durationLabel = nil;
    
    [moodView removeFromSuperview];
    moodView = nil;
    NSArray *childView = self.subviews;
    
    for (int p=0 ; p < [childView count]; p++) {
        
        UIView *view = [childView objectAtIndex:p];
        NSArray *subViewsArray = view.subviews;
        
        
        for (int i=0; i < [subViewsArray count]; i++) {
            
            id subViewItem = [subViewsArray objectAtIndex:i];
            
            if ([subViewItem isKindOfClass:[UIButton class]]) {
                
                UIButton *subButton = (UIButton*) subViewItem;
                [subButton removeFromSuperview];
                
            } else if ([subViewItem isKindOfClass:[UILabel class]]) {        
                
                UILabel *subButton = (UILabel*) subViewItem;
                [subButton removeFromSuperview];
                
            } else if ([subViewItem isKindOfClass:[UIImageView class]]) {
                
                UIImageView *subButton = (UIImageView*) subViewItem;
                subButton.image = nil;
                [subButton removeFromSuperview];
                
            } else if ([subViewItem isKindOfClass:[UITextView class]]) {
                
                UITextView *subText = (UITextView*)subViewItem;
                [subText removeFromSuperview];
                
            } else if ([subViewItem isKindOfClass:[UIView class]]) {
                
                UIView *subText = (UIView*)subViewItem;
                NSArray *childsViews = subText.subviews;
                for (int p=0; p < [childsViews count]; p++) {
                    
                    id childViewItem = [childsViews objectAtIndex:p];
                    if ([childViewItem isKindOfClass:[UIView class]]) {
                        UIView *childViewRemove = (UIView*)childViewItem;
                        //NSLog(@"VIEW child with Tag id: %li and name: %@",(long)childViewRemove.tag, childViewRemove);
                        [childViewRemove removeFromSuperview];
                        
                    }
                }
                [subText removeFromSuperview];
                
            }  else { 
                //NSLog(@"View did not match any type: %@",subViewItem);
            }
        }
        
        
    }
    for (int s=0; s < [childView count]; s++) {
        UIView *subProgView = [childView objectAtIndex:s];
        [subProgView removeFromSuperview];
        subProgView = nil;
    }
}
-(void) removeChildrenForView:(UIView*)removeView {
    NSArray *completeChildren = removeView.subviews;
    for (int i = 0; i < [completeChildren count]; i++) {
        
        UIView *view = (UIView*) [completeChildren objectAtIndex:i];
        [view removeFromSuperview];
        view = nil;
    }
}
-(void) checkSendArriveStatus {
    
    if ([visitInfo.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
        [arriveView setBackgroundColor:[colorPalette objectForKey:@"danger"]];
        UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resendButton.frame = CGRectMake(arriveView.frame.size.width - 37, 15, 32,32);
        [resendButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] forState:UIControlStateNormal];
        [resendButton addTarget:self 
                         action:@selector(resendArrive:) 
               forControlEvents:UIControlEventTouchUpInside];
        resendButton.tag = currentVisitID.integerValue;
        [arriveView addSubview:resendButton];     
    } else if ([visitInfo.currentArriveVisitStatus isEqualToString:@"SUCCESS"]) {
        [arriveView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    } else if([visitInfo.status isEqualToString:@"arrived"]) {
        [arriveView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    } else {
        [arriveView setBackgroundColor:[colorPalette objectForKey:@"infoDark"]];
    }
     
}
-(void) checkSendCompleteStatus {
    //NSLog(@"COMPLETE VIEW WITH VISIT STATUS: %@", visitInfo.status);
    if ([visitInfo.currentCompleteVisitStatus isEqualToString:@"FAIL"]) {
        [completeView setBackgroundColor:[colorPalette objectForKey:@"danger"]];
    } else if ([visitInfo.currentCompleteVisitStatus isEqualToString:@"SUCCESS"]) {
        [completeView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    } else {
        if ([visitInfo.status isEqualToString:@"arrived"]) {
            [completeView setBackgroundColor:[colorPalette objectForKey:@"infoDark"]];
        } else if ([visitInfo.status isEqualToString:@"future"] || [visitInfo.status isEqualToString:@"late"]) {
            [completeView setBackgroundColor:[colorPalette objectForKey:@"defaultDark"]];
        } else {
            [completeView setBackgroundColor:[colorPalette objectForKey:@"success"]];
        }
    }
}
-(void) resendPhoto:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *resendPhotoButton = (UIButton*)sender;
        NSString *visitIDString =[NSString stringWithFormat:@"%li", (long)resendPhotoButton.tag];
        if ([visitIDString isEqualToString:visitInfo.appointmentid]) {
            [visitInfo resendImageForPet];
            
        }
    }
}
-(void) resendMapSnapshot:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *resendMapSnapButton = (UIButton*)sender;
        NSString *visitIDString =[NSString stringWithFormat:@"%lu", resendMapSnapButton.tag];
        if ([visitIDString isEqualToString:visitInfo.appointmentid]) {
            [visitInfo resendMapSnapShot];
        }
    }
    
}
-(void) checkPhotoUploadStatus {
    
    if ([visitInfo.imageUploadStatus isEqualToString:@"FAIL"]) {
            
        [photoView setBackgroundColor:[colorPalette objectForKey:@"dangerDark"]];
        UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resendButton.frame = CGRectMake(5, 15, 30,30);
        [resendButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] forState:UIControlStateNormal];
        [resendButton addTarget:self 
                         action:@selector(resendPhoto:) 
               forControlEvents:UIControlEventTouchUpInside];
        resendButton.tag = currentVisitID.integerValue;
        [photoView addSubview:resendButton];        
        
    } else if ([visitInfo.imageUploadStatus isEqualToString:@"SUCCESS"]) {
        
        [photoView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
        
    } else {
        if([visitInfo.status isEqualToString:@"arrived"] && [visitInfo isPetImage]) {
        
            [photoView setBackgroundColor:[colorPalette objectForKey:@"infoDark"]];
            
        } else if ([visitInfo.status isEqualToString:@"completed"] && [visitInfo isPetImage]) {
            
            [photoView setBackgroundColor:[colorPalette objectForKey:@"warningDark"]];
        } else {
            
            [photoView setBackgroundColor:[colorPalette objectForKey:@"defaultDark"]];

        }
    }
    
}
-(void) checkMoodViewStatus {
    //NSLog(@"MOOD VIEW STATUS: %@", visitInfo.imageUploadStatus);
    
    if(visitInfo.didPee || visitInfo.didPoo || visitInfo.didPlay || visitInfo.didFeed || visitInfo.gaveTreat || visitInfo.gaveWater || visitInfo.gaveMedication || visitInfo.gaveInjection || visitInfo.dryTowel) {
        
        [moodView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
        
    } else {
        
        if ([visitInfo.status isEqualToString:@"completed"]) {
            [moodButtonView setBackgroundColor:[colorPalette objectForKey:@"warningDark"]];
        } else if ([visitInfo.status isEqualToString:@"arrived"]) {
            [moodButtonView setBackgroundColor:[colorPalette objectForKey:@"infoDark"]];
        } else {
            
            [moodButtonView setBackgroundColor:[colorPalette objectForKey:@"defaultDark"]];
            
        }
        
    }
    
}
-(void) checkNoteViewStatus {
        
    if(![visitInfo.visitNoteBySitter isEqual:[NSNull null]] && [visitInfo.visitNoteBySitter length] > 0) {
                
        [self removeChildrenForView:noteView];
        [self createNoteView:noteView];
        [noteView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    
    } else {
        if ([visitInfo.status isEqualToString:@"completed"]) {
            if ([visitInfo.visitReportUploadStatus isEqualToString:@"FAIL"]) {
                [noteView setBackgroundColor:[colorPalette objectForKey:@"dangerDark"]];
            } else {
                [noteView setBackgroundColor:[colorPalette objectForKey:@"warningDark"]];
            }
        } else if([visitInfo.status isEqualToString:@"arrived"]) {
            [noteView setBackgroundColor:[colorPalette objectForKey:@"infoDark"]];
        } else {
            [noteView setBackgroundColor:[colorPalette objectForKey:@"defaultDark"]];

        }
    }
}
-(void) checkVisitReportUploadStatus {
    if ([visitInfo.visitReportUploadStatus isEqualToString:@"FAIL"]) {
        UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resendButton.frame = CGRectMake(5, 15, 30,30);
        [resendButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] forState:UIControlStateNormal];
        [resendButton addTarget:parentViewRef 
                         action:@selector(resendVisitReport:) 
               forControlEvents:UIControlEventTouchUpInside];
        resendButton.tag = currentVisitID.integerValue;
        [photoView addSubview:resendButton];   
    } 
    
}
-(void) checkMapUploadStatus {
    if ([visitInfo.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
        
    } else if ([visitInfo.currentArriveVisitStatus isEqualToString:@"SUCCESS"]) {
        
    }
}

@end
