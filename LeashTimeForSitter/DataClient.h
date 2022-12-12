//
//  DataClient.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/17/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMAccordionSection.h"

@interface DataClient : NSObject

@property (nonatomic,copy)NSString *clientID;
@property (nonatomic,copy)NSString *sortName;
@property (nonatomic,copy)NSString *clientName;
@property (nonatomic,copy)NSString *homePhone;
@property (nonatomic,copy)NSString *firstName;
@property (nonatomic,copy)NSString *firstName2;
@property (nonatomic,copy)NSString *lastName;
@property (nonatomic,copy)NSString *lastName2;
@property (nonatomic,copy)NSString *email;
@property (nonatomic,copy)NSString *email2;
@property (nonatomic,copy)NSString *workphone;
@property (nonatomic,copy)NSString *cellphone;
@property (nonatomic,copy)NSString *cellphone2;
@property (nonatomic,copy)NSString *street1;
@property (nonatomic,copy)NSString *street2;
@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *state;
@property (nonatomic,copy)NSString *zip;
@property (nonatomic,copy)NSString *garageGateCode;
@property (nonatomic,copy)NSString *alarmCompany;
@property (nonatomic,copy)NSString *alarmCompanyPhone;
@property (nonatomic,copy)NSString *alarmInfo;
@property (nonatomic,copy)NSString *keyDescriptionText;
@property (nonatomic,copy)NSString *emergencyName;
@property (nonatomic,copy)NSString *emergencyCellPhone;
@property (nonatomic,copy)NSString *emergencyWorkPhone;
@property (nonatomic,copy)NSString *emergencyHomePhone;
@property (nonatomic,copy)NSString *emergencyLocation;
@property (nonatomic,copy)NSString *emergencyNote;
@property (nonatomic,copy)NSString *emergencyHasKey;
@property (nonatomic,copy)NSString *trustedNeighborName;
@property (nonatomic,copy)NSString *trustedNeighborCellPhone;
@property (nonatomic,copy)NSString *trustedNeighborWorkPhone;
@property (nonatomic,copy)NSString *trustedNeighborHomePhone;
@property (nonatomic,copy)NSString *trustedNeighborLocation;
@property (nonatomic,copy)NSString *trustedNeighborNote;
@property (nonatomic,copy)NSString *trustedNeighborHasKey;
@property (nonatomic,copy)NSString *leashLocation;
@property (nonatomic,copy)NSString *foodLocation;
@property (nonatomic,copy)NSString *parkingInfo;
@property(nonatomic,copy)NSString *directionsInfo;
@property(nonatomic,copy)NSString *basicInfoNotes;
@property (nonatomic,copy)NSString *clinicName;
@property (nonatomic,copy)NSString *clinicStreet1;
@property (nonatomic,copy)NSString *clinicStreet2;
@property (nonatomic,copy)NSString *clinicPhone;
@property (nonatomic,copy)NSString *clinicCity;
@property (nonatomic,copy)NSString *clinicLat;
@property (nonatomic,copy)NSString *clinicLon;
@property (nonatomic,copy)NSString *clinicZip;
@property (nonatomic,copy)NSString *clinicPtr;
@property (nonatomic,copy)NSString *vetPtr;
@property (nonatomic,copy)NSString *vetName;
@property (nonatomic,copy)NSString *vetCity;
@property (nonatomic,copy)NSString *vetPhone;
@property (nonatomic,copy)NSString *vetStreet1;
@property (nonatomic,copy)NSString *vetStreet2;
@property (nonatomic,copy)NSString *vetZip;
@property (nonatomic,copy)NSString *vetState;
@property (nonatomic,copy)NSString *vetLat;
@property (nonatomic,copy)NSString *vetLon;

@property BOOL noKeyRequired;
@property BOOL useKeyDescriptionInstead;
@property (nonatomic,copy)NSString *hasKey;
@property (nonatomic,copy)NSString *keyID;

-(void)createClientProfile:(NSDictionary*)clientProfile;

-(NSMutableArray*)getPetInfo; 
-(NSArray*) getFlags;
-(NSArray*) getPetProfiles;
-(NSMutableArray*) getCustomFields;
-(NSMutableArray*) getErrataDocs;

-(void) cleanDataClientData;



-(void)addPetImage:(NSString*)petID andImageData:(NSData*)imageData;
-(NSMutableDictionary*) getPetImages;
-(EMAccordionSection*)getAccordionSection:(NSString*)name;

-(NSMutableDictionary *) getCustomClientCheckBox;
-(void)handleCustomClientFields:(NSDictionary*)customClientFields;

@end
