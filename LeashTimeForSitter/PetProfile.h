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
-(void) addProfileImage:(UIImage*) profileImage;
-(void)addProfileImageData:(NSData*)profileImageData;
-(UIImage*) getProfilePhoto;
-(NSArray*) getCustomPetFields;
-(NSArray*) getPetErrataDoc;
-(NSString*) getPetID;
//-(NSMutableDictionary*) getBasicPetInfo;
-(NSString*) getPetName;
-(NSString*) getPetBreed;
-(NSString*) getPetGender;
-(NSString*) getPetColor;
-(NSString*) getPetType;
-(NSString*) getPetBirthday;
-(NSString*) getFixed;
-(NSString*) getPetDescription ;
-(NSString*) getPetNote;
-(void) removePhoto;
@end

NS_ASSUME_NONNULL_END
