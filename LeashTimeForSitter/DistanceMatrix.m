//
//  DistanceMatrix.m
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 12/23/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import "DistanceMatrix.h"
#import <CoreLocation/CoreLocation.h>
#import "VisitDetails.h"
#import "VisitsAndTracking.h"

#define kRoutificAPIToken @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfaWQiOiI1NmM5ZjRhZWI0ZTEwZGU1MGZjYTU5OWQiLCJpYXQiOjE0NTYzMzg3MjN9.NpSPS7Nxe8Mw63FQT6PY_PDCBJFG0LYlccxHnA0SZOw"
#define kRoutificURL @"https://api.routific.com/v1/vrp/"
#define kGraphHopperAPIKey @"ab8fa14c-8f13-4eef-aa37-ab4e64733581"
#define kGraphHopperURL @"https://graphhopper.com/api/1/vrp"


//
//
// Danny [Christopher McNelis] - dannym
// Kate [Katherine Reich] - kater
// Branigan [
// Robbyn [
// Katie O. [
//

// QVX992DISABLED


@implementation DistanceMatrix

-(instancetype) initWithVisitData:(NSMutableArray *)visitData {
    
	LocationShareModel *sharedLocationModel = [LocationShareModel sharedModel];
	//_sharedInstance = [VisitsAndTracking sharedInstance];
	
	/*[[NSNotificationCenter defaultCenter]addObserver:self
							    selector:@selector(printRoutes)
								  name:@"finishedRoutes"
								object:nil];
	
	[[NSNotificationCenter defaultCenter]addObserver:self
							    selector:@selector(displayRouteOptimize)
								  name:@"routeOptimized" object:nil];
	*/
	
	//_stopMatrix = [[NSMutableArray alloc]init];
	//__block float _total_distance = 0;
	//__block float _total_travel = 0;
	
	//[self actualTimeDistance:visitData];
	
	if(self = [super init]) {
		
		//_visitLocations = [[NSMutableArray alloc]init];
		//_optimizedVisitLocations = [[NSMutableArray alloc]init];
		
		NSString *sitterHomeLat;
		NSString *sitterHomeLon;
		NSString *sitterName;
		
		NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
		CLLocationCoordinate2D currentLocation = sharedLocationModel.lastValidLocation;
		
		if ([loginSettings objectForKey:@"username"] != NULL) {
			//_sitterName = [loginSettings objectForKey:@"username"];
		}
		
		if ([loginSettings objectForKey:@"sitterHomeLatitude"] != NULL) {
			sitterHomeLat = [loginSettings objectForKey:@"sitterHomeLatitude"];
		} else {
			sitterHomeLat = @"38.7806";
		}
		
		if([loginSettings objectForKey:@"sitterHomeLongitude"]) {
			sitterHomeLon = [loginSettings objectForKey:@"sitterHomeLongitude"];
		} else {
			sitterHomeLon = @"-77.0710";
		}
		if([loginSettings objectForKey:@"sitterName"]) {
			sitterName = [loginSettings objectForKey:@"sitterName"];
		} else {
			sitterName = @"My Name";
		}
        
        int visitCount = 1;
		
		NSMutableDictionary *jsonDictionaryContainer = [[NSMutableDictionary alloc]init];
		NSMutableDictionary *jsonVisitContainer = [[NSMutableDictionary alloc]init];
		NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc]init];
		[dateFormat2 setDateFormat:@"hh:mm "];
		
		for (VisitDetails *visitDic in visitData) {
			
			NSMutableDictionary *visitNumDic = [[NSMutableDictionary alloc]init];
			NSString *visitCountStr = [NSString stringWithFormat:@"order_%i",visitCount];
			NSMutableDictionary *locationDic = [[NSMutableDictionary alloc]init];
			
			[locationDic setObject:visitDic.latitude forKey:@"lat"];
			[locationDic setObject:visitDic.longitude forKey:@"lng"];
			[locationDic setObject:visitDic.appointmentid forKey:@"name"];
			
			NSMutableDictionary *visitDetails = [[NSMutableDictionary alloc]init];
			[visitDetails setObject:locationDic forKey:@"location"];
			
			NSString *startString = visitDic.starttime;
			NSString *endString = visitDic.endtime;
			
			NSDate *date = [dateFormat2 dateFromString:startString];
			NSDate *dateEnd = [dateFormat2 dateFromString:endString];
			
			startString = [dateFormat2 stringFromDate:date];
			endString = [dateFormat2 stringFromDate:dateEnd];
			
			[visitDetails setObject:@"08:00" forKey:@"start"];
			[visitDetails setObject:@"22:00" forKey:@"end"];
			[visitDetails setObject:@"30" forKey:@"duration"];
			[visitNumDic setObject:visitDetails forKey:visitCountStr];
			
			//[_visitLocations addObject:visitNumDic];
			[jsonVisitContainer setObject:visitDetails forKey:visitCountStr];
			
			visitCount++;
			//NSLog(@"visit dic: %@",visitDic.completed);
		}
		
		
		
		//_sitterAddress = CLLocationCoordinate2DMake(38.8606, -77.0900);
		
		NSMutableDictionary *sitterItem = [[NSMutableDictionary alloc]init];
		NSMutableDictionary *sitterStart = [[NSMutableDictionary alloc]init];
		NSMutableDictionary *locationDic = [[NSMutableDictionary alloc]init];
		[locationDic setObject:sitterHomeLat forKey:@"lat"];
		[locationDic setObject:sitterHomeLon forKey:@"lng"];
		[locationDic setObject:sitterName forKey:@"name"];
		[locationDic setObject:@"Home" forKey:@"id"];
		
		NSMutableDictionary *locationEndDic = [[NSMutableDictionary alloc]init];
		[locationEndDic setObject:[NSString stringWithFormat:@"%f",currentLocation.latitude] forKey:@"lat"];
		[locationEndDic setObject:[NSString stringWithFormat:@"%f",currentLocation.longitude] forKey:@"lng"];
		[locationEndDic setObject:sitterName forKey:@"name"];
		[locationEndDic setObject:@"Home" forKey:@"id"];
		[sitterStart setObject:locationDic forKey:@"start_location"];
		[sitterItem setObject:sitterStart forKey:@"driver_1"];
		
		NSMutableDictionary *driverDic = [[NSMutableDictionary alloc]init];
		[driverDic setObject:sitterItem forKey:@"fleet"];
		[jsonDictionaryContainer setObject:jsonVisitContainer forKey:@"visits"];
		[jsonDictionaryContainer setObject:sitterItem forKey:@"fleet"];
		
		//[self sendToOptimize:jsonDictionaryContainer];
		[self doLocalProcess];
		
	}
	
	
	
	return self;
}


-(void)doLocalProcess {
	
	//NSMutableArray *visitData = _sharedInstance.visitData;
	//NSMutableArray *coordArrayStart = [[NSMutableArray alloc]initWithCapacity:[visitData count]];
	//NSMutableArray *coordArrayEnd = [[NSMutableArray alloc]initWithCapacity:[visitData count]];
	
	//int visitCount = 1;

	float timeInterval = 0.1;

	/*for(int i = 0; i < [visitData count]-1; i++) {
		
		VisitDetails *begVisit = [visitData objectAtIndex:i];
		
		
		CLLocationCoordinate2D begCoord = CLLocationCoordinate2DMake([begVisit.latitude floatValue],
	 [begVisit.longitude floatValue]);
	 
		VisitDetails *destVisit = [visitData objectAtIndex:i+1];
		
		CLLocationCoordinate2D endCoord = CLLocationCoordinate2DMake([destVisit.latitude floatValue],
	 [destVisit.longitude floatValue]);
		
		NSMutableDictionary *coordBeginDic = [[NSMutableDictionary alloc]init];
		NSMutableDictionary *coordEndDic = [[NSMutableDictionary alloc]init];
		
		[coordBeginDic setObject:begVisit.latitude forKey:@"latitude"];
		[coordBeginDic setObject:begVisit.longitude forKey:@"longitude"];
		[coordBeginDic setObject:begVisit.starttime forKey:@"timeBegin"];
		[coordBeginDic setObject:begVisit.endtime forKey:@"timeEnd"];
		[coordBeginDic setObject:begVisit.appointmentid forKey:@"visitID"];
		[coordBeginDic setObject:begVisit.clientname forKey:@"clientName"];
		[coordBeginDic setObject:begVisit.street1 forKey:@"street"];
	 
		MKPlacemark *placeBegin = [[MKPlacemark alloc]initWithCoordinate:begCoord addressDictionary:nil];
		MKPlacemark *placeEnd = [[MKPlacemark alloc]initWithCoordinate:endCoord addressDictionary:nil];
		MKMapItem *mapItemSrc = [[MKMapItem alloc]initWithPlacemark:placeBegin];
		MKMapItem *mapItemDest = [[MKMapItem alloc]initWithPlacemark:placeEnd];
		
		MKDirectionsRequest *directionsFromPlaceToPlace = [[MKDirectionsRequest alloc]init];
		directionsFromPlaceToPlace.source = mapItemSrc;
		directionsFromPlaceToPlace.destination = mapItemDest;
		directionsFromPlaceToPlace.transportType = MKDirectionsTransportTypeAutomobile;
	 
		[coordEndDic setObject:destVisit.latitude forKey:@"latitude"];
		[coordEndDic setObject:destVisit.longitude forKey:@"longitude"];
		[coordEndDic setObject:destVisit.starttime forKey:@"timeBegin"];
		[coordEndDic setObject:destVisit.endtime forKey:@"timeEnd"];
		[coordEndDic setObject:destVisit.appointmentid forKey:@"visitID"];
		[coordEndDic setObject:destVisit.clientname forKey:@"clientName"];
		[coordEndDic setObject:destVisit.street1 forKey:@"street"];
		
		NSLog(@"begin coord: %f, %f, end coord: %f, %f",begCoord.latitude, begCoord.longitude, endCoord.latitude, endCoord.longitude);
		NSLog(@"->%@",[coordBeginDic objectForKey:@"street"]);
	 
		NSLog(@"---->%@",[coordEndDic objectForKey:@"street"]);
		
		
		NSMutableDictionary *userInfoDirections = [[NSMutableDictionary alloc]init];
		[userInfoDirections setObject:directionsFromPlaceToPlace forKey:@"MKDirections"];
		[userInfoDirections setObject:coordBeginDic forKey:@"coordBeginDic"];
		[userInfoDirections setObject:coordEndDic forKey:@"coordEndDic"];
		
		
		NSTimer *directionTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
	 target:self
	 selector:@selector(timedDirectionsRun:)
	 userInfo:userInfoDirections
	 repeats:NO];
	 
		timeInterval += 0.25;
		
	 }*/
	
	/*for (VisitDetails *visitDic in visitData) {
		
		
		NSMutableDictionary *coordBeginDic = [[NSMutableDictionary alloc]init];
		[coordBeginDic setObject:visitDic.latitude forKey:@"latitude"];
		[coordBeginDic setObject:visitDic.longitude forKey:@"longitude"];
		[coordBeginDic setObject:visitDic.starttime forKey:@"timeBegin"];
		[coordBeginDic setObject:visitDic.endtime forKey:@"timeEnd"];
		[coordBeginDic setObject:visitDic.appointmentid forKey:@"visitID"];
		[coordBeginDic setObject:visitDic.clientname forKey:@"clientName"];
		[coordBeginDic setObject:visitDic.street1 forKey:@"street"];
		[coordBeginDic setObject:@"30" forKey:@"visitTime"];
		[coordArrayStart addObject:coordBeginDic];
		[coordArrayEnd addObject:coordBeginDic];
		
	}*/
	
	timeInterval = 0.1;
		
	/*for (int i= 0; i  < [coordArrayStart count]; i++) {
		
		NSDictionary *beginDictionary = [coordArrayStart objectAtIndex:i];
		CLLocationCoordinate2D begCoord = CLLocationCoordinate2DMake([[beginDictionary objectForKey:@"latitude"]floatValue],
												 [[beginDictionary objectForKey:@"longitude"]floatValue]);
		
		for (int np = 0; np < [coordArrayEnd count]; np++)
		{
			_totalNumCoordinates++;
			
			NSDictionary *endDictionary = [coordArrayEnd objectAtIndex:np];
			CLLocationCoordinate2D endLocation = CLLocationCoordinate2DMake([[endDictionary objectForKey:@"latitude"]floatValue],
													    [[endDictionary objectForKey:@"longitude"]floatValue]);
			
			
			MKPlacemark *placeBegin = [[MKPlacemark alloc]initWithCoordinate:begCoord addressDictionary:nil];
			MKPlacemark *placeEnd = [[MKPlacemark alloc]initWithCoordinate:endLocation addressDictionary:nil];
			MKMapItem *mapItemSrc = [[MKMapItem alloc]initWithPlacemark:placeBegin];
			MKMapItem *mapItemDest = [[MKMapItem alloc]initWithPlacemark:placeEnd];
			
			MKDirectionsRequest *directionsFromPlaceToPlace = [[MKDirectionsRequest alloc]init];
			directionsFromPlaceToPlace.source = mapItemSrc;
			directionsFromPlaceToPlace.destination = mapItemDest;
			directionsFromPlaceToPlace.transportType = MKDirectionsTransportTypeAutomobile;
			
			
			NSMutableDictionary *userInfoDirections = [[NSMutableDictionary alloc]init];
			[userInfoDirections setObject:directionsFromPlaceToPlace forKey:@"MKDirections"];
			[userInfoDirections setObject:beginDictionary forKey:@"beginDic"];
			[userInfoDirections setObject:endDictionary forKey:@"endDic"];
			NSTimer *directionTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
												     target:self
												   selector:@selector(timedDirectionsRun:)
												   userInfo:userInfoDirections
												    repeats:NO];
			timeInterval += 1.5;
		}
		*/
	}
//}




-(void)timedDirectionsRun:(NSTimer*)timer {

	//_totalNumCoordinates--;
	
	MKDirectionsRequest *directionRequest = [timer.userInfo objectForKey:@"MKDirections"];
	//NSDictionary *beginDictionary = [timer.userInfo objectForKey:@"beginDic"];
	//NSDictionary *endDictionary = [timer.userInfo objectForKey:@"endDic"];
	
	MKDirections *directions = [[MKDirections alloc]initWithRequest:directionRequest];
	
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		
		if (error) {
			
		} else {
			
			/*MKRoute *route = [response.routes firstObject];
			float distanceRoute = route.distance;
			float timeTravel = route.expectedTravelTime;
			distanceRoute = distanceRoute/1000;
			timeTravel = timeTravel/60;
			
			_total_distance += distanceRoute;
			_total_time += timeTravel;
			
			NSString *begStreet = [beginDictionary objectForKey:@"street"];
			NSString *endStreet = [endDictionary objectForKey:@"street"];
			NSString *distanceStr = [NSString stringWithFormat:@"%f",distanceRoute];
			NSString *timeStr = [NSString stringWithFormat:@"%f",timeTravel];
			
			//NSLog(@"\nFrom: %@, To: %@  distance: %f time: %f",begStreet, endStreet, distanceRoute, timeTravel);
			
			NSMutableDictionary *matrixEntry = [[NSMutableDictionary alloc]init];
			[matrixEntry setObject:begStreet forKey:@"begin"];
			[matrixEntry setObject:endStreet forKey:@"end"];
			[matrixEntry setObject:distanceStr forKey:@"distance"];
			[matrixEntry setObject:timeStr forKey:@"time"];
			
			[_stopMatrix addObject:matrixEntry];*/
			
			
		}
	}];
	
	/*(if (_totalNumCoordinates == 0) {
		NSTimer *stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:6.0
											    target:self
											  selector:@selector(printRoutes)
											  userInfo:nil
											   repeats:NO];
	
	}*/
}

-(void) timedDirectionsAnalysis:(NSTimer*) timer {
	
	
}


-(void)printRoutes {

	//NSString *fileWriteComma = @"Begin Street, End Street, Distance, Time\n";
	
	/*for(NSDictionary *matrixItem in _stopMatrix) {
		NSString *begin = [matrixItem objectForKey:@"begin"];
		NSString *end = [matrixItem objectForKey:@"end"];
		NSString *distance = [matrixItem objectForKey:@"distance"];
		NSString *time = [matrixItem objectForKey:@"time"];
		NSString *anItem = [NSString stringWithFormat:@"%@,%@,%@,%@\n",begin,end,distance,time];
		fileWriteComma = [fileWriteComma stringByAppendingString:anItem];
	}*/
 
	//NSLog(@"%@", fileWriteComma);
	
	/*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths firstObject];
	NSString *filename = [NSString stringWithFormat:@"route-matrix-%@",_sitterName];
	NSString *plistPath = [documentsPath stringByAppendingPathComponent:filename];
	BOOL writeToFile = [fileWriteComma writeToFile:plistPath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
	if (!writeToFile) {
		NSLog(@"Error writing to file");
	}*/
}

-(void)calculateRoutes {
    
    //int itineraryCount = 0;
    //int stopCount = (int)[_stopMatrix count];
    //NSLog(@"stop array count: %i",stopCount);
    /*for (int i = 0; i < stopCount; i++) {
        NSDictionary *stopItem = [_stopMatrix objectAtIndex:i];
        NSLog(@"Stop: %@",stopItem);
    }*/
}

-(void)actualTimeDistance:(NSMutableArray*)visitData {
	
	NSMutableArray *sortArray = [[NSMutableArray alloc]init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	[dateFormat setDateFormat:@"YYYY-MM-dd HHmmss"];
	for(VisitDetails *visit in visitData) {
		if([visit.dateTimeMarkComplete isEqual:[NSNull null]] && [visit.dateTimeMarkComplete length] > 0 ) {
			[sortArray addObject:visit.dateTimeMarkComplete];
		}
	}
	[self doLocalProcess];
}


-(void)dealloc {
	
	//[[NSNotificationCenter defaultCenter]removeObserver:self name:@"finishedRoutes" object:nil];
	//[[NSNotificationCenter defaultCenter]removeObserver:self name:@"routeOptimized" object:nil];
}


-(void)sendToOptimize:(NSMutableDictionary*)optimizeVisitsDict {
	
	//NSLog(@"%@",optimizeVisitsDict);
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:optimizeVisitsDict
									   options:NSJSONWritingPrettyPrinted
									     error:&error];
	NSString *lengthData = [NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]];
	//NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:kRoutificURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:lengthData forHTTPHeaderField:@"Content-Length"];
	
	NSString *authToken = [NSString stringWithFormat:@"bearer %@",kRoutificAPIToken];
	[request setValue:authToken forHTTPHeaderField:@"Authorization"];
	[request setHTTPBody:jsonData];
	
	NSURLSessionConfiguration *urlConfig = [self sessionConfiguration];
	NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig
										   delegate:nil
									    delegateQueue:nil];
	
	
	NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,
																	 NSURLResponse * _Nullable response,
																	 NSError * _Nullable error) {
		
		
		NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
												options:
						     NSJSONReadingMutableContainers|
						     NSJSONReadingAllowFragments|
						     NSJSONWritingPrettyPrinted|
						     NSJSONReadingMutableLeaves
												  error:&error];
		
		//NSDictionary *solutionDic = [responseDic objectForKey:@"solution"];
		//NSArray *driverDic = [solutionDic objectForKey:@"driver_1"];
		NSArray *errorArray = [responseDic allKeys];
		
		BOOL errorBool = NO;
		
		for(NSString *key in errorArray) {
			
			//NSLog(@"key: %@",key);
			if ([key isEqualToString:@"error"]) {
				errorBool = YES;
			}
		}
		
		if (!errorBool) {
			
			//for (NSDictionary *visitLoc in driverDic) {
				//[_optimizedVisitLocations addObject:visitLoc];
			//}
			
			//[[NSNotificationCenter defaultCenter]postNotificationName:@"routeOptimized" object:nil];
			
		}
		
		//NSLog(@"%@",responseDic);
		
		
		
	}];
	[postDataTask resume];
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[urlSession finishTasksAndInvalidate];
	
}

-(void)graphHopperOptimize:(NSMutableDictionary*)optimizeVisitsDict {
	
	//NSLog(@"%@",optimizeVisitsDict);
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:optimizeVisitsDict
									   options:NSJSONWritingPrettyPrinted
									     error:&error];
	NSString *lengthData = [NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]];
	// NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:kRoutificURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:lengthData forHTTPHeaderField:@"Content-Length"];
	
	NSString *authToken = [NSString stringWithFormat:@"bearer %@",kRoutificAPIToken];
	[request setValue:authToken forHTTPHeaderField:@"Authorization"];
	[request setHTTPBody:jsonData];
	
	NSURLSessionConfiguration *urlConfig = [self sessionConfiguration];
	NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig
										   delegate:nil
									    delegateQueue:nil];
	
	
	NSURLSessionDataTask *postDataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,
																	 NSURLResponse * _Nullable response,
																	 NSError * _Nullable error) {
		
		
		NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
												options:
						     NSJSONReadingMutableContainers|
						     NSJSONReadingAllowFragments|
						     NSJSONWritingPrettyPrinted|
						     NSJSONReadingMutableLeaves
												  error:&error];
        
        if ([responseDic isEqual:[NSNull null]]) {
            for (id item in responseDic) {
                if ([item isKindOfClass:[NSString class]]) {
                    NSString *itemString = (NSString*)item;
                    NSLog(@"item: %@", itemString);
                }
            }
        }
		
		//NSDictionary *solutionDic = [responseDic objectForKey:@"solution"];
		//NSArray *driverDic = [solutionDic objectForKey:@"driver_1"];
		/*for (NSDictionary *visitLoc in driverDic) {
			[_optimizedVisitLocations addObject:visitLoc];
		}*/
		//NSLog(@"%@",responseDic);
		//[[NSNotificationCenter defaultCenter]postNotificationName:@"routeOptimized" object:nil];
		
	}];
	[postDataTask resume];
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[urlSession finishTasksAndInvalidate];
	
}

-(NSURLSessionConfiguration *)sessionConfiguration {
	NSURLSessionConfiguration *config =
	[NSURLSessionConfiguration defaultSessionConfiguration];
	
	config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0
									diskCapacity:0
									    diskPath:nil];
	
	return config;
}

-(void)displayRouteOptimize {
 
	
	//NSMutableArray *visitCoords = [[NSMutableArray alloc]init];
	
	/*for (VisitDetails *visit in _sharedInstance.visitData) {
		NSMutableDictionary *visitInfo = [[NSMutableDictionary alloc]init];
		[visitInfo setObject:visit.latitude forKey:@"lat"];
		[visitInfo setObject:visit.longitude forKey:@"lng"];
		[visitInfo setObject:visit.appointmentid forKey:@"visitID"];
		[visitCoords addObject:visitInfo];
	}*/
	
	
	//_totalNumCoordinates = (int)[_optimizedVisitLocations count]-1;
	
	//for (int i = 0; i < [_optimizedVisitLocations count]-1; i++) {
		//NSLog(@"locations: %lu, index val: %i",(unsigned long)[_optimizedVisitLocations count],i);
		
		//NSDictionary *routeItemBeg = [_optimizedVisitLocations objectAtIndex:i];
		
		//if (i == [_optimizedVisitLocations count]-1) {
			
			//NSLog(@"Route End");
			
		//} else {
			
			//_totalNumCoordinates--;
			//NSLog(@"num coord: %i",_totalNumCoordinates);
			
			/*NSDictionary *routeItemDest = [_optimizedVisitLocations objectAtIndex:i+1];
			
			NSString *visitID = [routeItemBeg objectForKey:@"location_name"];
			NSString *visitIDEnd = [routeItemDest objectForKey:@"location_name"];
			
			CLLocationCoordinate2D begCoord;
			CLLocationCoordinate2D endCoord;

			for (NSDictionary *visitDetails in visitCoords) {
				
				NSString *matchVisitID = [visitDetails objectForKey:@"visitID"];
				
				if([visitID isEqualToString:matchVisitID]){
					
					begCoord = CLLocationCoordinate2DMake([[visitDetails objectForKey:@"lat"]floatValue], [[visitDetails objectForKey:@"lng"]floatValue]);
				} else if ([visitID isEqualToString:@"Home"]) {
					begCoord = _sitterAddress;
				}
			}*/
			
			/*for (NSDictionary *visitDetails in visitCoords) {
				NSString *matchVisitID = [visitDetails objectForKey:@"visitID"];
				
				if([visitIDEnd isEqualToString:matchVisitID]){
					
					endCoord = CLLocationCoordinate2DMake([[visitDetails objectForKey:@"lat"]floatValue], [[visitDetails objectForKey:@"lng"]floatValue]);
					
				}*/
			}
			
			/*if (i==0) {
				
				//begCoord = _sitterAddress;
				
			} else if (i == [_optimizedVisitLocations count]-1) {
				//endCoord = _sitterAddress;
				
			} else {
				//begCoord = _sitterAddress;
				//endCoord = _sitterAddress;
			}*/

			/*
			MKPlacemark *placeBegin = [[MKPlacemark alloc]initWithCoordinate:begCoord addressDictionary:nil];
			MKPlacemark *placeEnd = [[MKPlacemark alloc]initWithCoordinate:endCoord addressDictionary:nil];
			MKMapItem *mapItemSrc = [[MKMapItem alloc]initWithPlacemark:placeBegin];
			MKMapItem *mapItemDest = [[MKMapItem alloc]initWithPlacemark:placeEnd];
			
			MKDirectionsRequest *directionsFromPlaceToPlace = [[MKDirectionsRequest alloc]init];
			directionsFromPlaceToPlace.source = mapItemSrc;
			directionsFromPlaceToPlace.destination = mapItemDest;
			directionsFromPlaceToPlace.transportType = MKDirectionsTransportTypeAutomobile;
			MKDirections *directions = [[MKDirections alloc]initWithRequest:directionsFromPlaceToPlace];
			
			[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
				if (error) {
				} else {
					MKRoute *route = [response.routes firstObject];
					float distanceRoute = route.distance;
					float timeTravel = route.expectedTravelTime;
					distanceRoute = distanceRoute/1000;
					timeTravel = timeTravel/60;
					
					if (_totalNumCoordinates == 0) {
						
						[[NSNotficationCenter defaultCenter]postNotificationName:@"finishedRoutes"
														   object:nil];
						
					}
				}
			}];
		}
	}
}
*/


@end
