//
//  DataClient.m
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/17/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "DataClient.h"
#import <UIKit/UIKit.h>
#import "PharmaStyle.h"
#import "PetProfile.h"
#import "VisitsAndTracking.h"

@interface DataClient () {
    NSMutableArray *petsDataRaw;
    NSMutableArray *clientFlagsArray;
    NSMutableArray *customClientFields;
    NSMutableArray *errataDoc;
    NSMutableArray *customClientCheckBox;
}
@end


@implementation DataClient

-(instancetype) init {
    if(self=[super init]){           
        
        customClientFields = [[NSMutableArray alloc]init];
        petsDataRaw = [[NSMutableArray alloc]init];
        clientFlagsArray = [[NSMutableArray alloc]init];
        customClientCheckBox = [[NSMutableArray alloc]init];
        errataDoc = [[NSMutableArray alloc]init];
        
        self.clientID = @"NONE";
        self.sortName = @"NONE";
        self.clientName = @"NONE";
        self.homePhone = @"NONE";
        self.firstName = @"NONE";
        self.firstName2 = @"NONE";
        self.lastName = @"NONE";
        self.lastName2 = @"NONE";

        self.email = @"NONE";
        self.email2 = @"NONE";
        
        self.workphone = @"NONE";
        self.cellphone = @"NONE";
        self.cellphone2 = @"NONE";
        self.street1 = @"NONE";
        self.street2 = @"NONE";
        self.city = @"NONE";
        self.state = @"NONE";
        self.zip = @"NONE";
        
        self.garageGateCode = @"NONE";
        self.alarmCompany = @"NONE";
        self.alarmCompanyPhone = @"NONE";
        self.alarmInfo = @"NONE";
        self.keyDescriptionText= @"NONE";
        self.hasKey = @"NONE";
        self.keyID = @"NONE";
        
        self.clinicName = @"NONE";
        self.clinicStreet1 = @"NONE";
        self.clinicStreet2 = @"NONE";
        self.clinicPhone = @"NONE";
        self.clinicCity = @"NONE";
        self.clinicZip = @"NONE";
        self.clinicPtr = @"NONE";

        self.vetPtr = @"NONE";
        self.vetName = @"NONE";
        self.vetCity = @"NONE";
        self.vetPhone = @"NONE";
        self.vetStreet1 = @"NONE";
        self.vetStreet2 = @"NONE";
        self.vetZip = @"NONE";
        self.vetState = @"NONE";
    }
    return self;
}

-(void) cleanDataClientData {
    
    for (int i = 0; i < [clientFlagsArray count]; i++) {
        NSMutableDictionary *flagDic = [clientFlagsArray objectAtIndex:i];
        flagDic = nil;
    }
    for (int j = 0; j < [customClientFields count]; j++) {
        NSMutableDictionary* customDic = [customClientFields objectAtIndex:j];
        customDic = nil;
    }
    for(int k=0; k < [errataDoc count]; k++) {
        NSMutableDictionary* errataDic = [errataDoc objectAtIndex:k];
        errataDic = nil;        
    }
    for(int m=0; m < [petsDataRaw count]; m++) {
        PetProfile *petInfo = [petsDataRaw objectAtIndex:m];
        if ([petInfo getProfilePhoto] != nil) {
            [petInfo addProfileImage:nil];
        }
        petInfo = nil;
        
    }
    self.clientID = nil;
    self.sortName = nil;
    self.clientName = nil;
    self.homePhone = nil;
    self.firstName = nil;
    self.firstName2 = nil;
    self.lastName =nil;
    self.lastName2 = nil;

    self.email = nil;
    self.email2 = nil;
    
    self.workphone = nil;
    self.cellphone = nil;
    self.cellphone2 = nil;
    self.street1 =nil;
    self.street2 =nil;
    self.city = nil;
    self.state = nil;
    self.zip = nil;
    
    self.garageGateCode = nil;
    self.alarmCompany = nil;
    self.alarmCompanyPhone = nil;
    self.alarmInfo =nil;
    self.keyDescriptionText= nil;
    self.hasKey = nil;
    self.keyID = nil;
    
    self.clinicName =nil;
    self.clinicStreet1 = nil;
    self.clinicStreet2 =nil;
    self.clinicPhone = nil;
    self.clinicCity =nil;
    self.clinicZip = nil;
    self.clinicPtr = nil;

    self.vetPtr = nil;
    self.vetName = nil;
    self.vetCity = nil;
    self.vetPhone = nil;
    self.vetStreet1 = nil;
    self.vetStreet2 =nil;
    self.vetZip =nil;
    self.vetState = nil;
    
}
-(NSArray*) getFlags {
    return clientFlagsArray;
}
-(NSMutableArray*)getPetInfo  {
   // return petInfo;
    return petsDataRaw;
}
-(NSMutableArray*) getPetProfiles {
    return petsDataRaw;
}
-(NSMutableArray*) getErrataDocs {
    return errataDoc;
}
-(NSMutableArray*) getCustomFields {
    return customClientFields;
}
-(void) addPetProfileForClient:(PetProfile*)petProfile {
    
    
}

-(EMAccordionSection*) getAccordionSection:(NSString*)name {
    EMAccordionSection *accordion = [[EMAccordionSection alloc]init];
    [accordion setBackgroundColor:[PharmaStyle colorBlue]];
    [accordion setTitleFont:[UIFont fontWithName:@"Lato-Bold" size:22.0]];
    [accordion setTitleColor:[PharmaStyle  colorRedShadow70]];
    
    if ([name isEqualToString:@"basic"]) {
        
        NSMutableArray *sectionItemsArray = [[NSMutableArray alloc]initWithCapacity:20];
        [accordion setTitle:@"CLIENT INFO"];
        
        if ([self checkStringNull:_clientName]) {
            [sectionItemsArray addObject:_clientName];
        }
        if ([self checkStringNull:_cellphone]) {
            NSString *phoneString = [NSString stringWithFormat:@"Cell: %@",_cellphone];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_workphone]) {
            NSString *phoneString = [NSString stringWithFormat:@"Work: %@",_workphone];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_cellphone2]) {
            NSString *phoneString = [NSString stringWithFormat:@"Cell 2: %@",_cellphone2];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_homePhone]) {
            NSString *phoneString = [NSString stringWithFormat:@"Home: %@",_homePhone];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_email]) {
            [sectionItemsArray addObject:_email];
        }
        if ([self checkStringNull:_email2]) {
            [sectionItemsArray addObject:_email2];
        }
        if ([self checkStringNull:_street1]) {
            [sectionItemsArray addObject:_street1];
        }
        if ([self checkStringNull:_street2]) {
            [sectionItemsArray addObject:_street2];
        }
        if ([self checkStringNull:_city] && [self checkStringNull:_state] && [self checkStringNull:_zip]) {
            NSString *addressStr = [NSString stringWithFormat:@"%@, %@ %@",_city,_state,_zip];
            [sectionItemsArray addObject:addressStr];
        }
        
        if ([self checkStringNull:_clientName]) {
            [sectionItemsArray addObject:_clientName];
        }
        if ([self checkStringNull:_cellphone]) {
            NSString *phoneString = [NSString stringWithFormat:@"Cell: %@",_cellphone];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_workphone]) {
            NSString *phoneString = [NSString stringWithFormat:@"Work: %@",_workphone];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_cellphone2]) {
            NSString *phoneString = [NSString stringWithFormat:@"Cell 2: %@",_cellphone2];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_homePhone]) {
            NSString *phoneString = [NSString stringWithFormat:@"Home: %@",_homePhone];
            [sectionItemsArray addObject:phoneString];
        }
        if ([self checkStringNull:_email]) {
            [sectionItemsArray addObject:_email];
        }
        if ([self checkStringNull:_email2]) {
            [sectionItemsArray addObject:_email2];
        }
        if ([self checkStringNull:_street1]) {
            [sectionItemsArray addObject:_street1];
        }
        if ([self checkStringNull:_street2]) {
            [sectionItemsArray addObject:_street2];
        }
        if ([self checkStringNull:_city] && [self checkStringNull:_state] && [self checkStringNull:_zip]) {
            NSString *addressStr = [NSString stringWithFormat:@"%@, %@ %@",_city,_state,_zip];
            [sectionItemsArray addObject:addressStr];
        }
        
        [accordion setItems:sectionItemsArray];
    } 
    else if ([name isEqualToString:@"alt"]) {
        
        NSMutableArray *sectionItems2 = [[NSMutableArray alloc]initWithCapacity:20];
        
        if ([self checkStringNull:_firstName2] && [self checkStringNull:_lastName2]) {
            NSString *altFirstLast = [NSString stringWithFormat:@"%@ %@",_firstName2,_lastName2];
            [sectionItems2 addObject:altFirstLast];
        }
        if ([self checkStringNull:_email2]) {
            [sectionItems2 addObject:_email2];
        }
        if ([self checkStringNull:_workphone]) {
            [sectionItems2 addObject:_workphone];
        }
        [accordion setItems:sectionItems2];
        [accordion setTitle:@"ALT INFO"];

    }
    else if ([name isEqualToString:@"vet"]) {

        NSMutableArray *sectionItemsArray = [[NSMutableArray alloc]initWithCapacity:20];
        if ([self checkStringNull:_vetName]) {
            [sectionItemsArray addObject:_vetName];
        }
        if ([self checkStringNull:_vetPhone]) {
            [sectionItemsArray addObject:_vetPhone];
        }
        if ([self checkStringNull:_vetCity]) {
            [sectionItemsArray addObject:_vetCity];
        }
        if ([self checkStringNull:_vetStreet1]) {
            [sectionItemsArray addObject:_vetStreet1];
        }
        if ([self checkStringNull:_vetStreet2]) {
            [sectionItemsArray addObject:_vetStreet2];
        }
        if ([self checkStringNull:_vetZip]) {
            [sectionItemsArray addObject:_vetZip];
        }
        if ([self checkStringNull:_clinicName]) {
            [sectionItemsArray addObject:_clinicName];
        }
        if ([self checkStringNull:_clinicPhone]) {
            [sectionItemsArray addObject:_clinicPhone];
        }
        
        if ([self checkStringNull:_clinicCity]) {
            [sectionItemsArray addObject:_clinicCity];
        }
        
        [accordion setItems:sectionItemsArray];
        [accordion setTitle:@"VET INFO"];
        

    } 
    else if ([name isEqualToString:@"alarm"]) {
        NSMutableArray *sectionItemsArray = [[NSMutableArray alloc]initWithCapacity:20];
        
        if ([self checkStringNull:_garageGateCode]) {
            NSString *garageCodeString = [NSString stringWithFormat:@"Garage Code: %@",_garageGateCode];
            [sectionItemsArray addObject:garageCodeString];
        }
        
        if ([self checkStringNull:_alarmCompany]) {
            [sectionItemsArray addObject:_alarmCompany];
        }
        
        if ([self checkStringNull:_alarmCompanyPhone]) {
            [sectionItemsArray addObject:_alarmCompanyPhone];
        }
        
        if ([self checkStringNull:_alarmInfo]) {
            NSString *alarmCodeString = [NSString stringWithFormat:@"ALARM: %@",_alarmInfo];
            [sectionItemsArray addObject:alarmCodeString];
        }
        
        if ([self checkStringNull:_keyDescriptionText]) {
            NSString *keyDescrString = [NSString stringWithFormat:@"KEY DESCR: %@",_keyDescriptionText];
            [sectionItemsArray addObject:keyDescrString];
        }
        
        if ([self checkStringNull:_emergencyName]) {
            NSString *emergencyHeader =  @"EMERGENCY CONTACT INFO";
            [sectionItemsArray addObject:emergencyHeader];
            NSString *emergName = [NSString stringWithFormat:@"%@",_emergencyName];
            [sectionItemsArray addObject:emergName];
        }
        
        if ([self checkStringNull:_emergencyCellPhone]) {
            NSString *emergName = [NSString stringWithFormat:@"CELL: %@",_emergencyCellPhone];
            [sectionItemsArray addObject:emergName];
        }
        if ([self checkStringNull:_emergencyWorkPhone]) {
            NSString *emergName = [NSString stringWithFormat:@"WORK: %@",_emergencyWorkPhone];
            [sectionItemsArray addObject:emergName];
        }
        
        if ([self checkStringNull:_emergencyHomePhone]) {
            NSString *emergName = [NSString stringWithFormat:@"HOME: %@",_emergencyHomePhone];
            [sectionItemsArray addObject:emergName];
        }

        if ([self checkStringNull:_emergencyLocation]) {
            NSString *emergName = [NSString stringWithFormat:@"%@",_emergencyLocation];
            [sectionItemsArray addObject:emergName];
        }
        
        if ([self checkStringNull:_emergencyNote]) {
            NSString *emergName = [NSString stringWithFormat:@"%@",_emergencyNote];
            [sectionItemsArray addObject:emergName];
        }
        
        if ([self checkStringNull:_emergencyHasKey]) {
            
            if ([_emergencyHasKey isEqualToString:@"0"]) {
                NSString *emergName = [NSString stringWithFormat:@"HAS KEY: NO"];
                [sectionItemsArray addObject:emergName];

            } else {
                NSString *emergName = [NSString stringWithFormat:@"HAS KEY: YES"];
                [sectionItemsArray addObject:emergName];

           }

        }

        if ([self checkStringNull:_trustedNeighborName]) {
            NSString *emergencyHeader =  @"TRUST NEIGHBOR CONTACT INFO";
            [sectionItemsArray addObject:emergencyHeader];
            NSString *emergName = [NSString stringWithFormat:@"%@",_trustedNeighborName];
            [sectionItemsArray addObject:emergName];
        }
        if ([self checkStringNull:_trustedNeighborCellPhone]) {
            NSString *emergName = [NSString stringWithFormat:@"CELL: %@",_trustedNeighborCellPhone];
            [sectionItemsArray addObject:emergName];
        }
        if ([self checkStringNull:_trustedNeighborWorkPhone]) {
            NSString *emergName = [NSString stringWithFormat:@"WORK: %@",_trustedNeighborWorkPhone];
            [sectionItemsArray addObject:emergName];
        }
        if ([self checkStringNull:_trustedNeighborHomePhone]) {
            NSString *emergName = [NSString stringWithFormat:@"HOME: %@",_trustedNeighborHomePhone];
            [sectionItemsArray addObject:emergName];
        }
        
        if ([self checkStringNull:_trustedNeighborLocation]) {
            NSString *emergName = [NSString stringWithFormat:@"%@",_trustedNeighborLocation];
            [sectionItemsArray addObject:emergName];
        }
        if ([self checkStringNull:_trustedNeighborNote]) {
            NSString *emergName = [NSString stringWithFormat:@"%@",_trustedNeighborNote];
            [sectionItemsArray addObject:emergName];
        }
        if ([self checkStringNull:_trustedNeighborHasKey]) {
            
            if ([_trustedNeighborHasKey isEqualToString:@"0"]) {
                NSString *emergName = [NSString stringWithFormat:@"HAS KEY: NO"];
                [sectionItemsArray addObject:emergName];
            } else {
                NSString *emergName = [NSString stringWithFormat:@"HAS KEY: YES"];
                [sectionItemsArray addObject:emergName];
            }
        }
        [accordion setTitle:@"ALARM INFO"];
        [accordion setItems:sectionItemsArray];
    } 
    else if ([name isEqualToString:@"location"]) {
        NSMutableArray *sectionItemsArray = [[NSMutableArray alloc]initWithCapacity:20];
        
        if ([self checkStringNull:_leashLocation]) {
            [sectionItemsArray addObject:_leashLocation];
        }
        if ([self checkStringNull:_foodLocation]) {
            [sectionItemsArray addObject:_foodLocation];
        }
        if ([self checkStringNull:_directionsInfo]) {
            [sectionItemsArray addObject:_directionsInfo];
        }
        if ([self checkStringNull:_parkingInfo]) {
            [sectionItemsArray addObject:_parkingInfo];
        }
        [accordion setItems:sectionItemsArray];
        [accordion setTitle:@"LOCATION OTHER"];
    } 
    else if ([name isEqualToString:@"custom"]) {
        
    }

    return accordion;
}


-(void)createPetData:(NSArray*)petArray {
    if ([petArray count] > 0) {
        for (int i = 0; i < [petArray count]; i++) {
            PetProfile *profilePet = [[PetProfile alloc]init];
            NSDictionary *petDict = [petArray objectAtIndex:i];
             [profilePet initWithData:petDict withClientID:_clientID];
            [petsDataRaw addObject:profilePet];
        }
    }  else {
        // NO PETS
    }
}

-(void) createErrataData:(NSDictionary*)errataDic {
    NSMutableDictionary *flatErrata = [[NSMutableDictionary alloc]init];
    [flatErrata setObject:[errataDic objectForKey:@"serverkey"] forKey:@"serverkey"];
    [flatErrata setObject: [errataDic objectForKey:@"label"] forKey:@"label"];
    NSDictionary *customDicTmp = [errataDic objectForKey:@"value"];
    [flatErrata setObject:[customDicTmp objectForKey:@"label"] forKey:@"docname"];
    [flatErrata setObject:[customDicTmp objectForKey:@"mimetype"] forKey:@"mimetype"];
    [flatErrata setObject:[customDicTmp objectForKey:@"url"] forKey:@"url"];
    NSString *customRegexErr = [self customFieldSequence:[errataDic objectForKey:@"serverkey"]];
    NSLog(@"ERRATA # %@", customRegexErr);
    [errataDoc addObject:flatErrata];
    
}

-(void)createClientProfile:(NSDictionary*)clientInformation {    
    
    [self createPetData:[clientInformation objectForKey:@"pets"]];
    
    for (NSDictionary *flagItemClient in [clientInformation objectForKey:@"flags"]) {
        [clientFlagsArray addObject:flagItemClient];
    }
    
    self.leashLocation = [clientInformation objectForKey:@"leashloc"];
    self.foodLocation = [clientInformation objectForKey:@"foodloc"];
    [self basicClientInfo:clientInformation];
    [self securityInfo:clientInformation];
    [self emergencyContactInfo:[clientInformation objectForKey:@"emergency"]];
    [self trustedNeighbor:[clientInformation objectForKey:@"neighbor"]];
    [self vetInfoAdd:clientInformation];
        
    NSArray *clientDataKeys = [clientInformation allKeys];
    for (NSString *clientKey in clientDataKeys) {
        if (![clientKey isEqualToString:@"emergency"] &&
            ![clientKey isEqualToString:@"neighbor"] && 
            ![clientKey isEqualToString:@"flags"] && 
            ![clientKey isEqualToString:@"pets"]) {
            
            if ([[clientInformation objectForKey:clientKey] isKindOfClass:[NSDictionary class]]) { 
                NSDictionary *customClientDic = [clientInformation objectForKey:clientKey];
                if ([[customClientDic objectForKey:@"value"]isKindOfClass:[NSDictionary class]]) {
                    [self createErrataData:customClientDic];
                }
                else {
                    NSString *customRegex = [self customFieldSequence:[customClientDic objectForKey:@"serverkey"]];
                    NSLog(@"custom regex: %@", customRegex);
                    [customClientFields addObject:customClientDic];
                }
            }  
            else {
                //NSLog(@"NOT CUSTOM, NOT ERRATA, NOT NEIGHBOR, NOT FLAGS, NOT PETS, NOT EMERGENCY");
                //NSLog(@"%@, %@", clientKey, [clientInformation objectForKey:clientKey]);
            }
        }
    }
}

-(NSString *)customFieldSequence:(NSString*) serverKey {
    NSString *sequenceResult ;
    NSError *error = NULL;
    NSString *myRegex = @"(\\d+)";
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:myRegex
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
        

    if (![serverKey isEqual:[NSNull null]] && [serverKey length] > 0) {
        long n = [regex numberOfMatchesInString:serverKey 
                                        options:0 
                                          range:NSMakeRange(0, [serverKey length])];
        
        if (n > 0) {
            NSArray *matches = [regex matchesInString:serverKey 
                                              options:0 
                                                range:NSMakeRange(0, [serverKey length])];
            for (NSTextCheckingResult *match in matches) 
            { 
                sequenceResult = [serverKey substringWithRange:[match range]];
            }
        } else {
                
        }
    }
    return sequenceResult;
}
-(void) basicClientInfo:(NSDictionary*)basicInfoDic {
    self.clientID = [basicInfoDic objectForKey:@"clientid"];
    self.clientName = [basicInfoDic objectForKey:@"clientname"];
    self.email = [basicInfoDic objectForKey:@"email"];
    self.email2 = [basicInfoDic objectForKey:@"email2"];
    self.cellphone = [basicInfoDic objectForKey:@"cellphone"];
    self.cellphone2 = [basicInfoDic objectForKey:@"cellphone2"];
    self.street1 = [basicInfoDic objectForKey:@"street1"];
    self.street2 = [basicInfoDic objectForKey:@"street2"];
    self.city = [basicInfoDic objectForKey:@"city"];
    self.state = [basicInfoDic objectForKey:@"state"];
    self.zip = [basicInfoDic objectForKey:@"zip"];
    self.sortName = [basicInfoDic objectForKey:@"sortname"];
    self.firstName = [basicInfoDic objectForKey:@"fname"];
    self.firstName2 = [basicInfoDic objectForKey:@"fname2"];
    self.lastName = [basicInfoDic objectForKey:@"lname"];
    self.lastName2 = [basicInfoDic objectForKey:@"lname2"];
    self.workphone = [basicInfoDic objectForKey:@"workphone"];
    self.homePhone = [basicInfoDic  objectForKey:@"homephone"];
    
}
-(void) securityInfo:(NSDictionary*)securityDic {
    self.garageGateCode = [securityDic objectForKey:@"garagegatecode"];
    self.alarmCompany = [securityDic objectForKey:@"alarmcompany"];
    self.alarmCompanyPhone = [securityDic objectForKey:@"alarmcophone"];
    self.alarmInfo = [securityDic objectForKey:@"alarminfo"];
    self.hasKey = [securityDic objectForKey:@"hasKey"];
    self.basicInfoNotes = [securityDic objectForKey:@"notes"];
    self.parkingInfo = [securityDic objectForKey:@"parkinginfo"];
    self.directionsInfo = [securityDic objectForKey:@"directions"];
}
-(void) emergencyContactInfo:(NSDictionary*)emergencyDic {
    self.emergencyCellPhone = [emergencyDic objectForKey:@"cellphone"];
    self.emergencyHasKey = [emergencyDic objectForKey:@"haskey"];
    self.emergencyHomePhone = [emergencyDic objectForKey:@"homephone"];
    self.emergencyLocation = [emergencyDic objectForKey:@"location"];
    self.emergencyName = [emergencyDic objectForKey:@"name"];
    self.emergencyNote = [emergencyDic objectForKey:@"note"];
    self.emergencyWorkPhone = [emergencyDic objectForKey:@"workphone"];
    
}
-(void) trustedNeighbor:(NSDictionary*)trustedNeighborDic {
    self.trustedNeighborName = [trustedNeighborDic objectForKey:@"name"];
    self.trustedNeighborHasKey = [trustedNeighborDic objectForKey:@"haskey"];
    self.trustedNeighborHomePhone = [trustedNeighborDic objectForKey:@"homephone"];
    self.trustedNeighborCellPhone = [trustedNeighborDic objectForKey:@"cellphone"];
    self.trustedNeighborLocation = [trustedNeighborDic objectForKey:@"location"];
    self.trustedNeighborNote = [trustedNeighborDic objectForKey:@"note"];
    self.trustedNeighborWorkPhone = [trustedNeighborDic objectForKey:@"workphone"];
}
-(void) vetInfoAdd:(NSDictionary*)vetInfoDic {
    self.clinicPtr = [vetInfoDic objectForKey:@"clinicptr"];
    self.clinicZip = [vetInfoDic objectForKey:@"cliniczip"];
    self.clinicCity = [vetInfoDic objectForKey:@"cliniccity"];
    self.clinicName = [vetInfoDic objectForKey:@"clinicname"];
    self.clinicPhone = [vetInfoDic objectForKey:@"clinicphone"];
    self.clinicLat = (NSString*)[vetInfoDic objectForKey:@"cliniclat"];
    self.clinicLon = (NSString*)[vetInfoDic objectForKey:@"cliniclon"];
    self.vetPtr = [vetInfoDic objectForKey:@"vetptr"];
    self.vetName = [vetInfoDic objectForKey:@"vetname"];
    self.vetCity = [vetInfoDic objectForKey:@"vetcity"];
    self.vetState = [vetInfoDic objectForKey:@"vetstate"];
    self.vetStreet1 = [vetInfoDic objectForKey:@"vetstreet"];
    self.vetStreet2 = [vetInfoDic objectForKey:@"vetstreet2"];
    self.vetPhone = [vetInfoDic objectForKey:@"vetphone"];
    self.vetLat = [vetInfoDic objectForKey:@"vetlat"];
    self.vetLon = [vetInfoDic objectForKey:@"vatlon"];
}

-(void) handleCustomClientFields:(NSDictionary*)clientCustomFields {

    NSString *label = [clientCustomFields objectForKey:@"label"];
    if (label != NULL) {
        //[_customClientFields addObject:customClientFields];
        [customClientFields addObject:clientCustomFields];
    }
}
-(void) addPetImage:(NSString*)petID andImageData:(UIImage*)petImage {
    NSLog(@"CLIENT DATA: Add pet image");
    for (PetProfile *pet in petsDataRaw) {
        if ([[pet getPetID]isEqualToString:petID]) {
            [pet addProfileImage:petImage];
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
/*-(void)createCustomClientFieldsAccordion {

    NSMutableArray *sectionItems2 = [[NSMutableArray alloc]initWithCapacity:100];
    NSMutableArray *checkBoxItems = [[NSMutableArray alloc]init];
	    
    for (NSDictionary *fieldValueDic in customClientFields) {

		id customValue = [fieldValueDic objectForKey:@"value"];
		NSString *label = [fieldValueDic objectForKey:@"label"];
				
		if (![customValue isEqual:[NSNull null]])  {
			if ([customValue isKindOfClass:[NSDictionary class]]) {
				
				NSMutableDictionary *customValSource = [[NSMutableDictionary alloc]init];
				customValSource = (NSMutableDictionary*) customValue;

				NSMutableDictionary *customValDict = [[NSMutableDictionary alloc]init];
				[customValDict setObject:[customValSource objectForKey:@"url"] forKey:@"url"];
				[customValDict setObject:[customValSource objectForKey:@"mimetype"] forKey:@"mimetype"];
				[customValDict setObject:[customValSource objectForKey:@"label"] forKey:@"label"];
				[customValDict setObject:label forKey:@"fieldlabel"];
				[customValDict setObject:@"docAttach" forKey:@"type"];
			
				[sectionItems2 addObject:customValDict];
				
                int errataCount = (int)[errataDoc count];

				errataCount = errataCount + 1;
				NSString *errataCountString = [NSString stringWithFormat:@"%i", errataCount];
				[customValDict setObject:errataCountString forKey:@"errataIndex"];
				//[_errataDoc addObject:customValDict];
                [errataDoc addObject:customValDict];

			} else {

				NSString *label = [fieldValueDic objectForKey:@"label"];
				NSString *value = [fieldValueDic objectForKey:@"value"];
				if ([value isEqualToString:@"0"]) {
					NSMutableDictionary *checkBoxDic = [[NSMutableDictionary alloc]init];
					[checkBoxDic setObject:@"0" forKey:@"value"];
					[checkBoxDic setObject:label forKey:@"label"];
					[checkBoxItems addObject:fieldValueDic];
					//[_customClientCheckBox addObject:checkBoxDic];
                    [customClientCheckBox addObject:checkBoxDic];

				} else if ([value isEqualToString:@"1"]) {
					NSMutableDictionary *checkBoxDic = [[NSMutableDictionary alloc]init];
					[checkBoxDic setObject:@"1" forKey:@"value"];
					[checkBoxDic setObject:label forKey:@"label"];
					[checkBoxItems addObject:fieldValueDic];
                    [customClientCheckBox addObject:checkBoxDic];

					//[_customClientCheckBox addObject:checkBoxDic];
				} else {
					[sectionItems2 addObject:fieldValueDic];
				}
			}
        }
    }
}*/



@end
