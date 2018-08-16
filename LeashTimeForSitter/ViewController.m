//
//  ViewController.m
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 6/19/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import "ViewController.h"
#import "ClientListViewController.h"
#import "SecondViewController.h"
#import "PetPicture.h"
#import "MessageViewController.h"
#import "SettingsViewController.h"
#import "LoginView.h"
#import "VisitsAndTracking.h"
#import "LocationTracker.h"

@interface ViewController () {
    
    NSUInteger currentViewID;
    CLLocationManager *locationTracker;
    LocationTracker *theLocationTracker;
    LoginView *loginVC;
    ClientListViewController *clientListVC;
    SettingsViewController *settingsVC;
    PetPicture *petPicVC;
    SecondViewController *secondVC;
    MessageViewController *messageVC;
	ViewController *currentVC;
	VisitsAndTracking *sharedVisits;
	
	int loginViewCount;
}
@end

@implementation ViewController


-(instancetype)init {
    
    self = [super init];
	
    if(self){
		currentViewID = 0;
		loginViewCount = 0;
        sharedVisits = [VisitsAndTracking sharedInstance];
        theLocationTracker = [LocationTracker sharedLocationManager];
        [theLocationTracker startLocationTracking];
		[[NSNotificationCenter defaultCenter]addObserver:self
												selector:@selector(applicationEnterBackground)
													name:UIApplicationDidEnterBackgroundNotification
												  object:nil];
		
		[[NSNotificationCenter defaultCenter]addObserver:self
												selector:@selector(foregroundPollingUpdate)
													name:@"comingForeground"
												  object:nil];
		if(!sharedVisits.firstLogin) {
			[self addNotifications];
			[self buildSegmentedControl];
			clientListVC = [[ClientListViewController alloc]init];
			messageVC = [[MessageViewController alloc]init];
			petPicVC = [[PetPicture alloc]init];
			settingsVC = [[SettingsViewController alloc]init];
			secondVC = [[SecondViewController alloc]init];
		}
    }
	
    return self;
	
}

-(void)addNotifications {
	
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(setupInitialView)
												name:@"loginSuccess"
											  object:nil];
	
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(setupInitialViewNoVisits)
												name:@"loginNoVisits"
											  object:nil];
	
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(createPermPass)
												name:@"tempPassword"
											  object:nil];
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(successfullPassSet)
												name:@"loginNewPass"
											  object:nil];
	
	
	
}

-(void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];

}

-(void)foregroundPollingUpdate {
	[sharedVisits foregroundBadRequest];
	
	NSLog(@"Foreground polling update");
	[self addChildViewController:clientListVC];
	[self.view addSubview:clientListVC.view];
	clientListVC.view.frame = self.view.frame;
	[clientListVC didMoveToParentViewController:self];
	 
	if (currentViewID == 1) {
		[secondVC willMoveToParentViewController:nil];
		[secondVC.view removeFromSuperview];
		[secondVC removeFromParentViewController];
	} 
	else if (currentViewID == 2) {
		[petPicVC willMoveToParentViewController:nil];
		[petPicVC.view removeFromSuperview];
		[petPicVC removeFromParentViewController];
	} 
	else if (currentViewID == 3) {
		[messageVC willMoveToParentViewController:nil];
		[messageVC.view removeFromSuperview];
		[messageVC removeFromParentViewController];
	} 
	else if (currentViewID == 4) {
		[settingsVC willMoveToParentViewController:nil];
		[settingsVC.view removeFromSuperview];
		[settingsVC removeFromParentViewController];
	}
	 
	_segmentedControlLocal.selectedSegmentIndex = 0;
	currentViewID = 0;
	[self.view insertSubview:_segmentedControlLocal aboveSubview:clientListVC.view];
	
	if(sharedVisits.firstLogin) {
		[clientListVC foregroundPollingUpdate];
	} else if(!sharedVisits.firstLogin) {
		[self addLoginView];
	}
}
	
-(void) addLoginView {
	loginVC = [[LoginView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.view addSubview:loginVC];

}

-(void)applicationEnterBackground {
	//NSLog(@"VIEW CONTROLLER enter background");

	[self removeCurrentViewController:currentViewID];
	[clientListVC willMoveToParentViewController:nil];
	[clientListVC.view removeFromSuperview];
	[clientListVC removeFromParentViewController];
	[_segmentedControlLocal removeFromSuperview];
	[self removeNotifications];
}

-(void)removeNotifications {
	
}

-(void)setupInitialView {
	//NSLog(@"successful login - set up initial view");

	loginVC.loginName.delegate = nil;
	loginVC.passWord.delegate = nil;
	
	[loginVC.failedLogin removeFromSuperview];
	[loginVC.loginButton removeFromSuperview];
	[loginVC.passWord removeFromSuperview];
	[loginVC.loginName removeFromSuperview];
	loginVC.failedLogin = nil;
	loginVC.loginName= nil;
	loginVC.loginButton = nil;
	loginVC.passWord = nil;
	[loginVC removeFromSuperview];
	loginVC = nil;
		
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(logoutButtonClick)
												name:@"logoutApp"
											  object:nil];

}

-(void)logoutButtonClick {
	
	sharedVisits.firstLogin = NO;
	[self addLoginView];
	[theLocationTracker stopLocationTracking];
}

-(void)buildSegmentedControl {
	
	//VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
	
	CGFloat yDelta;
	yDelta = 20.0f;
	
	UIImage *clipBoardImg = [UIImage imageNamed:@"appointbook128x128"];
	UIImage *mapImg = [UIImage imageNamed:@"mapicon128x128"];
	UIImage *cameraImg = [UIImage imageNamed:@"camera128x128"];
	UIImage *settingsImg = [UIImage imageNamed:@"messagebubble128x128"];
	UIImage *fileFolderImg = [UIImage imageNamed:@"settings-icon"];
	
	NSArray *initImg = [NSArray arrayWithObjects:clipBoardImg,mapImg,cameraImg,settingsImg,fileFolderImg, nil];
	
	_segmentedControlLocal = [[HMSegmentedControl alloc]initWithSectionImages:initImg sectionSelectedImages:initImg];
	float height = self.view.frame.size.height;
	
	NSString *theDeviceType = [sharedVisits tellDeviceType];
	
	if ([theDeviceType isEqualToString:@"iPhone6P"]) {
		_segmentedControlLocal.frame = CGRectMake(0,height-60, self.view.frame.size.width, 60);
	} else if ([theDeviceType isEqualToString:@"iPhone6"]) {
		_segmentedControlLocal.frame = CGRectMake(0,height-60, self.view.frame.size.width, 60);
	} else if ([theDeviceType isEqualToString:@"iPhone5"]) {
		_segmentedControlLocal.frame = CGRectMake(0,height-60, self.view.frame.size.width, 60);
	} else {
		_segmentedControlLocal.frame = CGRectMake(0,height-60, self.view.frame.size.width, 60);
		
	}
	
	_segmentedControlLocal.selectionIndicatorHeight = 1.0f;
	_segmentedControlLocal.backgroundColor = [UIColor colorWithRed:0.10 green:0.33 blue:0.69 alpha:1.0];
	_segmentedControlLocal.selectionStyle = HMSegmentedControlSelectionStyleBox;
	_segmentedControlLocal.tag = 1000;
	[_segmentedControlLocal addTarget:self
							   action:@selector(segmentedControlChangedValue:)
					 forControlEvents:UIControlEventValueChanged];
	
	
	[self.view addSubview:_segmentedControlLocal];
}

-(void)removeCurrentViewController:(NSUInteger)viewID {
	
	if(viewID == 0) {
		
	} else if (viewID == 1) {
		[secondVC willMoveToParentViewController:nil];
		[secondVC.view removeFromSuperview];
		[secondVC removeFromParentViewController];		
	} else if (viewID == 2) {
		[petPicVC willMoveToParentViewController:nil];
		[petPicVC.view removeFromSuperview];
		[petPicVC removeFromParentViewController];
	} else if (viewID == 3) {
		[messageVC willMoveToParentViewController:nil];
		[messageVC.view removeFromSuperview];
		[messageVC removeFromParentViewController];
	} else if (viewID == 4) {
		[settingsVC willMoveToParentViewController:nil];
		[settingsVC.view removeFromSuperview];
		[settingsVC removeFromParentViewController];
	}
}
-(void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
	
	[_segmentedControlLocal removeFromSuperview];

	
	if (segmentedControl.selectedSegmentIndex != currentViewID) {
		
		if(currentViewID == 0) {
			[clientListVC willMoveToParentViewController:nil];
			[clientListVC.view removeFromSuperview];
			[clientListVC removeFromParentViewController];
			//NSLog(@"CURRENT VIEW: %lu, REMOVE CLIENT LIST VC", (unsigned long)currentViewID);
			
		} else if (currentViewID == 1) {
			[secondVC willMoveToParentViewController:nil];
			[secondVC.view removeFromSuperview];
			[secondVC removeFromParentViewController];
			//NSLog(@"CURRENT VIEW: %lu, REMOVE MAP VIEW VC", (unsigned long)currentViewID);
			
		} else if (currentViewID == 2) {
			[petPicVC willMoveToParentViewController:nil];
			[petPicVC.view removeFromSuperview];
			[petPicVC removeFromParentViewController];
			
			//NSLog(@"CURRENT VIEW: %lu, REMOVE PET PIC VIEW VC", (unsigned long)currentViewID);
			
		} else if (currentViewID == 3) {
			[messageVC willMoveToParentViewController:nil];
			[messageVC.view removeFromSuperview];
			[messageVC removeFromParentViewController];
			
			//NSLog(@"CURRENT VIEW: %lu, REMOVE MESSAGE VC", (unsigned long)currentViewID);
			
		} else if (currentViewID == 4) {
			[settingsVC willMoveToParentViewController:nil];
			[settingsVC.view removeFromSuperview];
			[settingsVC removeFromParentViewController];
			settingsVC.view = nil;
			settingsVC = nil;
			//NSLog(@"CURRENT VIEW: %lu, REMOVE SETTINGS VC", (unsigned long)currentViewID);
			
		}
		
		
		//******************
		//
		// Switching view controller
		//
		//******************
		
		
		if (segmentedControl.selectedSegmentIndex == 0) {
			//NSLog(@"CLIENT LIST VC DID MOVE TO PARENT");
			
			[self addChildViewController:clientListVC];
			[self.view addSubview:clientListVC.view];
			clientListVC.view.frame = self.view.bounds;
			[clientListVC didMoveToParentViewController:self];
			[self.view insertSubview:_segmentedControlLocal aboveSubview:clientListVC.view];
			currentViewID = 0;
		}
		
		else if (segmentedControl.selectedSegmentIndex == 1) {
			
			//NSLog(@"MAP VIEW VC DID MOVE TO PARENT");
			[self addChildViewController:secondVC];
			[self.view addSubview:secondVC.view];
			secondVC.view.frame = self.view.bounds;
			[secondVC didMoveToParentViewController:self];
			[self.view insertSubview:_segmentedControlLocal aboveSubview:secondVC.view];
			currentViewID = 1;
			
		} 
		else if (segmentedControl.selectedSegmentIndex == 2) {
			//NSLog(@"PET PIC VC DID MOVE TO PARENT");
			
			[self addChildViewController:petPicVC];
			[self.view addSubview:petPicVC.view];
			petPicVC.view.frame = self.view.bounds;
			[petPicVC didMoveToParentViewController:self];
			[self.view insertSubview:_segmentedControlLocal aboveSubview:petPicVC.view];
			currentViewID = 2;
			
		} 
		else if (segmentedControl.selectedSegmentIndex == 3) {
			//NSLog(@"MESSAGE VC DID MOVE TO PARENT");
			if(messageVC == nil) {
				//NSLog(@"ALLOC");
				messageVC = [[MessageViewController alloc]init];
			}
			[self addChildViewController:messageVC];
			[self.view addSubview:messageVC.view];
			messageVC.view.frame = self.view.bounds;
			[messageVC didMoveToParentViewController:self];
			[self.view insertSubview:_segmentedControlLocal aboveSubview:messageVC.view];
			currentViewID = 3;
			
			
		} 
		else if (segmentedControl.selectedSegmentIndex == 4) {
			if(settingsVC == nil) {
				settingsVC = [[SettingsViewController alloc]init];
			}
			[self addChildViewController:settingsVC];
			[self.view addSubview:settingsVC.view];
			settingsVC.view.frame = self.view.bounds;
			[settingsVC didMoveToParentViewController:self];
			[self.view insertSubview:_segmentedControlLocal aboveSubview:settingsVC.view];
			currentViewID = 4;
			
		}
	}
	
	
}

-(void)setupInitialViewNoVisits {
	
	[loginVC removeFromSuperview];
	
}

-(void)dealloc {
	
	//NSLog(@"View controller is deallocated");
	
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"loginSuccess" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"loginNoVisits" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"logoutApp" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"tempPassword" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"loginNewPass" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
	
	//loginVC = nil;
	//clientListVC = nil;
	//messageVC = nil;
	//secondVC = nil;
	//petPicVC = nil;
	
}
-(void)recreatePermPass:(NSString*)failureText {
	
	UIAlertController * alert=   [UIAlertController
								  alertControllerWithTitle:@"PLEASE CREATE A PERMANENT PASSWORD"
								  message:failureText
								  preferredStyle:UIAlertControllerStyleAlert];
	
	
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Password";
		textField.secureTextEntry = YES;
		
	}];
	
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Re-Enter Password";
		textField.secureTextEntry = YES;
	}];
	
	
	UIAlertAction* ok = [UIAlertAction
						 actionWithTitle:@"OK"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 UITextField *password1 = alert.textFields.firstObject;
							 UITextField *password2 = alert.textFields.lastObject;
							 
							 if ([password1.text isEqualToString:password2.text]) {
								 if ([password1.text isEqualToString:@"pass"]) {
									 [self recreatePermPass:@"CANNOT USE pass FOR PASSWORD"];
								 } else if ([password1.text isEqualToString:@"password"]) {
									 [self recreatePermPass:@"CANNOT USE password FOR PASSWORD"];
								 } else if ([password1.text length] < 4) {
									 [self recreatePermPass:@"PASSWORD MUST BE GREATER THAN 4 CHARACTERS"];
								 } else {
									 NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
									 NSString *tempPass = [loginSetting objectForKey:@"password"];
									 NSString *userName = [loginSetting objectForKey:@"username"];
									 //VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
									 [sharedVisits changeTempPassword:tempPass loginID:userName newPass:password1.text];
									 [alert dismissViewControllerAnimated:YES completion:nil];
								 }
							 } else {
								 [self recreatePermPass:@"MISMATCH PASSWORDS"];
								 
							 }
						 }];
	
	
	
	UIAlertAction* cancel = [UIAlertAction
							 actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleDefault
							 handler:^(UIAlertAction * action)
							 {
								 [alert dismissViewControllerAnimated:YES completion:nil];
								 
							 }];
	
	
	[alert addAction:ok];
	[alert addAction:cancel];
	
	[self presentViewController:alert animated:YES completion:nil];
	
}
-(void)createPermPass {
	
	
	UIAlertController * alert=   [UIAlertController
								  alertControllerWithTitle:@"PLEASE CREATE A PERMANENT PASSWORD"
								  message:@"ENTER A NEW PASSWORD"
								  preferredStyle:UIAlertControllerStyleAlert];
	
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Password";
		textField.secureTextEntry = YES;
		
	}];
	
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Re-Enter Password";
		textField.secureTextEntry = YES;
	}];
	
	
	UIAlertAction* ok = [UIAlertAction
						 actionWithTitle:@"OK"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 UITextField *password1 = alert.textFields.firstObject;
							 UITextField *password2 = alert.textFields.lastObject;
							 
							 if ([password1.text isEqualToString:password2.text]) {
								 if ([password1.text isEqualToString:@"pass"]) {
									 [self recreatePermPass:@"CANNOT USE pass FOR PASSWORD"];
								 } else if ([password1.text isEqualToString:@"password"]) {
									 [self recreatePermPass:@"CANNOT USE password FOR PASSWORD"];
								 } else if ([password1.text length] < 4) {
									 [self recreatePermPass:@"PASSWORD MUST BE GREATER THAN 4 CHARACTERS"];
								 } else {
									 NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
									 NSString *tempPass = [loginSetting objectForKey:@"password"];
									 NSString *userName = [loginSetting objectForKey:@"username"];
									 
									 
									 //VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
									 
									 [sharedVisits changeTempPassword:tempPass loginID:userName newPass:password1.text];
									 [alert dismissViewControllerAnimated:YES completion:nil];
									 
								 }
							 } else {
								 
								 [alert dismissViewControllerAnimated:YES completion:nil];
								 
								 [self recreatePermPass:@"PASSWORD MISMATCH"];
								 
							 }
							 
						 }];
	
	
	
	UIAlertAction* cancel = [UIAlertAction
							 actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleDefault
							 handler:^(UIAlertAction * action)
							 {
								 [alert dismissViewControllerAnimated:YES completion:nil];
								 
							 }];
	
	
	[alert addAction:ok];
	[alert addAction:cancel];
	
	[self presentViewController:alert animated:YES completion:nil];
	
}
-(void)successfullPassSet {
	
	loginVC.failedLogin.text = @"RE-ENTER PASSWORD";
	
}
-(void)receivedLowMemoryWarning {
	
	loginVC = nil;
}
- (void)setApperanceForLabel:(UILabel *)label {
	CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
	CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
	CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
	UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
	label.backgroundColor = color;
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont systemFontOfSize:21.0f];
	label.textAlignment = NSTextAlignmentCenter;
}
- (BOOL)prefersStatusBarHidden {
	
	return YES;
	
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
}

@end
