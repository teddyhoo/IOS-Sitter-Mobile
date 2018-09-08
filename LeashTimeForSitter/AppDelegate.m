//
//  AppDelegate.m
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 6/19/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "LocationTracker.h"
#import "DataClient.h"
#import "SDVersion.h"
#import "UIDevice-Hardware.h"
#import <UserNotifications/UserNotifications.h>

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	_sharedVisits = [VisitsAndTracking sharedInstance];
	_sharedVisits.firstLogin = NO;
	_sharedVisits.appRunningBackground = NO;
	[self determinePhoneModel];
	NSString *appVersionString = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *buildNum =[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *userAgentInfo = [NSString stringWithFormat:@"LEASHTIME IOS 11 / ver: %@ / build:%@",appVersionString,buildNum];
	_sharedVisits.userAgentLT = userAgentInfo;
	
	self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
	
	self.viewController = [[ViewController alloc] init];
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
	return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    _sharedVisits.appRunningBackground = YES;

}
- (void)applicationDidEnterBackground:(UIApplication *)application {
	
    _sharedVisits.appRunningBackground = YES;
	bool isOnArriveVisit = FALSE;
	for(VisitDetails *visit in _sharedVisits.visitData) {
		if([visit.status isEqualToString:@"arrived"]) { 
			isOnArriveVisit = TRUE;
			NSLog(@"There is an arrived visit status");
		}
	}
	
	LocationTracker *location = [LocationTracker sharedLocationManager];

	if (isOnArriveVisit) {

		if (location.isLocationTracking) {
			NSLog(@"Already location tracking");
		} else {
			NSLog(@"Not location tracking");
			[location startLocationTracking];
		}
	} else {
		NSLog(@"No visits so stopping location tracking");
		[location stopLocationTracking];
	}
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    _sharedVisits.appRunningBackground = NO;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
		
	//NSLog(@"Post Application Did Become Active Notification from AppDelegate");
	[[NSNotificationCenter defaultCenter]postNotificationName:@"comingForeground" object:nil];
	bool isOnArriveVisit = FALSE;
	for(VisitDetails *visit in _sharedVisits.visitData) {
		if([visit.status isEqualToString:@"arrived"]) { 
			isOnArriveVisit = TRUE;
			NSLog(@"There is an arrived visit status");
		} 
	}
	LocationTracker *location = [LocationTracker sharedLocationManager];

	if (isOnArriveVisit) {
		if  (!location.isLocationTracking) {
			[location startLocationTracking];
			NSLog(@"starting location tracker");
		} else {
			NSLog(@"Location tracker is already tracking");
		}
	} else {
		NSLog(@"The location tracker is currently off");
	}

}
- (void)applicationWillTerminate:(UIApplication *)application {
    
    //NSLog(@"application did terminate");
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application  {
    
    //NSLog(@"App Delegate: Memory Warning");
}
- (void)determinePhoneModel {
	
	UIDevice *device = [[UIDevice alloc]init];
	NSString *modelNameForIdent = [device modelName];	
	if([device.model isEqualToString:@"iPad"]) {
		[_sharedVisits setDeviceType:@"iPhone5"];
	} else {
		if ([modelNameForIdent isEqualToString:@"iPhone 7 Plus"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		}  else if ([modelNameForIdent isEqualToString:@"iPhone 7"]) {
			[_sharedVisits setDeviceType:@"iPhone6"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone 6 Plus"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if([modelNameForIdent isEqualToString:@"iPhone 7"]) {
			[_sharedVisits setDeviceType:@"iPhone6"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone 6"]) {
			[_sharedVisits setDeviceType:@"iPhone6"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone 6s"]) {
			[_sharedVisits setDeviceType:@"iPhone6"];
		}  else if ([modelNameForIdent isEqualToString:@"iPhone SE"]) {
			[_sharedVisits setDeviceType:@"iPhone5"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone 5"]) {
			[_sharedVisits setDeviceType:@"iPhone5"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone 5c"]) {
			[_sharedVisits setDeviceType:@"iPhone5"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone 5s"]) {
			[_sharedVisits setDeviceType:@"iPhone5"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone 4s"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad 4"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad 3"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad 2"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad Air"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad Air 2"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad mini"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad Pro (9.7 inch)"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad Pro (12.9 inch)"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPad Pro (9.2 inch)"]) {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		} else if ([modelNameForIdent isEqualToString:@"iPhone X"]) {
			[_sharedVisits setDeviceType:@"iPhone X"];
		} else {
			[_sharedVisits setDeviceType:@"iPhone6P"];
		}
		//NSLog(@"model name singleton: %@",_sharedVisits.tellDeviceType);
	}
}

@end
