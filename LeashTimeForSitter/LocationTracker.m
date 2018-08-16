//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"
#import "VisitDetails.h"
#import "VisitsAndTracking.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

VisitsAndTracking *visitData;
BOOL userDeniedLocationTracking;

@implementation LocationTracker

+ (instancetype) sharedLocationManager {
	static LocationTracker *sharedMyManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMyManager = [[self alloc] init];
	});
	return sharedMyManager;
}

- (id)init {
	
	if (self==[super init]) {

        self.shareModel = [LocationShareModel sharedModel];
		self.shareModel.allCoordinates = [[NSMutableArray alloc]init];
        _regionMonitoringSetupForDay = NO;
        visitData = [VisitsAndTracking sharedInstance];
     
		if(_locationManager == nil) {

			_locationManager = [[CLLocationManager alloc]init];
			_locationManager.delegate = self;
			_locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
			_locationManager.allowsBackgroundLocationUpdates = YES;
			_locationManager.pausesLocationUpdatesAutomatically = NO;
			_locationManager.distanceFilter = [VisitsAndTracking sharedInstance].distanceSettingForGPS;
			[[NSNotificationCenter defaultCenter]postNotificationName:@"startGPS" object:nil];
		}
	
        _regionRadius = 50.0;
        _distanceFilterSetting = visitData.distanceSettingForGPS;
        _minAccuracy = visitData.minimumGPSAccuracy;
        _updateFrequencySeconds = visitData.updateFrequencySeconds;
        _minNumCoordinatesBeforeSend = visitData.minNumCoordinatesSend;
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(applicationEnterBackground)
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];

		
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(sendBackgroundCoordsToServer)
                                                    name:@"MarkComplete"
                                                  object:nil];
        
        
    }
	return self;
}

-(void)applicationEnterBackground{
}


-(void)restartLocationUpdates{
	_isLocationTracking = TRUE;
	[[NSNotificationCenter defaultCenter]postNotificationName:@"startGPS" object:nil];
	[_locationManager startUpdatingLocation];
}

-(void)getLocationPermissions {
	CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
	{
		if ((status == kCLAuthorizationStatusNotDetermined) && ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || 
																[_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
		{
			if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"]) { 
				if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
					[_locationManager performSelector:@selector(requestAlwaysAuthorization)];
				}
				else{
					[[NSException exceptionWithName:@"[BBLocationManager] Fix needed for location permission key" reason:@"Your app's info.plist need both NSLocationWhenInUseUsageDescription and NSLocationAlwaysAndWhenInUseUsageDescription keys for asking 'Always usage of location' in iOS 11" userInfo:nil] raise];
				}
				
			} else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) { 
				[_locationManager performSelector:@selector(requestWhenInUseAuthorization)];
			} else {
				[[NSException exceptionWithName:@"[BBLocationManager] Fix needed for location permission key" 
										 reason:@"Your app's info.plist does not contain NSLocationWhenInUseUsageDescription and/or NSLocationAlwaysAndWhenInUseUsageDescription key required for iOS 11" 
									   userInfo:nil] raise];
			}
		}
		else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
			NSString *title, *message;
			if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"]) {
				title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
				message = @"To use background location you must turn on 'Always' in the Location Services Settings";
			} else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
				title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Location Service is not enabled";
				message = @"To use location you must turn on 'While Using the App' in the Location Services Settings";
			}
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
																message:message
															   delegate:self
													  cancelButtonTitle:@"Cancel"
													  otherButtonTitles:@"Settings", nil];
			[alertView show];
		}
	}
	else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
	{
		if ((status == kCLAuthorizationStatusNotDetermined) && ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]))
		{
			if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
				[_locationManager performSelector:@selector(requestAlwaysAuthorization)];
			} else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
				[_locationManager performSelector:@selector(requestWhenInUseAuthorization)];
			} else {
				[[NSException exceptionWithName:@"[BBLocationManager] Location Permission Error" reason:@"Info.plist does not contain NSLocationWhenUse or NSLocationAlwaysUsageDescription key required for iOS 8" userInfo:nil] raise];
			}
		}
		else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
			NSString *title, *message;
			if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
				title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
				message = @"To use background location you must turn on 'Always' in the Location Services Settings";
			} else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
				title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Location Service is not enabled";
				message = @"To use location you must turn on 'While Using the App' in the Location Services Settings";
			}
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
																message:message
															   delegate:self
													  cancelButtonTitle:@"Cancel"
													  otherButtonTitles:@"Settings", nil];
			[alertView show];
		}
	}
}
-(void)startLocationTracking {
	_isLocationTracking = TRUE;
	[self getLocationPermissions];
	[_locationManager startUpdatingLocation];
	[[NSNotificationCenter defaultCenter]postNotificationName:@"startGPS" object:nil];
	self.locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:_updateFrequencySeconds
																target:self
															  selector:@selector(updateLocation)
															  userInfo:nil
															   repeats:YES];
	
}
-(void)stopLocationTracking {
	_isLocationTracking = FALSE;
	[self.locationManager stopUpdatingLocation];
}


-(void)stopLocationDelayBy10Seconds{
    [self.locationManager stopUpdatingLocation];
	[[NSNotificationCenter defaultCenter]postNotificationName:@"stopGPS" object:nil];
}
-(void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error{

    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
        }
            break;
        case kCLErrorDenied:
		{
        }
            break;
        default:
        {
        }
        break;
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *bestLocation = nil;
	
    for(int i=0; i<locations.count; i++){
        CLLocation *newLocation = [locations objectAtIndex:i];
		if(bestLocation == nil) {
			bestLocation = newLocation;
		} else {
			if(newLocation.horizontalAccuracy < bestLocation.horizontalAccuracy) {
				bestLocation = newLocation;
			}
		}
    }
	
	if(bestLocation!=nil
	   && bestLocation.horizontalAccuracy > 0
	   && bestLocation.horizontalAccuracy < _minAccuracy) {
		   
		   self.myLastLocation = bestLocation.coordinate;
		   self.myLocationAccuracy= bestLocation.horizontalAccuracy;
		
		   _shareModel.validLocationLast = bestLocation;
		   _shareModel.lastValidLocation = bestLocation.coordinate;
		   
		   if([visitData.onSequence isEqualToString:@"000"]) {
			   
		   } else {
			   if(visitData != NULL) {
				   [_shareModel.allCoordinates addObject:bestLocation];

				   if(visitData.multiVisitArrive) {
					   [visitData addLocationForMultiArrive:bestLocation];
				   } else {
					   [visitData addLocationCoordinate:bestLocation];
				   }
			   }
		   }
	}
	
	[[NSNotificationCenter defaultCenter]postNotificationName:@"debugGPS" object:nil];
}
-(void)updateLocation {

    if([_shareModel.allCoordinates count] > _minNumCoordinatesBeforeSend && visitData.isReachable) {
        if (visitData.appRunningBackground) {
            if(visitData.isReachable) {
                [self sendCoordinatesToServer:@"foreground"];
            }
        } else {
            if(visitData.isReachable) {
                [self sendCoordinatesToServer:@"foreground"];
            }
        }
    }
}
-(void)sendBackgroundCoordsToServer {

	if(visitData.isReachable) {
		[self sendCoordinatesToServer:@"completion"];
		if(visitData.multiVisitArrive) {
			if([visitData.onSequenceArray count] == 1) {
				[visitData.onSequenceArray removeAllObjects];
			}
			else if([visitData.onSequenceArray count] > 1) {
				VisitDetails *removeVisit;
				for(int i = 0; i < [visitData.onSequenceArray count]; i++) {
					VisitDetails *visitArrive = [visitData.onSequenceArray objectAtIndex:i];
					if ([visitArrive.sequenceID isEqualToString:visitData.onSequence]) {
						removeVisit = visitArrive;
					}
				}
				
				[visitData.onSequenceArray removeObject:removeVisit];
				removeVisit = nil;
				VisitDetails *visitForSeq = [visitData.onSequenceArray lastObject];
				visitData.onSequence = visitForSeq.sequenceID;
				[[NSNotificationCenter defaultCenter]postNotificationName:@"stopGPS" object:nil];
				
			}
		}
	}
}


double DegreesToRadians(double degrees) {return degrees * M_PI / 180;};
double RadiansToDegrees(double radians) {return radians * 180/M_PI;};

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
	
	NSUserDefaults *pauseLocationPersist = [NSUserDefaults standardUserDefaults];
	NSDate *rightNow = [NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	[dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
	NSString *dateString = [dateFormat stringFromDate:rightNow];
	[pauseLocationPersist setObject:@"LOCATION PAUSE" forKey:dateString];
	
}

-(double) bearingToLocation:(CLLocation *) fromLocation toLocation:(CLLocation*)toLocation {
	
	double lat1 = DegreesToRadians(fromLocation.coordinate.latitude);
	double lon1 = DegreesToRadians(fromLocation.coordinate.longitude);
	
	double lat2 = DegreesToRadians(toLocation.coordinate.latitude);
	double lon2 = DegreesToRadians(toLocation.coordinate.longitude);
	
	double dLon = lon2 - lon1;
	
	double y = sin(dLon) * cos(lat2);
	double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
	double radiansBearing = atan2(y, x);
	
	return RadiansToDegrees(radiansBearing);
}

-(void) sendCoordinatesToServer:(NSString*)backgroundOrForeground {

    NSDate *rightNow = [NSDate date];
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
    [dateFormat2 setDateFormat:@"HH:mm:ss"];
    NSString *shortDateString = [dateFormat2 stringFromDate:rightNow];
    NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
    NSString *credentialString = [NSString stringWithFormat:@"loginid=%@&password=%@&coords=[",[loginSettings objectForKey:@"username"],[loginSettings objectForKey:@"password"]];
    NSMutableArray *arrayVisitsSendCoords = [[NSMutableArray alloc]init];
    
    if(visitData.multiVisitArrive && 
	   [backgroundOrForeground isEqualToString:@"foreground"]) {
        
        if(visitData.onSequenceArray != NULL) {
            for(VisitDetails *visit in visitData.visitData) {
                for(VisitDetails *sequenceIDArrive in visitData.onSequenceArray) {
                    if([sequenceIDArrive.sequenceID isEqualToString:visit.sequenceID]) {
                        [arrayVisitsSendCoords addObject:visit];
                    }
                }
            }
            
            int countVisits = (int)[arrayVisitsSendCoords count];
            
            for(VisitDetails *visitInfo in arrayVisitsSendCoords) {
                int i = 0;
                for (CLLocation *coordinateAll in _shareModel.allCoordinates) {
                    
                    NSString *theLatitude = [NSString stringWithFormat:@"%f",coordinateAll.coordinate.latitude];
                    NSString *theLongitude = [NSString stringWithFormat:@"%f",coordinateAll.coordinate.longitude];
                    NSString *theAccuracy = [NSString stringWithFormat:@"%f",coordinateAll.horizontalAccuracy];
                    NSString *theEvent = @"mv";
                    NSString *theHeading = @"3";
                    NSString *theError = @"";
                    NSDate *timestampCoordinate = coordinateAll.timestamp;
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
                    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                    NSString *dateString = [dateFormat stringFromDate:timestampCoordinate];
                    
                    _shareModel.lastSendTimeStamp = shortDateString;
                    _shareModel.lastSendNumCoordinates = [NSString stringWithFormat:@"%lu",(unsigned long)[_shareModel.allCoordinates count]];
                    
                    i++;
			    
                    if (i < [_shareModel.allCoordinates count]) {
                        NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"},",visitInfo.appointmentid,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
                        credentialString = [credentialString stringByAppendingString:coordinateString];
                    } else {
                        if(countVisits == 1) {
                            NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"}]",visitInfo.appointmentid,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
                            credentialString = [credentialString stringByAppendingString:coordinateString];
                        } else {
                            NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"},",visitInfo.appointmentid,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
                            credentialString = [credentialString stringByAppendingString:coordinateString];
						}
                    }
                }
                countVisits--;
            }
        }
		
        [self transmitNetworkRequest:credentialString
                             forType:@"multi-visit"];
		
	} else if (visitData.multiVisitArrive && 
			   [backgroundOrForeground isEqualToString:@"completion"]) {
		
		VisitDetails *visitCompleteRemove;
        if(visitData.onSequenceArray != NULL) {
            for(VisitDetails *visit in visitData.visitData) {
                for(VisitDetails *sequenceIDComplete in visitData.onSequenceArray) {
                    if([sequenceIDComplete.sequenceID isEqualToString:visit.sequenceID]) {
						if([sequenceIDComplete.appointmentid isEqualToString:visitData.onWhichVisitID]) {
							visitCompleteRemove = visit;
						}
                    }
                }
            }
        }
        
        int i = 0;
        
        for (CLLocation *coordinateAll in _shareModel.allCoordinates) {
            
            NSString *theLatitude = [NSString stringWithFormat:@"%f",coordinateAll.coordinate.latitude];
            NSString *theLongitude = [NSString stringWithFormat:@"%f",coordinateAll.coordinate.longitude];
            NSString *theAccuracy = [NSString stringWithFormat:@"%f",coordinateAll.horizontalAccuracy];
            NSString *theEvent = @"mv";
            NSString *theHeading = @"3";
            NSString *theError = @"";
            NSDate *timestampCoordinate = coordinateAll.timestamp;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormat stringFromDate:timestampCoordinate];
            
            _shareModel.lastSendTimeStamp = shortDateString;
            _shareModel.lastSendNumCoordinates = [NSString stringWithFormat:@"%lu",(unsigned long)[_shareModel.allCoordinates count]];
            
            i++;
            if (i < [_shareModel.allCoordinates count]) {
                NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"},",visitCompleteRemove.appointmentid,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
                credentialString = [credentialString stringByAppendingString:coordinateString];
            } else {
                NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"}]",visitCompleteRemove.appointmentid,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
                credentialString = [credentialString stringByAppendingString:coordinateString];
            }
        }
        
        [self transmitNetworkRequest:credentialString forType:@"multi-visit-complete"];
		
    } else if (!visitData.multiVisitArrive){
        
        NSString *visitID = visitData.onWhichVisitID;
		if([visitID isEqual:[NSNull null]]) {
			visitID = @"000";
		}
		
        if (visitData != NULL) {
            for (VisitDetails *visit in visitData.visitData) {
                if ([visitData.onSequence isEqualToString:visit.sequenceID]) {
                    visitID = visit.appointmentid;
                }
            }
        }
        NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
        NSString *credentialString = [NSString stringWithFormat:@"loginid=%@&password=%@&coords=[",[loginSettings objectForKey:@"username"], [loginSettings objectForKey:@"password"]];
        int i = 0;
        
        for (CLLocation *coordinateAll in _shareModel.allCoordinates) {
            
            NSString *theLatitude = [NSString stringWithFormat:@"%f",coordinateAll.coordinate.latitude];
            NSString *theLongitude = [NSString stringWithFormat:@"%f",coordinateAll.coordinate.longitude];
            NSString *theAccuracy = [NSString stringWithFormat:@"%f",coordinateAll.horizontalAccuracy];
			NSString *theEvent =@"mv";
			NSString *theHeading = [NSString stringWithFormat:@"%f", coordinateAll.course]; //@"3";
            NSString *theError = @"";
            NSDate *timestampCoordinate = coordinateAll.timestamp;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormat stringFromDate:timestampCoordinate];
            
            _shareModel.lastSendTimeStamp = shortDateString;
            _shareModel.lastSendNumCoordinates = [NSString stringWithFormat:@"%lu",(unsigned long)[_shareModel.allCoordinates count]];
            
            i++;
            
            if (i < [_shareModel.allCoordinates count]) {
                NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"},",
							    visitID,
							    dateString,
							    theLatitude,
							    theLongitude,
							    theAccuracy,
							    theEvent,
							    theHeading,
							    theError];
			
                credentialString = [credentialString stringByAppendingString:coordinateString];
            } else {
                NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"}]",
							    visitID,
							    dateString,
							    theLatitude,
							    theLongitude,
							    theAccuracy,
							    theEvent,
							    theHeading,
							    theError];
                credentialString = [credentialString stringByAppendingString:coordinateString];
            }
        }
        
        NSData *requestBodyDataForJSONCoordinates = [credentialString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
		NSMutableURLRequest *urlSendCoordinateData = [self sendCoordUrlRequest:credentialString];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:self
                                                         delegateQueue:nil];
        
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:urlSendCoordinateData
                                                                   fromData:requestBodyDataForJSONCoordinates
                                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                              
                                                              NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                              
                                                              if(!error && httpResp.statusCode == 200) {
                                                                  [_shareModel.allCoordinates removeAllObjects];
																  [[NSNotificationCenter defaultCenter]postNotificationName:@"debugGPS" object:nil];

                                                              }
                                                          }];
        [uploadTask resume];
        [[NSURLCache sharedURLCache]removeAllCachedResponses];
        [session finishTasksAndInvalidate];

    }

}
-(void)transmitNetworkRequest:(NSString*)requestString
					  forType:(NSString*)type {

	
	NSData *requestBodyDataForJSONCoordinates = [requestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSMutableURLRequest *urlSendCoordinateData = [self sendCoordUrlRequest:requestString];
	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
														  delegate:self
													 delegateQueue:nil];
	
	NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:urlSendCoordinateData
															   fromData:requestBodyDataForJSONCoordinates
													  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
														  
														  NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
														  //NSString *myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
														  
														  if(!error && httpResp.statusCode == 200) {
														
															  if([type isEqualToString:@"multi-visit"]){
																  
																  [_shareModel.allCoordinates removeAllObjects];
																  
															  } else if ([type isEqualToString:@"multi-visit-complete"]) {
																  
																  if ([visitData.onSequenceArray count] == 0) {
																	  [_shareModel.allCoordinates removeAllObjects];
																  }
															  }
														  } 
													  }];
	[uploadTask resume];
	[[NSURLCache sharedURLCache]removeAllCachedResponses];
	[session finishTasksAndInvalidate];
}


-(NSMutableURLRequest*) sendCoordUrlRequest:(NSString*)requestString {
	
	NSString *sendCoordURL = @"https://leashtime.com/native-sitter-location.php";
	NSData *requestBodyDataForJSONCoordinates = [requestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBodyDataForJSONCoordinates length]];
	NSURL *url = [NSURL URLWithString:sendCoordURL];

	NSMutableURLRequest *urlSendCoordinateData = [[NSMutableURLRequest alloc]initWithURL:url];
	[urlSendCoordinateData setURL:url];
	[urlSendCoordinateData setHTTPMethod:@"POST"];
	[urlSendCoordinateData setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[urlSendCoordinateData setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[urlSendCoordinateData setTimeoutInterval:20.0];
	
	NSString *userAgentString = visitData.userAgentLT;
	[urlSendCoordinateData setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
	[urlSendCoordinateData setHTTPBody:requestBodyDataForJSONCoordinates];

	return urlSendCoordinateData;
}


@end
