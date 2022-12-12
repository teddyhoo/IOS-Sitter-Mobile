//
//  VisitNoteView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 12/29/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitDetails.h"
#import "DataClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface VisitNoteView : UIView

-(instancetype)initWithFrame:(CGRect)frame 
                   visitInfo:(VisitDetails*)visit 
                  clientInfo:(DataClient*)client 
                  parentView:(UIView*)parent;


@end

NS_ASSUME_NONNULL_END
