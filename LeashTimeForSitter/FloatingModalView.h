//
//  FloatingModalView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 9/24/17.
//  Copyright © 2017 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitsAndTracking.h"


@interface FloatingModalView: UIView <UITextViewDelegate>
	
-(void)show;
-(instancetype)initWithFrame:(CGRect)frame type:(NSString*)type;
-(instancetype)initWithFrame:(CGRect)frame itemType:(NSString*)itemType andTagNum:(int)tagNum;
-(instancetype)initWithFrame:(CGRect)frame appointmentID:(NSString*)appointmentID itemType:(NSString*)itemType;
-(instancetype)initWithFrame:(CGRect)frame appointmentID:(NSString*)appointmentID itemType:(NSString*)itemType andTagNum:(int)tagNum; 
@end
