//
//  PetProfile.h
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 1/31/21.
//  Copyright © 2021 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PetProfile : NSObject


-(void) initWithData:(NSDictionary*)petProfileDictionary withClientID:(NSString*) clientID;
-(UIImage*) getProfilePhoto;
-(NSArray*) getVisitPhotos:(NSDate*)startDate untilDate:(NSDate*)endDate;

@end

NS_ASSUME_NONNULL_END
