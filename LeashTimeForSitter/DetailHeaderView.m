//
//  DetailHeaderView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 12/18/18.
//  Copyright © 2018 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VisitsAndTracking.h"
#import "DataClient.h"
#import "VisitDetails.h"

@interface DetailHeaderView : UIView {
 
    
}
@end

@implementation DetailHeaderView

-(instancetype) initWithFrame:(CGRect)frame andClientData:(DataClient*)clientDetails withVisitIInfo:(VisitDetails*)visitInfo {
    
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/*-(instancetype) initWithFrame:(CGRect)frame withClientID:(DataClient.*)clientInfo {
    [self initWithFrame:frame];
}*/

@end
