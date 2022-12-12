//
//  TodayViewController.m
//  LeashTimeAlerts
//
//  Created by Edward Hooban on 3/20/17.
//  Copyright © 2017 Ted Hooban. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "VisitsAndTracking.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)visitArriveButton:(id)button {
	

	if([button isKindOfClass:[UIButton class]]) {
		UIButton *arriveButton = (UIButton*)button;
		//NSLog(@"button tag: %li",(long)arriveButton.tag);
		[arriveButton setSelected:YES];
		
	}
	
}


-(void)cannotDoButton:(id)button {
	
	
	if([button isKindOfClass:[UIButton class]]) {
		UIButton *arriveButton = (UIButton*)button;
		//NSLog(@"button tag: %li",(long)arriveButton.tag);
		[arriveButton setSelected:YES];
		
	}
	
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
	
	id bundleMain = (VisitsAndTracking*)[[NSBundle bundleWithIdentifier:@"com.doublethink.LeashTimeMobileSitter2"]classNamed:@"VisitsAndTracking.class"];
	VisitsAndTracking *myVisitTracking = (VisitsAndTracking*)[bundleMain sharedInstance];
	
	//NSLog(@"retrieved bundle for visits and tracking: %@",myVisitTracking.description);
	
	UILabel *visitLabel = [[UILabel alloc]initWithFrame:CGRectMake(30,10,320,20)];
	[visitLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];
	[visitLabel setTextColor:[UIColor redColor]];
	[visitLabel setText:@"FIDO THE PET  -   10AM    -   LATE VISIT"];
	[self.view addSubview:visitLabel];
	
	UIButton *arrivedButton = [UIButton buttonWithType:UIButtonTypeCustom];
	arrivedButton.frame = CGRectMake(0,30,140,20);
	arrivedButton.titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14];
	arrivedButton.titleLabel.textColor = [UIColor blueColor];
	[arrivedButton setTitle:@"MARK ARRIVE"
				   forState:UIControlStateNormal];
	[arrivedButton setTitle:@"ARRIVED" forState:UIControlStateSelected];
	arrivedButton.tag = 12345;
	arrivedButton.titleLabel.frame = CGRectMake(0, 0, 140, 20);
	arrivedButton.titleLabel.textAlignment = NSTextAlignmentLeft;
	arrivedButton.titleLabel.numberOfLines = 1;
	arrivedButton.imageView.frame = CGRectMake(0,0,20,20);
	[arrivedButton setImage:[UIImage imageNamed:@"arrive-pink-button"]
				   forState:UIControlStateNormal];
	[arrivedButton addTarget:self
					  action:@selector(visitArriveButton:)
			forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:arrivedButton];
	
	
	UIButton *cannotDoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cannotDoButton.frame = CGRectMake(140,30,140,20);
	cannotDoButton.titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14];
	cannotDoButton.titleLabel.textColor = [UIColor blueColor];
	[cannotDoButton setTitle:@"CANNOT DO"
				   forState:UIControlStateNormal];
	[cannotDoButton setTitle:@"WTF?" forState:UIControlStateSelected];
	cannotDoButton.tag = 12345;
	cannotDoButton.titleLabel.frame = CGRectMake(0, 0, 140, 20);
	cannotDoButton.titleLabel.textAlignment = NSTextAlignmentLeft;
	cannotDoButton.titleLabel.numberOfLines = 1;
	cannotDoButton.imageView.frame = CGRectMake(0,0,20,20);
	[cannotDoButton setImage:[UIImage imageNamed:@"arrive-pink-button"]
				   forState:UIControlStateNormal];
	[cannotDoButton addTarget:self
					  action:@selector(cannotDoButton:)
			forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:cannotDoButton];
	
	
	
	UILabel *changeVisitLabel = [[UILabel alloc]initWithFrame:CGRectMake(30,60,320,20)];
	[changeVisitLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
	[changeVisitLabel setTextColor:[UIColor redColor]];
	[changeVisitLabel setText:@"FIFI CAT -> REASSIGNED TO YOU"];
	[self.view addSubview:changeVisitLabel];
	
	
	
    completionHandler(NCUpdateResultNewData);
}

@end
