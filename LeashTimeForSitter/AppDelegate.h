//
//  AppDelegate.h
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 6/19/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "LocationShareModel.h"
#import "LocationTracker.h"
#import "VisitsAndTracking.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong,nonatomic) UIWindow *window;
@property LocationShareModel *shareModel;
@property (nonatomic,strong) VisitsAndTracking *sharedVisits;
@property (strong,nonatomic) ViewController *viewController;
@property (strong,nonatomic) LocationTracker *locationTracker;


@end

