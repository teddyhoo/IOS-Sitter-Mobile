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
    
    NSMutableArray *customPetFields;
    NSMutableArray *customPetCheckBoxes;
    NSMutableArray *errataDocPet;
    
    UIImage *petProfileImage;
    
    
}
@end



@implementation PetProfile


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
                //NSLog(@" FOR KEY: %@ --> VAL IS NULL - ignore", key);
            } 
            else if ([[customPetField objectForKey:@"value"] isEqualToString:@"0"] || 
                       [[customPetField objectForKey:@"value"] isEqualToString:@"1"]) {
                
                [customPetCheckBoxes addObject:customPetField];
            }
            else {                
                [customPetFields addObject:customPetField];
            }
        }
    }    
    /*NSLog(@"\n----------------------------------------\nPET INFO for ID: %@\n----------------------------------------\n", petID);
    NSLog(@"Name: %@", name);
    NSLog(@"Breed: %@", breed);
    NSLog(@"Gender: %@", gender);
    NSLog(@"Type: %@", type);
    NSLog(@"Color: %@", color);
    NSLog(@"--------------------");
    NSLog(@"Notes: %@",notes);
    NSLog(@"Description: %@", description);*/
    
    NSLog(@"------------CUSTOM PET FIELDS---------------------\n");
    for (NSDictionary *customDictArray  in customPetFields) {
        NSString *customPetLabel = [customDictArray objectForKey:@"label"];
        NSString *customPetVal = [customDictArray objectForKey:@"value"];
        NSString *serverCustVal = [customDictArray objectForKey:@"serverkey"];
        //NSLog(@"[%@]  %@ -> %@", serverCustVal, customPetLabel, customPetVal );
    }
    
    NSLog(@"------------CUSTOM PET CHECBOXES---------------------\n");
    for (NSDictionary *checkDic in customPetCheckBoxes) {

        if ([[checkDic objectForKey:@"value"] isEqualToString:@"1"]) {
            //NSLog(@"%@ : YES", [checkDic objectForKey:@"label"]); 
            
        } else {
            //NSLog(@"%@ : NO", [checkDic objectForKey:@"label"]); 

        }
    }
    
    NSLog(@"------------CUSTOM PET ERRATA---------------------\n");
    for (NSDictionary *errata in errataDocPet) {
        //NSLog(@" %@ of Type: %@", [errata objectForKey:@"label"], [errata objectForKey:@"mimetype"]);
        //NSLog(@"URL: %@", [errata objectForKey:@"url"]);
    }

}

-(UIImage *)getProfilePhoto {
    
    NSData *data  = [[NSData alloc]init];
    return [UIImage imageWithData:data ];
    
}


-(NSArray*) getVisitPhotos:(NSDate *)startDate untilDate:(NSDate *)endDate {
    
    return [[NSArray alloc]init];
    
}


-(BOOL) checkStringNull:(NSString*)profileString {
    if (![profileString isEqual:[NSNull null]] && [profileString length] > 0) {
        return YES;
    } else {        
        return NO;
    }
}


@end
