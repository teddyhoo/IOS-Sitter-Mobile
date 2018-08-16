//
//  MySessionManager.h
//  LeashTimeMobileSitter2
//
//  Created by Ted Hooban on 8/13/15.
//  Copyright (c) 2015 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface MySessionManager : AFHTTPSessionManager

+ (instancetype)sharedManager;


@end
