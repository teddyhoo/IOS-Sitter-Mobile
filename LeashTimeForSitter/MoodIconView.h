//
//  MoodIconView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 9/4/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "VisitDetails.h"
#import "DataClient.h"
#import "VisitProgressView.h"

@interface MoodIconView : UIView

-(instancetype)initWithFrame:(CGRect)frame visitInfo:(VisitDetails*)visit clientInfo:(DataClient*)client parentView:(VisitProgressView*)parent;


@end
