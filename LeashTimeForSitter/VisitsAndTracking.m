//
//  VisitsAndTracking.m
//  LeashTimeSitter
//
//  Created by Ted Hooban on 8/13/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "VisitsAndTracking.h"
#import "LocationTracker.h"
#import "DateTools.h"
#import "DataClient.h"
#import "VisitDetails.h"
#import "AFNetworking.h"
#import "DistanceMatrix.h"
#import "SDWebImageDownloader.h"
#import <UserNotifications/UserNotifications.h>
#import <MapKit/MapKit.h>

@implementation VisitsAndTracking {

	NSMutableArray *yesterdayVisits;
	NSMutableArray *tomorrowVisits;
	NSMutableArray *todaysVisits;
	NSURLSession *mySession;
	NSURLSessionConfiguration *sessionConfiguration;
	NSTimer *checkForBadArriveComplete;
	NSDateFormatter *oldFormatter;
	NSDateFormatter *newFormatter;		
	NSDateFormatter *dateFormat;
	NSDateFormatter *requestDateFormat;

}

NSString *const pollingCompleteWithChanges = @"pollingCompleteWithChanges";
NSString *const pollingFailed = @"pollingFailed";
int NUMBER_MIN_LATE_NOTIFICATION = -30;
int totalCoordinatesInSession;

// PathSense API key: 7wVgpNip5P3mbBLtTYML33jrHesVKKwo3XeTpONV
// PathSense API client ID: DbbrW7ccQjp4pEKMBoRms7B5EcpTtJcAo6DZHulf
// @"LeashTime Sitter iOS /v2.5 /08-10-2016";
// QVX992DISABLED


/*
 native-client-visit-report-list.php
 
 Returns a JSON array describing the visit reports for a supplied client in a supplied date range.
 Parameters: loginid,password,start,end,clientid.  All are required.
 Errors
 Authentication errors: single character, as everywhere else.
 Other errors - displayed as a multiline text that may include:
 
 ERROR: No provider found for user {$user['userid']}
 ERROR: No client id supplied
 ERROR: No client found for client id [$clientid]
 ERROR: Bad start parameter [$start]
 ERROR: Bad end parameter [$end]
 Sample Visit Report
 
 {"clientptr":"45","NOTE":"Just so playful and exuberant.","ARRIVED":"2016-10-02 10:14:23","COMPLETED":"2016-10-02 10:18:30","MAPROUTEURL":"https:\/\/LeashTime.com\/visit-map.php?id=175825","VISITPHOTOURL":"appointment-photo.php?id=175825","MOODBUTTON":{"cat":"0","happy":"1","hungry":"0","litter":"0","pee":"1","play":"0","poo":"1","sad":"0","shy":"0","sick":"0"},"appointmentid":"175825","date":"2016-10-02","starttime":"09:00:00","timeofday":"9:00 am-11:00 am","sittername":"Brian Martinez","nickname":null}
 
 No Reports Found
 
 []
 
 Sample Visit Report for a visit not arrived, not completed, and no note:
 
 [{"clientptr":"45","NOTE":null,"ARRIVED":null,"COMPLETED":null,"MAPROUTEURL":"https:\/\/LeashTime.com\/visit-map.php?id=175931","VISITPHOTOURL":null,"MOODBUTTON":[],"appointmentid":"175931","date":"2016-10-05","starttime":"09:00:00","timeofday":"9:00 am-11:00 am","sittername":"Brian Martinez","nickname":null}
 
 TBD
 
 This script filters only on date and client.  It returns data for every visit in the range, regardless of status.  Please let me know if you would like me to filter it any further.  If so, please describe the filter in terms of the attributes listed above (e.g., do not return a report if NOTE is null, ARRIVED is null, and COMPLETED is null
 
 PLEASE BE AWARE...
 
 The NOTE attribute is the visit note at the time of retrieval, which may be the manager's note (from the client) or the sitter's note.


*/
+(VisitsAndTracking *)sharedInstance {
    
    static VisitsAndTracking *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		_sharedInstance =[[VisitsAndTracking alloc]init];
	});
    return _sharedInstance;
}
-(id)init {
    self = [super init];
    if (self) {
        
        _userAgentLT = @"LEASHTIME V3.3/FEBRUARY 2018/IOS 11";
        _shareLocationManager = [LocationShareModel sharedModel];
        _numFutureDaysVisitInformation = 20;
        _onSequence = @"000";
        _onSequenceArray = [[NSMutableArray alloc]init];
        _onWhichVisitID = NULL;


		_todayDate = [NSDate date];
        _showingWhichDate = _todayDate;        
        _cachedPetImages = [[NSMutableArray alloc]init];
        _fileManager = [NSFileManager new];
        
        coordinatesForVisits = [[NSMutableDictionary alloc]init];
        _clientData = [[NSMutableArray alloc]init];
        _visitData = [[NSMutableArray alloc]init];
	    _localNotificationQueue = [[NSMutableArray alloc]init];
		
		yesterdayVisits = [[NSMutableArray alloc]init];
		tomorrowVisits = [[NSMutableArray alloc]init];
		todaysVisits = [[NSMutableArray alloc]init];
	    
        _arrivalCompleteQueueItems = [[NSMutableArray alloc]init];

		 sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.URLCache = [[NSURLCache alloc]initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
		
		oldFormatter = [[NSDateFormatter alloc] init];
		newFormatter = [[NSDateFormatter alloc] init];
		dateFormat = [[NSDateFormatter alloc]init];
		oldFormatter.dateFormat = @"HH:mm:ss"; // The old format
		newFormatter.dateFormat = @"h:mm a"; // The new format
		[dateFormat setDateFormat:@"YYYY-MM-dd"];
		[dateFormat setTimeZone:[NSTimeZone localTimeZone]];
		requestDateFormat=[[NSDateFormatter alloc]init];
		[requestDateFormat setDateFormat:@"yyyy-MM-dd"];
	    
		checkForBadArriveComplete = [NSTimer scheduledTimerWithTimeInterval:1200 
																	repeats:YES
																	  block:^(NSTimer * _Nonnull timer) {
																		  
																		  NSMutableArray *removeItems = [[NSMutableArray alloc]init];
																		  //[self visitDetailsVisitStatus];
																		  
																		  for (NSMutableDictionary *arrComDic in _arrivalCompleteQueueItems) {
																			  
																			  NSString *statusString = [arrComDic objectForKey:@"STATUS"];
																			  NSString *resendType = [arrComDic objectForKey:@"TYPE"];
																			  NSString *appointmentID = [arrComDic objectForKey:@"appointmentptr"];
																			  
																			  if (_isReachable) {
																				  if ([statusString isEqualToString:@"FAIL-NETWORK RESPONSE"] || [statusString isEqualToString:@"FAIL-NOT REACHABLE"] ) {
																					 
																					  if([resendType isEqualToString:@"IMAGE"]) {
																						  [self resendImageUpload:arrComDic];
																					  } else if ([resendType isEqualToString:@"MAP"]) {
																						  VisitDetails *visit = [self getVisitDetailForVisitID:appointmentID];
																						  if ([visit.mapSnapTakeStatus isEqualToString:@"FAIL"] ||
																							  visit.mapSnapShotImage == NULL) {
																							  [self createMapSnapshot:visit requestDic:arrComDic];
																						  } else if (![visit.mapSnapTakeStatus isEqualToString:@"FAIL"] &&
																									 visit.mapSnapShotImage != NULL &&
																									 [visit.mapSnapUploadStatus isEqualToString:@"FAIL"]) {
																							  [self resendMapSnapUpload:arrComDic];
																						  }
																					  } else if ([resendType isEqualToString:@"MAP-SNAP"]) {
																						  VisitDetails *visit = [self getVisitDetailForVisitID:appointmentID];
																						  [self createMapSnapshot:visit  requestDic:arrComDic];
																					  } else if([resendType isEqualToString:@"ARRIVE"]) {
																						  [self resendMarKArriveCompleteToServer:arrComDic];
																					  } else if([resendType isEqualToString:@"COMPLETE"]) {
																						  [self resendMarKArriveCompleteToServer:arrComDic];
																					  } else if ([resendType isEqualToString:@"REPORT"]) {
																						  [self resendVisitReport:arrComDic];
																					  }	
																				  } else if ([statusString isEqualToString:@"SUCCESS"]) {
																					  [removeItems addObject:arrComDic];
																				  }
																			  }
																		  } 
																		  @synchronized(@"resendQueue") {
																			  [_arrivalCompleteQueueItems removeObjectsInArray:removeItems];
																		  }
																	  }];
			
        [self setUpReachability];
        [self readSettings];
		
		
	    [[NSNotificationCenter 
		  defaultCenter]addObserver:self
		 selector:@selector(changeResendStatus:)
		 name:@"resendArriveCompleteSuccess"
		 object:nil];
	
    }
    
    return self;
}

-(void)foregroundBadRequest {
	NSMutableArray *removeItems = [[NSMutableArray alloc]init];
	for (NSMutableDictionary *arrComDic in _arrivalCompleteQueueItems) {
		
		NSString *statusString = [arrComDic objectForKey:@"STATUS"];
		NSString *resendType = [arrComDic objectForKey:@"TYPE"];
		NSString *appointmentID = [arrComDic objectForKey:@"appointmentptr"];

		if (_isReachable) {
			if ([statusString isEqualToString:@"FAIL-NETWORK RESPONSE"] || [statusString isEqualToString:@"FAIL-NOT REACHABLE"] ) {
				
				if([resendType isEqualToString:@"IMAGE"]) {
					
					[self resendImageUpload:arrComDic];
					
				} else if ([resendType isEqualToString:@"MAP"]) {
					
					VisitDetails *visit = [self getVisitDetailForVisitID:appointmentID];
					
					if ([visit.mapSnapTakeStatus isEqualToString:@"FAIL"] ||
						visit.mapSnapShotImage == NULL) {
						
						[self createMapSnapshot:visit requestDic:arrComDic];
						
					} else if (![visit.mapSnapTakeStatus isEqualToString:@"FAIL"] &&
							   visit.mapSnapShotImage != NULL &&
							   [visit.mapSnapUploadStatus isEqualToString:@"FAIL"]) {
						
						[self resendMapSnapUpload:arrComDic];
					}
				} else if ([resendType isEqualToString:@"MAP-SNAP"]) {
					
					VisitDetails *visit = [self getVisitDetailForVisitID:appointmentID];
					[self createMapSnapshot:visit  requestDic:arrComDic];
					
				} else if([resendType isEqualToString:@"ARRIVE"]) {
					
					[self resendMarKArriveCompleteToServer:arrComDic];
					
				} else if([resendType isEqualToString:@"COMPLETE"]) {
					
					[self resendMarKArriveCompleteToServer:arrComDic];
					
				} else if ([resendType isEqualToString:@"REPORT"]) {
					
					[self resendVisitReport:arrComDic];
					
				}	
			} else if ([statusString isEqualToString:@"SUCCESS"]) {
				
				[removeItems addObject:arrComDic];
			}
		}
	} 
	@synchronized(@"resendQueue") {
		[_arrivalCompleteQueueItems removeObjectsInArray:removeItems];
	}
}
																	
-(VisitDetails*)getVisitDetailForVisitID:(NSString*) appointmentID {
	for (VisitDetails *visit in _visitData) {
		if ([visit.appointmentid isEqualToString:appointmentID]) {
			return visit;
		}
	}
	return NULL;
}
																			
- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
	
	CLLocationDegrees minLat = 90.0;
	CLLocationDegrees maxLat = -90.0;
	CLLocationDegrees minLon = 180.0;
	CLLocationDegrees maxLon = -180.0;
	
	for (CLLocation *location in annotations) {
		
		CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
		if (coordinates.latitude < minLat) {
			minLat = coordinates.latitude;
		}
		if (coordinates.longitude < minLon) {
			minLon = coordinates.longitude;
		}
		if (coordinates.latitude > maxLat) {
			maxLat = coordinates.latitude;
		}
		if (coordinates.longitude > maxLon) {
			maxLon = coordinates.longitude;
		}
	}
	
	double maxLatDouble = maxLat;
	maxLatDouble = maxLatDouble - minLat;
	double maxLonDouble = maxLon;
	maxLonDouble = maxLonDouble - minLon;
	CLLocationCoordinate2D convertCoord = CLLocationCoordinate2DMake(maxLatDouble, maxLonDouble);
	CLLocationDegrees maxLatConvert = convertCoord.latitude;
	CLLocationDegrees maxLonConvert = convertCoord.longitude;
	MKCoordinateSpan span = MKCoordinateSpanMake(maxLatConvert, maxLonConvert);
	CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2);	
	return MKCoordinateRegionMake(center, span);
}

- (void)createMapSnapshot:(VisitDetails*)currentVisit requestDic:(NSMutableDictionary*)arrComDic {
	UIImageView *mapSnapShotImage;
	
	if([deviceType isEqualToString:@"iPhone6P"]) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 350, 345, 345)];
	} else if ([deviceType isEqualToString:@"iPhone6"]) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 335, 310, 310)];
	} else if ([deviceType isEqualToString:@"iPhone5"]) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 280, 254, 254)];
	} else if ([deviceType isEqualToString:@"iPhone4"]) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 280, 300, 300)];
	}
	float markVisitCompleteLat;
	float markVisitComplateLon;
	markVisitComplateLon = [currentVisit.coordinateLongitudeMarkComplete floatValue];
	markVisitCompleteLat = [currentVisit.coordinateLatitudeMarkComplete floatValue];
	//CLLocationCoordinate2D completeVisit = CLLocationCoordinate2DMake(markVisitCompleteLat,markVisitComplateLon);
	__block MKMapSnapshotter *snapshotter;
	__block NSArray *redrawVisitPoints = [NSArray arrayWithArray:[self getCoordinatesForVisit:currentVisit.appointmentid]];
	//__block NSDictionary *arriveCompleteBad = arrComDic;
	MKMapSnapshotOptions *mapSnapOp = [[MKMapSnapshotOptions alloc]init];
	
	mapSnapOp.size = CGSizeMake(mapSnapShotImage.frame.size.width, mapSnapShotImage.frame.size.height);
	mapSnapOp.scale = [[UIScreen mainScreen]scale];
	mapSnapOp.mapType = MKMapTypeStandard;
	mapSnapOp.showsBuildings = YES;
	mapSnapOp.showsPointsOfInterest = YES;
	
	MKMapCamera *mapViewVC = [[MKMapCamera alloc]init];
	mapViewVC.pitch = 45;
	mapViewVC.altitude = 400;
	mapSnapOp.camera = mapViewVC;
	//MKCoordinateRegion region;
	CLLocationCoordinate2D clientHome = CLLocationCoordinate2DMake([currentVisit.latitude floatValue], [currentVisit.longitude floatValue]);
	
	//if([redrawVisitPoints count] > 4) {
	//	region = [self regionForAnnotations:redrawVisitPoints];
	//	mapSnapOp.region = region;
	//	mapViewVC.centerCoordinate = completeVisit;
	//} else {
		double maxLatSpan = clientHome.latitude;
		double maxLonSpan = clientHome.longitude;
		maxLatSpan = 0.002611;
		maxLonSpan = 0.002964;
		CLLocationCoordinate2D clientLoc = CLLocationCoordinate2DMake(maxLatSpan, maxLonSpan);
		MKCoordinateSpan span = MKCoordinateSpanMake(clientLoc.latitude, clientLoc.longitude);
		MKCoordinateRegion region = MKCoordinateRegionMake(clientHome, span);
		mapViewVC.centerCoordinate = clientHome;
		mapSnapOp.region = region;
	//}

	snapshotter = [[MKMapSnapshotter alloc]initWithOptions:mapSnapOp];
	[snapshotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
		
		if(error == nil) {
			UIImage * res = nil;
			UIImage * image = snapshot.image;
			UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
			[image drawAtPoint:CGPointMake(0, 0)];
			CGContextRef context = UIGraphicsGetCurrentContext();
			UIColor *color = [UIColor blueColor];
			CGContextSetStrokeColorWithColor(context,[color CGColor]);
			CGContextSetLineWidth(context,4.0f);
			CGContextBeginPath(context);
			CLLocationCoordinate2D coordinates[[redrawVisitPoints count]];
			for(int i=0;i<[redrawVisitPoints count];i++)
			{
				CLLocation *thePoint = [redrawVisitPoints objectAtIndex:i];
				coordinates[i] = thePoint.coordinate;
			}
			for (int i = 0; i < [redrawVisitPoints count]; i++) {
				CGPoint point = [snapshot pointForCoordinate:coordinates[i]];					
				if(i==0)
				{
					CGContextMoveToPoint(context,point.x, point.y);
				}
				else{
					CGContextAddLineToPoint(context,point.x, point.y);
				}
			}
			CGContextStrokePath(context);
			MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
			UIImage *pinImage = [UIImage imageNamed:@"red-paw"];
			CGPoint point = [snapshot pointForCoordinate:clientHome];
			CGPoint pinCenterOffset = pin.centerOffset;
			point.x -= pin.bounds.size.width / 2.0;
			point.y -= pin.bounds.size.height / 2.0;
			point.x += pinCenterOffset.x;
			point.y += pinCenterOffset.y;
			[pinImage drawAtPoint:point];
			res = UIGraphicsGetImageFromCurrentImageContext();

			UIGraphicsEndImageContext();
			mapSnapShotImage.image = res;
			[arrComDic setValue:@"SUCCESS" forKey:@"MAP-SNAP"];
			[currentVisit addMapsnapShotImageToVisit:res];

		}
	}];
}

-(void)visitDetailsVisitStatus { 
	
	for (VisitDetails *visit in _visitData) {
		
		if([visit.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
			NSMutableDictionary *resendDic = [[NSMutableDictionary alloc]init];
			[resendDic setObject:visit.appointmentid forKey:@"appointmentptr"];
			[resendDic setObject:@"ARRIVE"  forKey:@"TYPE"];
			[resendDic setObject:@"FAIL" forKey:@"STATUS"];
		} 
		if([visit.currentCompleteVisitStatus isEqualToString:@"FAIL"]) {
			NSMutableDictionary *resendDic = [[NSMutableDictionary alloc]init];
			[resendDic setObject:visit.appointmentid forKey:@"appointmentptr"];
			[resendDic setObject:@"COMPLETE"  forKey:@"TYPE"];
			[resendDic setObject:@"FAIL" forKey:@"STATUS"];
		}
		if([visit.imageUploadStatus isEqualToString:@"FAIL"]) {
			NSMutableDictionary *resendDic = [[NSMutableDictionary alloc]init];
			[resendDic setObject:visit.appointmentid forKey:@"appointmentptr"];
			[resendDic setObject:@"IMAGE"  forKey:@"TYPE"];
			[resendDic setObject:@"FAIL" forKey:@"STATUS"];
		}
		if([visit.mapSnapUploadStatus isEqualToString:@"FAIL"]) {
			NSMutableDictionary *resendDic = [[NSMutableDictionary alloc]init];
			[resendDic setObject:visit.appointmentid forKey:@"appointmentptr"];
			[resendDic setObject:@"MAP"  forKey:@"TYPE"];
			[resendDic setObject:@"FAIL" forKey:@"STATUS"];
		} 
		if([visit.mapSnapTakeStatus isEqualToString:@"FAIL"]) {
			NSMutableDictionary *resendDic = [[NSMutableDictionary alloc]init];
			[resendDic setObject:visit.appointmentid forKey:@"appointmentptr"];
			[resendDic setObject:@"MAP-SNAP"  forKey:@"TYPE"];
			[resendDic setObject:@"FAIL" forKey:@"STATUS"];
		} 
		if([visit.visitReportUploadStatus isEqualToString:@"FAIL"]) {
			NSMutableDictionary *resendDic = [[NSMutableDictionary alloc]init];
			[resendDic setObject:visit.appointmentid forKey:@"appointmentptr"];
			[resendDic setObject:@"REPORT"  forKey:@"TYPE"];
			[resendDic setObject:@"FAIL" forKey:@"STATUS"];
		}
	}
}

-(BOOL)checkVisitStatus:(NSString*)visitID type:(NSString*)requestType {
	for (VisitDetails *visit in _visitData) {
		if ([visit.appointmentid isEqualToString:visitID]) {
			
			if ([requestType isEqualToString:@"IMAGE"]) {
				if ([visit.imageUploadStatus isEqualToString:@"SUCCESS"] ||
					[visit.imageUploadStatus isEqualToString:@"PEND"]) {
					return TRUE;
				}
			} else if ([requestType isEqualToString:@"MAP"]) {
				if ([visit.mapSnapUploadStatus isEqualToString:@"SUCCESS"] ||
					[visit.mapSnapUploadStatus isEqualToString:@"PEND"]) {
					return TRUE;
				}
			}  else if ([requestType isEqualToString:@"ARRIVE"]) {
				if ([visit.currentArriveVisitStatus isEqualToString:@"SUCCESS"] ||
					[visit.currentArriveVisitStatus isEqualToString:@"PEND"]) {
					return TRUE;
				}
			}  else if ([requestType isEqualToString:@"COMPLETE"]) {
				if ([visit.currentCompleteVisitStatus isEqualToString:@"SUCCESS"] ||
					[visit.currentCompleteVisitStatus isEqualToString:@"PEND"]) {
					return TRUE;
				}
			} else if ([requestType isEqualToString:@"REPORT"]) {
				if ([visit.visitReportUploadStatus isEqualToString:@"SUCCESS"] ||
					[visit.visitReportUploadStatus isEqualToString:@"PEND"]) {
					return TRUE;
				}
			}
		}
	}
	return FALSE;
}

-(void) resendMapSnapUpload:(NSDictionary*) resendDicData {
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
	NSString *appointmentID = [resendDicData objectForKey:@"apppointmentptr"];

	NSDictionary *parameters = @{@"loginid":  username,
								 @"password": pass,
								 @"appointmentid":[resendDicData objectForKey:@"appointmentptr"]};
	
	[manager POST:scriptName
	   parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
	
	
	[formData appendPartWithFileData:[resendDicData objectForKey:@"imageData"]
								name:@"image"
							fileName:[resendDicData objectForKey:@"imageFile"]
							mimeType:@"image/png"];
	
} success:^(AFHTTPRequestOperation *operation, id responseObject) {
	

	VisitDetails *currentVisit;
	
	for (VisitDetails *visit in _visitData) {
		if ([visit.appointmentid isEqualToString:appointmentID]) {
			currentVisit = visit;
		}
	}
	currentVisit.mapSnapUploadStatus = @"SUCCESS";
	[currentVisit writeVisitDataToFile];

	[resendDicData setValue:@"SUCCESS" forKey:@"STATUS"];
	@synchronized(@"resendQueue") {
		[_arrivalCompleteQueueItems removeObject:resendDicData];
	}
	
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	
}];
	
}

-(void) resendImageUpload:(NSDictionary*)resendDicData {
	
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
	NSString *appointmentID = [resendDicData objectForKey:@"apppointmentptr"];
	NSDictionary *parameters = @{@"loginid":  username,@"password": pass,@"appointmentid" : [resendDicData objectForKey:@"appointmentptr"]};
	//NSData *picData = [resendDicData objectForKey:@"imageData"];
	[manager POST:scriptName
	   parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
	
	
	[formData appendPartWithFileData:[resendDicData objectForKey:@"imageData"]
								name:@"image"
							fileName: [resendDicData objectForKey:@"imageFile"]
							mimeType:@"image/png"];
	
} success:^(AFHTTPRequestOperation *operation, id responseObject) {
	
	VisitDetails *currentVisit;
	
	for (VisitDetails *visit in _visitData) {
		if ([visit.appointmentid isEqualToString:appointmentID]) {
			currentVisit = visit;
		}
	}
	[resendDicData setValue:@"SUCCESS" forKey:@"STATUS"];
	currentVisit.mapSnapUploadStatus = @"SUCCESS";
	[currentVisit writeVisitDataToFile];

	@synchronized (@"resendQueue") {
		[_arrivalCompleteQueueItems removeObject:resendDicData];
		
	}	
	
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	
	
	
}];
}

-(void)resendMarKArriveCompleteToServer:(NSMutableDictionary*)sendDictionary {
	NSString *username = [sendDictionary objectForKey:@"loginid"];
	NSString *pass = [sendDictionary objectForKey:@"password"];
	NSString *dateStr = [sendDictionary objectForKey:@"datetime"];
	NSString *theLatitude = [sendDictionary objectForKey:@"lat"];
	NSString *theLongitude = [sendDictionary objectForKey:@"lon"];
	NSString *theAccuracy = [sendDictionary objectForKey:@"accuracy"];
	NSString *eventStr = [sendDictionary objectForKey:@"event"];
	NSString *apptStr = [sendDictionary objectForKey:@"appointmentptr"];
	NSString *postRequestString = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&coords={\"appointmentptr\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"event\":\"%@\",\"accuracy\":\"%@\"}",username,pass,dateStr,apptStr,theLatitude,theLongitude,eventStr,theAccuracy];
	
	NSData *postData = [postRequestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	NSURL *urlLogin = [NSURL URLWithString:postRequestString];
	
	VisitDetails *currentVisit;
	for (VisitDetails *visit in _visitData) {
		if ([visit.appointmentid isEqualToString:apptStr]) {
			currentVisit = visit;
		}
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
	[request setURL:[NSURL URLWithString:@"https://leashtime.com/native-visit-action.php"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setTimeoutInterval:20.0];
	[request setHTTPBody:postData];
	
	if(_isReachable) {
		NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
																 delegate:nil
															delegateQueue:nil];
		NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,
																										 NSURLResponse * _Nullable responseDic,
																										 NSError * _Nullable error) {
			if(error == nil) {
				
				NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
																			options:
											 NSJSONReadingMutableContainers|
											 NSJSONReadingAllowFragments|
											 NSJSONWritingPrettyPrinted|
											 NSJSONReadingMutableLeaves
																			  error:&error];
				
				//NSLog(@"Response dic: %@",responseDic);

			
				if([eventStr isEqualToString:@"arrived"]) {
					currentVisit.currentArriveVisitStatus = @"SUCCESS";
				}
				if([eventStr isEqualToString:@"completed"]) {
					currentVisit.currentCompleteVisitStatus = @"SUCCESS";
				}
				[currentVisit writeVisitDataToFile];
				[sendDictionary setObject:@"SUCCESS" forKey:@"STATUS"];
				@synchronized (@"resendQueue") {
					[_arrivalCompleteQueueItems removeObject:sendDictionary];
					
				}
			
				dispatch_async(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter]
					 postNotificationName:@"resendArriveCompleteSuccess"
					 object:self
					 userInfo:sendDictionary];
					
				});
			}
		}];

		[postDataTask resume];
		[[NSURLCache sharedURLCache] removeAllCachedResponses];
		[urlSession finishTasksAndInvalidate];
		
	}
	
}

-(void) resendVisitReport:(NSMutableDictionary*)sendDictionary {

	VisitDetails *currentVisit;
	for (VisitDetails *visit in _visitData) {
		if ([visit.appointmentid isEqualToString:[sendDictionary objectForKey:@"appointmentptr"]]) {
			currentVisit = visit;
		}
	}
	NSString *dateTimeString = currentVisit.dateTimeMarkComplete;
	NSString *appointmentID = currentVisit.appointmentid;
	NSString *consolidatedVisitNote = [NSString stringWithFormat:@"[VISIT: %@] ",dateTimeString];
	
	
	if(![currentVisit.visitNoteBySitter isEqual:[NSNull null]] && [currentVisit.visitNoteBySitter length] > 0) {
		consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.visitNoteBySitter];
	}
	consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:@"  [MGR NOTE] "];
	if(![currentVisit.note isEqual:[NSNull null]] && [currentVisit.note length] > 0) {
		//NSString *tempVisitNote= [consolidatedVisitNote stringByAppendingString:currentVisit.note];
		consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.note];//[tempVisitNote stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
	}
	
	
	NSString *moodButton = @"buttons={";
	if(currentVisit.didPee) {
		NSString *peeMood = @"\"pee\":\"yes\"";
		moodButton = [moodButton stringByAppendingString:peeMood];
	} else if (!currentVisit.didPee) {
		NSString *peeMood = @"\"pee\":\"no\"";
		moodButton = [moodButton stringByAppendingString:peeMood];
	}
	if(currentVisit.didPoo) {
		moodButton = [moodButton stringByAppendingString:@",\"poo\":\"yes\""];
	} else if (!currentVisit.didPoo) {
		moodButton = [moodButton stringByAppendingString:@",\"poo\":\"no\""];
	}
	if(currentVisit.didPlay) {
		moodButton = [moodButton stringByAppendingString:@",\"play\":\"yes\""];
	} else if (!currentVisit.didPlay) {
		moodButton = [moodButton stringByAppendingString:@",\"play\":\"no\""];
	}
	if(currentVisit.wasHappy) {
		moodButton = [moodButton stringByAppendingString:@",\"happy\":\"yes\""];
	} else if (!currentVisit.wasHappy) {
		moodButton = [moodButton stringByAppendingString:@",\"happy\":\"no\""];
	}
	if(currentVisit.wasHungry) {
		moodButton = [moodButton stringByAppendingString:@",\"hungry\":\"yes\""];
	} else if (!currentVisit.wasHungry) {
		moodButton = [moodButton stringByAppendingString:@",\"hungry\":\"no\""];
	}
	if(currentVisit.wasAngry) {
		moodButton = [moodButton stringByAppendingString:@",\"angry\":\"yes\""];
	} else if (!currentVisit.didPee) {
		moodButton = [moodButton stringByAppendingString:@",\"angry\":\"no\""];
	}
	if(currentVisit.wasShy) {
		moodButton = [moodButton stringByAppendingString:@",\"shy\":\"yes\""];
	} else if (!currentVisit.wasShy) {
		moodButton = [moodButton stringByAppendingString:@",\"shy\":\"no\""];
	}
	if(currentVisit.wasSad) {
		moodButton = [moodButton stringByAppendingString:@",\"sad\":\"yes\""];
	} else if (!currentVisit.wasSad) {
		moodButton = [moodButton stringByAppendingString:@",\"sad\":\"no\""];
	}
	if(currentVisit.wasSick) {
		moodButton = [moodButton stringByAppendingString:@",\"sick\":\"yes\""];
	} else if (!currentVisit.wasSick) {
		moodButton = [moodButton stringByAppendingString:@",\"sick\":\"no\""];
	}
	if(currentVisit.wasCat) {
		moodButton = [moodButton stringByAppendingString:@",\"cat\":\"yes\""];
	} else if (!currentVisit.wasShy) {
		moodButton = [moodButton stringByAppendingString:@",\"cat\":\"no\""];
	}
	if(currentVisit.didScoopLitter) {
		moodButton = [moodButton stringByAppendingString:@",\"litter\":\"yes\""];
	} else if (!currentVisit.didScoopLitter) {
		moodButton = [moodButton stringByAppendingString:@",\"litter\":\"no\""];
	}
	NSString *closeMood = @"}";
	moodButton = [moodButton stringByAppendingString:closeMood];

	NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
	NSString *username = [loginSetting objectForKey:@"username"];
	NSString *pass = [loginSetting objectForKey:@"password"];
	NSString *paramTemp = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&appointmentptr=%@&note=%@&%@",
						   username,pass,dateTimeString,appointmentID,consolidatedVisitNote,moodButton];
	NSString *parameterString = paramTemp; // [sendDictionary objectForKey:@"parameterString"];
	
	NSString *parameterData = [parameterString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
	NSData *requestBodyData = [parameterData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBodyData length]];
	NSURL *urlLogin = [NSURL URLWithString:parameterData];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
	
	[request setURL:[NSURL URLWithString:@"https://leashtime.com/native-visit-update.php"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setTimeoutInterval:20.0];
	[request setValue:_userAgentLT forHTTPHeaderField:@"User-Agent"];
	[request setHTTPBody:requestBodyData];
	
	NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
															 delegate:nil
														delegateQueue:nil];
	
	NSURLSessionDataTask *postDataTask = 
	[urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,NSURLResponse * _Nullable responseDic,NSError * _Nullable error) {
														   if(error == nil) {
															   
															   NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data 
																														   options:NSJSONReadingMutableContainers| NSJSONReadingAllowFragments| NSJSONWritingPrettyPrinted| NSJSONReadingMutableLeaves  
																															 error:&error];
															   
															   
															   //NSLog(@"Response dic: %@",responseDic);
															   
															   currentVisit.visitReportUploadStatus = @"SUCCESS";
															   [currentVisit writeVisitDataToFile];
															   [sendDictionary setObject:@"SUCCESS" forKey:@"STATUS"];
															   [sendDictionary setObject:@"REPORT" forKey:@"TYPE"];
															   
														   } 
													   }];
	[postDataTask resume];
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[urlSession finishTasksAndInvalidate];
}

-(void)sendVisitNote:(NSString*)note
               moods:(NSString*)moodButtons
            latitude:(NSString *)currentLatitude
           longitude:(NSString *)currentLongitude
          markArrive:(NSString *)arriveTime
        markComplete:(NSString *)completionTime
    forAppointmentID:(NSString *)appointmentID
 {

	 VisitDetails *currentVisit;
	 
	 for (VisitDetails *visit in _visitData) {
		 if ([visit.appointmentid isEqualToString:appointmentID]) {
			 currentVisit = visit;
		 }
	 }
	
	 if( _isReachable) {
		 NSDate *rightNow = [NSDate date];
		 NSDateFormatter *dateFormat = [NSDateFormatter new];
		 [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
		 NSString *dateTimeString = [dateFormat stringFromDate:rightNow];
		 NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
		 NSString *username = [loginSetting objectForKey:@"username"];
		 NSString *pass = [loginSetting objectForKey:@"password"];
		 NSString *paramTemp = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&appointmentptr=%@&note=%@&%@",
								username,pass,dateTimeString,appointmentID,note,moodButtons];
		 
		 NSString *parameterData = [paramTemp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
		 NSData *requestBodyData = [parameterData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
		 NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBodyData length]];
		 NSURL *urlLogin = [NSURL URLWithString:parameterData];
		 
		 NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
		 
		 [request setURL:[NSURL URLWithString:@"https://leashtime.com/native-visit-update.php"]];
		 [request setHTTPMethod:@"POST"];
		 [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		 [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		 [request setTimeoutInterval:20.0];
		 [request setValue:_userAgentLT forHTTPHeaderField:@"User-Agent"];
		 [request setHTTPBody:requestBodyData];
		 
		 mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
												   delegate:self
											  delegateQueue:[NSOperationQueue mainQueue]];
		 
		 NSURLSessionDataTask *postDataTask = [mySession dataTaskWithRequest:request
														   completionHandler:^(NSData * _Nullable data,
																			   NSURLResponse * _Nullable responseDic, 
																			   NSError * _Nullable error) {
															   
															   
															   if(error == nil) {
																   NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data 
																															   options:NSJSONReadingMutableContainers|
																								NSJSONReadingAllowFragments|
																								NSJSONWritingPrettyPrinted|
																								NSJSONReadingMutableLeaves
																																 error:&error];
																   
																   currentVisit.visitReportUploadStatus = @"SUCCESS";
																   [currentVisit writeVisitDataToFile];
																   
																   //NSLog(@"Response dic: %@",responseDic);


																   
															   } else {
																   
																   currentVisit.visitReportUploadStatus = @"FAIL";
																   [currentVisit writeVisitDataToFile];
																   NSMutableDictionary *reportResend = [[NSMutableDictionary alloc]init];
																   [reportResend setObject:@"REPORT" forKey:@"TYPE"];
																   [reportResend setObject:@"FAIL-NETWORK RESPONSE" forKey:@"STATUS"];
																   [reportResend setObject:appointmentID forKey:@"appointmentptr"];
																   [_arrivalCompleteQueueItems addObject:reportResend];		
															   }
															   
														   }];
		 
		 [postDataTask resume];
		 [[NSURLCache sharedURLCache] removeAllCachedResponses];
		 [mySession finishTasksAndInvalidate];
		 
	 } else {
		 NSMutableDictionary *reportResend = [[NSMutableDictionary alloc]init];
		 [reportResend setObject:@"REPORT" forKey:@"TYPE"];
		 [reportResend setObject:@"FAIL-NETWORK RESPONSE" forKey:@"STATUS"];
		 [reportResend setObject:appointmentID forKey:@"appointmentptr"];
		 [_arrivalCompleteQueueItems addObject:reportResend];		
	 }
}

-(void)changeResendStatus:(NSNotification*) notification {
	
	NSMutableDictionary *visitResendDic = (NSMutableDictionary*)notification.userInfo;
	int removeIndex = -1;
	
	for (int i = 0; i < [_arrivalCompleteQueueItems count]; i++) {
		NSMutableDictionary *statusDic = [_arrivalCompleteQueueItems objectAtIndex:i];
		
		if([[visitResendDic objectForKey:@"appointmentptr"]isEqualToString:[statusDic objectForKey:@"appointmentptr"]]) {
			removeIndex = i;
			statusDic = nil;
		}
	}
	
	if (removeIndex >= 0) {
		@synchronized (@"resendQueue") {
			[_arrivalCompleteQueueItems removeObjectAtIndex:removeIndex];
		}
	}
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	
	[session invalidateAndCancel];
	session = nil;
}
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
	
	[session invalidateAndCancel];
	session = nil;
}

-(void)markVisitUnarrive:(NSString*)visitID {
	
    BOOL foundVisitInQueue = NO;
	
    for (int i = 0; i < [_arrivalCompleteQueueItems count]; i++) {
	    
        NSMutableDictionary *arriveCompleteQueueDic = [_arrivalCompleteQueueItems objectAtIndex:i];
        if([[arriveCompleteQueueDic objectForKey:@"appointmentptr"] isEqualToString:visitID]) {
            foundVisitInQueue = YES;
            [self unarriveNetwork:arriveCompleteQueueDic];
        }
    }
    
    if(!foundVisitInQueue) {
        
        NSMutableDictionary *arriveCompleteQueueDic = [[NSMutableDictionary alloc]init];
        
        NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
        NSString *userName;
        NSString *password;
        
        if ([loginSettings objectForKey:@"username"] != NULL) {
            userName = [loginSettings objectForKey:@"username"];
        }
        if ([loginSettings objectForKey:@"password"]) {
            password = [loginSettings objectForKey:@"password"];
        }
        
        NSDateFormatter *formatterWindow = [[NSDateFormatter alloc] init];
        [formatterWindow setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
        NSDate *rightNow2 = [NSDate date];
        NSString *dateString2 = [formatterWindow stringFromDate:rightNow2];

        
        [arriveCompleteQueueDic setObject:userName forKey:@"loginid"];
        [arriveCompleteQueueDic setObject:password forKey:@"password"];
        [arriveCompleteQueueDic setObject:dateString2 forKey:@"date"];
        [arriveCompleteQueueDic setObject:@"0.0" forKey:@"lat"];
        [arriveCompleteQueueDic setObject:@"0.0" forKey:@"lon"];
        [arriveCompleteQueueDic setObject:@"none" forKey:@"accuracy"];
        [arriveCompleteQueueDic setObject:visitID forKey:@"appointmentptr"];
        [self unarriveNetwork:arriveCompleteQueueDic];

    }
}

-(void)unarriveNetwork:(NSDictionary*)sendDictionary {
    NSString *username = [sendDictionary objectForKey:@"loginid"];
    NSString *pass = [sendDictionary objectForKey:@"password"];
    NSString *dateStr = [sendDictionary objectForKey:@"datetime"];
    NSString *theLatitude = [sendDictionary objectForKey:@"lat"];
    NSString *theLongitude = [sendDictionary objectForKey:@"lon"];
    NSString *theAccuracy = [sendDictionary objectForKey:@"accuracy"];
    NSString *eventStr = @"unarrived";
    NSString *apptStr = [sendDictionary objectForKey:@"appointmentptr"];

    
    NSString *postRequestString = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&coords={\"appointmentptr\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"event\":\"%@\",\"accuracy\":\"%@\"}",username,pass,dateStr,apptStr,theLatitude,theLongitude,eventStr,theAccuracy];
    NSData *postData = [postRequestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSURL *urlLogin = [NSURL URLWithString:postRequestString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
    [request setValue:_userAgentLT forHTTPHeaderField:@"User-Agent"];
    [request setURL:[NSURL URLWithString:@"https://leashtime.com/native-visit-action.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0];
    [request setHTTPBody:postData];

    mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                             delegate:self
                                        delegateQueue:[NSOperationQueue mainQueue]];
    
    
    NSURLSessionDataTask *postDataTask = [mySession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,
                                                                                                     NSURLResponse * _Nullable responseDic,
                                                                                                     NSError * _Nullable error) {
        
        
        NSString *errorCodeResponse = [self checkErrorCodes:data];        
        if(error == nil) {
            [_lastRequest addObject:@"OK"];
            if ([errorCodeResponse isEqualToString:@"OK"]) {
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:
                                             NSJSONReadingMutableContainers|
                                             NSJSONReadingAllowFragments|
                                             NSJSONWritingPrettyPrinted|
                                             NSJSONReadingMutableLeaves
                                                                              error:&error];
				//NSLog(@"Response dic: %@",responseDic);
            }
        }
	}];
    
    
    
    [postDataTask resume];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [mySession finishTasksAndInvalidate];
}

-(void)logoutCleanup {
	
	for(int i = 0; i < [_visitData count]; i++) {
		VisitDetails *visit = [_visitData objectAtIndex:i];
		visit = nil;
	}
	
	for(int i = 0; i < [todaysVisits count]; i++) {
		NSMutableDictionary *visit = [todaysVisits objectAtIndex:i];
		visit = nil;
	}
	
	for(int i = 0; i < [yesterdayVisits count]; i++) {
		NSMutableDictionary *visit = [yesterdayVisits objectAtIndex:i];
		visit = nil;
	}
	for(int i = 0; i < [tomorrowVisits count]; i++) {
		NSMutableDictionary *visit = [tomorrowVisits objectAtIndex:i];
		visit = nil;
	}
	
	for(NSMutableDictionary *badRequestDic in _arrivalCompleteQueueItems) {
		[badRequestDic removeAllObjects];
	}
	[_arrivalCompleteQueueItems removeAllObjects];
	_arrivalCompleteQueueItems = nil;
	
}

-(void) updateCoordinateData {
    
    for (VisitDetails *visit in _visitData) {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setLocale:[NSLocale currentLocale]];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"HH:mm"];
        
        NSArray *coordinatesForVisitArray = [visit getPointForRoutes];
	
        if(coordinatesForVisitArray != NULL) {
            for (NSData *coordinateData in coordinatesForVisitArray) {
                CLLocation *coordinateForVisit = [NSKeyedUnarchiver unarchiveObjectWithData:coordinateData];
                NSMutableDictionary *locationDic = [[NSMutableDictionary alloc]init];
                [locationDic setObject:visit.appointmentid forKey:coordinateForVisit];
            }
        } else {
			
        }
        
    }
}

-(void) parseDataResponsePolling:(NSDictionary *)responseDic {	
	
	NSArray *visitsArray = [responseDic objectForKey:@"visits"];
	NSDictionary *clientsDic = [responseDic objectForKey:@"clients"];
	
	if ([clientsDic count] > 0) {
		NSArray *clientKeys = [clientsDic allKeys];
		NSMutableDictionary *clientsDicNew = [[NSMutableDictionary alloc]init];
		for (NSString *keyMatch in clientKeys) {
			NSDictionary *clientDicNew = [clientsDic objectForKey:keyMatch];
			NSString *matchClientId = [clientDicNew objectForKey:@"clientid"];
			
			BOOL inCurrentClientList = FALSE;
			
			for (DataClient *client in _clientData) {
				if ([client.clientID isEqualToString:matchClientId]) {
					inCurrentClientList = TRUE;
				}
			}
			
			if (!inCurrentClientList) {
				NSDictionary *addClientDic = [clientsDic objectForKey:keyMatch];
				[clientsDicNew setObject:addClientDic forKey:keyMatch];
			}
		}
		if ([clientsDicNew count] > 0) {
			[self createClientData:clientsDicNew];
		}
		NSDateFormatter *formatterWindow = [[NSDateFormatter alloc]init];
		[formatterWindow setDateFormat:@"MM/dd/yyyy"];
		
		for(int i = 0; i < [yesterdayVisits count]; i++) {
			NSDictionary *visit = [yesterdayVisits objectAtIndex:i];
			visit = nil;
		}
		[yesterdayVisits removeAllObjects];
		
		for(int i = 0; i < [tomorrowVisits count]; i++) {
			NSDictionary *visit = [tomorrowVisits objectAtIndex:i];
			visit = nil;
		}
		[tomorrowVisits removeAllObjects];
		if([[responseDic objectForKey:@"visits"]isKindOfClass:[NSArray class]] &&
		   [[responseDic objectForKey:@"visits"] count] > 0) {
			
			for(NSDictionary *visitDic in visitsArray) {
				NSDate *evalVisitDate = [formatterWindow dateFromString:[visitDic objectForKey:@"shortDate"]];
				NSTimeInterval timeDifference = [_todayDate timeIntervalSinceDate:evalVisitDate];
				double minutes = timeDifference / 60;
				double days = minutes / 1440;
				
				if (days > 1.0 ) {
					[yesterdayVisits addObject:visitDic];
				}  else if (days < -0.001) {
					[tomorrowVisits addObject:visitDic];
				}
			}
		}
	}
}


-(void) networkRequest:(NSDate*)forDate toDate:(NSDate*)toDate pollUpdate:(NSString*)pollUpdate {
	NSString *userName;
	NSString *password;
	if (_lastRequest != NULL) {
		[_lastRequest removeAllObjects];
	}
	_lastRequest = [[NSMutableArray alloc]init];
	
	NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
	
	if ([loginSettings objectForKey:@"username"] != NULL) {
		userName = [loginSettings objectForKey:@"username"];
	}
	if ([loginSettings objectForKey:@"password"]) {
		password = [loginSettings objectForKey:@"password"];
	}
	
	NSString *urlLoginStr = [userName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
	NSString *urlPassStr = [password stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];

	NSString *requestString;
	NSDate *yesterday = [forDate dateBySubtractingDays:_numFutureDaysVisitInformation];
	NSString *date_String=[requestDateFormat stringFromDate:yesterday];
	NSString *endDateString = [self stringForNextTwoWeeks:_numFutureDaysVisitInformation fromDate:forDate];

	NSDateFormatter *formatFutureDate = [[NSDateFormatter alloc]init];
	[formatFutureDate setDateFormat:@"yyyy/MM/dd"];
	
	if(!_firstLogin) {
		requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&firstLogin=1"
						 ,urlLoginStr,urlPassStr,date_String,endDateString];
	} else {
		requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@",urlLoginStr,urlPassStr,date_String,endDateString];
	}
	
	NSURL *urlLogin = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
	[request setTimeoutInterval:40.0];
	[request setValue:_userAgentLT forHTTPHeaderField:@"User-Agent"];
	mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
											  delegate:self
										 delegateQueue:[NSOperationQueue mainQueue]];
	
	NSURLSessionDataTask *postDataTask = [mySession dataTaskWithRequest:request
													  completionHandler:^(NSData * _Nullable data,
																		  NSURLResponse * _Nullable responseDic, 
																		  NSError * _Nullable error) {
														  
														  NSUserDefaults *networkLogging = [NSUserDefaults standardUserDefaults];
														  NSDate *rightNow2 = [NSDate date];
														  NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
														  [dateFormat2 setDateFormat:@"HH:mm:ss"];
														  NSString *dateString2 = [dateFormat2 stringFromDate:rightNow2];
														  NSDictionary *errorDic = [error userInfo];
														  [_lastRequest addObject:dateString2];
														  
														  NSString *errorCodeResponse = [self checkErrorCodes:data];
														  
														  if(error == nil) {
															  [_lastRequest addObject:@"OK"];
															  if ([errorCodeResponse isEqualToString:@"OK"]) {
																  NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
																															  options:
																							   NSJSONReadingMutableContainers|
																							   NSJSONReadingAllowFragments|
																							   NSJSONWritingPrettyPrinted|
																							   NSJSONReadingMutableLeaves
																																error:&error];
																  
																  if (responseDic != NULL) {
																	  [self parseDataResponsePolling:responseDic];
																	  
																  }  else {
																	  _pollingFailReasonCode = @"NODATA";
																	  dispatch_async(dispatch_get_main_queue(), ^{
																		  [[NSNotificationCenter defaultCenter]
																		   postNotificationName:pollingFailed
																		   object:self];
																	  });
																  }
															  }
															  
															  else if ([errorCodeResponse isEqualToString:@"T"]) {
																  dispatch_async(dispatch_get_main_queue(), ^{
																	  [[NSNotificationCenter defaultCenter]
																	   postNotificationName:@"tempPassword"
																	   object:self];
																  });
															  }
															  
															  else if ([errorCodeResponse isEqualToString:@"P"]) {
																  dispatch_async(dispatch_get_main_queue(), ^{
																	  [[NSNotificationCenter defaultCenter]
																	   postNotificationName:pollingFailed
																	   object:self];
																  });
															  }
														  } else {
															  
															  [_lastRequest addObject:@"FAIL"];
															  NSString *failURLString = [errorDic valueForKey:@"NSErrorFailingURLStringKey"];
															  NSString *errorDetails = error.localizedDescription;
															  NSMutableDictionary *logServerError = [[NSMutableDictionary alloc]init];
															  [logServerError setObject:rightNow2 forKey:@"date"];
															  [logServerError setObject:failURLString forKey:@"error1"];
															  [logServerError setObject:errorDetails forKey:@"errorDetails"];
															  [logServerError setObject:@"polling request" forKey:@"location"];
															  [logServerError setObject:@"network" forKey:@"type"];
															  [networkLogging setObject:logServerError forKey:dateString2];
															  
															  //NSLog(@"POLLING FAILED");
															  dispatch_async(dispatch_get_main_queue(), ^{
																  [[NSNotificationCenter defaultCenter]
																   postNotificationName:pollingFailed
																   object:self];
															  });
														  }
													  }];
	
	[postDataTask resume];
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[mySession finishTasksAndInvalidate];
}
-(void) networkRequest:(NSDate*)forDate toDate:(NSDate*)toDate {
    NSString *userName;
    NSString *password;
    
    if (_lastRequest != NULL) {
        [_lastRequest removeAllObjects];
    }
    _lastRequest = [[NSMutableArray alloc]init];
	
    NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
	
    if ([loginSettings objectForKey:@"username"] != NULL) {
        userName = [loginSettings objectForKey:@"username"];
    }
    if ([loginSettings objectForKey:@"password"]) {
        password = [loginSettings objectForKey:@"password"];
    }
	
    NSString *urlLoginStr = [userName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *urlPassStr = [password stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];

	NSString *requestString;
	NSDateFormatter *formatFutureDate = [[NSDateFormatter alloc]init];
	[formatFutureDate setDateFormat:@"yyyy-MM-dd"];

	NSString *dateBegin = [formatFutureDate stringFromDate:forDate];
	NSString *dateEnd = [formatFutureDate stringFromDate:toDate];
	
	if(!_firstLogin) {
        requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&firstLogin=1&clientdocs=complete",urlLoginStr,urlPassStr,dateBegin,dateEnd];
    } else {
		requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&clientdocs=complete",urlLoginStr,urlPassStr,dateBegin,dateEnd];
    }
		
	NSURL *urlLogin = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
    [request setTimeoutInterval:40.0];
    [request setValue:_userAgentLT forHTTPHeaderField:@"User-Agent"];
    mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *postDataTask = [mySession dataTaskWithRequest:request
                                                     completionHandler:^(NSData * _Nullable data,
																		 NSURLResponse * _Nullable responseDic, 
																		 NSError * _Nullable error) {
									     
														 NSDate *rightNow2 = [NSDate date];
														 NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
														 [dateFormat2 setDateFormat:@"HH:mm:ss"];
														 NSString *dateString2 = [dateFormat2 stringFromDate:rightNow2];
														 [_lastRequest addObject:dateString2];
														NSString *errorCodeResponse = [self checkErrorCodes:data];

														 //NSLog(@"Raw data: %@, errorResponseCode: %@", data, _pollingFailReasonCode);
														 if(error == nil) {
															 if (responseDic != NULL) {
																 [_lastRequest addObject:@"OK"];
																 if ([errorCodeResponse isEqualToString:@"OK"]) {
																	 NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data 
																																  options:NSJSONReadingMutableContainers|
																								   NSJSONReadingAllowFragments|
																								   NSJSONReadingMutableLeaves 
																																	error:&error];
																	 
																	 
																	// NSLog(@"response: %@", responseDic);
																	 [self parseDataResponseMulti:responseJSON];
																	 [self updateCoordinateData];
																	 
																	 if (!self.firstLogin) {
																		 self.firstLogin = YES;
																		 [[NSNotificationCenter defaultCenter]postNotificationName:@"loginSuccess" object:NULL];
																		 [self visitDetailsVisitStatus];
																	 }
																	 
																 }  else {
																	 //_pollingFailReasonCode = @"NODATA";
																	 dispatch_async(dispatch_get_main_queue(), ^{
																		 [[NSNotificationCenter defaultCenter]
																		  postNotificationName:pollingFailed
																		  object:self];
																	 });
																 }
															 }
															 
															 else if ([errorCodeResponse isEqualToString:@"T"]) {
																 dispatch_async(dispatch_get_main_queue(), ^{
																	 [[NSNotificationCenter defaultCenter]
																	  postNotificationName:@"tempPassword"
																	  object:self];
																 });
															 }
														
														 } else {
															 dispatch_async(dispatch_get_main_queue(), ^{
																 [[NSNotificationCenter defaultCenter]
																  postNotificationName:pollingFailed
																  object:self];
															 });
														 }
        
    }];
    
    [postDataTask resume];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [mySession finishTasksAndInvalidate];
    
}

-(void) getNextPrevDay:(NSDate*)dateGet {
	
	NSDateFormatter *formatDate = [[NSDateFormatter alloc]init];
	[formatDate setDateFormat:@"MM/dd/yyyy"];
	NSString *todayDateString = [formatDate stringFromDate:_todayDate];
	NSString *getDateString = [formatDate stringFromDate:dateGet];

	if([todayDateString isEqualToString:getDateString]) {
		[self createVisitData:todaysVisits dataNew:@"YES"];
		_showingWhichDate = dateGet;
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:pollingCompleteWithChanges
		 object:self];
	}
	else {
		
		NSMutableArray *otherVisitDay = [[NSMutableArray alloc]init];
		for(NSDictionary *visit in tomorrowVisits) {
			NSString *shortDateVisit = [visit objectForKey:@"shortDate"];
			if([shortDateVisit isEqualToString:getDateString]) {
				[otherVisitDay addObject:visit];
			}
		}
		for (NSDictionary *visit in yesterdayVisits) {
			NSString *shortDateVisit = [visit objectForKey:@"shortDate"];
			if([shortDateVisit isEqualToString:getDateString]) {
				[otherVisitDay addObject:visit];
			}
		}
		[self createVisitData:otherVisitDay dataNew:@"none"];
		_showingWhichDate = dateGet;


		[[NSNotificationCenter defaultCenter]
		 postNotificationName:pollingCompleteWithChanges
		 object:self];
	}
}

-(NSString*) dayBeforeAfter:(NSDate*)goingToDate {
	
	NSTimeInterval timeDifference = [_todayDate timeIntervalSinceDate:goingToDate];
	double minutes = timeDifference / 60;
	double days = minutes / 1440;
	
	if (days > 0.0 && days < 0.111111) {
		return @"today";
	} else if (days > 0.111111) {
		return @"previous";
	} else if(days < 0.001) {
		return @"next";
	}
	return @"before";
	
}

-(NSString*) showingDateBeforeAfter:(NSDate*)goingToDate {
	
	NSTimeInterval timeDifference = [_showingWhichDate timeIntervalSinceDate:goingToDate];
	double minutes = timeDifference / 60;
	double days = minutes / 1440;
	
	
	if (days > 0.0 && days < 1.0) {
		return @"today";
	} else if (days > 0.0) {
		return @"showDateBeforeAfter previous";
	} else if(days < 0.001) {
		return @"next";
	}
	return @"before";
	
}

-(void) updateArriveCompleteInTodayYesterdayTomorrow:(VisitDetails*)visitItem withStatus:(NSString*)status {
	
	NSMutableDictionary *matchVisit;
	
	for(NSMutableDictionary *visits in todaysVisits) {
		if([visitItem.appointmentid isEqualToString:[visits objectForKey:@"appointmentid"]]) {
			matchVisit = visits;
		}
	}
	
	for(NSMutableDictionary *visits in yesterdayVisits) {
		if([visitItem.appointmentid isEqualToString:[visits objectForKey:@"appointmentid"]]) {
			matchVisit = visits;
		}
	}
	
	for(NSMutableDictionary *visits in tomorrowVisits) {
		if([visitItem.appointmentid isEqualToString:[visits objectForKey:@"appointmentid"]]) {
			matchVisit = visits;
		}
	}
	
	
	if([status isEqualToString:@"arrived"] && matchVisit != NULL) {
				
		[matchVisit setObject:visitItem.status forKey:@"status"];
		[matchVisit setObject:visitItem.arrived forKey:@"arrived"];
	}
	
	if([status isEqualToString:@"completed"]) {
		[matchVisit setObject:visitItem.status forKey:@"status"];
		[matchVisit setObject:visitItem.completed forKey:@"completed"];
	}
}

-(void) parseDataResponseMulti:(NSDictionary *)responseDic {
	
    NSArray *visitsArray = [responseDic objectForKey:@"visits"];
    NSDictionary *clientsDic = [responseDic objectForKey:@"clients"];
	
	[self setUpFlags:[responseDic objectForKey:@"flags"]];
	[self readPreferencesDic:[responseDic objectForKey:@"preferences"]];
	
	NSDateFormatter *formatterWindow = [[NSDateFormatter alloc]init];
	[formatterWindow setDateFormat:@"MM/dd/yyyy"];
	NSString *dateString = [formatterWindow stringFromDate:_todayDate];
	
	for(int i = 0; i < [todaysVisits count]; i++) {
		NSDictionary *visit = [todaysVisits objectAtIndex:i];
		visit = nil;
	}
	
	[todaysVisits removeAllObjects];
	
    if([[responseDic objectForKey:@"visits"]isKindOfClass:[NSArray class]]) {

        NSMutableArray *todayVisitArray = [[NSMutableArray alloc]init];	
        for(NSDictionary *visitDic in visitsArray) {
            NSString *todayDate = [visitDic objectForKey:@"shortDate"];
			NSDate *evalVisitDate = [formatterWindow dateFromString:[visitDic objectForKey:@"shortDate"]];
			NSTimeInterval timeDifference = [_todayDate timeIntervalSinceDate:evalVisitDate];
			double minutes = timeDifference / 60;
			double days = minutes / 1440;
						
			if (days > 0.0 && days < 1.0) {
				[todaysVisits addObject:visitDic];
			}
            if ([todayDate isEqualToString:dateString]) {
				[todayVisitArray addObject:visitDic];
			}
        }
        
        NSInteger payloadCount = [todayVisitArray count];
        NSInteger visitListCount = [_visitData count];
        NSMutableDictionary *visitDictionary = [[NSMutableDictionary alloc]init];
        
        [visitDictionary setObject:todayVisitArray forKey:@"visits"];

		
		[visitDictionary setObject:clientsDic forKey:@"clients"];
		
        if (payloadCount <= 0) {
			
            [self.visitData removeAllObjects];

			dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"noVisits"
                                                                   object:nil];
            });

        }
        else if (payloadCount > 0 && visitListCount <= 0 && _showingWhichDate == _todayDate) {
			
            [self setUpNewData:visitDictionary];
			
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:pollingCompleteWithChanges
                 object:self];
            });
		
        }
        else if (_showingWhichDate != _todayDate) {
            
            [self setUpNewData:visitDictionary];
			
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:pollingCompleteWithChanges
                 object:self];
            });
            
        }
        else if (payloadCount > 0 && visitListCount > 0) {
            
            [self setUpNewData:visitDictionary];
			
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:pollingCompleteWithChanges
                 object:self];
			});
        }
        
    } 
	NSDate *today = [NSDate date];
	[self networkRequest:today toDate:today pollUpdate:@"append"];
}

-(void) setUpNewData:(NSDictionary *)responseDic {

	if([responseDic objectForKey:@"clients"] != NULL) {
		NSDictionary *clientDic = [responseDic objectForKey:@"clients"];
		[self createClientData:clientDic];
	}
	
	if ([responseDic objectForKey:@"visits"] != NULL) {
		NSArray *visitsDic = [responseDic objectForKey:@"visits"];
		[self createVisitData:visitsDic dataNew:@"YES"];
	}
	
}

-(void) readPreferencesDic: (NSDictionary *)preferenceDic {

	if([[preferenceDic objectForKey:@"showDocAttachListView"]isEqualToString:@"YES"]) {
		self.showDocAttachListView = TRUE;
	} else {
		//self.showDocAttachListView = FALSE;
		self.showDocAttachListView = TRUE;
	}
	for (NSString *prefOption in preferenceDic) {
		///NSLog(@"Option: %@, Val: %@", prefOption, [preferenceDic objectForKey:prefOption]);
	}
	
}

-(void) createClientData:(NSDictionary *)clientDic {

	NSMutableArray *clientDataTemp = [[NSMutableArray alloc]init];

	
    for (NSString *clientIDNum in clientDic) {
        DataClient *clientProfile = [[DataClient alloc]init];
        NSMutableDictionary *clientInformation = [clientDic objectForKey:clientIDNum];   
        clientProfile.clientID = [clientInformation objectForKey:@"clientid"];
        clientProfile.clientName = [clientInformation objectForKey:@"clientname"];
        clientProfile.email = [clientInformation objectForKey:@"email"];
        clientProfile.email2 = [clientInformation objectForKey:@"email2"];
        clientProfile.cellphone = [clientInformation objectForKey:@"cellphone"];
        clientProfile.cellphone2 = [clientInformation objectForKey:@"cellphone2"];
        clientProfile.street1 = [clientInformation objectForKey:@"street1"];
        clientProfile.street2 = [clientInformation objectForKey:@"street2"];
        clientProfile.city = [clientInformation objectForKey:@"city"];
        clientProfile.state = [clientInformation objectForKey:@"state"];
        clientProfile.zip = [clientInformation objectForKey:@"zip"];
        clientProfile.garageGateCode = [clientInformation objectForKey:@"garagegatecode"];
        clientProfile.alarmCompany = [clientInformation objectForKey:@"alarmcompany"];
        clientProfile.alarmCompanyPhone = [clientInformation objectForKey:@"alarmcophone"];
        clientProfile.alarmInfo = [clientInformation objectForKey:@"alarminfo"];
        clientProfile.hasKey = [clientInformation objectForKey:@"hasKey"];
		clientProfile.basicInfoNotes = [clientInformation objectForKey:@"notes"];
		clientProfile.parkingInfo = [clientInformation objectForKey:@"parkinginfo"];
		clientProfile.directionsInfo = [clientInformation objectForKey:@"directions"];
		
        if ([clientProfile.hasKey isEqualToString:@"Yes"]) {
            clientProfile.hasKey = @"Yes";
		} else if (clientProfile.hasKey == NULL)  {
			clientProfile.hasKey = @"No";
		}else  {
            clientProfile.hasKey = @"No";
        }
				
        clientProfile.keyID = [clientInformation objectForKey:@"keyid"];
        clientProfile.clinicPtr = [clientInformation objectForKey:@"clinicptr"];
        clientProfile.clinicZip = [clientInformation objectForKey:@"cliniczip"];
        clientProfile.clinicCity = [clientInformation objectForKey:@"cliniccity"];
        clientProfile.clinicName = [clientInformation objectForKey:@"clinicname"];
        clientProfile.clinicPhone = [clientInformation objectForKey:@"clinicphone"];
        clientProfile.clinicLat = (NSString*)[clientInformation objectForKey:@"cliniclat"];
        clientProfile.clinicLon = (NSString*)[clientInformation objectForKey:@"cliniclon"];
			
        clientProfile.vetPtr = [clientInformation objectForKey:@"vetptr"];
        clientProfile.vetName = [clientInformation objectForKey:@"vetname"];
        clientProfile.vetCity = [clientInformation objectForKey:@"vetcity"];
        clientProfile.vetState = [clientInformation objectForKey:@"vetstate"];
        clientProfile.vetStreet1 = [clientInformation objectForKey:@"vetstreet"];
        clientProfile.vetStreet2 = [clientInformation objectForKey:@"vetstreet2"];
        clientProfile.vetPhone = [clientInformation objectForKey:@"vetphone"];
        clientProfile.vetLat = [clientInformation objectForKey:@"vetlat"];
        clientProfile.vetLon = [clientInformation objectForKey:@"vatlon"];

        clientProfile.sortName = [clientInformation objectForKey:@"sortname"];
        clientProfile.firstName = [clientInformation objectForKey:@"fname"];
        clientProfile.firstName2 = [clientInformation objectForKey:@"fname2"];
        clientProfile.lastName = [clientInformation objectForKey:@"lname"];
        clientProfile.lastName2 = [clientInformation objectForKey:@"lname2"];
        clientProfile.workphone = [clientInformation objectForKey:@"workphone"];
        clientProfile.homePhone = [clientInformation objectForKey:@"homephone"];
        clientProfile.leashLocation = [clientInformation objectForKey:@"leashloc"];
        clientProfile.foodLocation = [clientInformation objectForKey:@"foodloc"];

        NSDictionary *emergencyDic = [clientInformation objectForKey:@"emergency"];
        clientProfile.emergencyCellPhone = [emergencyDic objectForKey:@"cellphone"];
        clientProfile.emergencyHasKey = [emergencyDic objectForKey:@"haskey"];
        clientProfile.emergencyHomePhone = [emergencyDic objectForKey:@"homephone"];
        clientProfile.emergencyLocation = [emergencyDic objectForKey:@"location"];
        clientProfile.emergencyName = [emergencyDic objectForKey:@"name"];
        clientProfile.emergencyNote = [emergencyDic objectForKey:@"note"];
        clientProfile.emergencyWorkPhone = [emergencyDic objectForKey:@"workphone"];
        
        NSDictionary *trustedNeighborDic = [clientInformation objectForKey:@"neighbor"];
        clientProfile.trustedNeighborName = [trustedNeighborDic objectForKey:@"name"];
        clientProfile.trustedNeighborHasKey = [trustedNeighborDic objectForKey:@"haskey"];
        clientProfile.trustedNeighborHomePhone = [trustedNeighborDic objectForKey:@"homephone"];
        clientProfile.trustedNeighborCellPhone = [trustedNeighborDic objectForKey:@"cellphone"];
        clientProfile.trustedNeighborLocation = [trustedNeighborDic objectForKey:@"location"];
        clientProfile.trustedNeighborNote = [trustedNeighborDic objectForKey:@"note"];
        clientProfile.trustedNeighborWorkPhone = [trustedNeighborDic objectForKey:@"workphone"];
        
		for (int i = 1; i < 101; i ++) {
			NSString *customString = [NSString stringWithFormat:@"custom%i",i];
			if([clientInformation objectForKey:customString] != NULL) {
				[clientProfile.customClientFields addObject:[clientInformation objectForKey:customString]];				
			}
		}
		
        if ([[clientInformation objectForKey:@"nokeyrequired"]isEqualToString:@"1"]) {
            clientProfile.noKeyRequired = YES;
		} else if ([clientInformation objectForKey:@"nokeyrequired"] == NULL) {
			clientProfile.noKeyRequired = NO;
		}else {
            clientProfile.noKeyRequired = NO;
        }
					
		if ([[clientInformation objectForKey:@"showkeydescriptionnotkeyid"]isEqualToString:@"Yes"]) {
            clientProfile.useKeyDescriptionInstead = YES;
            clientProfile.keyDescriptionText = [clientInformation objectForKey:@"keydescription"];
        } else {
            clientProfile.useKeyDescriptionInstead = NO;
            clientProfile.keyDescriptionText = [clientInformation objectForKey:@"keydescription"];
        }
        
        NSArray *clientFlags = [clientInformation objectForKey:@"flags"];
        
        for (NSDictionary *flagItemClient in clientFlags) {
            [clientProfile.clientFlagsArray addObject:flagItemClient];
        }
	
        NSArray *petsData = [clientInformation objectForKey:@"pets"];
		
        clientProfile.petsDataRaw = (NSMutableArray*)petsData;

		NSString *customLabelDescr;
        NSString *customLabelNotes;
        
		for (int i = 0; i < [petsData count]; i++) {
			id petInfoTest = [petsData objectAtIndex:i];
			if ([petInfoTest isKindOfClass:[NSDictionary class]]) {
				NSMutableDictionary *petInfo = [petsData objectAtIndex:i];
				customLabelDescr = [petInfo objectForKey:@"description"];
				customLabelNotes = [petInfo objectForKey:@"notes"];
			}
			[clientDataTemp addObject:clientProfile];
        }
        
        int petCount =(int) [petsData count];
        NSString *petName;
        NSString *petID;
		int errataCount = (int)[clientProfile.errataDoc count];

		if (petCount == 0) {
			NSMutableDictionary *petBasicInfoDic = [[NSMutableDictionary alloc]init];
			[petBasicInfoDic setObject:@"NO PETS" forKey:@"name"];
			[petBasicInfoDic setObject:@"0" forKey:@"petid"];
			[clientProfile.petInfo addObject:petBasicInfoDic];
		} else {
			for (int i = 0; i < petCount; i++) {
				NSDictionary *petsDataDicType = [petsData objectAtIndex:i];
				NSMutableDictionary *petBasicInfoDic = [[NSMutableDictionary alloc]init];
				NSMutableDictionary *petCustomInfoDic = [[NSMutableDictionary alloc]init];
				petName = [petsDataDicType objectForKey:@"name"];
				petID = [petsDataDicType objectForKey:@"petid"];
				NSString *customLabel;
				NSString *customLabelVal;
				id customLabelValid;
				
				for (NSString* petDataDicKey in petsDataDicType) {
					if ([[petsDataDicType objectForKey:petDataDicKey]isKindOfClass:[NSDictionary class]]) {
						NSDictionary *customFieldValuePair = [petsDataDicType objectForKey:petDataDicKey];
						customLabel = [customFieldValuePair objectForKey:@"label"];
						customLabelValid = [customFieldValuePair objectForKey:@"value"];
						if ([customLabelValid isKindOfClass:[NSString class]]) {
							customLabelVal = [customFieldValuePair objectForKey:@"value"];
							if (![customLabelVal isEqual:[NSNull null]] && [customLabelVal length] > 0) {
								if ([customLabelVal isEqualToString:@"1"])
								{
									[petCustomInfoDic setObject:@"1" forKey:customLabel];
								}  else if ([customLabelVal isEqualToString:@"0"]) {
									[petCustomInfoDic setObject:@"0" forKey:customLabel];
								}  else {
									[petCustomInfoDic setObject:customLabelVal forKey:customLabel];
								}
							}
						} else if ([customLabelValid isKindOfClass:[NSDictionary class]]) {
							NSDictionary *docAttachDic = (NSMutableDictionary*)customLabelValid;
							NSMutableDictionary *customLabelValueDictionary = [[NSMutableDictionary alloc]init];
							[customLabelValueDictionary setObject:[docAttachDic objectForKey:@"url"] forKey:@"url"];
							[customLabelValueDictionary setObject:[docAttachDic objectForKey:@"mimetype"] forKey:@"mimetype"];
							[customLabelValueDictionary setObject:[docAttachDic objectForKey:@"label"] forKey:@"label"];
							[customLabelValueDictionary setObject:customLabel forKey:@"fieldlabel"];
							[customLabelValueDictionary setObject:petID forKey:@"petid"];
							[customLabelValueDictionary setObject:@"docAttach" forKey:@"type"];
							errataCount = errataCount  + 1;
							NSString *errataCountString = [NSString stringWithFormat:@"%i",errataCount];
							[customLabelValueDictionary setObject:errataCountString forKey:@"errataIndex"];
							[clientProfile.errataDoc addObject:customLabelValueDictionary];
							[petCustomInfoDic setObject:customLabelValueDictionary forKey:customLabel];
						}
					} else {
						//NSLog(@"Pet basic info field: %@", [petsDataDicType objectForKey:petDataDicKey]);
						[petBasicInfoDic setObject:[petsDataDicType objectForKey:petDataDicKey] forKey:petDataDicKey];
					}
				}
				if (petBasicInfoDic != nil) {
					[petBasicInfoDic setObject:petID forKey:@"petid"];
					[clientProfile.petInfo addObject:petBasicInfoDic];
				}
				if (petCustomInfoDic != nil) {
					NSMutableDictionary *customDicForPet = [[NSMutableDictionary alloc]init];
					[petCustomInfoDic setObject:petID forKey:@"petid"];
					[customDicForPet setObject:petCustomInfoDic forKey:petName];
					[clientProfile.customPetInfo addObject:customDicForPet];
				}
			}
		}
		[clientProfile createDetailAccordions];
		[clientDataTemp addObject:clientProfile];
	}

    NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
    NSString *userName;
    NSString *password;
    
    if ([loginSettings objectForKey:@"username"] != NULL) {
        userName = [loginSettings objectForKey:@"username"];
    }
    if ([loginSettings objectForKey:@"password"]) {
        password = [loginSettings objectForKey:@"password"];
    }
    
    NSArray *userDefaultKeys = [[[NSUserDefaults standardUserDefaults]dictionaryRepresentation]allKeys];
    NSArray *values = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]allValues];

    for (int i = 0; i < userDefaultKeys.count; i++) {
        if([[userDefaultKeys objectAtIndex:i]isKindOfClass:[NSString class]]) {
            NSString *keyValStr = (NSString*)[userDefaultKeys objectAtIndex:i];
            if ([[values objectAtIndex:i]isKindOfClass:[NSString class]]) {
                NSString *valStr = (NSString*)[values objectAtIndex:i];
                if([valStr isEqualToString:@"cachedImage"]) {
                    if (![keyValStr isEqual:[NSNull null]] && [keyValStr length] > 0 ) {
						[_cachedPetImages addObject:keyValStr];
                    }
                }
            }
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    for (DataClient *clientProfile in clientDataTemp) {

        if([clientProfile.petInfo count] > 0)
        {
            BOOL imageCached = NO;
            
            for (NSDictionary *petDictionary in clientProfile.petInfo) {
                
                NSString *petID = [petDictionary objectForKey:@"petid"];
                NSString *petName = [petDictionary objectForKey:@"name"];
				NSString *nameOfImageFile = [NSString stringWithFormat:@"/profile-%@-%@.png",clientProfile.clientID,petID];
                NSString *imagePath = [documentsPath stringByAppendingString:nameOfImageFile];

                if ([_cachedPetImages count] > 0) {
                    for (NSString *petIDForImage in _cachedPetImages) {
                        if ([petIDForImage isEqualToString:nameOfImageFile]) {
                            imageCached = YES;
                            if ([_fileManager fileExistsAtPath:imagePath]) {
                                UIImage *petProfileImage = [[UIImage alloc]initWithContentsOfFile:imagePath];
                                if (petProfileImage != nil) {
                                    [clientProfile.petImages setObject:petProfileImage forKey:petName];
                                }
                            }
                        }
                    }
                }

                if (!imageCached) {
                    NSString *petImgReq = [NSString stringWithFormat:@"https://leashtime.com/pet-photo-sessionless.php?id=%@&loginid=%@&password=%@",petID,userName,password];
                    NSURL *urlRequest = [NSURL URLWithString:petImgReq];
                    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
                    [NSURLCache setSharedURLCache:sharedCache];
                    
                    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
                    downloader.maxConcurrentDownloads = 1;
                    [downloader downloadImageWithURL:urlRequest
                                             options:0
                                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                
                                                
                                            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                
                                                NSDateFormatter *format = [[NSDateFormatter alloc]init];
                                                [format setDateFormat:@"MM/dd/yyyy"];
                                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                NSString *documentsPath = paths[0];
                                                
                                                NSString *nameOfImageFile = [NSString stringWithFormat:@"/profile-%@-%@.png",clientProfile.clientID,petID];
                                                NSString *imagePath = [documentsPath stringByAppendingString:nameOfImageFile];
                                                
                                                NSData *jpgDataImg = UIImageJPEGRepresentation(image, 1);
                                                UIImage *petImageJpeg = [UIImage imageWithData:jpgDataImg];


                                                [jpgDataImg writeToFile:imagePath atomically:YES];
                                                
                                                if (data != nil) {
                                                    
                                                    [clientProfile.petImages setObject:petImageJpeg forKey:petName];
                                                    [_cachedPetImages addObject:nameOfImageFile];
                                                    [loginSettings setObject:@"cachedImage" forKey:nameOfImageFile];
                                                    
                                                }
                                            }];
                }
            }
        }
    }
    
    @synchronized(@"clientCopy") {
		
        for (DataClient *clientDataDetails in clientDataTemp) {
			BOOL isNewClient = TRUE;
			for (DataClient *clientOld in _clientData) {
				if ([clientDataDetails.clientID isEqualToString:clientOld.clientID]) {
					isNewClient = FALSE;
				}
			}
			if (isNewClient) {
				[_clientData addObject:clientDataDetails];
			}
        }
    }
}

-(void) createVisitData:(NSArray *)visitsDic dataNew:(NSString*)dataNew {

	[_onSequenceArray removeAllObjects];
	if (visitsDic == NULL) {
		return;
	}
	NSMutableArray *visitDataTemp = [[NSMutableArray alloc]init];
	int i = 100;
	
	for (NSDictionary *key in visitsDic) {
		VisitDetails *detailsVisit = [[VisitDetails alloc]init];

		NSDictionary *visitInfo = key;
		detailsVisit.appointmentid = [visitInfo objectForKey:@"appointmentid"];
		NSString *clientIntVal = [visitInfo valueForKey:@"clientptr"];
		detailsVisit.sequenceID = [NSString stringWithFormat:@"%i",i];
		detailsVisit.clientptr = [NSString stringWithFormat:@"%@",clientIntVal];
		detailsVisit.service = [visitInfo objectForKey:@"service"];
  
		detailsVisit.timeofday = [visitInfo objectForKey:@"timeofday"];
		detailsVisit.petName = [visitInfo objectForKey:@"petNames"];
		detailsVisit.latitude = [visitInfo objectForKey:@"lat"];
		detailsVisit.longitude = [visitInfo objectForKey:@"lon"];
		detailsVisit.date = [visitInfo objectForKey:@"shortDate"];

		detailsVisit.status = [visitInfo objectForKey:@"status"];
				
		NSString *timeFrom = [visitInfo objectForKey:@"starttime"];
		NSString *timeTo = [visitInfo objectForKey:@"endtime"];
		NSDate *dateFrom = [oldFormatter dateFromString:timeFrom];
		NSString *newTimeFrom = [newFormatter stringFromDate:dateFrom];
		NSDate *dateTo = [oldFormatter dateFromString:timeTo];
		NSString *newTimeTo = [newFormatter stringFromDate:dateTo];
		
		detailsVisit.starttime = newTimeFrom;
		detailsVisit.endtime = newTimeTo;
		detailsVisit.endDateTime = [visitInfo objectForKey:@"endDateTime"];
		detailsVisit.rawStartTime = [visitInfo objectForKey:@"starttime"];
		
		if ([detailsVisit.status isEqualToString:@"arrived"]) {
			self.onWhichVisitID = detailsVisit.appointmentid;
			self.onSequence = detailsVisit.sequenceID;
			[_onSequenceArray addObject:detailsVisit];
			detailsVisit.hasArrived = YES;
		}
		
		if((![[visitInfo objectForKey:@"arrived"]isEqual:[NSNull null]] )
		   && ( [[visitInfo objectForKey:@"arrived"] length] != 0 )) {
			
			detailsVisit.arrived = [visitInfo objectForKey:@"arrived"];
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
			[dateFormat setTimeZone:[NSTimeZone localTimeZone]];
			
			NSDate *date = [dateFormat dateFromString:detailsVisit.arrived];
			detailsVisit.NSDateMarkArrive = date;
			detailsVisit.dateTimeMarkArrive = detailsVisit.arrived;
			
		}
		
		if((![[visitInfo objectForKey:@"completed"]isEqual:[NSNull null]] )
		   && ( [[visitInfo objectForKey:@"completed"] length] != 0 )) {
			
			detailsVisit.completed = [visitInfo objectForKey:@"completed"];
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
			[dateFormat setTimeZone:[NSTimeZone localTimeZone]];
			NSDate *date = [dateFormat dateFromString:detailsVisit.completed];

			NSString *dateString = [dateFormat stringFromDate:date];
			detailsVisit.dateTimeMarkComplete = dateString;

		}
		
		if((![[visitInfo objectForKey:@"canceled"]isEqual:[NSNull null]] )
		   && ( [[visitInfo objectForKey:@"canceled"] length] != 0 )) {
			
			detailsVisit.canceled = [visitInfo objectForKey:@"canceled"];
			detailsVisit.isCanceled = YES;
			NSLog(@"Canceled");

		} else {
			
			detailsVisit.canceled = @"NO";
			detailsVisit.isCanceled = NO;
		}
		
		if((![[visitInfo objectForKey:@"note"]isEqual:[NSNull null]] )
		   && ( [[visitInfo objectForKey:@"note"] length] != 0 )) {
			
			detailsVisit.note = [visitInfo objectForKey:@"note"];

		}
		
		if((![[visitInfo objectForKey:@"highpriority"]isEqual:[NSNull null]] )
		   && ( [[visitInfo objectForKey:@"highpriority"] length] != 0 )) {
			
			detailsVisit.highpriority = YES;

		}
		
		if((![[visitInfo objectForKey:@"clientname"]isEqual:[NSNull null]] )
		   && ( [[visitInfo objectForKey:@"clientname"] length] != 0 )) {
			
			detailsVisit.clientname = [visitInfo objectForKey:@"clientname"];

		}
		
		if((![[visitInfo objectForKey:@"clientemail"]isEqual:[NSNull null]] )
		   && ( [[visitInfo objectForKey:@"clientemail"] length] != 0 )) {
			
			detailsVisit.clientEmail = [visitInfo objectForKey:@"clientemail"];
			
		}
		
		for(DataClient *client in _clientData) {
			if ([client.clientID isEqualToString:detailsVisit.clientptr]) {
				if([client.hasKey isEqualToString:@"Yes"]) {
					detailsVisit.hasKey = YES;
				} else {
					detailsVisit.hasKey = NO;
				}
				detailsVisit.keyID = client.keyID;
				detailsVisit.useKeyDescriptionInstead = client.useKeyDescriptionInstead;
				detailsVisit.noKeyRequired = client.noKeyRequired;
				detailsVisit.keyDescriptionText = client.keyDescriptionText;
				
				if([client.errataDoc count] > 0) {
					for (NSDictionary *errataDic in client.errataDoc) {
						[detailsVisit.docItems addObject:errataDic];
					}
				}
			}
		}
		
		[self addPawPrintForVisits:(int)i forVisit:detailsVisit];
		
		[visitDataTemp addObject:detailsVisit];
		
		NSDateFormatter *arriveCompleteTime = [[NSDateFormatter alloc]init];
		[arriveCompleteTime setDateFormat:@"HH:mm a"];

		
		if([_arrivalCompleteQueueItems count] > 0) {				
			for(NSDictionary *badRequestItem in _arrivalCompleteQueueItems) {
				for (VisitDetails *visitDetail in visitDataTemp) {
					
					if([[badRequestItem objectForKey:@"appointmentptr"]isEqualToString:visitDetail.appointmentid]) {
						if([[badRequestItem objectForKey:@"TYPE"]isEqualToString:@"ARRIVE"]) {

							visitDetail.status = @"arrived";
							visitDetail.isComplete = NO;
							visitDetail.hasArrived = YES;
							NSString *dateTimeMarkArriveString = [badRequestItem objectForKey:@"visitDateTimeArrive"];
							NSDate *markArriveTime = [arriveCompleteTime dateFromString:dateTimeMarkArriveString];
							visitDetail.NSDateMarkArrive = markArriveTime;
							visitDetail.dateTimeMarkArrive = dateTimeMarkArriveString;
							visitDetail.coordinateLatitudeMarkArrive = [badRequestItem objectForKey:@"visitArriveLatitude"];
							visitDetail.coordinateLongitudeMarkArrive = [badRequestItem objectForKey:@"visitArriveLongitude"];
							
						} else if ([[badRequestItem objectForKey:@"TYPE"]isEqualToString:@"COMPLETE"]) {
						
							visitDetail.status = @"completed";
							visitDetail.isComplete = YES;
							visitDetail.hasArrived = NO;
							NSString *dateTimeMarkArriveString = [badRequestItem objectForKey:@"visitDateTimeMarkComplete"];
							NSDate *markCompleteTime = [arriveCompleteTime dateFromString:dateTimeMarkArriveString];
							visitDetail.NSDateMarkComplete = markCompleteTime;
							visitDetail.dateTimeMarkComplete = dateTimeMarkArriveString;
							visitDetail.coordinateLatitudeMarkComplete = [badRequestItem objectForKey:@"visitCompleteLatitude"];
							visitDetail.coordinateLongitudeMarkArrive = [badRequestItem objectForKey:@"visitCompleteLongitude"];
						}
					}
				}
			}
		}
		i++;
	}

	[_visitData removeAllObjects];
	for (VisitDetails *visitDetail in visitDataTemp) {
		[_visitData addObject:visitDetail];
		dispatch_async(dispatch_get_main_queue(), ^{
			[visitDetail syncVisitDetailFromFile];
		});
	}
	[visitDataTemp removeAllObjects];
}

-(NSString *)checkErrorCodes:(NSData*)responseCode {
	
	NSString *receivedDataString = [[NSString alloc] initWithData:responseCode encoding:NSUTF8StringEncoding];
	if ([receivedDataString isEqualToString:@"U"]) {
		_pollingFailReasonCode = @"U";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
	}
	else if ([receivedDataString isEqualToString:@"P"]) {
		_pollingFailReasonCode = @"P";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
	}
	else if ([receivedDataString isEqualToString:@"S"]) {
		
		_pollingFailReasonCode = @"S";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"I"]) {
		
		_pollingFailReasonCode = @"I";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"F"]) {
		
		_pollingFailReasonCode = @"F";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"B"]) {
		
		_pollingFailReasonCode = @"B";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"M"]) {
		
		_pollingFailReasonCode = @"M";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"O"]) {
		
		_pollingFailReasonCode = @"O";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"R"]) {
		
		_pollingFailReasonCode = @"R";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"C"]) {
		
		_pollingFailReasonCode = @"C";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"L"]) {
		
		_pollingFailReasonCode = @"L";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
		
	}
	else if ([receivedDataString isEqualToString:@"X"]) {
		
		_pollingFailReasonCode = @"X";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
	}
	else if ([receivedDataString isEqualToString:@"T"]) {
		
		_pollingFailReasonCode = @"T";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
	}
	
	else {
		
		_pollingFailReasonCode = @"OK";
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:pollingFailed
			 object:self];
		});
	}
	
	return _pollingFailReasonCode;
}

-(void) addPictureForPet:(UIImage*)petPicture {

    for (VisitDetails *visitInfo in _visitData) {
        
        if ([_onWhichVisitID isEqualToString:visitInfo.appointmentid]) {
			[visitInfo addImageForPet:petPicture];
            [visitInfo writeVisitDataToFile];
        }
    }
}

-(void) addLocationForMultiArrive:(CLLocation*)point {
	
	if(_multiVisitArrive) {
		
		if(_onWhichVisitID != NULL && _onSequenceArray != NULL && point != NULL) {
			for(VisitDetails *onSequence in _onSequenceArray) {
				for(VisitDetails *visitInfo in _visitData) {
					if([visitInfo.sequenceID isEqualToString:onSequence.sequenceID]
					   && ![visitInfo.status isEqualToString:@"completed"]) {
						[visitInfo addPointForRouteUsingCLLocation:point];
					}
				}
			}
		}
	}
}

-(void) addLocationCoordinate:(CLLocation*)point {
	if(_onWhichVisitID != NULL && ![_onSequence isEqualToString:@"000"] && point != NULL) {

		for (VisitDetails *visitInfo in _visitData) {
			if ([_onSequence isEqualToString:visitInfo.sequenceID] &&
				![visitInfo.status isEqualToString:@"completed"]) {
				
				[visitInfo addPointForRouteUsingCLLocation:point];
				
			}
		}
	}
}
-(NSArray*)getCoordinatesForVisit:(NSString*)visitID {
	
	NSMutableArray *rebuildVisitPoints = [[NSMutableArray alloc]init];
	VisitDetails *currentVisit;
	
	for (VisitDetails *visitInfo in _visitData) {
		if ([visitID isEqualToString:visitInfo.appointmentid]) {
			currentVisit = visitInfo;
			NSArray *rawCoordinates = [[NSArray alloc]initWithArray:[visitInfo getPointForRoutes]];
			for (NSData *locationDic in rawCoordinates) {
				CLLocation *locationPoint = [NSKeyedUnarchiver unarchiveObjectWithData:locationDic];
				[rebuildVisitPoints addObject:locationPoint];
			}
		}
	}
	
	//NSString *markArriveLatitutde = currentVisit.coordinateLatitudeMarkArrive;
	//NSString *markArriveLongitude = currentVisit.coordinateLongitudeMarkArrive;
	//NSString *markCompleteLatitude = currentVisit.coordinateLatitudeMarkComplete;
	//NSString *markCompleteLongitude = currentVisit.coordinateLongitudeMarkComplete;
	
	//double arriveLat = [markArriveLatitutde doubleValue];
	//double arriveLon = [markArriveLongitude doubleValue];
	//double completeLat = [markCompleteLatitude doubleValue];
	//double completeLon = [markCompleteLongitude doubleValue];
	
	//CLLocationCoordinate2D arriveLoc = CLLocationCoordinate2DMake(arriveLat, arriveLon);
	//CLLocationCoordinate2D completeLoc  = CLLocationCoordinate2DMake(completeLat, completeLon);
	
	//CLLocation *arriveLocation = [[CLLocation alloc]initWithCoordinate:arriveLoc altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
	
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"timestamp" ascending:YES];
	[rebuildVisitPoints sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	
	//double average_distance = 0;
	//int number_coordinates = (int)[rebuildVisitPoints count];
	//double total_distance = 0;
	
	/*for (int p = 0; p < number_coordinates; p++) {
		CLLocation *currentLocationPoint = [rebuildVisitPoints objectAtIndex:p];
		CLLocation *nextPoint = [rebuildVisitPoints objectAtIndex:p+1];
		double distanceBetween = [nextPoint distanceFromLocation:currentLocationPoint];
		total_distance = total_distance + distanceBetween;
	}
	average_distance = total_distance / number_coordinates;
	
	NSMutableArray *removeDistanceElements = [[NSMutableArray alloc]init];
	CLLocation *firstPoint = [rebuildVisitPoints objectAtIndex:0];
	
	double distanceArriveToFirstCoord = [firstPoint distanceFromLocation:arriveLocation];
	if (distanceArriveToFirstCoord > 2 * average_distance) {
		// Assign the first coordinate tracked as the Arrival Coordinate
	}
	for (int p = 0; p < number_coordinates; p++) {
		CLLocation *currentLocationPoint = [rebuildVisitPoints objectAtIndex:p];
		CLLocation *nextPoint = [rebuildVisitPoints objectAtIndex:p+1];
		double distanceBetween = [nextPoint distanceFromLocation:currentLocationPoint];	
		if (distanceBetween > 2 * average_distance) {
			
			if (p == 0) {
				// First coordinate is bad
				
			}
			int p2 = p + 2;
			if (p2 == number_coordinates - 1) { 
				
			} else if (p2 < number_coordinates - 1) {
				CLLocation *nextNextPoint = [rebuildVisitPoints objectAtIndex:p2];
				
			}
		}
	}*/
	
	return rebuildVisitPoints;
}
-(void) setUpReachability {
    
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
		
        if (status == -1) {

            _isReachable = NO;
            _isUnreachable = YES;
            _isReachableViaWiFi = NO;
            _isReachableViaWWAN = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"unreachable" object:nil];
            
        } else if (status == 0) {


            _isReachable = NO;
            _isUnreachable = YES;
            _isReachableViaWiFi = NO;
            _isReachableViaWWAN = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"unreachable" object:nil];
            
        } else if (status == 1) {
 

            _isReachable = YES;
            _isUnreachable = NO;
            _isReachableViaWiFi = NO;
            _isReachableViaWWAN = YES;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reachable" object:nil];
            
        } else if (status == 2) {

            _isReachable = YES;
            _isUnreachable = NO;
            _isReachableViaWiFi = YES;
            _isReachableViaWWAN = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reachable" object:nil];
            
        }
    }];
}
-(void) turnOffGPSTracking {
    
    if (_userTracking) {
        
        _userTracking = NO;
        NSUserDefaults *settingsGPS = [NSUserDefaults standardUserDefaults];
        [settingsGPS setObject:@"NO" forKey:@"gpsON"];
        
    } else {
        
        _userTracking = YES;
        NSUserDefaults *settingsGPS = [NSUserDefaults standardUserDefaults];
        [settingsGPS setObject:@"YES" forKey:@"gpsON"];
        
    }
}
-(void) changePollingFrequency:(NSNumber*)changePollingFrequencyTo {
    
    _pollingFrequency = (float)[changePollingFrequencyTo floatValue];
    
    NSUserDefaults *settingsPollFrequency = [NSUserDefaults standardUserDefaults];
    [settingsPollFrequency setObject:changePollingFrequencyTo forKey:@"frequencyOfPolling"];
    
}
-(void) changeDistanceFilter:(NSNumber*)changeDistanceFilterTo {
    
    NSUserDefaults *distanceOptionSetting = [NSUserDefaults standardUserDefaults];
    [distanceOptionSetting setObject:changeDistanceFilterTo forKey:@"distanceSettingForGPS"];
    
}
-(void) setUserDefault:(NSString*)preferenceSetting {
    
    
}
-(void) setDeviceType:(NSString*)typeDev {
    
    deviceType = typeDev;
    
}
-(NSMutableArray *) getTodayVisits {
	
	return _visitData;
}
-(NSString *) tellDeviceType {
	
	return deviceType;
	
}
-(NSString *) getCurrentSystemVersion {
	
	UIDevice *currentDevice = [UIDevice currentDevice];
	NSString *systemVersion = [currentDevice systemVersion];
	return systemVersion;
	
}

-(NSString *) stringForNextTwoWeeks:(int)numDays fromDate:(NSDate*)startDate {
	
	NSDateFormatter *formatFutureDate = [[NSDateFormatter alloc]init];
	[formatFutureDate setDateFormat:@"yyyy/MM/dd"];
	NSCalendar *newCalendar = [NSCalendar currentCalendar];
	
	NSDate *twoWeeksFrom = [newCalendar dateByAddingUnit:NSCalendarUnitDay
								     value:numDays
								    toDate:startDate
								   options:kNilOptions];
	
	NSString *twoWeeksFromString = [formatFutureDate stringFromDate:twoWeeksFrom];
	
	return twoWeeksFromString;
	
}

-(NSString *) stringForPrevTwoWeeks:(int)numDays fromDate:(NSDate *)startDate {
	
	NSDateFormatter *formatFutureDate = [[NSDateFormatter alloc]init];
	[formatFutureDate setDateFormat:@"yyyy/MM/dd"];
	
	NSDate *tomorrow = [startDate dateByAddingDays:1];
	NSDate *yesterday = [tomorrow dateBySubtractingDays:numDays];
	NSString *twoWeeksString = [formatFutureDate stringFromDate:yesterday];
	return twoWeeksString;
	
}

-(NSString *) stringForYesterday:(int)numDays {
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"yyyyMMdd"];
	NSDate *now = [NSDate date];
	NSDate *yesterday = [now dateByAddingDays:numDays];
	NSString *dateString = [format stringFromDate:yesterday];
	return dateString;
}
-(NSString *) stringForCurrentDateAndTime {
	
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *now = [NSDate date];
	NSString *dateString = [format stringFromDate:now];
	return dateString;
	
}
-(NSString *) stringForCurrentDay {
	
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"yyyyMMdd"];
	NSDate *now = [NSDate date];
	NSString *dateString = [format stringFromDate:now];
	return dateString;
}
-(NSString*) formatTime:(NSString*)theTimeString {
	NSString *telNumStr = @"(\\d\\d):(\\d\\d)";
	NSString *telNumPattern;
	telNumPattern = [NSString stringWithFormat:theTimeString,telNumPattern];
	NSRegularExpression *telRegex = [NSRegularExpression regularExpressionWithPattern:telNumStr
																			  options:NSRegularExpressionCaseInsensitive
																				error:NULL];
	
	__block NSString *dateFormatted;
	
	[telRegex enumerateMatchesInString:theTimeString
							   options:0
								 range:NSMakeRange(0, [theTimeString length])
							usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop)
	 {
		 NSRange range = [match rangeAtIndex:0];
		 NSString *regExTel = [theTimeString substringWithRange:range];
		 
		 NSTimeZone *timeZone = [NSTimeZone localTimeZone];
		 
		 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
		 [dateFormatter setTimeZone:timeZone];
		 [dateFormatter setDateFormat:@"HH:mm"];
		 NSDate *timeBegEnd = [dateFormatter dateFromString:regExTel];
		 [dateFormatter setDateFormat:@"H:mma"];
		 NSString *formattedDate = [dateFormatter stringFromDate:timeBegEnd];
		 
		 //NSString *telephoneNumFormat = [@"" stringByAppendingString:regExTel];
		 dateFormatted = [NSString stringWithString:formattedDate];
		 
	 }];
	
	return dateFormatted;
}
-(void)setUpFlags:(NSArray*)flagArray {
	
	NSString *pListData = [[NSBundle mainBundle]
						   pathForResource:@"flagID"
						   ofType:@"plist"];
	
	NSMutableDictionary *flagDicMap = [[NSMutableDictionary alloc]initWithContentsOfFile:pListData];
	_flagTable = [[NSMutableArray alloc]init];
	for (NSMutableDictionary *flagDic in flagArray) {
		NSString *srcImg = [flagDic objectForKey:@"src"];
		for (NSString *flagMapKey in flagDicMap) {
			if ([flagMapKey isEqualToString:srcImg]) {
				[flagDic setObject:[flagDicMap objectForKey:flagMapKey] forKey:@"src"];
			}
		}
		[_flagTable addObject:flagDic];
	}
	
}
-(void)addPawPrintForVisits:(int)pawprintID
				   forVisit:(VisitDetails*)visitInfo {
	if (pawprintID == 100) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-red-100"];
		visitInfo.sequenceID = @"100";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
		
	} else if (pawprintID == 101) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-lime-100"];
		visitInfo.sequenceID = @"101";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 102) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-purple-100"];
		visitInfo.sequenceID = @"102";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 103) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-dark-blue"];
		visitInfo.sequenceID = @"103";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 104) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-pine-100"];
		visitInfo.sequenceID = @"104";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
		
	} else if (pawprintID == 105) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-orange-100"];
		visitInfo.sequenceID = @"105";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
		
	} else if (pawprintID == 106) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-teal-100"];
		visitInfo.sequenceID = @"106";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 107) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-pink-100"];
		visitInfo.sequenceID = @"107";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 108) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-powder-blue-100"];
		visitInfo.sequenceID = @"108";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 109) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"paw-black-100"];
		visitInfo.sequenceID = @"109";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 110) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"dog-footprint-green"];
		visitInfo.sequenceID = @"110";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 111) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"dog-footprint-green"];
		visitInfo.sequenceID = @"111";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 112) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"dog-footprint-green"];
		visitInfo.sequenceID = @"112";
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
		
	} else if (pawprintID == 113) {
		
		visitInfo.pawPrintForSession = [UIImage imageNamed:@"dog-footprint-green"];
		NSMutableArray *visitPoints = [[NSMutableArray alloc]init];
		[coordinatesForVisits setObject:visitPoints forKey:visitInfo.appointmentid];
	}
}

-(void) readSettings {
	
	NSDictionary *userDefaultDic = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	
	if([[userDefaultDic objectForKey:@"showKeyIcon"]boolValue]) {
		_showKeyIcon = YES;
	} else {
		_showKeyIcon = NO;
	}
	
	if([[userDefaultDic objectForKey:@"showPetPicInCell"]boolValue]) {
		_showPetPicInCell = YES;
	} else {
		_showPetPicInCell = NO;
	}
	
	if([[userDefaultDic objectForKey:@"showFlags"]boolValue]) {
		_showFlags = YES;
	} else {
		_showFlags  = NO;
	}
	
	if([[userDefaultDic objectForKey:@"showTimer"]boolValue]) {
		_showTimer = YES;
	} else {
		_showTimer  = NO;
	}
	
	if([[userDefaultDic objectForKey:@"showClientName"]boolValue]) {
		_showClientName = YES;
	} else {
		_showClientName = NO;
	}
	
	if([[userDefaultDic objectForKey:@"multiVisitArrive"]boolValue]) {
		_multiVisitArrive = YES;
	} else {
		_multiVisitArrive = NO;
	}
	
	if([[userDefaultDic objectForKey:@"regionMonitor"]boolValue]) {
		_regionMonitor = YES;
	} else {
		_regionMonitor = NO;
	}
	
	if([[userDefaultDic objectForKey:@"showReachability"]boolValue]) {
		_showReachabilityIcon = YES;
	} else {
		_showReachabilityIcon = NO;
	}
	
	
	if ([userDefaultDic objectForKey:@"minimumGPSAccuracy"] != NULL) {
		NSNumber *minGPSAccuracyNum = [userDefaultDic objectForKey:@"minimumGPSAccuracy"];
		_minimumGPSAccuracy = [minGPSAccuracyNum intValue];
	} else {
		[standardDefaults setObject:[NSNumber numberWithInt:25.0] forKey:@"minimumGPSAccuracy"];
		_minimumGPSAccuracy = 25.0f;
	}
	
	if([userDefaultDic objectForKey:@"distanceSettingForGPS"] != NULL) {
		NSNumber *distanceSettingForGPSNum = [userDefaultDic objectForKey:@"distanceSettingForGPS"];
		_distanceSettingForGPS = [distanceSettingForGPSNum intValue];
	} else {
		[standardDefaults setObject:[NSNumber numberWithInt:15.0] forKey:@"distancepSettingForGPS"];
		_distanceSettingForGPS = 15;
	}
	
	if ([userDefaultDic objectForKey:@"updateFrequencySeconds"] != NULL) {
		NSNumber *updateFrequencyNum = [userDefaultDic objectForKey:@"updateFrequencySeconds"];
		_updateFrequencySeconds = [updateFrequencyNum intValue];
	} else {
		[standardDefaults setObject:[NSNumber numberWithInt:120] forKey:@"updateFrequencySeconds"];
		_updateFrequencySeconds = 120;
	}
	if ([userDefaultDic objectForKey:@"minNumCoordinatesSend"] != NULL) {
		NSNumber *updateFrequencyNum = [userDefaultDic objectForKey:@"minNumCoordinatesSend"];
		_minNumCoordinatesSend = [updateFrequencyNum intValue];
	} else {
		[standardDefaults setObject:[NSNumber numberWithInt:20.0] forKey:@"minNumCoordinatesSend"];
		_minNumCoordinatesSend = 20.0f;
	}
	
	if ([userDefaultDic objectForKey:@"earlyMarkArriveMin"] != NULL) {
		NSNumber *earlyMarkArriveNum = [userDefaultDic objectForKey:@"earlyMarkArriveMin"];
		_numMinutesEarlyArrive = [earlyMarkArriveNum floatValue];
	} else {
		[standardDefaults setObject:[NSNumber numberWithFloat:240] forKey:@"earlyMarkArriveMin"];
		_numMinutesEarlyArrive = 240.0;
	}
	//_numMinutesEarlyArrive = 3000.0;
	//NSLog(@"Num minutes arrive early: %f",_numMinutesEarlyArrive);

}

-(void)changeTempPassword:(NSString*)currentTemp
				  loginID:(NSString*)loginID
				  newPass:(NSString*)newPass {
	
	
	NSString *urlLoginStr = [loginID stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
	NSString *urlPassStr = [currentTemp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
	NSString *urlPassStrNew = [newPass stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
	
	NSString *requestString = [NSString stringWithFormat:@"https://leashtime.com/native-change-pass.php?loginid=%@&password=%@&newpassword=%@",urlLoginStr,urlPassStr,urlPassStrNew];
	
	NSURL *urlLogin = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
	mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
											  delegate:self
										 delegateQueue:[NSOperationQueue mainQueue]];
	
	NSURLSessionDataTask *postDataTask = [mySession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,
																									NSURLResponse * _Nullable responseDic,
																									NSError * _Nullable error) {
		[[NSNotificationCenter defaultCenter]postNotificationName:@"loginNewPass" object:nil];
	}];
	
	[postDataTask resume];
	
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	
	[mySession finishTasksAndInvalidate];
	
}

-(void) uploadCoordinatesToServer {
	
	
	NSDate *rightNow = [NSDate date];
	
	NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
	[dateFormat2 setDateFormat:@"HH:mm:ss"];
	NSString *shortDateString = [dateFormat2 stringFromDate:rightNow];
	
	
	NSString *userName;
	NSString *password;
	
	
	NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
	
	if ([loginSettings objectForKey:@"username"] != NULL) {
		userName = [loginSettings objectForKey:@"username"];
	}
	if ([loginSettings objectForKey:@"password"]) {
		password = [loginSettings objectForKey:@"password"];
	}
	
	NSString *credentialString = [NSString stringWithFormat:@"loginid=%@&password=%@&coords=[",userName,password];
	int i = 0;
	
	NSString *visitID;
	
	if (_visitData != NULL) {
		for (VisitDetails *visit in _visitData) {
			if ([_onSequence isEqualToString:visit.sequenceID]) {
				visitID = visit.appointmentid;
			}
		}
	}
	
	for (CLLocation *coordinateAll in _shareLocationManager.allCoordinates) {
		
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
		
		_shareLocationManager.lastSendTimeStamp = shortDateString;
		_shareLocationManager.lastSendNumCoordinates = [NSString stringWithFormat:@"%lu",(unsigned long)[_shareLocationManager.allCoordinates count]];
		
		i++;
		
		if (i < [_shareLocationManager.allCoordinates count]) {
			NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"},",visitID,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
			credentialString = [credentialString stringByAppendingString:coordinateString];
		} else {
			NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"}]",visitID,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
			credentialString = [credentialString stringByAppendingString:coordinateString];
		}
	}
}

-(void) resendAllCoordinatesToServer:(NSString*)visitID {
	
	for (VisitDetails *visitCoord in _visitData) {
		if([visitCoord.appointmentid isEqualToString:visitID]) {
			
			NSArray *coordinatesForVisit = [visitCoord getPointForRoutes];
			
			NSMutableArray *arrayCoordForVisit = [[NSMutableArray alloc]init];
			
			if (coordinatesForVisit != NULL) {
				for (NSData *coordinateData in coordinatesForVisit) {
					CLLocation *coordinateForVisit = [NSKeyedUnarchiver unarchiveObjectWithData:coordinateData];
					[arrayCoordForVisit addObject:coordinateForVisit];
				}
			}
			
			NSString *userName;
			NSString *password;
			
			NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
			
			if ([loginSettings objectForKey:@"username"] != NULL) {
				userName = [loginSettings objectForKey:@"username"];
			}
			if ([loginSettings objectForKey:@"password"]) {
				password = [loginSettings objectForKey:@"password"];
			}
			
			NSString *credentialString = [NSString stringWithFormat:@"loginid=%@&password=%@&coords=[",userName,password];
			int i = 0;
			
			for (CLLocation *coordinateAll in arrayCoordForVisit) {
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
				NSString *visitID = visitCoord.appointmentid;
				
				i++;
				
				if (i < [arrayCoordForVisit count]) {
					NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"},",visitID,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
					credentialString = [credentialString stringByAppendingString:coordinateString];
				} else {
					NSString *coordinateString = [NSString stringWithFormat:@"{\"appointmentptr\":\"%@\",\"date\":\"%@\",\"lat\":\"%@\",\"lon\":\"%@\",\"accuracy\":\"%@\",\"event\":\"%@\",\"heading\":\"%@\",\"error\":\"%@\"}]",visitID,dateString,theLatitude,theLongitude,theAccuracy,theEvent,theHeading,theError];
					credentialString = [credentialString stringByAppendingString:coordinateString];
				}
			}
			
			NSData *requestBodyDataForJSONCoordinates = [credentialString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
			
			NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBodyDataForJSONCoordinates length]];
			NSString *sendCoordURL = @"https://leashtime.com/native-sitter-location.php";
			NSURL *url = [NSURL URLWithString:sendCoordURL];
			NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
			[request setHTTPMethod:@"POST"];
			[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			[request setTimeoutInterval:20.0];
			[request setHTTPBody:requestBodyDataForJSONCoordinates];
			mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
									     delegate:self
									delegateQueue:[NSOperationQueue mainQueue]];
			
			NSURLSessionTask *resendCoordTask = [mySession dataTaskWithRequest:request
											completionHandler:^(NSData * _Nullable data,
														  NSURLResponse * _Nullable response,
														  NSError * _Nullable error) {
												
												
												
												if(error == nil) {
													
													NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
																							options:
																	     NSJSONReadingMutableContainers|
																	     NSJSONReadingAllowFragments|
																	     NSJSONWritingPrettyPrinted|
																	     NSJSONReadingMutableLeaves
																							  error:&error];
													
													///NSLog(@"Response dic: %@",responseDic);

												} else {
													
													NSString *errorCodeResponse = [self checkErrorCodes:data];
													//NSLog(@"error response code: %@",errorCodeResponse);
													//NSLog(@"%@",response);
												}
												
												
											}];
			
			[resendCoordTask resume];
			[[NSURLCache sharedURLCache] removeAllCachedResponses];
			
			[mySession finishTasksAndInvalidate];
		}
	}
}

-(void) optimizeRoute {
//DistanceMatrix *distanceMatrix = [[DistanceMatrix alloc]initWithVisitData:self.visitData];
}

/*-(void)fireLocalNotificationsForLateVisits {
	
	UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
	
	for(VisitDetails *visit in _localNotificationQueue) {
 NSString *bodyString;
 bodyString = [bodyString stringByAppendingString:visit.appointmentid];
 bodyString = [bodyString stringByAppendingString:@"\n"];
 bodyString = [bodyString stringByAppendingString:visit.petName];
 bodyString = [bodyString stringByAppendingString:@"\n"];
 bodyString = [bodyString stringByAppendingString:visit.clientname];
 bodyString = [bodyString stringByAppendingString:@"\n"];
 bodyString = [bodyString stringByAppendingString:visit.endtime];
 bodyString = [bodyString stringByAppendingString:@"\n"];
 bodyString = [bodyString stringByAppendingString:visit.street1];
 bodyString = [bodyString stringByAppendingString:@"\n"];
 bodyString = [bodyString stringByAppendingString:@"\n"];
 
 UNNotificationAction *arriveAction = [UNNotificationAction actionWithIdentifier:visit.appointmentid
 title:@"Arrived"
 options:UNNotificationCategoryOptionCustomDismissAction];
 
 UNNotificationAction *onWayAction = [UNNotificationAction actionWithIdentifier:visit.appointmentid
 title:@"On Way"
 options:UNNotificationCategoryOptionCustomDismissAction];
 
 UNNotificationAction *cannotMake = [UNNotificationAction actionWithIdentifier:visit.appointmentid
 title:@"Cannot Make IT"
 options:UNNotificationCategoryOptionCustomDismissAction];
 
 NSArray *notificationActions = @[ arriveAction, onWayAction, cannotMake ];
 
 UNNotificationCategory *inviteCategory = [UNNotificationCategory categoryWithIdentifier:@"Late Visits"
 actions:notificationActions
 intentIdentifiers:@[]
 options:UNNotificationCategoryOptionCustomDismissAction];
 
 NSSet *categories = [NSSet setWithObject:inviteCategory];
 
 [center setNotificationCategories:categories];
 
 UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
 content.title = [NSString localizedUserNotificationStringForKey:@"LATE VISITS" arguments:nil];
 content.body = bodyString;
 content.categoryIdentifier = visit.appointmentid;
 content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
 UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:20 repeats:NO];
 UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:visit.appointmentid
 content:content
 trigger: trigger];
 [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
 if (!error) {
 } else {
 }
 }];
	}*/




@end
