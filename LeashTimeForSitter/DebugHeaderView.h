//
//  DebugHeaderView.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 6/17/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugHeaderView : UIView
-(void)updateViewMarkComplete;
-(void)cleanView;
-(void)showUserErrorLog;
@end

NS_ASSUME_NONNULL_END
