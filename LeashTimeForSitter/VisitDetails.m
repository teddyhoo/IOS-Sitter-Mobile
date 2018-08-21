//
//  VisitDetails.m
//  LeashTimeSitter
//
//  Created by Ted Hooban on 7/11/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "VisitDetails.h"
#import <UIKit/UIImage.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFNetworking.h"
#import "VisitsAndTracking.h"


@implementation VisitDetails


-(instancetype)init {
    
    self = [super init];
    if(self) {
        fileManager = [NSFileManager new];
		petPhotos = [[NSMutableArray alloc]init];
		_petPhotosFileNames = [[NSMutableArray alloc]init];
        _currentPetImage = NULL;
		_profileChangeItems = [[NSMutableArray alloc]init];
		_docItems = [[NSMutableArray alloc]init];
    }
    
    return self;
    
}

-(void) cleanLocationCoords {
	
	
}

-(void) addVisitNoteToVisit:(NSString*)visitNote {
    self.visitNoteBySitter = [NSString stringWithString:visitNote];
    [self writeVisitDataToFile];
    
}

-(void) markComplete:(NSString*)timeMarkComplete
            latitude:(NSString *)coordinateLatitudeMarkComplete
           longitude:(NSString *)coordinateLongitudeMarkComplete {

    //_dateTimeMarkComplete = [NSString stringWithString:timeMarkComplete];
    _coordinateLatitudeMarkComplete = [NSString stringWithString:coordinateLatitudeMarkComplete];
    _coordinateLongitudeMarkComplete = [NSString stringWithString:coordinateLongitudeMarkComplete];
    
    [self writeVisitDataToFile];
}

-(void)markArrive:(NSString*)timeMarkArrive
         latitude:(NSString *)coordinateLatitudeMarkArrive
         longitude:(NSString *)coordinateLongitudeMarkArrive   {
    
    _inProcess = YES;
    //_hasArrived = YES;
    //_dateTimeMarkArrive = [NSString stringWithString:timeMarkArrive];
    _coordinateLatitudeMarkArrive = [NSString stringWithString:coordinateLatitudeMarkArrive];
    _coordinateLongitudeMarkArrive = [NSString stringWithString:coordinateLongitudeMarkArrive];
    [self writeVisitDataToFile];

}

-(void)addErrataData:(NSArray*)errataArray {
	for(NSDictionary *errataDic in errataArray) {
		[_docItems addObject:errataDic];
	}
}

-(NSMutableArray*)getProfileUpdates {
	return _profileChangeItems;
}

-(NSMutableArray*)getErrataDocItems {
	return _docItems;
}

-(void) addMapsnapShotImageToVisit:(UIImage*) mapImg {
	self.mapSnapShotImage = mapImg;
	NSData *imageData = UIImagePNGRepresentation(_mapSnapShotImage);
	NSString *dateForImageFilename = [self stringForCurrentDateAndTime];
	NSString *nameOfImageFile = [NSString stringWithFormat:@"mapSnap-%@-%@.png",self.appointmentid,dateForImageFilename];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths firstObject];
	NSString *imagePath = [documentsPath stringByAppendingPathComponent:
						   [NSString stringWithFormat:@"mapSnap-%@-%@.png",
							self.appointmentid,dateForImageFilename]];
	self.mapSnapShotFilename = imagePath;
	[imageData writeToFile:imagePath atomically:YES];
	NSURL *filePathURL = [[NSURL alloc]initFileURLWithPath:imagePath];
	[self sendMapSnapshotViaAFNetwork:filePathURL imageData:imageData imageFileNameString:nameOfImageFile];

}
-(void)addImageForPet:(UIImage*)petImage {

    _currentPetImage = petImage;
	NSData *imageData = UIImagePNGRepresentation(_currentPetImage);
    [petPhotos addObject:petImage];

    NSString *dateForImageFilename = [self stringForCurrentDateAndTime];
    NSString *nameOfImageFile = [NSString stringWithFormat:@"image-%@-%@.png",self.appointmentid,dateForImageFilename];
    _petImageFile = [NSString stringWithString:nameOfImageFile];
	[_petPhotosFileNames addObject:_petImageFile];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"image-%@-%@.png",
                            self.appointmentid,dateForImageFilename]];
    
    [imageData writeToFile:imagePath atomically:YES];
    NSURL *filePathURL = [[NSURL alloc]initFileURLWithPath:imagePath];

    [self sendPhotoViaAFNetwork:filePathURL imageData:imageData imageFileNameString:nameOfImageFile];
    
}

-(void)sendMapSnapshotViaAFNetwork:(NSURL*) filePathURL
						 imageData:(NSData*)imageData
			   imageFileNameString:(NSString*)imageFileNameString {
	NSString *scriptName = @"https://leashtime.com/appointment-map-upload.php";

	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
	manager.responseSerializer = serializer;
	manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes
														 setByAddingObject:@"application/json"];
	manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes
														 setByAddingObject:@"text/html"];
	manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes
														 setByAddingObject:@"text/plain"];

	NSDictionary *creds = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
	NSString *username = [creds objectForKey:@"username"];
	NSString *pass = [creds objectForKey:@"password"];
	NSDictionary *parameters = @{@"loginid":  username,
								 @"password": pass,
								 @"appointmentid": self.appointmentid};

	__block NSString *imageFileB = imageFileNameString;
	__block NSData *imageDataB = imageData;
	[manager POST:scriptName
	   parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {


	[formData appendPartWithFileData:imageData
								name:@"image"
							fileName:imageFileNameString
							mimeType:@"image/png"];



} success:^(AFHTTPRequestOperation *operation, id responseObject) {

	//NSLog(@"FIRST ATTEMPT MAP SNAP SUCCESS: %@", responseObject);
	//NSLog(@"Request headers: %@",manager.requestSerializer.HTTPRequestHeaders);
	//NSLog(@"Request body: %@",manager.requestSerializer);
	self.mapSnapUploadStatus = @"SUCCESS";
	[self writeVisitDataToFile];

} failure:^(AFHTTPRequestOperation *operation, NSError *error) {

	self.mapSnapUploadStatus = @"FALSE";
	VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
	NSMutableDictionary *imgDicResend = [[NSMutableDictionary alloc]init];
	[imgDicResend setObject:self.appointmentid forKey:@"appointmentptr"];
	[imgDicResend setObject:imageFileB forKey:@"imageFile"];
	[imgDicResend setObject:imageDataB forKey:@"imageData"];
	[imgDicResend setObject:@"MAP" forKey:@"TYPE"];
	[imgDicResend setObject:@"FAIL-NETWORK RESPONSE" forKey:@"STATUS"];
	[sharedVisits.arrivalCompleteQueueItems addObject:imgDicResend];
}];
}

-(void)sendPhotoViaAFNetwork:(NSURL*)filePathURL
                   imageData:(NSData*)imageData
         imageFileNameString:(NSString*)imageFileNameString {
    
    NSString *scriptName = @"https://leashtime.com/appointment-photo-upload.php";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.responseSerializer = serializer;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes
                                                         setByAddingObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes
                                                         setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes
                                                         setByAddingObject:@"text/plain"];
    
    NSDictionary *creds = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
    NSString *username = [creds objectForKey:@"username"];
    NSString *pass = [creds objectForKey:@"password"];
    NSDictionary *parameters = @{@"loginid":  username,
                                 @"password": pass,
                                 @"appointmentid": self.appointmentid};
    
    __block NSString *imageFileB = imageFileNameString;
    __block NSData *imageDataB = imageData;
	
    [manager POST:scriptName
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    

        [formData appendPartWithFileData:imageData
                                    name:@"image"
                                fileName:imageFileNameString
                                mimeType:@"image/png"];
    
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
		self.imageUploadStatus = @"SUCCESS";
		self.mapSnapTakeStatus = @"SUCCESS";
		[self writeVisitDataToFile];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

		self.imageUploadStatus = @"FAIL";
        VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
		NSMutableDictionary *imgDicResend = [[NSMutableDictionary alloc]init];
		[imgDicResend setObject:self.appointmentid forKey:@"appointmentptr"];
		[imgDicResend setObject:imageFileB forKey:@"imageFile"];
		[imgDicResend setObject:imageDataB forKey:@"imageData"];
		[imgDicResend setObject:@"IMAGE" forKey:@"TYPE"];
		[imgDicResend setObject:@"FAIL-NETWORK RESPONSE" forKey:@"STATUS"];
		[sharedVisits.arrivalCompleteQueueItems addObject:imgDicResend];
    }];
}

-(void)writeVisitDataToFile {
	NSMutableDictionary *fileDictionary = [self getMyVisitDetails:self.appointmentid];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"%@-visitdetails",self.appointmentid];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:filename];
	BOOL writeStatus = [fileDictionary writeToFile:plistPath atomically:YES ];
	if(!writeStatus) {
		NSLog(@"Error writing file");
	} else {			
		NSLog(@"WROTE VISIT DETAILS TO FILE");
	}
}

-(NSMutableDictionary *)getMyVisitDetails:(NSString *)visitID {

	NSMutableDictionary *visitDetails = [[NSMutableDictionary alloc]init];
	[visitDetails setValue:self.appointmentid forKey:@"appointmentid"];
	[visitDetails setValue:self.dateTimeMarkArrive forKey:@"dateTimeMarkArrive"];
	[visitDetails setValue:self.arrived forKey:@"arrived"];
	[visitDetails setValue:self.completed forKey:@"completed"];
	[visitDetails setValue:self.dateTimeMarkComplete forKey:@"dateTimeMarkComplete"];
	//NSLog(@"writing to file: %@ (dateTimeMarkArrive), %@ (dateTimeMarkComplete)",_dateTimeMarkArrive, _dateTimeMarkComplete);
	[visitDetails setValue:self.coordinateLatitudeMarkArrive forKey:@"coordinateLatitudeMarkArrive"];
	[visitDetails setValue:self.coordinateLongitudeMarkArrive forKey:@"coordinateLongitudeMarkArrive"];
	[visitDetails setValue:self.coordinateLongitudeMarkComplete forKey:@"coordinateLongitudeMarkComplete"];
	[visitDetails setValue:self.coordinateLatitudeMarkComplete forKey:@"coordinateLatitudeMarkComplete"];
	[visitDetails setValue:self.visitNoteBySitter forKey:@"visitNoteBySitter"];
	[visitDetails setValue:self.dateTimeVisitReportSubmit forKey:@"dateTimeVisitReportSubmit"];
	[visitDetails setValue:self.petImageFile forKey:@"petImageFile"];
	
	[visitDetails setValue:self.mapSnapShotFilename forKey:@"mapSnapShotFilename"];
	[visitDetails setValue:self.currentArriveVisitStatus forKey:@"currentArriveVisitStatus"];
	[visitDetails setValue:self.currentCompleteVisitStatus forKey:@"currentCompleteVisitStatus"];
	[visitDetails setValue:self.imageUploadStatus forKey:@"imageUploadStatus"];
	[visitDetails setValue:self.mapSnapUploadStatus forKey:@"mapSnapUploadStatus"];
	[visitDetails setValue:self.visitReportUploadStatus forKey:@"visitReportUploadStatus"];
	[visitDetails setValue:self.mapSnapTakeStatus forKey:@"mapSnapTakeStatus"];
	
	if (_didPoo) {
		[visitDetails setValue:@"YES" forKey:@"didPoo"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"didPoo"];
	}

	if (_didPee) {
		[visitDetails setValue:@"YES" forKey:@"didPee"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"didPee"];
	}

	if (_wasHappy) {
		[visitDetails setValue:@"YES" forKey:@"wasHappy"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"wasHappy"];
	}

	if (_wasSad) {
		[visitDetails setValue:@"YES" forKey:@"wasSad"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"wasSad"];
	}

	if (_wasAngry) {
		[visitDetails setValue:@"YES" forKey:@"wasAngry"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"wasAngry"];
	}

	if (_wasShy) {
		[visitDetails setValue:@"YES" forKey:@"wasShy"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"wasShy"];
	}

	if (_wasHungry) {
		[visitDetails setValue:@"YES" forKey:@"wasHungry"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"wasHungry"];
	}

	if (_wasSick) {
		[visitDetails setValue:@"YES" forKey:@"wasSick"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"wasSick"];
	}

	if (_didPlay) {
		[visitDetails setValue:@"YES" forKey:@"didPlay"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"didPlay"];
	}

	if (_wasCat) {
		[visitDetails setValue:@"YES" forKey:@"wasCat"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"wasCat"];
	}

	if (_didScoopLitter) {
		[visitDetails setValue:@"YES" forKey:@"didScoopLitter"];
	} else {
		[visitDetails setValue:@"NO" forKey:@"didScoopLitter"];
	}

	return visitDetails;

}

-(void)syncVisitDetailFromFile {
    
	fileManager = [NSFileManager new];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *filename = [NSString stringWithFormat:@"%@-visitdetails",self.appointmentid];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:filename];
    
    
    if([fileManager fileExistsAtPath:plistPath]) {
        
        NSDictionary *visitDetail = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
        self.visitNoteBySitter = [visitDetail valueForKey:@"visitNoteBySitter"];
        
        if(self.dateTimeMarkArrive == NULL)
            self.dateTimeMarkArrive = [visitDetail valueForKey:@"dateTimeMarkArrive"];
       // if(self.dateTimeMarkComplete == NULL)
			//NSLog(@"Date Time Mark Arrive: %@",self.dateTimeMarkArrive);


		NSDateFormatter *dateString = [[NSDateFormatter alloc]init];
		[dateString setDateFormat:@"HH:mm a"];
		
		self.dateTimeMarkArrive = [visitDetail valueForKey:@"dateTimeMarkArrive"];
		self.arrived = [visitDetail valueForKey:@"arrived"];
		self.NSDateMarkArrive = [dateString dateFromString:self.dateTimeMarkArrive];
		//NSLog(@"Reading from file: %@ (dateTimeMarkArrive), %@ (arrived), %@ (NSDate) ", _dateTimeMarkArrive, _arrived, _NSDateMarkArrive);

        self.dateTimeMarkComplete = [visitDetail valueForKey:@"dateTimeMarkComplete"];
		self.NSDateMarkComplete = [dateString dateFromString:self.dateTimeMarkComplete];
		self.completed = [visitDetail valueForKey:@"completed"];
		//NSLog(@"Reading from file: %@ (dateTimeMarkArrive), %@ (arrived), %@ (NSDate) ", _dateTimeMarkComplete, _completed, _NSDateMarkComplete);
		
		self.coordinateLatitudeMarkArrive =[visitDetail valueForKey:@"coordinateLatitudeMarkArrive"];
        self.coordinateLongitudeMarkArrive = [visitDetail valueForKey:@"coordinateLongitudeMarkArrive"];
        self.coordinateLongitudeMarkComplete = [visitDetail valueForKey:@"coordinateLongitudeMarkComplete"];
        self.coordinateLatitudeMarkComplete = [visitDetail valueForKey:@"coordinateLatitudeMarkComplete"];
        self.dateTimeVisitReportSubmit = [visitDetail valueForKey:@"dateTimeVisitReportSubmit"];
        self.petImageFile = [visitDetail valueForKey:@"petImageFile"];
		self.mapSnapShotFilename = [visitDetail valueForKey:@"mapSnapShotFilename"];
		self.currentArriveVisitStatus = [visitDetail valueForKey:@"currentArriveVisitStatus"];
		self.currentCompleteVisitStatus = [visitDetail valueForKey:@"currentCompleteVisitStatus"];
		self.imageUploadStatus = [visitDetail valueForKey:@"imageUploadStatus"];
		self.mapSnapUploadStatus = [visitDetail valueForKey:@"mapSnapUploadStatus"];
		self.visitReportUploadStatus = [visitDetail valueForKey:@"visitReportUploadStatus"];
		self.mapSnapTakeStatus = [visitDetail valueForKey:@"mapSnapTakeStatus"];

		//NSLog(@"ARR: %@, COMP: %@, IMG:%@,MAP: %@, Mapup: %@, Report:%@",_currentArriveVisitStatus,_currentCompleteVisitStatus,_imageUploadStatus,_mapSnapTakeStatus,_mapSnapUploadStatus,_visitReportUploadStatus);
        NSString *petImagePath = [documentsPath stringByAppendingPathComponent:_petImageFile];
        _currentPetImage = [[UIImage alloc]initWithContentsOfFile:petImagePath];
		_mapSnapShotImage = [[UIImage alloc]initWithContentsOfFile:_mapSnapShotFilename];
		
        if([[visitDetail valueForKey:@"didPoo"]isEqualToString:@"YES"]) {
            _didPoo = YES;
        } else {
            _didPoo = NO;
        }
        if([[visitDetail valueForKey:@"didPee"]isEqualToString:@"YES"]) {
            _didPee = YES;
        } else {
            _didPee = NO;
        }
        if([[visitDetail valueForKey:@"wasHappy"]isEqualToString:@"YES"]) {
            _wasHappy = YES;
        } else {
            _wasHappy = NO;
        }
        if([[visitDetail valueForKey:@"wasSad"]isEqualToString:@"YES"]) {
            _wasSad = YES;
        } else {
            _wasSad = NO;
        }
        if ([[visitDetail valueForKey:@"wasAngry"]isEqualToString:@"YES"]) {
            _wasAngry = YES;
            
        } else {
            _wasAngry = NO;
        }
        if([[visitDetail valueForKey:@"wasShy"]isEqualToString:@"YES"]) {
            _wasShy = YES;
            
        } else  {
            _wasShy = NO;
        }
        if([[visitDetail valueForKey:@"wasHungry"]isEqualToString:@"YES"]) {
            _wasHungry = YES;
            
        } else  {
            _wasHungry = NO;
        }
        if ([[visitDetail valueForKey:@"wasSick"]isEqualToString:@"YES"]) {
            _wasSick = YES;
        } else {
            _wasSick = NO;

        }
        if([[visitDetail valueForKey:@"didPlay"]isEqualToString:@"YES"]) {
            _didPlay = YES;
        } else {
            _didPlay = NO;
        }
        if ([[visitDetail valueForKey:@"wasCat"]isEqualToString:@"YES"]) {
            _wasCat = YES;
        } else {
            _wasCat = NO;
        }
        if ([[visitDetail valueForKey:@"didScoopLitter"]isEqualToString:@"YES"]) {
            
            _didScoopLitter = YES;
        } else {
            _didScoopLitter = NO;
        }
    }
}

-(void)addPointForRouteUsingCLLocation:(CLLocation*)location {

	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	[dateFormat setLocale:[NSLocale currentLocale]];
	[dateFormat setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormat setDateFormat:@"hhMMss"];

	NSDateFormatter *keyDateFormat = [[NSDateFormatter alloc]init];
	[keyDateFormat setDateFormat:@"HH:mm:ss MMM dd yyyy"];

	NSData *pointData = [NSKeyedArchiver archivedDataWithRootObject:location];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths firstObject];
	NSString *filename = [NSString stringWithFormat:@"%@-coordinates",self.appointmentid];
	NSString *coordinateFilePath = [documentsPath stringByAppendingPathComponent:filename];

	if([fileManager fileExistsAtPath:coordinateFilePath]) {

		NSArray *coordinateArray = [[NSArray alloc]initWithContentsOfFile:coordinateFilePath];
		_routePoints = [[NSMutableArray alloc]initWithArray:coordinateArray];
		[_routePoints addObject:pointData];
		NSArray *coordinateArrayFile = [[NSArray alloc]initWithArray:_routePoints];
		
		BOOL wroteCoordArr = [coordinateArrayFile writeToFile:coordinateFilePath atomically:YES];

		if(wroteCoordArr) {
			NSLog(@"coordinate count: %lu",(unsigned long)[coordinateArrayFile count]);
		} else {
			NSLog(@"coord arr file not written");
		}
	} else {

		NSArray *coordinateArray = [[NSArray alloc]initWithObjects:pointData, nil];
		BOOL wroteCoordArr = [coordinateArray writeToFile:coordinateFilePath atomically:YES];
		if(wroteCoordArr) {
			NSLog(@"coord arr file written");
		} else {
			NSLog(@"coord arr file not written");
		}
	}
}

-(NSArray*)getPointForRoutes {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *filename = [NSString stringWithFormat:@"%@-coordinates",self.appointmentid];
    NSString *coordinateFilePath = [documentsPath stringByAppendingPathComponent:filename];
    
    if([fileManager fileExistsAtPath:coordinateFilePath]) {
        
        NSArray *coordinateArray = [[NSArray alloc]initWithContentsOfFile:coordinateFilePath];
        return coordinateArray;

    } else {
        
        return NULL;
        
    }
}

-(NSString *)stringForCurrentDateAndTime {
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *now = [NSDate date];
    NSString *dateString = [format stringFromDate:now];
    return dateString;
}

-(NSString *)stringForCurrentDay {
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *now = [NSDate date];
    NSString *dateString = [format stringFromDate:now];
    return dateString;
}

@end
