//
//  SitterPay.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 10/15/17.
//  Copyright © 2017 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SitterPay : NSObject

@property (nonatomic,strong) NSDate *visitDate;
@property (nonatomic,strong) NSDate *visitArrive;
@property (nonatomic,strong) NSDate *visitComplete;
@property (nonatomic,strong) NSString *visitStatus;
@property (nonatomic,strong) NSString *serviceName;
@property (nonatomic,strong) NSString *visitID;
@property (nonatomic,strong) NSString *payRate;

@end
