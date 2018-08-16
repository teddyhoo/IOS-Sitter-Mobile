 //
//  ClientListViewController.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/19/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "VisitsAndTracking.h"
#import "DetailAccordionViewController.h"
//@import UserNotifications;

@interface ClientListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate>

@property(nonatomic,strong)UITableView *tableView;


-(void)getUpdatedVisitsForToday;
-(void)foregroundPollingUpdate;
-(void) setupListView;

@end
