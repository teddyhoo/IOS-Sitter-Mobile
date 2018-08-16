//
//  LoginView.h
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 6/20/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *loginName;
@property (nonatomic,strong) UITextField *passWord;
@property (nonatomic,strong) UIButton *loginButton;
@property (nonatomic,strong) UILabel *failedLogin;

@end
