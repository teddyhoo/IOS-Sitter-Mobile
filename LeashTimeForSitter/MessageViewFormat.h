
//
//  MessageViewFormat.h
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 10/10/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitDetails.h"
#import "VisitsAndTracking.h"

@interface MessageViewFormat : UIView

-(id)initWithFrame:(CGRect)frame andVisitID:(NSString*)visitID andCheckMarkCoord:(float)checkPoint;

@end
