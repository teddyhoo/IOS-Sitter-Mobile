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
@property (nonatomic,strong)NSMutableArray *customClientFields;
@property (nonatomic,strong)NSMutableArray *customClientCheckBox;
@property (nonatomic,strong)NSMutableArray *petInfo;
@property (nonatomic,strong)NSMutableArray *customPetInfo;
@property (nonatomic,strong)NSMutableArray *clientFlagsArray;
@property (nonatomic,strong)NSMutableDictionary *petImages;
@property (nonatomic,strong)NSMutableArray *petsDataRaw;
@property (nonatomic,strong)NSMutableArray *errataDoc;
@property (nonatomic,strong)NSMutableArray *errataProfile;

@property (nonatomic,strong) EMAccordionSection *basicClientInfo;
@property (nonatomic,strong) EMAccordionSection *altClientInfo;
@property (nonatomic,strong) EMAccordionSection *vetInfo;
@property (nonatomic,strong) EMAccordionSection *alarmInfoAccordion;
@property (nonatomic,strong) EMAccordionSection *locationSupplies;
@property (nonatomic,strong) EMAccordionSection *customClientAccordionFields;

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




@property (nonatomic,copy)NSString *petAge;
@property (nonatomic,copy)NSString *petName;
@property (nonatomic,copy)NSString *petBreed;
@property (nonatomic,copy)NSString *petColor;
@property (nonatomic,copy)NSString *petFixed;
@property (nonatomic,copy)NSString *petNotes;
@property (nonatomic,copy)NSString *petDescription;

@property BOOL read;
@property BOOL flag;
@property BOOL garageGateCodeRequired;
@property BOOL alarmInfoRequired;
@property BOOL noKeyRequired;
@property BOOL useKeyDescriptionInstead;
@property BOOL isErrataDoc;
@property (nonatomic,copy)NSString *hasKey;
@property (nonatomic,copy)NSString *keyID;
@property (nonatomic,copy)NSNumber *howManyPets;


@property (nonatomic,copy)NSString *customPet1;
@property (nonatomic,copy)NSString *customPet2;
@property (nonatomic,copy)NSString *customPet3;
@property (nonatomic,copy)NSString *customPet4;
@property (nonatomic,copy)NSString *customPet5;
@property (nonatomic,copy)NSString *customPet6;
@property (nonatomic,copy)NSString *customPet7;
@property (nonatomic,copy)NSString *customPet8;
@property (nonatomic,copy)NSString *customPet9;
@property (nonatomic,copy)NSString *customPet10;
@property (nonatomic,copy)NSString *customPet11;
@property (nonatomic,copy)NSString *customPet12;
@property (nonatomic,copy)NSString *customPet13;
@property (nonatomic,copy)NSString *customPet14;
@property (nonatomic,copy)NSString *customPet15;
@property (nonatomic,copy)NSString *customPet16;
@property (nonatomic,copy)NSString *customPet17;
@property (nonatomic,copy)NSString *customPet18;
@property (nonatomic,copy)NSString *customPet19;
@property (nonatomic,copy)NSString *customPet20;
@property (nonatomic,copy)NSString *customPet21;
@property (nonatomic,copy)NSString *customPet22;
@property (nonatomic,copy)NSString *customPet23;
@property (nonatomic,copy)NSString *customPet24;
@property (nonatomic,copy)NSString *customPet25;
@property (nonatomic,copy)NSString *customPet26;
@property (nonatomic,copy)NSString *customPet27;
@property (nonatomic,copy)NSString *customPet28;
@property (nonatomic,copy)NSString *customPet29;
@property (nonatomic,copy)NSString *customPet30;

@property (nonatomic,copy)NSString *customClient1;
@property (nonatomic,copy)NSString *customClient2;
@property (nonatomic,copy)NSString *customClient3;
@property (nonatomic,copy)NSString *customClient4;
@property (nonatomic,copy)NSString *customClient5;
@property (nonatomic,copy)NSString *customClient6;
@property (nonatomic,copy)NSString *customClient7;
@property (nonatomic,copy)NSString *customClient8;
@property (nonatomic,copy)NSString *customClient9;
@property (nonatomic,copy)NSString *customClient10;
@property (nonatomic,copy)NSString *customClient11;
@property (nonatomic,copy)NSString *customClient12;
@property (nonatomic,copy)NSString *customClient13;
@property (nonatomic,copy)NSString *customClient14;
@property (nonatomic,copy)NSString *customClient15;
@property (nonatomic,copy)NSString *customClient16;
@property (nonatomic,copy)NSString *customClient17;
@property (nonatomic,copy)NSString *customClient18;
@property (nonatomic,copy)NSString *customClient19;
@property (nonatomic,copy)NSString *customClient20;
@property (nonatomic,copy)NSString *customClient21;
@property (nonatomic,copy)NSString *customClient22;
@property (nonatomic,copy)NSString *customClient23;
@property (nonatomic,copy)NSString *customClient24;
@property (nonatomic,copy)NSString *customClient25;
@property (nonatomic,copy)NSString *customClient26;
@property (nonatomic,copy)NSString *customClient27;
@property (nonatomic,copy)NSString *customClient28;
@property (nonatomic,copy)NSString *customClient29;
@property (nonatomic,copy)NSString *customClient30;
@property (nonatomic,copy)NSString *customClient31;
@property (nonatomic,copy)NSString *customClient32;
@property (nonatomic,copy)NSString *customClient33;
@property (nonatomic,copy)NSString *customClient34;
@property (nonatomic,copy)NSString *customClient35;
@property (nonatomic,copy)NSString *customClient36;
@property (nonatomic,copy)NSString *customClient37;
@property (nonatomic,copy)NSString *customClient38;
@property (nonatomic,copy)NSString *customClient39;
@property (nonatomic,copy)NSString *customClient40;
@property (nonatomic,copy)NSString *customClient41;
@property (nonatomic,copy)NSString *customClient42;
@property (nonatomic,copy)NSString *customClient43;
@property (nonatomic,copy)NSString *customClient44;
@property (nonatomic,copy)NSString *customClient45;
@property (nonatomic,copy)NSString *customClient46;
@property (nonatomic,copy)NSString *customClient47;
@property (nonatomic,copy)NSString *customClient49;
@property (nonatomic,copy)NSString *customClient50;
@property (nonatomic,copy)NSString *customClient51;
@property (nonatomic,copy)NSString *customClient52;
@property (nonatomic,copy)NSString *customClient53;
@property (nonatomic,copy)NSString *customClient54;
@property (nonatomic,copy)NSString *customClient55;
@property (nonatomic,copy)NSString *customClient56;
@property (nonatomic,copy)NSString *customClient57;
@property (nonatomic,copy)NSString *customClient58;
@property (nonatomic,copy)NSString *customClient59;
@property (nonatomic,copy)NSString *customClient60;
@property (nonatomic,copy)NSString *customClient61;
@property (nonatomic,copy)NSString *customClient62;

-(void)addPetImage:(NSString*)petID andImageData:(NSData*)imageData;
-(void)handleCustomClientFields:(NSDictionary*)customClientFields;
-(void)handlePetInformation:(NSDictionary *)customPetFields;
-(void)prettyPrint;
-(void)createDetailAccordions;
-(void)createAltContactInfo;


@end
