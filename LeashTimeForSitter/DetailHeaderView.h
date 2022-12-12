//
//  DetailHeaderView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 1/3/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitsAndTracking.h"
#import "DataClient.h"
#import "VisitDetails.h"

@interface DetailHeaderView : UIView

-(instancetype) initWithFrame:(CGRect)frame andClientData:(DataClient*)clientDetails withVisitIInfo:(VisitDetails*)visitInfo;
-(void)addPetImages;


@end
