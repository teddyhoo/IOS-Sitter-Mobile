//
//  MyNotificationViewController.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 1/28/17.
//  Copyright © 2017 Ted Hooban. All rights reserved.
//

#import "MyNotificationViewController.h"
@import UserNotifications;

@interface MyNotificationViewController ()

@end

@implementation MyNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
	[center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
				    completionHandler:^(BOOL granted, NSError * _Nullable error) {
					   
					    
					    
				    }];
	
	UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
	content.title = [NSString localizedUserNotificationStringForKey:@"Hello!"
										arguments:nil];
	content.body = [NSString localizedUserNotificationStringForKey:@"Hello_message_body"
									     arguments:nil];
	content.sound = [UNNotificationSound defaultSound];
	
	UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2
																	repeats:NO];
	
	
	UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"LeashTime"
														    content:content
														    trigger:trigger];
	
	[center addNotificationRequest:notificationRequest
		   withCompletionHandler:^(NSError * _Nullable error) {
			   //NSLog(@"completed!");
		   }];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
