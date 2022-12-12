//
//  AppDelegate.m
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 6/19/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice-Hardware.h"
#import <UIKit/UIKit.h>
#import "LocationShareModel.h"
#import "LocationTracker.h"
#import "VisitsAndTracking.h"
#import "ClientListViewController.h"


@interface AppDelegate () {
    
    LocationTracker *locationTracker;
    ClientListViewController *viewController;
    UIWindow *window;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [VisitsAndTracking sharedInstance].firstLogin = NO;
    [VisitsAndTracking sharedInstance].appRunningBackground = NO;
    
	[self determinePhoneModel];
    [self setUserAgent];
     
    window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    viewController = [[ClientListViewController alloc]init];   
    window.rootViewController  = viewController;
    [window makeKeyAndVisible];
    
    locationTracker = [LocationTracker sharedLocationManager];

    return YES;

}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    bool isOnArriveVisit = FALSE;
    for (VisitDetails *visit in [VisitsAndTracking sharedInstance].visitData) {
        if([visit.status isEqualToString:@"arrived"]) {
            isOnArriveVisit = TRUE;
            NSLog(@"ARRIVED VISIT");
        }
    }
    LocationTracker *location = [LocationTracker sharedLocationManager];

    if (isOnArriveVisit) {
        if  (!location.isLocationTracking) {
            [location startLocationTracking];
        } else {
        }
    } else {
    }
    
    if ([VisitsAndTracking sharedInstance].firstLogin) {
        NSLog(@"Coming foreground");
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"comingForeground" object:nil];
    } else {
        NSLog(@"This is the first login");
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"[AD] RESIGN ACTIVE");
    [VisitsAndTracking sharedInstance].appRunningBackground = YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //NSLog(@"[AD]ENTER BACKGROUND");
    [VisitsAndTracking sharedInstance].appRunningBackground = YES;
    [[VisitsAndTracking sharedInstance] backgroundClean];
	bool isOnArriveVisit = FALSE;
    for (VisitDetails *visit in [VisitsAndTracking sharedInstance].visitData) {
		if([visit.status isEqualToString:@"arrived"]) { 
			isOnArriveVisit = TRUE;
            LocationTracker *location = [LocationTracker sharedLocationManager];
            if (isOnArriveVisit) {
                if (location.isLocationTracking) {
                    NSLog(@"Already location tracking");
                } else {
                    [location startLocationTracking];
                }
            } else {
                [location stopLocationTracking];
            }
		}
    }
    [viewController applicationEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [VisitsAndTracking sharedInstance].appRunningBackground = NO;
    if (viewController == nil) {
        viewController = [[ClientListViewController alloc]init];
        window.rootViewController  = viewController;
        [window makeKeyAndVisible];
        
    } else {
        window.rootViewController = viewController;
        [viewController foregroundPollingUpdate];
        [window makeKeyAndVisible];
    }
    
    /*if (window.rootViewController == nil) {
        viewController = [[ClientListViewController alloc]init];
        window.rootViewController = viewController;
        [window makeKeyAndVisible];
        [viewController foregroundPollingUpdate];
    }*/
}
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSLog(@"application did terminate");
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application  {
    
    NSLog(@"App Delegate: Memory Warning");
    
}
-(void) setUserAgent {
    NSString *appVersionString = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNum =[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *userAgentInfo = [NSString stringWithFormat:@"LEASHTIME IOS 13 / ver: %@ / build:%@",appVersionString,buildNum];
    [[VisitsAndTracking sharedInstance]setUserAgent:userAgentInfo];
}

- (void)determinePhoneModel {
	
	UIDevice *device = [[UIDevice alloc]init];
	NSString *modelNameForIdent = [device modelName];
    NSLog(@"Model name: %@", modelNameForIdent);
    VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
    
    /*
    "iPhone5,1" : .iPhone5,
    "iPhone5,2" : .iPhone5,
    "iPhone5,3" : .iPhone5C,
    "iPhone5,4" : .iPhone5C,
    "iPhone6,1" : .iPhone5S,
    "iPhone6,2" : .iPhone5S,
    "iPhone7,1" : .iPhone6Plus,
    "iPhone7,2" : .iPhone6,
    "iPhone8,1" : .iPhone6S,
    "iPhone8,2" : .iPhone6SPlus,
    "iPhone8,4" : .iPhoneSE,
*/
    
    if ([modelNameForIdent isEqualToString:@"iPhone12,5"]) {
        
        [sharedVisits setDeviceType:@"iPhone11ProMax"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone12,3"]) {
        
        [sharedVisits setDeviceType:@"iPhone11Pro"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone12,1"]) {
        
        [sharedVisits setDeviceType:@"iPhone11"];
        
    }
    
    else if ([modelNameForIdent isEqualToString:@"iPhone11,8"]) {
        
        [sharedVisits setDeviceType:@"iPhoneXR"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone11,6"] || [modelNameForIdent isEqualToString:@"iPhon11,4"])  {
        
        [sharedVisits setDeviceType:@"iPhoneXSMax"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone11,2"]) {
        
        [sharedVisits setDeviceType:@"iPhoneXS"];
        
    }
    
    else if ([modelNameForIdent isEqualToString:@"iPhone10,6"] || [modelNameForIdent isEqualToString:@"iPhone10,3"]) {
        
        [sharedVisits setDeviceType:@"iPhoneX"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone10,5"] || [modelNameForIdent isEqualToString:@"iPhon10,2"])  {
        
        [sharedVisits setDeviceType:@"iPhone8Plus"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone11,2"]) {
        
        [sharedVisits setDeviceType:@"iPhoneXS"];
        
    }
    
    else if ([modelNameForIdent isEqualToString:@"iPhone10,4"] || [modelNameForIdent isEqualToString:@"iPhone10,1"]) {
        
        [sharedVisits setDeviceType:@"iPhone8"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone9,2"] || [modelNameForIdent isEqualToString:@"iPhon9,4"])  {
        
        [sharedVisits setDeviceType:@"iPhone7Plus"];
        
    } else if ([modelNameForIdent isEqualToString:@"iPhone9,1"] || [modelNameForIdent isEqualToString:@"iPhone9,3"]) {
        
        [sharedVisits setDeviceType:@"iPhone7"];
        
    }

}

@end
