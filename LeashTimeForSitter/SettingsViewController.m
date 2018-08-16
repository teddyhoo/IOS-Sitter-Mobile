//
//  SettingsViewController.m
//  LeashTimeSitter
//
//  Created by Ted Hooban on 8/22/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "SettingsViewController.h"
#import <UIKit/UIKit.h>

@interface SettingsViewController () {
    
    NSMutableArray *settingsData;
    
    UILabel *networkStatusUpdateGPSLabel;
    UILabel *numCoordinatesUpdateGPSLabel;
    UILabel *gpsAccuracyLabel;
    UILabel *labelDistanceGPS;

    
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
    
    CGFloat height;
    CGFloat width;
    
    VisitsAndTracking *sharedVisitsAndTracking;
    NSUserDefaults *optionSettings;
    
}

@end

@implementation SettingsViewController


-(instancetype)init {
    
    //NSLog(@"SETTINGS VIEW CONTROLLER INIT");
    
    
    self = [super init];
    if(self){
        
        sharedVisitsAndTracking = [VisitsAndTracking sharedInstance];
        NSString *theDeviceType = [sharedVisitsAndTracking tellDeviceType];
        
        if ([theDeviceType isEqualToString:@"iPhone6P"]) {
            isIphone6P = YES;
            
        } else if ([theDeviceType isEqualToString:@"iPhone6"]) {
            isIphone6 = YES;
            
        } else if ([theDeviceType isEqualToString:@"iPhone5"]) {
            isIphone5 = YES;
            
        } else {
            isIphone4 = YES;
        }
        
        height = self.view.bounds.size.height;
        width = self.view.bounds.size.width;
        [self.view setBackgroundColor:[UIColor whiteColor]];
                
        
    }
    return self;
}

-(void)didMoveToParentViewController:(UIViewController *)parent {
    
   // NSLog(@"Called Settings View Controller didMoveToParentViewController");
    sharedVisitsAndTracking = [VisitsAndTracking sharedInstance];
    optionSettings = [NSUserDefaults standardUserDefaults];
    NSString *theDeviceType = [sharedVisitsAndTracking tellDeviceType];
    if ([theDeviceType isEqualToString:@"iPhone6P"]) {
        isIphone6P = YES;
        
    } else if ([theDeviceType isEqualToString:@"iPhone6"]) {
        isIphone6 = YES;
        
    } else if ([theDeviceType isEqualToString:@"iPhone5"]) {
        isIphone5 = YES;
        
    } else {
        isIphone4 = YES;
    }
    height = self.view.bounds.size.height;
    width = self.view.bounds.size.width;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    NSString *pListData = [[NSBundle mainBundle]
                           pathForResource:@"Settings"
                           ofType:@"plist"];
    
    settingsData = [[NSMutableArray alloc]initWithContentsOfFile:pListData];
    
    
    [self setupBackground];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)logoutApp {
	//NSLog(@"Settings click LOGOUT");
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"logoutApp" object:nil];
}
-(void)dealloc
{
    
    //NSLog(@"DEALLOC: SETTINGS");

    [labelDistanceGPS removeFromSuperview];
    [networkStatusUpdateGPSLabel removeFromSuperview];
    [numCoordinatesUpdateGPSLabel removeFromSuperview];
    [gpsAccuracyLabel removeFromSuperview];
    
    labelDistanceGPS = nil;
    networkStatusUpdateGPSLabel = nil;
    numCoordinatesUpdateGPSLabel = nil;
    gpsAccuracyLabel = nil;
	
	for (int i = 0 ; i < [settingsData count] ; i++) {
		NSMutableDictionary *dic = [settingsData objectAtIndex:i];
		NSArray *allKeys = [dic allKeys];
		for (NSString *key in allKeys) {
			[dic removeObjectForKey:key];
		}
		[settingsData removeObject:dic];
	}
    
    [settingsData removeAllObjects];
	//NSLog(@"settingdata: %i",[settingsData count]);
    settingsData = nil;
	self.view = nil;

}


-(void)removeFromParentViewController {
    

    [labelDistanceGPS removeFromSuperview];
    [networkStatusUpdateGPSLabel removeFromSuperview];
    [numCoordinatesUpdateGPSLabel removeFromSuperview];
    [gpsAccuracyLabel removeFromSuperview];
    
    labelDistanceGPS = nil;
    networkStatusUpdateGPSLabel = nil;
    numCoordinatesUpdateGPSLabel = nil;
    gpsAccuracyLabel = nil;

	for (int i = 0 ; i < [settingsData count] ; i++) {
		NSMutableDictionary *dic = [settingsData objectAtIndex:i];
		NSArray *allKeys = [dic allKeys];
		for (NSString *key in allKeys) {
			[dic removeObjectForKey:key];
		}
		[dic removeAllObjects];
		[settingsData removeObject:dic];
	}
	[settingsData removeAllObjects];

    settingsData = nil;
    
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    
    
}

-(void)setupBackground {

    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width,height)];
    backgroundView.image = [UIImage imageNamed:@"BG-plainBlue"];
    [self.view addSubview:backgroundView];
    
    
    UIImageView *backgroundView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width,80)];
    backgroundView2.image = [UIImage imageNamed:@"header-white"];
    [self.view addSubview:backgroundView2];
    
    UILabel *titleSetting = [[UILabel alloc]initWithFrame:CGRectMake(20,5, width, 40)];
    [titleSetting setText:@"LEASHTIME MOBILE SETTINGS"];
    [titleSetting setFont:[UIFont fontWithName:@"CompassRoseCPC-Bold" size:18]];
    [titleSetting setTextColor:[UIColor blackColor]];
    
    [self.view addSubview:titleSetting];
    
    float labelFontSize = 0;
	int xSecondColumn = self.view.frame.size.width - 50;
	int ySecondColumn = self.view.frame.size.height / 2 - 80;

    UIImage *minImage = [[UIImage imageNamed:@"slider-min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider-max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    UIImage *thumbImage = [UIImage imageNamed:@"slider-handle"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];


	UIFont *fontBase = [UIFont fontWithName:@"Lato-Regular" size:14];
	
    if (isIphone6P || isIphone6) {
        
        labelFontSize = 14;
        
        for (NSDictionary *settingDic in settingsData) {
            
            if([[settingDic objectForKey:@"Type"]isEqualToString:@"UISlider"]) {
            
                float yVal = [[settingDic objectForKey:@"yPos"]floatValue];
                NSString *labelText = [settingDic objectForKey:@"Name"];
                
                UILabel *sliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, yVal, 200, 24)];
                [sliderLabel setFont:fontBase];
                [sliderLabel setTextColor:[UIColor blackColor]];
                [sliderLabel setText:labelText];
                
                
                UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(sliderLabel.frame.origin.x + 180, sliderLabel.frame.origin.y, 150, 25)];
                slider.minimumValue = [[settingDic objectForKey:@"minValue"]floatValue];
                slider.maximumValue = [[settingDic objectForKey:@"maxValue"]floatValue];
                //slider.value = 100.0;
                [slider setContinuous:TRUE];
                NSString *targetVal = [settingDic objectForKey:@"target"];
                
                if ([targetVal isEqualToString:@"getGPSDistanceValue:"]) {
                    [slider addTarget:self
                               action:@selector(getGPSDistanceValue:)
                     forControlEvents:UIControlEventValueChanged];
                    NSString *gpsAccuracy = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.distanceSettingForGPS];
                    float value = [gpsAccuracy floatValue];
                    slider.value = value;
                    labelDistanceGPS = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, slider.frame.origin.y, 80, 20)];
                    [labelDistanceGPS setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [labelDistanceGPS setTextColor:[UIColor redColor]];
                    [labelDistanceGPS setText:gpsAccuracy];
                    [self.view addSubview:labelDistanceGPS];
                    
                } else if ([targetVal isEqualToString:@"gpsAccuracyValue:"]) {
                    
                    [slider addTarget:self
                               action:@selector(gpsAccuracyValue:)
                     forControlEvents:UIControlEventValueChanged];

                    NSString *distanceSet = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.minimumGPSAccuracy];
                    float value = [distanceSet floatValue];
                    slider.value = value;
                    
                    
                    gpsAccuracyLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, slider.frame.origin.y, 80, 20)];
                    [gpsAccuracyLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [gpsAccuracyLabel setTextColor:[UIColor redColor]];
                    [gpsAccuracyLabel setText:distanceSet];
                    [self.view addSubview:gpsAccuracyLabel];
                    
                } else if ([targetVal isEqualToString:@"getPollingFrequency:"]) {
                    
                    [slider addTarget:self
                               action:@selector(getNetworkValue:)
                     forControlEvents:UIControlEventValueChanged];
                    
                    NSString *distanceSet = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.updateFrequencySeconds];
                    
                    float value = [distanceSet floatValue];
                    slider.value = value;
                    
                    networkStatusUpdateGPSLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, slider.frame.origin.y, 80, 20)];
                    [networkStatusUpdateGPSLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [networkStatusUpdateGPSLabel setTextColor:[UIColor redColor]];
                    [networkStatusUpdateGPSLabel setText:distanceSet];
                    [self.view addSubview:networkStatusUpdateGPSLabel];
                    
                } else if ([targetVal isEqualToString:@"getNumberCoordinatesTransmitValue:"]) {
                    [slider addTarget:self
                               action:@selector(getNumberCoordinatesTransmitValue:)
                     forControlEvents:UIControlEventValueChanged];
                    
                    NSString *numCoordString = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.minNumCoordinatesSend];
                    float value = [numCoordString floatValue];
                    slider.value = value;
                    
                    numCoordinatesUpdateGPSLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, slider.frame.origin.y, 80, 20)];
                    [numCoordinatesUpdateGPSLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [numCoordinatesUpdateGPSLabel setTextColor:[UIColor redColor]];
                    [numCoordinatesUpdateGPSLabel setText:numCoordString];
                    [self.view addSubview:numCoordinatesUpdateGPSLabel];
                }
                
                [self.view addSubview:sliderLabel];
                [self.view addSubview:slider];

            }
            
            else if ([[settingDic objectForKey:@"Type"]isEqualToString:@"UIButton"]) {
                float yVal = [[settingDic objectForKey:@"yPos"]floatValue];
                NSString *labelText = [settingDic objectForKey:@"Name"];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, yVal, 200, 22)];
                [label setFont:[UIFont fontWithName:@"Umhlanga-Regular." size:16]];
                [label setTextColor:[UIColor blackColor]];
                [label setText:labelText];
                [self.view addSubview:label];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                
                button.frame = CGRectMake(label.frame.origin.x  + 140, yVal, 64, 32);
                [button setImage:[UIImage imageNamed:@"off-button"]
                        forState:UIControlStateNormal];
                
                [button setImage:[UIImage imageNamed:@"on-button"]
                        forState:UIControlStateSelected];
                
                NSString *settingStat = [settingDic objectForKey:@"target"];
                BOOL isOn;
                if([[optionSettings objectForKey:settingStat]boolValue]) {
                    isOn = YES;
                    [button setSelected:YES];
                } else {
                    isOn = NO;
                    [button setSelected:NO];
                }
                
                [button addTarget:self
                           action:@selector(touchButton:)
                 forControlEvents:UIControlEventTouchUpInside];
                    
                button.tag = [[settingDic objectForKey:@"tagID"]intValue];
                
                [self.view addSubview:button];
                
            }
            
        }

		UIButton *payCalcButton = [UIButton buttonWithType:UIButtonTypeCustom];
		payCalcButton.frame = CGRectMake(xSecondColumn, ySecondColumn,32,32);
		[payCalcButton setImage:[UIImage imageNamed:@"dollar-icon"]
					   forState:UIControlStateNormal];
		[payCalcButton addTarget:self
						  action:@selector(calculatePay:)
				forControlEvents:UIControlEventTouchUpInside];
		//[self.view addSubview:payCalcButton];
    }
    
    else if (isIphone5) {
        
        labelFontSize = 13;
		int buttonCount = 0;
		int sliderCount = 0;
		
        for (NSDictionary *settingDic in settingsData) {
            
            if([[settingDic objectForKey:@"Type"]isEqualToString:@"UISlider"]) {
                
                float yVal = [[settingDic objectForKey:@"yPos"]floatValue];
                yVal -= 20;
				yVal = yVal-(sliderCount*20);
                NSString *labelText = [settingDic objectForKey:@"Name"];
                
                UILabel *sliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, yVal, 160, 20)];
                [sliderLabel setFont:[UIFont fontWithName:@"Langdon" size:14]];
                [sliderLabel setTextColor:[UIColor blackColor]];
                [sliderLabel setText:labelText];
                
                
                UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(sliderLabel.frame.origin.x + 120, sliderLabel.frame.origin.y, 120, 25)];
                slider.minimumValue = [[settingDic objectForKey:@"minValue"]floatValue];
                slider.maximumValue = [[settingDic objectForKey:@"maxValue"]floatValue];
                [slider setContinuous:TRUE];
                NSString *targetVal = [settingDic objectForKey:@"target"];
                
                if ([targetVal isEqualToString:@"getGPSDistanceValue:"]) {
                    [slider addTarget:self
                               action:@selector(getGPSDistanceValue:)
                     forControlEvents:UIControlEventValueChanged];
                    NSString *gpsAccuracy = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.distanceSettingForGPS];
                    float value = [gpsAccuracy floatValue];
                    slider.value = value;
                    labelDistanceGPS = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [labelDistanceGPS setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [labelDistanceGPS setTextColor:[UIColor redColor]];
                    [labelDistanceGPS setText:gpsAccuracy];
                    [self.view addSubview:labelDistanceGPS];
                    
                } else if ([targetVal isEqualToString:@"gpsAccuracyValue:"]) {
                    
                    [slider addTarget:self
                               action:@selector(gpsAccuracyValue:)
                     forControlEvents:UIControlEventValueChanged];

                    NSString *distanceSet = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.minimumGPSAccuracy];
                    float value = [distanceSet floatValue];
                    slider.value = value;
                    
                    gpsAccuracyLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [gpsAccuracyLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
                    [gpsAccuracyLabel setTextColor:[UIColor redColor]];
                    [gpsAccuracyLabel setText:distanceSet];
                    [self.view addSubview:gpsAccuracyLabel];
                    
                } else if ([targetVal isEqualToString:@"getPollingFrequency:"]) {
                    
                    [slider addTarget:self
                               action:@selector(getNetworkValue:)
                     forControlEvents:UIControlEventValueChanged];
                    
                    //slider.value = sharedVisitsAndTracking.updateFrequencySeconds;
                    NSString *distanceSet = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.updateFrequencySeconds];
                    
                    float value = [distanceSet floatValue];
                    slider.value = value;
                    
                    networkStatusUpdateGPSLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [networkStatusUpdateGPSLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
                    [networkStatusUpdateGPSLabel setTextColor:[UIColor redColor]];
                    [networkStatusUpdateGPSLabel setText:distanceSet];
                    [self.view addSubview:networkStatusUpdateGPSLabel];
                    
                } else if ([targetVal isEqualToString:@"getNumberCoordinatesTransmitValue:"]) {
                    [slider addTarget:self
                               action:@selector(getNumberCoordinatesTransmitValue:)
                     forControlEvents:UIControlEventValueChanged];
                    
                    //slider.value = sharedVisitsAndTracking.minNumCoordinatesSend;
                    NSString *numCoordString = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.minNumCoordinatesSend];
                    float value = [numCoordString floatValue];
                    slider.value = value;
                    
                    numCoordinatesUpdateGPSLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [numCoordinatesUpdateGPSLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [numCoordinatesUpdateGPSLabel setTextColor:[UIColor redColor]];
                    [numCoordinatesUpdateGPSLabel setText:numCoordString];
                    [self.view addSubview:numCoordinatesUpdateGPSLabel];
                }
                
                [self.view addSubview:sliderLabel];
                [self.view addSubview:slider];
				sliderCount++;
            }
            
            else if ([[settingDic objectForKey:@"Type"]isEqualToString:@"UIButton"]) {
                float yVal = [[settingDic objectForKey:@"yPos"]floatValue];
                yVal -= 100;
				yVal = yVal - (buttonCount * 14); 
                NSString *labelText = [settingDic objectForKey:@"Name"];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, yVal, 200, 14)];
                [label setFont:[UIFont fontWithName:@"Langdon" size:14]];
                [label setTextColor:[UIColor blackColor]];
                [label setText:labelText];
                [self.view addSubview:label];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                
                button.frame = CGRectMake(label.frame.origin.x  + 100, yVal-5, 40, 20 );
                [button setImage:[UIImage imageNamed:@"off-button"]
                        forState:UIControlStateNormal];
                
                [button setImage:[UIImage imageNamed:@"on-button"]
                        forState:UIControlStateSelected];
                
                NSString *settingStat = [settingDic objectForKey:@"target"];
                BOOL isOn;
                if([[optionSettings objectForKey:settingStat]boolValue]) {
                    isOn = YES;
                    [button setSelected:YES];
                } else {
                    isOn = NO;
                    [button setSelected:NO];
                }
                
                [button addTarget:self
                           action:@selector(touchButton:)
                 forControlEvents:UIControlEventTouchUpInside];
                
                button.tag = [[settingDic objectForKey:@"tagID"]intValue];
                
                [self.view addSubview:button];
				buttonCount++;
                
            }
            
        }

    } 
	
	else if (isIphone4) {
        
        labelFontSize = 14;
        
        for (NSDictionary *settingDic in settingsData) {
            
            if([[settingDic objectForKey:@"Type"]isEqualToString:@"UISlider"]) {
                
                float yVal = [[settingDic objectForKey:@"yPos"]floatValue];
                yVal -= 12.0;
                NSString *labelText = [settingDic objectForKey:@"Name"];
                
                UILabel *sliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, yVal, 160, 20)];
                [sliderLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
                [sliderLabel setTextColor:[UIColor blackColor]];
                [sliderLabel setText:labelText];
                
                
                UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(sliderLabel.frame.origin.x + 140, sliderLabel.frame.origin.y, 120, 25)];
                slider.minimumValue = [[settingDic objectForKey:@"minValue"]floatValue];
                slider.maximumValue = [[settingDic objectForKey:@"maxValue"]floatValue];
                //slider.value = 100.0;
                [slider setContinuous:TRUE];
                NSString *targetVal = [settingDic objectForKey:@"target"];
                
                if ([targetVal isEqualToString:@"getGPSDistanceValue:"]) {
                    [slider addTarget:self
                               action:@selector(getGPSDistanceValue:)
                     forControlEvents:UIControlEventValueChanged];
                    NSString *gpsAccuracy = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.distanceSettingForGPS];
                    float value = [gpsAccuracy floatValue];
                    slider.value = value;
                    labelDistanceGPS = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [labelDistanceGPS setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [labelDistanceGPS setTextColor:[UIColor redColor]];
                    [labelDistanceGPS setText:gpsAccuracy];
                    [self.view addSubview:labelDistanceGPS];
                    
                } else if ([targetVal isEqualToString:@"gpsAccuracyValue:"]) {
                    
                    [slider addTarget:self
                               action:@selector(gpsAccuracyValue:)
                     forControlEvents:UIControlEventValueChanged];
                    
                    //slider.value = sharedVisitsAndTracking.minimumGPSAccuracy;
                    
                    
                    
                    NSString *distanceSet = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.minimumGPSAccuracy];
                    float value = [distanceSet floatValue];
                    slider.value = value;
                    
                    
                    gpsAccuracyLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [gpsAccuracyLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [gpsAccuracyLabel setTextColor:[UIColor redColor]];
                    [gpsAccuracyLabel setText:distanceSet];
                    [self.view addSubview:gpsAccuracyLabel];
                    
                } else if ([targetVal isEqualToString:@"getPollingFrequency:"]) {
                    
                    [slider addTarget:self
                               action:@selector(getNetworkValue:)
                     forControlEvents:UIControlEventValueChanged];
                    
                    //slider.value = sharedVisitsAndTracking.updateFrequencySeconds;
                    NSString *distanceSet = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.updateFrequencySeconds];
                    
                    float value = [distanceSet floatValue];
                    slider.value = value;
                    
                    networkStatusUpdateGPSLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [networkStatusUpdateGPSLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [networkStatusUpdateGPSLabel setTextColor:[UIColor redColor]];
                    [networkStatusUpdateGPSLabel setText:distanceSet];
                    [self.view addSubview:networkStatusUpdateGPSLabel];
                    
                } else if ([targetVal isEqualToString:@"getNumberCoordinatesTransmitValue:"]) {
                    [slider addTarget:self
                               action:@selector(getNumberCoordinatesTransmitValue:)
                     forControlEvents:UIControlEventValueChanged];
                    
                    //slider.value = sharedVisitsAndTracking.minNumCoordinatesSend;
                    NSString *numCoordString = [NSString stringWithFormat:@"%i",sharedVisitsAndTracking.minNumCoordinatesSend];
                    float value = [numCoordString floatValue];
                    slider.value = value;
                    
                    numCoordinatesUpdateGPSLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, slider.frame.origin.y, 80, 20)];
                    [numCoordinatesUpdateGPSLabel setFont:[UIFont fontWithName:@"Lato-Light" size:16]];
                    [numCoordinatesUpdateGPSLabel setTextColor:[UIColor redColor]];
                    [numCoordinatesUpdateGPSLabel setText:numCoordString];
                    [self.view addSubview:numCoordinatesUpdateGPSLabel];
                }
                
                [self.view addSubview:sliderLabel];
                [self.view addSubview:slider];
                
            }
            
            else if ([[settingDic objectForKey:@"Type"]isEqualToString:@"UIButton"]) {
                float yVal = [[settingDic objectForKey:@"yPos"]floatValue];
                yVal -= 32.0;
                NSString *labelText = [settingDic objectForKey:@"Name"];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, yVal, 200, 14)];
                [label setFont:[UIFont fontWithName:@"Umhlanga-Regular." size:12]];
                [label setTextColor:[UIColor blackColor]];
                [label setText:labelText];
                [self.view addSubview:label];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                
                button.frame = CGRectMake(label.frame.origin.x  + 200, yVal, 48, 26 );
                [button setImage:[UIImage imageNamed:@"off-button"]
                        forState:UIControlStateNormal];
                
                [button setImage:[UIImage imageNamed:@"on-button"]
                        forState:UIControlStateSelected];
                
                NSString *settingStat = [settingDic objectForKey:@"target"];
                BOOL isOn;
                if([[optionSettings objectForKey:settingStat]boolValue]) {
                    isOn = YES;
                    [button setSelected:YES];
                } else {
                    isOn = NO;
                    [button setSelected:NO];
                }
                
                [button addTarget:self
                           action:@selector(touchButton:)
                 forControlEvents:UIControlEventTouchUpInside];
                
                button.tag = [[settingDic objectForKey:@"tagID"]intValue];
                
                [self.view addSubview:button];
                
            }
            
        }
        
    }
        
    UIButton *logoutButton =[UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = CGRectMake(self.view.frame.size.width - 40, 40, 32, 32);
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"logout-button"] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutApp) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:logoutButton];
}


-(void) calculatePay:(id)sender {

	//UIView *payView = [[UIView alloc] initWithFrame:CGRectMake(20, 80, self.view.frame.size.width - 40, self.view.frame.size.height - 100)];
	int totalPay = 0;

	for(VisitDetails *visit in sharedVisitsAndTracking.visitData) {
		int visitPay = [visit.payRate intValue];
		totalPay += visitPay;
	}


}

-(void)touchButton:(id)sender {
    
    if([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *touchedButton = (UIButton*)sender;
        
        int tagButton = (int)touchedButton.tag;
        
        if(touchedButton.selected) {
            
            [touchedButton setSelected:NO];
            
        } else {
            
            [touchedButton setSelected:YES];
            
        }
        
        for(NSDictionary *settingDic in settingsData) {
            
            NSString *settingName = [settingDic objectForKey:@"target"];
            NSString *tagIDVal = [settingDic objectForKey:@"tagID"];
            int tagIDmatch = [tagIDVal intValue];
            
            if(tagButton == tagIDmatch) {
                            
                [optionSettings setObject:[NSNumber numberWithBool:touchedButton.isSelected] forKey:settingName];
                
            }
        }
        [sharedVisitsAndTracking readSettings];

    }
}
-(void) getGPSDistanceValue:(UISlider *)paramSender {
    sharedVisitsAndTracking.distanceSettingForGPS = paramSender.value;
    NSNumber *gpsDistNum = [NSNumber numberWithInt:paramSender.value];
    [optionSettings setObject:gpsDistNum forKey:@"distanceSettingForGPS"];
    [labelDistanceGPS setText:[NSString stringWithFormat:@"%i",[gpsDistNum intValue]]];
    
    
}
-(void) getNumberCoordinatesTransmitValue:(UISlider*)paramSender {
    sharedVisitsAndTracking.minNumCoordinatesSend = paramSender.value;
    NSNumber *getNumCoordTransmitNum = [NSNumber numberWithInt:paramSender.value];
    [optionSettings setObject:getNumCoordTransmitNum forKey:@"minNumCoordinatesSend"];
    [numCoordinatesUpdateGPSLabel setText:[NSString stringWithFormat:@"%i",[getNumCoordTransmitNum intValue]]];
    
}
-(void) getNetworkValue:(UISlider*)paramSender {
    sharedVisitsAndTracking.updateFrequencySeconds = paramSender.value;
    NSNumber *getNumCoordTransmitNum = [NSNumber numberWithInt:paramSender.value];
    [optionSettings setObject:getNumCoordTransmitNum forKey:@"updateFrequencySeconds"];
    [networkStatusUpdateGPSLabel setText:[NSString stringWithFormat:@"%i",[getNumCoordTransmitNum intValue]]];
}
-(void) gpsAccuracyValue:(UISlider*)paramSender {
    sharedVisitsAndTracking.minimumGPSAccuracy = paramSender.value;
    NSNumber *getAccuracy = [NSNumber numberWithInt:paramSender.value];
    [optionSettings setObject:getAccuracy forKey:@"minimumGPSAccuracy"];
    [gpsAccuracyLabel setText:[NSString stringWithFormat:@"%i",[getAccuracy intValue]]];
    
    
}

/*
-(void)cleanUpLogFiles {
    
    NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    NSArray *values = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allValues];
    
    for (int i = 0; i < keys.count; i++) {
        
        if([[values objectAtIndex:i]isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *val = (NSDictionary*)[values objectAtIndex:i];
            
            if([[val objectForKey:@"type"]isEqualToString:@"network"]) {
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[keys objectAtIndex:i]];
                //NSLog(@"removed");

                
            }
        }
        
        if([[values objectAtIndex:i]isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *val = (NSDictionary *)[values objectAtIndex:i];
            if([[val objectForKey:@"type"]isEqualToString:@"location"]) {
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[keys objectAtIndex:i]];
                //NSLog(@"removed");

                
            }
        }
        
        if([[values objectAtIndex:i]isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *val = (NSDictionary*)[values objectAtIndex:i];
            if([[val objectForKey:@"type"]isEqualToString:@"GPS upload"]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[keys objectAtIndex:i]];

                
            }
        }
    }
    
    [self removeFiles];

}
-(void)sendLogToServer {
    
    
}
- (NSArray*)showFiles
{
    
    NSMutableArray *fileListArray = [[NSMutableArray alloc]init];
    BOOL isDirectory;
    NSString *entry;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [fileMgr changeCurrentDirectoryPath:documentsDir];
    NSDirectoryEnumerator *enumerator = [fileMgr enumeratorAtPath:documentsDir];
    
    while ((entry = [enumerator nextObject]) != nil)
    {
        if ([fileMgr fileExistsAtPath:entry isDirectory:&isDirectory] && isDirectory) {
            
            NSLog (@"Directory - %@", entry);
            [fileListArray addObject:entry];
            
        } else {
            
            NSLog (@"  File - %@", entry);
            [fileListArray addObject:entry];
            
        }
    }
    return fileListArray;
}
-(void)removeFiles {
    
    BOOL isDirectory;
    NSString *entry;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [fileMgr changeCurrentDirectoryPath:documentsDir];
    NSDirectoryEnumerator *enumerator = [fileMgr enumeratorAtPath:documentsDir];
    
    while ((entry = [enumerator nextObject]) != nil)
    {
        if ([fileMgr fileExistsAtPath:entry isDirectory:&isDirectory] && isDirectory) {
            
            NSLog (@"Directory - %@", entry);
            
        } else {
            
            NSLog (@"  File - %@", entry);
            
            BOOL deleteFile = YES;
            
            for (VisitDetails *visit in sharedVisitsAndTracking.visitData) {
                
                NSString *matchFileString = [NSString stringWithFormat:@"%@-visitdetails",visit.appointmentid];
                NSString *matchFileString2 = [NSString stringWithFormat:@"%@-coordinates",visit.appointmentid];
                
                if ([matchFileString isEqualToString:entry] || [matchFileString2 isEqualToString:entry]) {
                    deleteFile = NO;
                }
            }
            
            if (deleteFile) {
                BOOL success = [fileMgr removeItemAtPath:entry error:nil];
                if(success) NSLog(@"removed file: %@",entry);
            }
        }
    }
}
 */

@end
