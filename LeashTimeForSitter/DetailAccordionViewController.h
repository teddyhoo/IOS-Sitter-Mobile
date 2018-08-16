//
//  DetailAccordionViewController.h
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 12/23/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "EMAccordionTableViewController.h"
#import "VisitDetails.h"
#import "DataClient.h"

@interface DetailAccordionViewController : UIViewController <EMAccordionTableDelegate,MFMessageComposeViewControllerDelegate>


@property (nonatomic,strong) EMAccordionTableViewController *emTV;
@property (nonatomic,strong) EMAccordionTableParallaxHeaderView *emParallaxHeaderView;
@property float cellHeight;

-(void)setClientAndVisitID:(DataClient*)clientID visitID:(VisitDetails*)visitID;



@end
