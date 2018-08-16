//
//  FloatingModalView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 9/24/17.
//  Copyright © 2017 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitsAndTracking.h"


@interface FloatingModalView: UIView 
	
@property(nonatomic,strong) VisitsAndTracking* sharedVisits;

-(void)show;
-(instancetype)initWithFrame:(CGRect)frame appointmentID:(NSString*)appointmentID itemType:(NSString*)itemType;
-(instancetype)initWithFrame:(CGRect)frame appointmentID:(NSString*)appointmentID itemType:(NSString*)itemType andTagNum:(int)tagNum; 
@end
