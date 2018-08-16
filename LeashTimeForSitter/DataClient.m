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

@implementation DataClient

-(instancetype) init {
    if(self=[super init]){
        _customClientFields = [[NSMutableArray alloc]initWithCapacity:100];
		
        _petInfo = [[NSMutableArray alloc]init];
        _customPetInfo = [[NSMutableArray alloc]init];
        _clientFlagsArray = [[NSMutableArray alloc]init];
        _petImages = [[NSMutableDictionary alloc]init];
        _customClientCheckBox = [[NSMutableArray alloc]init];
		_errataDoc = [[NSMutableArray alloc]init];
		_errataProfile = [[NSMutableArray alloc]init];

        _basicClientInfo = [[EMAccordionSection alloc]init];
        
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
        
        self.customClient1= @"NONE";
        self.customClient2= @"NONE";
        self.customClient3= @"NONE";
        self.customClient4= @"NONE";
        self.customClient5= @"NONE";
        self.customClient6= @"NONE";
        self.customClient7= @"NONE";
        self.customClient8= @"NONE";
        self.customClient9= @"NONE";
        self.customClient10= @"NONE";
        self.customClient11= @"NONE";
        self.customClient12= @"NONE";
        self.customClient13= @"NONE";
        self.customClient14= @"NONE";
        self.customClient15= @"NONE";
        self.customClient16= @"NONE";
        self.customClient17= @"NONE";
        self.customClient18= @"NONE";
        self.customClient19= @"NONE";
        self.customClient20= @"NONE";

    }
    return self;
}

-(void)prettyPrint {
    NSLog(@"----------------------------------");
    NSLog(@"|CLIENT ID; %@                    |",self.clientID);
    NSLog(@"----------------------------------");
    NSLog(@"----------------------------------");
    NSLog(@"Basic Info");
    NSLog(@"----------------------------------");
    NSLog(@"name: %@",self.sortName);
    NSLog(@"Client name: %@",self.clientName);
    NSLog(@"first name; %@",self.firstName);
    NSLog(@"last name; %@",self.lastName);
    NSLog(@"first name2; %@",self.firstName2);
    NSLog(@"last name2; %@",self.lastName2);
    NSLog(@"email; %@",self.email);
    NSLog(@"email2; %@",self.email2);
    NSLog(@"Home Phone: %@",self.homePhone);
    NSLog(@"workphone; %@",self.workphone);
    NSLog(@"cellphone; %@",self.cellphone);
    NSLog(@"cellphone2; %@",self.cellphone2);
    NSLog(@"----------------------------------");
    NSLog(@"Address");
    NSLog(@"----------------------------------");
    NSLog(@"street; %@",self.street1);
    NSLog(@"street2; %@",self.street2);
    NSLog(@"city; %@",self.city);
    NSLog(@"state; %@",self.state);
    NSLog(@"zip; %@",self.zip);
    NSLog(@"----------------------------------");
    NSLog(@"Security");
    NSLog(@"----------------------------------");
    NSLog(@"Garage/Gate Code; %@",self.garageGateCode);
    NSLog(@"Alarm Info: %@",self.alarmInfo);
    NSLog(@"Alarm Company: %@",self.alarmCompany);
    NSLog(@"Alarm Company Phone: %@",self.alarmCompanyPhone);
    NSLog(@"key ID; %@",self.keyID);
    NSLog(@"Has Key: %@",self.hasKey);
    NSLog(@"----------------------------------");
    NSLog(@"Veterinary Clinic");
    NSLog(@"----------------------------------");
    NSLog(@"Clinic Name: %@",self.clinicName);
    NSLog(@"Clinic Street: %@",self.clinicStreet1);
    NSLog(@"Clinic Street2: %@",self.clinicStreet2);
    NSLog(@"Clinic Phone: %@",self.clinicPhone);
    NSLog(@"Clinic City: %@",self.clinicCity);
    NSLog(@"Clinic Lat: %@",self.clinicLat);
    NSLog(@"Clinic Lon: %@",self.clinicLon);
    NSLog(@"Vet: %@",self.vetPtr);
    NSLog(@"----------------------------------");
    NSLog(@"Pet Info");
    NSLog(@"----------------------------------");
    
    for (NSDictionary *petDicTmp in _petInfo) {
    
        NSLog(@"--------------------------");
        NSLog(@"%@",[petDicTmp valueForKey:@"name"]);
        NSLog(@"----------------------------------");
        for(NSString *petKey in petDicTmp) {
            
            NSLog(@"[C]%@: %@",petKey,[petDicTmp valueForKey:petKey]);
            
        }
    }
    
    NSLog(@"----------------------------------");
    NSLog(@"Custom Client Fields");
    NSLog(@"----------------------------------");
    

    
}

-(void)handlePetInformation:(NSDictionary *)customPetFields {
    
    
}

-(void)handleCustomClientFields:(NSDictionary*)customClientFields {

    NSString *label = [customClientFields objectForKey:@"label"];
    if (label != NULL) {
        [_customClientFields addObject:customClientFields];
    }
}

-(void)addPetImage:(NSString*)petID andImageData:(UIImage*)petImage {

    [_petImages setObject:petImage forKey:petID];
    
}

-(BOOL)checkStringNull:(NSString*)profileString {
    if (![profileString isEqual:[NSNull null]] && [profileString length] > 0) {
        return YES;
    } else {        
        return NO;
    }
}

-(void)createDetailAccordions {
    UIColor *sectionsColor = [PharmaStyle colorBlue];
    UIColor *sectionTitleColor = [PharmaStyle  colorRedShadow70];
    UIFont *sectionTitleFont = [UIFont fontWithName:@"Lato-Bold" size:22.0];
    
    NSMutableArray *sectionItemsArray = [[NSMutableArray alloc]initWithCapacity:20];
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
	
    _basicClientInfo = [[EMAccordionSection alloc] init];
    [_basicClientInfo setBackgroundColor:sectionsColor];
    [_basicClientInfo setItems:sectionItemsArray];
    [_basicClientInfo setTitle:@"CLIENT INFO"];
    [_basicClientInfo setTitleFont:sectionTitleFont];
    [_basicClientInfo setTitleColor:sectionTitleColor];
    
    
    [self createAltContactInfo];
    [self createDetailAccordionVetInfo];
    [self createDetailAccordionAlarmInfo];
    [self createOtherInfoAccordion];
    [self createCustomClientFieldsAccordion];
    
    
}

-(void)createCustomClientFieldsAccordion {
    
    UIColor *sectionsColor = [PharmaStyle colorBlue];
    UIColor *sectionTitleColor = [PharmaStyle colorRedShadow70];
    UIFont *sectionTitleFont = [UIFont fontWithName:@"Lato-Bold" size:22.0];
	
    NSMutableArray *sectionItems2 = [[NSMutableArray alloc]initWithCapacity:100];
    NSMutableArray *checkBoxItems = [[NSMutableArray alloc]init];
	
    for (NSDictionary *fieldValueDic in _customClientFields) {
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
				
				int errataCount = (int)[_errataDoc count];
				errataCount = errataCount + 1;
				NSString *errataCountString = [NSString stringWithFormat:@"%i", errataCount];
				[customValDict setObject:errataCountString forKey:@"errataIndex"];
				[_errataDoc addObject:customValDict];
				_isErrataDoc = true;

			} else {

				NSString *label = [fieldValueDic objectForKey:@"label"];
				NSString *value = [fieldValueDic objectForKey:@"value"];
				if ([value isEqualToString:@"0"]) {
					NSMutableDictionary *checkBoxDic = [[NSMutableDictionary alloc]init];
					[checkBoxDic setObject:@"0" forKey:@"value"];
					[checkBoxDic setObject:label forKey:@"label"];
					[checkBoxItems addObject:fieldValueDic];
					[_customClientCheckBox addObject:checkBoxDic];
				} else if ([value isEqualToString:@"1"]) {
					NSMutableDictionary *checkBoxDic = [[NSMutableDictionary alloc]init];
					[checkBoxDic setObject:@"1" forKey:@"value"];
					[checkBoxDic setObject:label forKey:@"label"];
					[checkBoxItems addObject:fieldValueDic];
					[_customClientCheckBox addObject:checkBoxDic];
				} else {
					[sectionItems2 addObject:fieldValueDic];
				}
			}
        }
    }
    
	    
	if([sectionItems2 count] == 0 && [_customClientCheckBox count] == 0) {
		
		
	} else {
		_customClientAccordionFields = [[EMAccordionSection alloc]init];
		[_customClientAccordionFields setBackgroundColor:sectionsColor];
		[_customClientAccordionFields setItems:sectionItems2];

		[_customClientAccordionFields setTitle:@"CUSTOM CLIENT FIELDS"];
		[_customClientAccordionFields setTitleFont:sectionTitleFont];
		[_customClientAccordionFields setTitleColor:sectionTitleColor];
	}
    
}

-(void)createAltContactInfo {
    
    UIColor *sectionsColor = [PharmaStyle colorBlue];
    UIColor *sectionTitleColor = [PharmaStyle colorRedShadow70];
    UIFont *sectionTitleFont = [UIFont fontWithName:@"Lato-Bold" size:22.0f];
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
    
    _altClientInfo = [[EMAccordionSection alloc]init];
    [_altClientInfo setBackgroundColor:sectionsColor];
    [_altClientInfo setItems:sectionItems2];
    [_altClientInfo setTitle:@"ALT INFO"];
    [_altClientInfo setTitleFont:sectionTitleFont];
    [_altClientInfo setTitleColor:sectionTitleColor];
    
}

-(void)createDetailAccordionVetInfo {
    
    UIColor *sectionsColor = [PharmaStyle colorBlue];
    UIColor *sectionTitleColor = [PharmaStyle  colorRedShadow70];
    UIFont *sectionTitleFont = [UIFont fontWithName:@"Lato-Bold" size:22.0f];
    
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
    
    _vetInfo = [[EMAccordionSection alloc]init];
    [_vetInfo setBackgroundColor:sectionsColor];
    [_vetInfo setItems:sectionItemsArray];
    [_vetInfo setTitle:@"VET INFO"];
    [_vetInfo setTitleFont:sectionTitleFont];
    [_vetInfo setTitleColor:sectionTitleColor];
    
    
}

-(void)createDetailAccordionAlarmInfo {
    
    UIColor *sectionsColor = [PharmaStyle colorBlue];
    UIColor *sectionTitleColor = [PharmaStyle  colorRedShadow70];
    UIFont *sectionTitleFont = [UIFont fontWithName:@"Lato-Bold" size:22.0f];
    
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
    
    _alarmInfoAccordion = [[EMAccordionSection alloc]init];
    [_alarmInfoAccordion setBackgroundColor:sectionsColor];
    [_alarmInfoAccordion setItems:sectionItemsArray];
    [_alarmInfoAccordion setTitle:@"ALARM INFO"];
    [_alarmInfoAccordion setTitleFont:sectionTitleFont];
    [_alarmInfoAccordion setTitleColor:sectionTitleColor];
    
    
}

-(void)createOtherInfoAccordion {
    
    UIColor *sectionsColor = [PharmaStyle colorBlue];
    UIColor *sectionTitleColor = [PharmaStyle  colorRedShadow70];
    UIFont *sectionTitleFont = [UIFont fontWithName:@"Lato-Bold" size:22.0f];
    
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
    _locationSupplies = [[EMAccordionSection alloc]init];
    [_locationSupplies setBackgroundColor:sectionsColor];
    [_locationSupplies setItems:sectionItemsArray];
    [_locationSupplies setTitle:@"HOME INFO"];
    [_locationSupplies setTitleFont:sectionTitleFont];
    [_locationSupplies setTitleColor:sectionTitleColor];
}


@end
