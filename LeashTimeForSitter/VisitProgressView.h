//
//  VisitProgressView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 10/3/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import "ClientListViewController.h"
#import <UIKit/UIKit.h>


@interface VisitProgressView : UIView

-(instancetype)initWithFrame:(CGRect)frame 
                   visitInfo:(VisitDetails*)visit 
                  clientInfo:(DataClient*)client 
                  parentView:(ClientListViewController*)parent;

-(void) updateMoodView:(id)sender;
-(void) dismissReportView:(id)sender;
-(void) sendVisitReport:(id)sender;
-(void) viewLargeMap:(id)sender;
-(void) removeFinalView;
-(void) updateViewsInitial;
-(void) goToPhotoTaker:(id)sender;

@end

