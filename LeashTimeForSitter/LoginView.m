//
//  LoginView.m
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 6/20/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import "LoginView.h"
#import "VisitsAndTracking.h"
#import "PharmaStyle.h"

@interface LoginView() {
    
    VisitsAndTracking *sharedVisits;
    
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
    
    UITextField *loginName;
    UITextField *passWord;
    UIButton *loginButton;
    UIImageView *loginTextBox;
    UIImageView *passwordText;
    UILabel *logStatus;
    UIView *connectStatusBannerView;
}


@end

@implementation LoginView

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [PharmaStyle colorBlueShadow];
        sharedVisits = [VisitsAndTracking sharedInstance];
        [self addNotificationObservers];
        
        NSString *theDeviceType = [sharedVisits tellDeviceType];
        UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 70, 177, 156)];
        UIImageView *careProvider = [[UIImageView alloc]initWithFrame:CGRectMake(100, 235, 215, 42)];
        
        loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"btn-enter"] forState:UIControlStateNormal];
        [loginButton addTarget:self
                         action:@selector(loginButtonClick:) 
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginButton];
            
        if ([theDeviceType isEqualToString:@"iPhone6P"]) {
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 70, 177, 156)];
        }
        else if ([theDeviceType isEqualToString:@"XR"]) {
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 70, 177, 156)];
        }  
        else if ([theDeviceType isEqualToString:@"X"]) {
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 40, 177, 156)];
        }
        else if ([theDeviceType isEqualToString:@"iPhone5"]) {
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 70, 177, 156)];
        } else {
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 70, 177, 156)];
        }
                
        careProvider = [[UIImageView alloc]initWithFrame:CGRectMake(81, logoView.frame.origin.y  + 165, 215, 42)];
        loginTextBox = [[UIImageView alloc]initWithFrame:CGRectMake(67,logoView.frame.origin.y + 200, 240, 40)];
        passwordText = [[UIImageView alloc]initWithFrame:CGRectMake(67,loginTextBox.frame.origin.y + 45, 240,40)];
        
        
        loginButton.frame = CGRectMake(103,passwordText.frame.origin.y + 45,172, 60);
        
        
        [logoView setImage:[UIImage imageNamed:@"icon-brand"]];
        [self addSubview:logoView];
        
        [loginTextBox setImage:[UIImage imageNamed:@"btn-login-text"]];
        [self addSubview:loginTextBox];
        
        [careProvider setImage:[UIImage imageNamed:@"careProvider"]];
        [self addSubview:careProvider];
        
        loginName = [[UITextField alloc]initWithFrame:CGRectMake(loginTextBox.frame.origin.x + 20,loginTextBox.frame.origin.y,loginTextBox.frame.size.width, loginTextBox.frame.size.height)];
        [loginName setClearsOnBeginEditing:YES];
        [loginName setBorderStyle:UITextBorderStyleNone];
        [loginName setFont:[UIFont fontWithName:@"Lato-Light" size:22]];
        [loginName setTextColor:[UIColor blackColor]];
        loginName.autocapitalizationType = UITextAutocapitalizationTypeNone;
        loginName.autocorrectionType = UITextAutocorrectionTypeNo;
		//loginName.delegate = self;
		loginName.tag = 1;
        [self addSubview:loginName];
        
        NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
        NSString *userName = [loginSetting objectForKey:@"username"];
        
        loginName.text = userName;
        
        [passwordText setImage:[UIImage imageNamed:@"btn-login-text"]];
        [self addSubview:passwordText];
        
        passWord = [[UITextField alloc]initWithFrame:CGRectMake(passwordText.frame.origin.x + 20,passwordText.frame.origin.y ,passwordText.frame.size.width, passwordText.frame.size.height)];
        [passWord setClearsOnBeginEditing:YES];
        [passWord setBorderStyle:UITextBorderStyleNone];
        [passWord setSecureTextEntry:YES];
        [passWord setTextColor:[UIColor blackColor]];
        passWord.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passWord.autocorrectionType = UITextAutocorrectionTypeNo;
		passWord.tag = 2;
		passWord.delegate = self;
        
        [self addSubview:passWord];
        UILabel *versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height-20, 360, 20)];
        [versionLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
        [versionLabel setTextColor:[UIColor whiteColor]];
		NSString *buildNumLabel = [NSString stringWithFormat:@"VERSION: %@    BUILD NUM: %@",
                                   [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                   [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"]];
		[versionLabel setText:buildNumLabel];
		[self addSubview:versionLabel];
 
            
    }
    return self;
}

-(void) connectionNotificationUI {
    
    NSArray *connectEl = [connectStatusBannerView subviews];
    for (int i = 0; i < [connectEl count]; i++) {
        id subViewItem = [connectEl objectAtIndex:i];
        if ([subViewItem isKindOfClass:[UILabel class]]) {
            UILabel *labelItem = (UILabel*) subViewItem;
            [labelItem removeFromSuperview];
            labelItem = nil;
        }
    }
    [connectStatusBannerView removeFromSuperview];
    
    
}
-(void) noConnectionNotificationUI {
    connectStatusBannerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width, 60)];
    [connectStatusBannerView setBackgroundColor:[UIColor redColor]];
    [connectStatusBannerView setAlpha:0.75];
    UILabel *noConnectLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    [noConnectLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];
    [noConnectLabel setTextColor:[UIColor whiteColor]];
    [noConnectLabel setText:@"NO CONNECTION"];
    [noConnectLabel setTextAlignment:NSTextAlignmentCenter];
    [connectStatusBannerView addSubview:noConnectLabel];
    [self addSubview:connectStatusBannerView];
}
-(void) addNotificationObservers {
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(connectionNotificationUI)
                                                name:@"reachable"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(noConnectionNotificationUI)
                                                name:@"unreachable"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didNotHaveVisits)
                                                name:@"noVisits"
                                              object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(loginFailed)
                                                name:@"pollingFailed"
                                              object:nil];
    
    
}
-(void)removeObservers {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"noVisits" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"pollingFailed" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reachable" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"unreachable" object:nil];
    
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	if(textField.tag == 1) {
		//[_loginName setTintColor:[UIColor whiteColor]];
	} else {
		//[_passWord setTintColor:[UIColor whiteColor]];
	}	
	return TRUE;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
	if(textField.tag == 1) {
		//[_loginName setTintColor:[UIColor whiteColor]];
	} else {
		//[_passWord setTintColor:[UIColor whiteColor]];
	}	
	return TRUE;

}
-(void) loginButtonClick:(id)sender {
    [logStatus removeFromSuperview];
    
    logStatus = [[UILabel alloc]initWithFrame:CGRectMake(loginButton.frame.origin.x,
                                                         loginButton.frame.origin.y - 158,
                                                         loginButton.frame.size.width,
                                                         loginButton.frame.size.height)];
    
    [logStatus setBackgroundColor:[UIColor clearColor]];
    [logStatus setFont:[UIFont fontWithName:@"Lato-Light" size:18]];
    [logStatus setTextAlignment:NSTextAlignmentCenter];
    [logStatus setTextColor:[UIColor yellowColor]];
    [logStatus setText:@"Logging in ... "];
    [logStatus setAlpha:1.0];
    
    UILabel *logStatusTmp = logStatus;
    NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
    NSString *userName;

    if ([loginName.text isEqualToString:@""]) {
        userName = @"";
        [logStatus setText:@"NO LOGIN NAME"];

    } else if ([loginName.text length] > 1){
        userName = loginName.text;
        [loginSetting setObject:userName forKey:@"username"];
    }
    NSString *password = passWord.text;
    //password = @"QVX992DISABLED";
   // NSLog(@"password: %@",_passWord.text);
    [self addSubview:logStatusTmp];

    if ([password isEqualToString:@""]) {
        [logStatus setText:@"NO PASSWORD"];
        
    } else {
        [loginSetting setObject:password forKey:@"password"];
        
        NSDate *todayDate = [NSDate date];
        
        [sharedVisits networkRequest:todayDate toDate:todayDate];
        
        if ([sender isKindOfClass:[UIButton class]]) {
            
            UIButton *loginButton = (UIButton*)sender;
            [loginButton setUserInteractionEnabled:FALSE];
            [UIView animateWithDuration:0.3 animations:^{
                loginButton.frame = CGRectMake(loginButton.frame.origin.x - 5,
                                               loginButton.frame.origin.y - 5,
                                               loginButton.frame.size.width +5,
                                               loginButton.frame.size.height -5);
                [loginButton setAlpha:0.5];
                
            } completion:^(BOOL finished) {
                [loginButton setAlpha:0.5];
                loginButton.frame = CGRectMake(loginButton.frame.origin.x + 5,
                                               loginButton.frame.origin.y + 5,
                                               loginButton.frame.size.width -5,
                                               loginButton.frame.size.height +5);
                
                [loginButton setUserInteractionEnabled:TRUE];
            }];
        }
    }
}
-(void) successFullLogin {

    loginName.delegate = nil;
    passWord.delegate  = nil;
    
    NSArray *subVArr = [self subviews];
    for (id v in subVArr) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *vButton = (UIButton*)v;
            [vButton removeFromSuperview];
            vButton =nil;
        } else if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *vButton = (UIImageView*)v;
            [vButton removeFromSuperview];
            vButton =nil;
        } else if ([v isKindOfClass:[UILabel class]]) {
            UILabel *vButton = (UILabel*)v;
            [vButton removeFromSuperview];
            vButton =nil;
        } else if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *vButton = (UIImageView*)v;
            [vButton removeFromSuperview];
            vButton =nil;
        } else if ([v isKindOfClass:[UITextField class]]) {
            UITextField *vButton = (UITextField*)v;
            [vButton removeFromSuperview];
            vButton =nil;
        } 
    }
     [self removeObservers];
}
-(void) didNotHaveVisits {
    
    sharedVisits.firstLogin = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loginNoVisits" object:self];
}
-(void) loginFailed {

    [loginButton setUserInteractionEnabled:TRUE];
    [passWord setText:@""];
    
    NSString *failureCodeString;

    passWord.text = @"";
    
    if ([sharedVisits.pollingFailReasonCode isEqualToString:@"S"]) {
        failureCodeString = @"SITTER MOBILE APP NOT ENABLED FOR BUSINESS";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"P"]) {
        failureCodeString = @"UNKNOWN ACCOUNT INFO [P]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"U"]) {
        failureCodeString = @"UNKNOWN ACCOUNT INFO  [U]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"I"]) {
		failureCodeString = @"UNKNOWN ACCOUNT INFO [I]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"F"]) {
        failureCodeString = @"NO BUSINESS FOUND [F]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"B"]) {
        failureCodeString = @"BUSINESS INACTIVE [B]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"M"]) {
        failureCodeString = @"MISSING ORGANIZATION [M]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"O"]) {
        failureCodeString = @"ORGANIZATION INACTIVE [O]";
	} else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"R"]) {
        failureCodeString = @"RIGHTS MISSING. CONTACT support@leashtime.com";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"C"]) {
        failureCodeString = @"NO COOKIE [C]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"L"]) {
        failureCodeString = @"ACCOUNT LOCKED [L]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"X"]) {
        failureCodeString = @"NOT A SITTER ACCOUNT [X]";
    } else if ([sharedVisits.pollingFailReasonCode isEqualToString:@"T"]) {
        failureCodeString = @"TEMP PASSWORD [T]";
    } else if([sharedVisits.pollingFailReasonCode isEqualToString:@"OK"]) {
        failureCodeString = @"SUCCESSFUL LOGIN";
    } else {
        failureCodeString = @"PROBLEM WITH NETWORK";
    }
    
    logStatus.text = failureCodeString;
    
}
-(void) viewWillDisappear:(BOOL)animated {

}
-(void)dealloc {
    
    //NSLog(@"Dealloc Login View");
    [self removeObservers];
    loginButton = nil;
    loginName = nil;
    passWord = nil;
	
}
-(void)successfullPassSet {
	
}
-(void)reachabilityChanged {
    
}


@end
