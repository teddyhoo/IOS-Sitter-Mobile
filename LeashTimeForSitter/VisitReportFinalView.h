//
//  VisitReportFinalView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 12/27/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitDetails.h"
#import "DataClient.h"
#import "VisitProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VisitReportFinalView : UIView


-(instancetype)initWithFrame:(CGRect)frame 
                   visitInfo:(VisitDetails*)visit 
                  clientInfo:(DataClient*)client 
                  parentView:(VisitProgressView*)parent;


@end

NS_ASSUME_NONNULL_END
