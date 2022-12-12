 //
//  ClientListViewController.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/19/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitsAndTracking.h"
#import "DetailAccordionViewController.h"

@interface ClientListViewController : UIViewController 


-(void) foregroundPollingUpdate;
-(void) applicationEnterBackground;

-(void) tapDetailView:(id)sender;
-(void) showManagerNote:(id)sender;
-(void) goToPhotoTaker:(id)sender;
-(void) showDocAttach:(id)sender;
-(void) showMultiDocAttach:(id)sender;

-(void) showAlarmCodeDetailView:(id)sender;
-(void) showKeyHomeInfo:(id)sender;
-(void) showHomeInfo:(id)sender;

//-(void) sendVisitReport:(NSString*)visitID withButton:(id)sender;
-(void) sendVisitReportNoButton:(NSString*) visitID;
-(void) markArriveButton:(id)sender; 
-(void) markVisitComplete:(id)sender;
-(void) resendArrive:(id)sender;
-(void) resendComplete:(id)sender;

@end
