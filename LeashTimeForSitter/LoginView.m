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
}


@end

@implementation LoginView

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [PharmaStyle colorBlueShadow];
        sharedVisits = [VisitsAndTracking sharedInstance];
		
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(reachabilityChanged)
                                                    name:@"reachable"
                                                  object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(didNotHaveVisits)
                                                    name:@"noVisits"
                                                  object:nil];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(loginFailed)
                                                    name:@"pollingFailed"
                                                  object:nil];
		
		[[NSNotificationCenter defaultCenter]addObserver:self 
												selector:@selector(successFullLogin) 
													name:@"loginSuccess" 
												  object:NULL];

        
        NSString *theDeviceType = [sharedVisits tellDeviceType];
        
        float x_logo_big_upper_right_corner = 5;
        float y_logo_big_upper_right_corner = 15;
        
        float x_logo_size = 80;
        float y_logo_size = 80;
        
        float x_LT = 100;
        float y_LT = 10;
        
        UIImageView *loginTextBox;
        UIImageView *passwordText;
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"login-red-200"] forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_loginButton];

		UIImageView *logoView;
		UIImageView *logoView2;
		UIImageView *logoView3;
		NSString *pListData = [[NSBundle mainBundle]
							   pathForResource:@"/leashtime-logo-big@3x"
							   ofType:@"png"];
		NSString *pListData2 = [[NSBundle mainBundle]
								pathForResource:@"/leashtime-logo-text@3x"
								ofType:@"png"];
		NSString *pListData3 = [[NSBundle mainBundle]
								pathForResource:@"/sit-stay-propser-compassrose@3x"
								ofType:@"png"];
		
        if ([theDeviceType isEqualToString:@"iPhone6P"]) {
 
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(x_logo_big_upper_right_corner, y_logo_big_upper_right_corner, x_logo_size, y_logo_size)];
            logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(x_LT,y_LT, 160,44)];
			logoView3 = [[UIImageView alloc]initWithFrame:CGRectMake(90,60, 180,40)];
            isIphone6P = YES;
            loginTextBox = [[UIImageView alloc]initWithFrame:CGRectMake(50,120, 300, 30)];
            passwordText = [[UIImageView alloc]initWithFrame:CGRectMake(50,160, 300,30)];
            _loginButton.frame = CGRectMake(100,250,170, 48);
        }
        else if ([theDeviceType isEqualToString:@"iPhone6"]) {
            
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(20, y_logo_big_upper_right_corner, x_logo_size, y_logo_size)];
            logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(x_LT,y_LT, 220,68)];
            logoView3 = [[UIImageView alloc]initWithFrame:CGRectMake(150,70, 180,40)];            
            isIphone6 = YES;
            loginTextBox = [[UIImageView alloc]initWithFrame:CGRectMake(20,120, 300, 30)];
            passwordText = [[UIImageView alloc]initWithFrame:CGRectMake(20,160, 300,30)];
            _loginButton.frame = CGRectMake(100,250,170, 48);

        }
        else if ([theDeviceType isEqualToString:@"iPhone5"]) {

            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 80, 80)];
            logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 220,10, 200,58)];
            logoView3 = [[UIImageView alloc]initWithFrame:CGRectMake(110,70, 160,30)];
            isIphone5 = YES;
            loginTextBox = [[UIImageView alloc]initWithFrame:CGRectMake(40,120, 240, 24)];
            passwordText = [[UIImageView alloc]initWithFrame:CGRectMake(40,160, 240,24)];
            _loginButton.frame = CGRectMake(80,200,160, 44);
        }
        else {
            logoView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 80, 80)];
            logoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 220,10, 200,58)];
            logoView3 = [[UIImageView alloc]initWithFrame:CGRectMake(110,70, 160,30)];
            loginTextBox = [[UIImageView alloc]initWithFrame:CGRectMake(40,120, 240, 32)];
            passwordText = [[UIImageView alloc]initWithFrame:CGRectMake(40,160, 240,32)];
            _loginButton.frame = CGRectMake(120,200,100, 28);
        }
		
		logoView3.image = [UIImage imageWithContentsOfFile:pListData3];
		logoView2.image = [UIImage imageWithContentsOfFile:pListData2];
		logoView2.backgroundColor = [UIColor clearColor];
		logoView2.alpha = 1.0;
		logoView.image = [UIImage imageWithContentsOfFile:pListData];
		logoView.backgroundColor = [UIColor clearColor];
		logoView.alpha = 1.0;

		[self addSubview:logoView];
		[self addSubview:logoView2];
		[self addSubview:logoView3];
        [loginTextBox setImage:[UIImage imageNamed:@"username-login-clean"]];
        [self addSubview:loginTextBox];
        
        _loginName = [[UITextField alloc]initWithFrame:CGRectMake(loginTextBox.frame.origin.x + 50,loginTextBox.frame.origin.y,loginTextBox.frame.size.width, loginTextBox.frame.size.height)];
        [_loginName setClearsOnBeginEditing:YES];
        [_loginName setBorderStyle:UITextBorderStyleNone];
        [_loginName setTextColor:[UIColor whiteColor]];
        [_loginName setFont:[UIFont fontWithName:@"Lato-Bold" size:26]];
        _loginName.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _loginName.autocorrectionType = UITextAutocorrectionTypeNo;
		_loginName.delegate = self;
		_loginName.tag = 1;
        [self addSubview:_loginName];
        
        NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
        NSString *userName = [loginSetting objectForKey:@"username"];
        _loginName.text = userName;


        [passwordText setImage:[UIImage imageNamed:@"password-593x68"]];
        [self addSubview:passwordText];
        
        _passWord = [[UITextField alloc]initWithFrame:CGRectMake(passwordText.frame.origin.x + 50,passwordText.frame.origin.y ,passwordText.frame.size.width, passwordText.frame.size.height)];
        [_passWord setClearsOnBeginEditing:YES];
        [_passWord setBorderStyle:UITextBorderStyleNone];
        [_passWord setSecureTextEntry:YES];
        _passWord.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passWord.autocorrectionType = UITextAutocorrectionTypeNo;
		_passWord.tag = 2;
		_passWord.delegate = self;
        
        [self addSubview:_passWord];
        
        
        UILabel *versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height-20, 360, 20)];
        [versionLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
        [versionLabel setTextColor:[UIColor whiteColor]];

		NSString *appVersionString = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *buildNum =[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
		NSString *buildNumLabel = [NSString stringWithFormat:@"VERSION: %@    BUILD NUM: %@",appVersionString,buildNum];
		[versionLabel setText:buildNumLabel];
		[self addSubview:versionLabel];
        
        
        if (!sharedVisits.isReachable) {
            
            _failedLogin = [[UILabel alloc]initWithFrame:CGRectMake(0, _loginButton.frame.origin.y + 70, self.frame.size.width, 20)];
            [_failedLogin setFont:[UIFont fontWithName:@"CompassRoseCPC-Regular" size:18]];
            [_failedLogin setTextColor:[UIColor redColor]];
            [_failedLogin setText:@"NO NETWORK"];
            _failedLogin.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_failedLogin];
            
            
        }
    }
    return self;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	if(textField.tag == 1) {
		[_loginName setTintColor:[UIColor whiteColor]];
	} else {
		[_passWord setTintColor:[UIColor whiteColor]];
	}	
	return TRUE;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
	if(textField.tag == 1) {
		[_loginName setTintColor:[UIColor whiteColor]];
	} else {
		[_passWord setTintColor:[UIColor whiteColor]];
	}	
	return TRUE;

}
-(void)loginButtonClick {

    [_failedLogin setText:@""];
    
    NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];    
    NSString *userName;

    if ([_loginName.text isEqualToString:@""]) {
        userName = @"";

    } else if ([_loginName.text length] > 1){
        userName = _loginName.text;
        [loginSetting setObject:userName forKey:@"username"];

    }
    NSString *password = _passWord.text;
	//password = @"QVX992DISABLED";
   // NSLog(@"password: %@",_passWord.text);
    
    if ([password isEqualToString:@""] && [userName isEqualToString:@""]) {
        
        _failedLogin = [[UILabel alloc]initWithFrame:CGRectMake(120, _loginButton.frame.origin.y + 70, 200, 20)];
        [_failedLogin setFont:[UIFont fontWithName:@"CompassRoseCPC-Regular" size:18]];
        [_failedLogin setTextColor:[UIColor yellowColor]];
        [_failedLogin setText:@"NEED USER NAME AND PASSWORD"];
        [self addSubview:_failedLogin];
        
        
    } else {
        [loginSetting setObject:password forKey:@"password"];

        NSDate *todayDate = [NSDate date];
        
        if (sharedVisits.isReachable) {
			
            [sharedVisits networkRequest:todayDate toDate:todayDate];
			
        }
        
        _failedLogin = [[UILabel alloc]initWithFrame:CGRectMake(120, _loginButton.frame.origin.y + 70, 200, 20)];
        [_failedLogin setFont:[UIFont fontWithName:@"CompassRoseCPC-Regular" size:18]];
        [_failedLogin setTextColor:[UIColor yellowColor]];
        if (sharedVisits.isReachable) {
            [_failedLogin setText:@"LOGGING IN"];
        }
        [self addSubview:_failedLogin];
    }
}

-(void) successFullLogin {
	[_failedLogin setText:@"SUCCESSFUL LOGIN"];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"noVisits" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"pollingFailed" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"reachable" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"successfulLogin" object:nil];
}

-(void) didNotHaveVisits {
    
    [_failedLogin removeFromSuperview];
    sharedVisits.firstLogin = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loginNoVisits" object:self];
}

-(void) loginFailed {
    
	NSLog(@"called login failed in ViewController with failure code string: %@", sharedVisits.pollingFailReasonCode);
    [_failedLogin removeFromSuperview];
    _failedLogin = [[UILabel alloc]initWithFrame:CGRectMake(50, 300, 330, 20)];
    [_failedLogin setFont:[UIFont fontWithName:@"Lato-Regular" size:14]];
    [_failedLogin setTextColor:[UIColor redColor]];
    
    NSString *failureCodeString;
    
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
	} else {
        [_failedLogin setTextColor:[UIColor yellowColor]];
        failureCodeString = @"PROBLEM WITH NETWORK";
    }
    [_failedLogin setText:failureCodeString];
    
    [self addSubview:_failedLogin];
}

-(void) viewWillDisappear:(BOOL)animated {

}

-(void)dealloc {
    
    //NSLog(@"Dealloc Login View");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"noVisits" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"pollingFailed" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"reachable" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"loginSuccess" object:nil];
    _failedLogin = nil;
    _loginButton = nil;
    _loginName = nil;
    _passWord = nil;
	
}

-(void)successfullPassSet {
	[_failedLogin removeFromSuperview];
	[_failedLogin setText:@"TYPE NEW PASSWORD TO LOGIN"];
	[self addSubview:_failedLogin];
	
}

-(void)reachabilityChanged {
	
	[_failedLogin removeFromSuperview];
	
}


@end
