//
//  VisitReportFinalView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 12/27/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import "VisitReportFinalView.h"
#import "VisitsAndTracking.h"

@interface VisitReportFinalView() {

    VisitsAndTracking *sharedVisits;
    VisitDetails *visitInfo;
    DataClient *clientInfo;
    __weak VisitProgressView *visitProgressView;
    
    NSDateFormatter  *arriveTimeFormat;
    NSDateFormatter *arriveCompleteTimeFormat;
    NSMutableDictionary *colorPalette;

    UIView *petPhotoView;
    UIButton *petPhoto;
    NSNumber *currentVisitID;
    int char_per_line;
    int globalFontSize;    
    int borderWidth;
    float moodViewHeight;
    float headerHeight;

    UIButton *mapSnapImageButton;

}

@end

@implementation VisitReportFinalView

-(instancetype)initWithFrame:(CGRect)frame 
                   visitInfo:(VisitDetails*)visit 
                  clientInfo:(DataClient*)client 
                  parentView:(VisitProgressView*)parent {
    
    
    sharedVisits = [VisitsAndTracking sharedInstance];
    colorPalette = [sharedVisits getColorPalette];
    visitInfo = visit;
    visitProgressView = parent;
    currentVisitID =[[[NSNumberFormatter alloc] init] numberFromString:visitInfo.appointmentid];
    clientInfo = client;

    arriveTimeFormat = [[NSDateFormatter alloc]init];
    [arriveTimeFormat setDateFormat:@"h:mm a"];

    arriveCompleteTimeFormat = [[NSDateFormatter alloc]init];
    [arriveCompleteTimeFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(addMapImage)
                                                name:@"uploadMapSnapShot"
                                              object:nil];
    
    return [self initWithFrame:frame];
    
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];

    if (self) {
        
        char_per_line = 30;
        borderWidth = 1;
        moodViewHeight = 60;
        headerHeight = 80;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView *finalPreviewView = [[UIView alloc]initWithFrame:CGRectMake(20, frame.size.height, frame.size.width, frame.size.height)];
        [finalPreviewView setBackgroundColor:[UIColor whiteColor]];
        if([visitInfo.status isEqualToString:@"completed"] && visitInfo.dateTimeVisitReportSubmit != nil) {
            
            [finalPreviewView setBackgroundColor:[colorPalette objectForKey:@"successDark"]];    
            [self createSentVisitReportView:finalPreviewView];
            [self buildSentVisitReportView:finalPreviewView];
            
        } else {            
            [finalPreviewView setBackgroundColor:[colorPalette objectForKey:@"infoWarning"]];    
            [self createPreviewVisitReportView:finalPreviewView];
        }

        [self addSubview:finalPreviewView];

        [UIView animateWithDuration:0.2 animations:^{
            finalPreviewView.frame = CGRectMake(0,0,self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {   
            
        }];    
    }
    
    return self;
}

-(void) addMapImage {
    
    if([visitInfo isMapSnapShotImage]) {

        VisitDetails *localVisitInfo = visitInfo;
        UIButton *tempBtn = mapSnapImageButton;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tempBtn setBackgroundImage:[localVisitInfo getMapImage] forState:UIControlStateNormal];
            [self checkMapUploadStatus:tempBtn];
        });

        [[NSNotificationCenter defaultCenter]removeObserver:self
                                                       name:@"uploadMapSnapShot"
                                                     object:nil];
        
    }
}

-(void)createSentVisitReportView:(UIView*)baseView {
    
    float offsetReportFromBase = 100;
    
    UIView *reportView = [[UIView alloc]initWithFrame:CGRectMake(40, 80, baseView.frame.size.width-80, baseView.frame.size.height -offsetReportFromBase)];    
    UIView *reportBorder = [self createReportBorder:reportView];
    
    [self buildHeaderInfo:reportView withStatus:@"sent" andHeight:headerHeight];
    
    petPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    petPhoto.frame = CGRectMake(10, 74, reportView.frame.size.width - 20, reportView.frame.size.width - 20);
    
     float noteViewHeight = baseView.frame.size.height - petPhoto.frame.size.height - moodViewHeight - headerHeight - offsetReportFromBase - 30;
    
     UIView *finalNoteView = [[UIView alloc]initWithFrame:CGRectMake(
                                                                     petPhoto.frame.origin.x,
                                                                     petPhoto.frame.size.height  + moodViewHeight + headerHeight, 
                                                                     petPhoto.frame.size.width, 
                                                                     noteViewHeight)];
    
    
     UITextView *finalNoteTextField = [[UITextView alloc]initWithFrame:CGRectMake(1,1, finalNoteView.frame.size.width-2, finalNoteView.frame.size.height-2)];

    [reportBorder setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    [reportView setBackgroundColor:[colorPalette objectForKey:@"success"]];
    [finalNoteView setBackgroundColor:[UIColor lightGrayColor]];
    [finalNoteTextField setBackgroundColor:[UIColor whiteColor]];
    finalNoteTextField.font = [UIFont fontWithName:@"Lato-Regular" size:18];
    finalNoteTextField.delegate = nil;
    
    if (visitInfo.visitNoteBySitter != nil) {
           [finalNoteTextField setText:visitInfo.visitNoteBySitter];
       } else {
           [finalNoteTextField setText:@"Dear Client,\n\nWe had a great visit today.\n\nBest regards"];
       }
       
       if([visitInfo isPetImage]) {
           [petPhoto setImage:[visitInfo getPetPhoto] 
                               forState:UIControlStateNormal];
           
           [petPhoto addTarget:visitProgressView 
                        action:@selector(viewLargePhoto:)
              forControlEvents:UIControlEventTouchUpInside];
           petPhoto.tag = currentVisitID.integerValue;
       } 
       else {
           [petPhoto setBackgroundImage:[UIImage imageNamed:@"camera-icon-100"] 
                               forState:UIControlStateNormal];
           [petPhoto addTarget:visitProgressView 
                        action:@selector(goToPhotoTaker:) 
              forControlEvents:UIControlEventTouchUpInside];
           petPhoto.tag = currentVisitID.integerValue;
       }
    
    [self checkPhotoUploadStatusWithView:petPhoto];
    
    [self addMoodButtonsToFinalView:reportView 
                         withYStart:petPhoto.frame.origin.y + petPhoto.frame.size.height + 8];
    
    
    [self addMapIconFinalView:reportView atYPostion:petPhoto.frame.origin.y + petPhoto.frame.size.height + 4];
    
    [baseView addSubview:reportBorder];
    [finalNoteView addSubview:finalNoteTextField];
    [reportView addSubview:petPhoto];
    [reportView addSubview:finalNoteView];
    [baseView addSubview: reportView];
    
}

-(void)createPreviewVisitReportView:(UIView*)baseView {
    
    float offsetReportFromBase = 45;

    UIView*reportView = [[UIView alloc]initWithFrame:CGRectMake(40, 90, baseView.frame.size.width-80, baseView.frame.size.height -120)];
    
    UIView *reportBorder = [self createReportBorder:reportView];

    [self buildHeaderInfo:reportView withStatus:@"review" andHeight:80];
    [self addButtonInfoFinalView:baseView relativeReportView:reportView];
    
    petPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    petPhoto.frame = CGRectMake(10, 74, reportView.frame.size.width - 20, reportView.frame.size.width - 20);
    petPhoto.tag = 0;
    
    float noteViewHeight = baseView.frame.size.height -  petPhoto.frame.size.height - moodViewHeight - headerHeight - offsetReportFromBase - reportView.frame.origin.y;
        
    
    UIView *finalNoteView = [[UIView alloc]initWithFrame:CGRectMake(
                                                                        petPhoto.frame.origin.x,
                                                                        petPhoto.frame.size.height + moodViewHeight + headerHeight, 
                                                                        petPhoto.frame.size.width, 
                                                                        noteViewHeight)];
    
    
    UITextView *finalNoteTextField = [[UITextView alloc]initWithFrame:CGRectMake(1,1, finalNoteView.frame.size.width-2, finalNoteView.frame.size.height-2)];

    [reportBorder setBackgroundColor:[colorPalette objectForKey:@"successDark"]];
    [reportView setBackgroundColor:[colorPalette objectForKey:@"success"]];
    [finalNoteView setBackgroundColor:[UIColor lightGrayColor]];
    [finalNoteTextField setBackgroundColor:[UIColor whiteColor]];
        
    finalNoteTextField.font = [UIFont fontWithName:@"Lato-Regular" size:18];
    finalNoteTextField.delegate = nil;
    
    if (visitInfo.visitNoteBySitter != nil) {

        [finalNoteTextField setText:visitInfo.visitNoteBySitter];

    } else {

        [finalNoteTextField setText:@"Dear Client,\n\nWe had a great visit today.\n\nBest regards"];

    }
          

    if([visitInfo isPetImage]) {

        [petPhoto setImage:[visitInfo getPetPhoto] 
                                  forState:UIControlStateNormal];
        [petPhoto addTarget:visitProgressView 
                           action:@selector(viewLargePhoto:) 
                 forControlEvents:UIControlEventTouchUpInside];
              
        petPhoto.tag = currentVisitID.integerValue;

    } 

    else {

        [petPhoto setBackgroundImage:[UIImage imageNamed:@"camera-icon-100"] 
                                  forState:UIControlStateNormal];

        [petPhoto addTarget:visitProgressView 
                           action:@selector(goToPhotoTaker:) 
                 forControlEvents:UIControlEventTouchUpInside];

        petPhoto.tag = currentVisitID.integerValue;

    }
    [self checkPhotoUploadStatusWithView:petPhoto];
    
    [self addMoodButtonsToFinalView:reportView 
                            withYStart:petPhoto.frame.origin.y + petPhoto.frame.size.height + 8];
    [self addMapIconFinalView:reportView 
                      atYPostion:petPhoto.frame.origin.y + petPhoto.frame.size.height + 4];
    
    [baseView addSubview:reportBorder];
    [finalNoteView addSubview:finalNoteTextField];
    [reportView addSubview:petPhoto];
    [reportView addSubview:finalNoteView];
    [baseView addSubview: reportView];
}

-(void) buildHeaderInfo:(UIView*)baseView withStatus:(NSString*)status andHeight:(int)headerHeight {
    
    if ([status isEqualToString:@"sent"]) {
        
        UIImageView *background = [[UIImageView alloc]initWithFrame:CGRectMake(5,0, baseView.frame.size.width-7, 100)];
        [background setImage:[UIImage imageNamed:@"bright-green-bar"]];
        [baseView addSubview:background];
        
    } else {
        UIImageView *background = [[UIImageView alloc]initWithFrame:CGRectMake(5,0, baseView.frame.size.width-7, 100)];
        [background setImage:[UIImage imageNamed:@"bright-green-bar"]];
        [baseView addSubview:background];
        
    }
    
    UILabel *petCareReport = [[UILabel alloc]initWithFrame:CGRectMake(0, 4, baseView.frame.size.width, 18)];
    [petCareReport setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
    [petCareReport setTextColor:[UIColor blackColor]];
    NSString *headerString = [NSString stringWithFormat:@"CARE REPORT"];
    petCareReport.numberOfLines = 2;
    [petCareReport setText:headerString];
    [petCareReport setTextAlignment:NSTextAlignmentCenter];
    [baseView addSubview:petCareReport];
    
    UILabel *petName = [[UILabel alloc]initWithFrame:CGRectMake(20,20,baseView.frame.size.width - 40, 20)];
    [petName setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [petName setTextColor:[UIColor blackColor]];
    [petName setText:visitInfo.petName];
    [baseView addSubview:petName];
    
    UILabel *startTimeEndTime = [[UILabel alloc] initWithFrame:CGRectMake(20, petName.frame.size.height + petName.frame.origin.y + 4, baseView.frame.size.width -40, 20)];
    
    [startTimeEndTime setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
    [startTimeEndTime setTextColor:[UIColor blackColor]];
    
    NSDate *stringToDate = [arriveCompleteTimeFormat dateFromString:visitInfo.arrived]; // HH:mm:ss MMM dd yyyy
    
    if ([stringToDate isEqual:[NSNull null]]) {
        stringToDate = [sharedVisits getDateFromStringArriveComplete:visitInfo.arrived]; // yyyy-MM-dd HH:mm:ss
    }

    NSString *startTimeFormat =  [NSString stringWithFormat:@"%@", [arriveTimeFormat stringFromDate:stringToDate]];
    
    NSDate *completeStringDate = [arriveCompleteTimeFormat dateFromString:visitInfo.completed];
    if([completeStringDate isEqual:[NSNull null]]) {
        completeStringDate = [sharedVisits getDateFromStringArriveComplete:visitInfo.completed];
    }
    
    
    NSString *endTimeFormat =  [NSString stringWithFormat:@"%@", [arriveTimeFormat stringFromDate:completeStringDate]];
    NSString *visitTimeString = [NSString stringWithFormat:@"%@ - %@ (%@)" , startTimeFormat, endTimeFormat,visitInfo.service];
    
    [startTimeEndTime setText:visitTimeString];
    [baseView addSubview:startTimeEndTime];
    
    
}

-(void) buildSentVisitReportView:(UIView*)finalView {
    
    [finalView setBackgroundColor:[UIColor darkGrayColor]];
    UILabel *lastSentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,48  , finalView.frame.size.width,16)];
    lastSentLabel.numberOfLines = 2;
    [lastSentLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
    [lastSentLabel setTextColor:[UIColor whiteColor]];
    lastSentLabel.textAlignment = NSTextAlignmentCenter;
    if([visitInfo.dateTimeVisitReportSubmit isEqual:[NSNull null]] && [visitInfo.dateTimeVisitReportSubmit length] == 0) {

        [lastSentLabel setText:@"VISIT REPORT HAS NOT BEEN SENT YET!"];
         
    } else if([visitInfo.visitReportUploadStatus isEqualToString:@"FAIL"]) {
        
        [lastSentLabel setText:@"VISIT REPORT FAIL UPLOAD"];
        [lastSentLabel setTextColor:[UIColor redColor]];
        
    } else {
        
        NSString *sentLabelText = [NSString stringWithFormat:@" VISIT REPORT SENT: %@", visitInfo.dateTimeVisitReportSubmit];    
        [lastSentLabel setText:sentLabelText];
        
    }    
    [self checkVisitReportUploadStatus:finalView];
    
    [finalView addSubview:lastSentLabel];
    
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.frame = CGRectMake(2, 35, 32,32);
    [exitButton setBackgroundImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    [exitButton addTarget:visitProgressView 
                   action:@selector(dismissReportView:) 
         forControlEvents:UIControlEventTouchUpInside];
    [finalView addSubview:exitButton];
    
}

-(void) addMapIconFinalView:(UIView *)targetView atYPostion:(int)y {
    
    //UIImageView *mapImageView = [[UIImageView alloc]initWithFrame:CGRectMake(targetView.frame.size.width - 60, y, 80,80)];
    
    mapSnapImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapSnapImageButton.frame = CGRectMake(targetView.frame.size.width - 60, y, 50, 50);
    mapSnapImageButton.tag = 1;
    [mapSnapImageButton addTarget:self
                           action:@selector(swapMapPhoto:)
                 forControlEvents:UIControlEventTouchUpInside];
    [targetView addSubview:mapSnapImageButton];
    [self checkMapUploadStatus:mapSnapImageButton];

    
    if([visitInfo getMapImage] != nil) {
        [mapSnapImageButton setBackgroundImage:[visitInfo getMapImage] forState:UIControlStateNormal];
    }
}

-(void) swapMapPhoto:(id)sender {
    
    if([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *mapButton = (UIButton*)sender;
        if (mapButton.tag == 1) {
            [mapButton setImage:[visitInfo getPetPhoto] forState:UIControlStateNormal];
            [petPhoto setImage:[visitInfo getMapImage] forState:UIControlStateNormal];
            mapButton.tag = 0;
        } else {
            [mapButton setImage:[visitInfo getMapImage] forState:UIControlStateNormal];
            [petPhoto setImage:[visitInfo getPetPhoto]
                      forState:UIControlStateNormal];
            mapButton.tag = 1;
        }
}
    
}

-(void) addMoodButtonsToFinalView:(UIView*) detailsView withYStart:(int)yM {
    NSString *pListData = [[NSBundle mainBundle]
                           pathForResource:@"MoodButtons"
                           ofType:@"plist"];
    NSMutableArray *moodButtonArray = [[NSMutableArray alloc]initWithContentsOfFile:pListData];
    int moodCount = 1;
    int moodFactorX = 42;
    for (NSDictionary *moodDic in moodButtonArray) {
        NSString *moodText = [moodDic objectForKey:@"Label"];
        if([self checkVisitMood:moodText]) {
            
            UIImage *buttonOnImage = [UIImage imageNamed:[moodDic objectForKey:@"Color"]];
            UIButton *moodNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            if (moodCount == 1) {
                
                moodNoteButton.frame = CGRectMake(20, yM, 50, 50);
                
            } else{
                moodNoteButton.frame = CGRectMake((moodCount * moodFactorX) + 4, yM, 50, 50);

            }
            [moodNoteButton setBackgroundImage:buttonOnImage forState:UIControlStateNormal];
            [detailsView addSubview:moodNoteButton];
            moodCount++;
        }
    }
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
        return TRUE;
    } else if ([moodDescription isEqualToString:@"FEED"] && visitInfo.didFeed) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"PLAY"] && visitInfo.didPlay) {
        return TRUE;
    } else {
        return FALSE;
    }
}   

-(void) addButtonInfoFinalView:(UIView*)finalView relativeReportView:(UIView*)relativeReportView{
    
    //float offsetTop = relativeReportView.frame.origin.y;
    float padding = 40;
    float yPosition = 35;
    float leftOffset = padding;
    //float rightOffset = padding * 2;
    float availableWidth = relativeReportView.frame.size.width;
    float buttonWidth = availableWidth / 3;
    float buttonHeight = buttonWidth / 2.5;
    //float buttonWidth = 110;
    //float buttonHeight = 36;
    
    UIButton *goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *sendVisitReport = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    goBackButton.frame = CGRectMake(leftOffset,yPosition, buttonWidth - 2, buttonHeight);
    sendVisitReport.frame = CGRectMake(goBackButton.frame.origin.x + goBackButton.frame.size.width + 2, yPosition,buttonWidth - 2, buttonHeight);
    editButton.frame = CGRectMake(sendVisitReport.frame.origin.x + sendVisitReport.frame.size.width + 2, yPosition, buttonWidth - 2, buttonHeight);
        
    [goBackButton setBackgroundImage:[UIImage imageNamed:@"btn-save-active"] 
                            forState:UIControlStateNormal];
    
    [sendVisitReport setBackgroundImage:[UIImage imageNamed:@"btn-send-active"] 
                                       forState:UIControlStateNormal];
    
    [editButton setBackgroundColor:[colorPalette objectForKey:@"warning"]];
    [editButton setBackgroundImage:[UIImage imageNamed:@"btn-edit-active"] forState:UIControlStateNormal];
     
    [editButton addTarget:visitProgressView 
                   action:@selector(updateViewsInitial)
         forControlEvents:UIControlEventTouchUpInside];
    
    [goBackButton addTarget:self 
                     action:@selector(dismissReportView:) 
           forControlEvents:UIControlEventTouchUpInside];
    
    [sendVisitReport addTarget:visitProgressView 
                                action:@selector(sendVisitReport:) 
                      forControlEvents:UIControlEventTouchUpInside];

    [finalView addSubview:goBackButton];
    [finalView addSubview:sendVisitReport];
    [finalView addSubview:editButton];
    
}

-(void) dismissReportView:(id)sender {
    
    sharedVisits.onWhichVisitID = visitInfo.appointmentid;
  
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateTable" object:self];
    
    NSArray *petPhotoSubviews = [petPhotoView subviews];
    for (id photoSubview in petPhotoSubviews) {
        if ([photoSubview isKindOfClass:[UIImageView class]]) {
            UIImageView *photoImageSubview = (UIImageView*) photoSubview;
            [photoImageSubview setImage:nil];
            [photoImageSubview removeFromSuperview];
            photoImageSubview = nil;
        }
    }
    
    NSArray *children = [self subviews];
       
    for (int i= 0; i < [children count]; i++ ) {
        
        id child = [children objectAtIndex:i];
        
        if ([child isKindOfClass:[UILabel class]]) {
            
            UILabel *rLabel = (UILabel*)child;
            [rLabel removeFromSuperview];
            rLabel = nil;
            
        } else  if ([child isKindOfClass:[UIButton class]]) {
            UIButton *rButton = (UIButton*)child;
            [rButton removeFromSuperview];
            rButton = nil;
            
        } else  if ([child isKindOfClass:[UIImageView class]]) {
            UIImageView *rImg = (UIImageView*)child;
            [rImg removeFromSuperview];
            rImg = nil;
            
        } else  if ([child isKindOfClass:[UITextField class]]) {
            UITextField *rTxt = (UITextField*)child;
            [rTxt removeFromSuperview];
            rTxt = nil;
        } else  if ([child isKindOfClass:[UIView class]]) {
            UIView *rTxt = (UIView*)child;
            [rTxt removeFromSuperview];
            rTxt = nil;
        } 
    }
    
    [self removeFromSuperview];
    [visitProgressView removeFinalView];
}

-(UIView*)createPetPhotoView:(UIView*)baseView {
    
    petPhotoView = [[UIView alloc]initWithFrame:CGRectMake(10,72, baseView.frame.size.width - 20, baseView.frame.size.width - 20)];
    return petPhotoView;
    
}
-(UIView*)createNoteView:(UIView*)baseView {
    
    UIView *noteView = [[UIView alloc]initWithFrame:CGRectMake(10,72, baseView.frame.size.width - 20, baseView.frame.size.width - 20)];
    return noteView;
}
-(UIView*)createReportBorder:(UIView*)baseView {
    
    UIView*reportBorder = [[UIView alloc]initWithFrame:CGRectMake(
                                                                  baseView.frame.origin.x -borderWidth,
                                                                  baseView.frame.origin.y - borderWidth,     
                                                                  baseView.frame.size.width  + (borderWidth),
                                                                  baseView.frame.size.height+ (borderWidth))];
    return reportBorder;
    
}

-(void) checkPhotoUploadStatusWithView:(UIView*)baseView  {
    
    if([visitInfo.imageUploadStatus isEqualToString:@"FAIL"]) {
        
        UIButton *warnResendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        warnResendButton.frame = CGRectMake(baseView.frame.size.width - 50, baseView.frame.size.height - 50, 50,50);
        [warnResendButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] forState:UIControlStateNormal];
        [baseView addSubview:warnResendButton];
        
    } 
}
-(void) checkMapUploadStatus:(UIView*)baseView {
    if ([visitInfo.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
        UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resendButton.frame = CGRectMake(0, 0, baseView.frame.size.width,baseView.frame.size.height);
        [resendButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] forState:UIControlStateNormal];
        resendButton.alpha = 0.25;
        [baseView addSubview:resendButton];
    }
}
-(void) checkNoteViewStatusWithView:(UIView*)baseView  {
        
    if(![visitInfo.visitNoteBySitter isEqual:[NSNull null]] && [visitInfo.visitNoteBySitter length] > 0) {
                
        UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resendButton.frame = CGRectMake(baseView.frame.size.width - 60, baseView.frame.size.height - 60, 50,50);
        [resendButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] forState:UIControlStateNormal];
        [baseView addSubview:resendButton];
    } 
}
-(void) checkVisitReportUploadStatus:(UIView*)baseView {
    
    if ([visitInfo.visitReportUploadStatus isEqualToString:@"FAIL"]) {
        
        UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resendButton.frame = CGRectMake(5, self.frame.size.height - 35, 30, 30);
        [resendButton setBackgroundImage:[UIImage imageNamed:@"btnResend"] forState:UIControlStateNormal];
        [resendButton addTarget:visitProgressView 
                         action:@selector(resendVisitReport:) 
               forControlEvents:UIControlEventTouchUpInside];
        resendButton.tag = currentVisitID.integerValue;
        [baseView addSubview:resendButton];
        
    } 
}

-(UIButton*) createButton:(CGRect)  frameSize bImage:(id)backgroundImage tagID:(long)tag 
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
@end
