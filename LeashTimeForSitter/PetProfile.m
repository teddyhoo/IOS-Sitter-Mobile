//
//  PetProfile.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 1/31/21.
//  Copyright © 2021 Ted Hooban. All rights reserved.
//

#import "PetProfile.h"

@interface PetProfile () {
  
    NSString *clientID;
    NSString *petID;
    NSString *name;
    NSString *color;
    NSString *breed;
    NSString *type;
    NSString *gender;
    NSString *birthday;
    NSString *fixed;
    NSString *description;
    NSString *notes;
    UIImage *petProfileImage;

    NSMutableArray *customPetFields;
    NSMutableArray *customPetCheckBoxes;
    NSMutableArray *errataDocPet;
    
}
@end



@implementation PetProfile

-(void) removePhoto {
    petProfileImage = nil;
}
-(void) addProfileImage:(UIImage *)profileImage {
    petProfileImage = profileImage;
}

-(void)addProfileImageData:(NSData*)profileImageData {
    petProfileImage = [UIImage imageWithData:profileImageData];
    
}
-(UIImage *)getProfilePhoto {
    return petProfileImage;
}
-(NSString*) getPetID {
    return petID;
}
-(NSString*) getPetColor {
    return color;
}
-(NSString*) getPetName {
    return name;
}
-(NSString*) getPetBreed {
    return breed;
}
-(NSString*) getPetGender {
    return gender;
}
-(NSString*) getPetType {
    return type;
}
-(NSString*) getPetBirthday {
    return birthday;
}
-(NSString*) getFixed {
    return fixed;
}
-(NSString*) getPetDescription {
    return description;
}
-(NSString*) getPetNote {
    return notes;
}
-(NSArray*) getPetErrataDoc {
    return errataDocPet;
}
-(NSArray*) getCustomPetFields {
    return customPetFields;
}

-(void)setupBasicProfileInfo:(NSDictionary*) petProfileDictionary {
    
    petID= [petProfileDictionary objectForKey:@"petid"];
    if (![self checkStringNull:petID]) {
        petID = @"NONE";
    }

    name = [petProfileDictionary objectForKey:@"name"];
    if (![self checkStringNull:name]) {
        name = @"NONE";
    }    
    color = [petProfileDictionary objectForKey:@"color"];
    if (![self checkStringNull:color]) {
        color = @"NONE";
    }
    breed = [petProfileDictionary objectForKey:@"breed"];
    if (![self checkStringNull:breed]) {
        breed = @"NONE";
    }
    gender = [petProfileDictionary objectForKey:@"sex"];
    if (![self checkStringNull:gender]) {
        gender = @"NONE";
    } else {
        if ([gender isEqualToString:@"m"]) { 
            gender = @"MALE";
        } else if ([gender isEqualToString:@"f"]) {
            gender = @"FEMALE";
        }
    }
    birthday = [petProfileDictionary objectForKey:@"birthday"];
    if (![self checkStringNull:birthday]) {
        birthday = @"NONE";
    }
    
    fixed = [petProfileDictionary objectForKey:@"fixed"];
    if (![self checkStringNull:fixed]) {
        fixed = @"NONE";
    } else {
        if ([fixed isEqualToString:@"1"]) {
            fixed = @"YES";
        } else {
            fixed = @"NO";
        }
    }
    
    description = [petProfileDictionary objectForKey:@"description"];
    if (![self checkStringNull:description]) {
        description = @"NONE";
    }
    notes = [petProfileDictionary objectForKey:@"notes"];
    if (![self checkStringNull:notes]) {
        notes = @"NONE";
    }
    
    
}
-(void)initWithData:(NSDictionary*)petProfileDictionary withClientID:(NSString*) clientID  {

    clientID = clientID;    
    
    customPetFields = [[NSMutableArray alloc]init];
    errataDocPet = [[NSMutableArray alloc]init];
    customPetCheckBoxes = [[NSMutableArray alloc]init];
    
    [self setupBasicProfileInfo:petProfileDictionary];

    NSArray *petKeys = [petProfileDictionary allKeys];    
    
    for (NSString *key in petKeys) {
        if ([[petProfileDictionary objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *customPetField = [petProfileDictionary objectForKey:key];

            if ([[customPetField objectForKey:@"value"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *errataDictionary = (NSDictionary*)[customPetField objectForKey:@"value"];
                [errataDocPet addObject:errataDictionary];
            } 
            else if ([[customPetField objectForKey:@"value"]isEqual:[NSNull null]]) {
            } 
            else {                
                [customPetFields addObject:customPetField];
            }
        }
    }    
}
-(BOOL) checkStringNull:(NSString*)profileString {
    if (![profileString isEqual:[NSNull null]] && [profileString length] > 0) {
        return YES;
    } else {        
        return NO;
    }
}


@end
