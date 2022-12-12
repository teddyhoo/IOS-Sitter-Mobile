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
#import <MapKit/MapKit.h>

@interface VisitDetails () {

    NSMutableArray *petPhotos;
    NSMutableArray *docItems;
    NSString *petImageFile;
    UIImage *currentPetImage;
    NSString *mapSnapShotFilename;
    UIImage *mapSnapShotImage;
    NSDateFormatter *logUploadTimeDate;
    
}
@end

@implementation VisitDetails

-(instancetype)init {
    
    self = [super init];
    if(self) {
        docItems = [[NSMutableArray alloc]init];
		petPhotos = [[NSMutableArray alloc]init];
        logUploadTimeDate = [[NSDateFormatter alloc]init];
        currentPetImage = NULL;

    }
    
    return self;
    
}
-(void) writeVisitDataToFile {
      
    //NSLog(@"------------------WRITING VISIT DATA TO FILE ------------");
    NSMutableDictionary *fileDictionary = [self getMyVisitDetails:self.appointmentid];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"%@-visitdetails",self.appointmentid];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:filename];
    
    dispatch_queue_t writeVisitDataAsync = dispatch_queue_create("WriteFile", NULL);
    dispatch_async(writeVisitDataAsync, ^ {
        BOOL writeStatus = [fileDictionary writeToFile:plistPath atomically:YES ];
        if (!writeStatus) {
            NSUserDefaults *writeError = [NSUserDefaults standardUserDefaults];
            //NSMutableDictionary *badWrite = [[NSMutableDictionary alloc]init];
            NSDate *rightNow = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            [writeError setObject:@"BAD VISIT DETAILS WRITE TO FILE" forKey:[dateFormat stringFromDate:rightNow]];
        }
    });
}
-(void)moodButtonSyncFromFile:(NSDictionary*) visitDetailDictMoodSync {
    
    if([[visitDetailDictMoodSync valueForKey:@"didPoo"]isEqualToString:@"YES"]) {
        _didPoo = YES;
    } else {
        _didPoo = NO;
    }
    if([[visitDetailDictMoodSync valueForKey:@"didPee"]isEqualToString:@"YES"]) {
        _didPee = YES;
    } else {
        _didPee = NO;
    }
    if([[visitDetailDictMoodSync valueForKey:@"gaveTreat"]isEqualToString:@"YES"]) {
        _gaveTreat = YES;
    } else {
        _gaveTreat = NO;
    }
    if([[visitDetailDictMoodSync valueForKey:@"gaveWater"]isEqualToString:@"YES"]) {
        _gaveWater = YES;
    } else {
        _gaveWater = NO;
    }
    if ([[visitDetailDictMoodSync valueForKey:@"dryTowel"]isEqualToString:@"YES"]) {
        _dryTowel = YES;
        
    } else {
        _dryTowel = NO;
    }
    if([[visitDetailDictMoodSync valueForKey:@"gaveInjection"]isEqualToString:@"YES"]) {
        _gaveInjection = YES;
        
    } else  {
        _gaveInjection = NO;
    }
    if([[visitDetailDictMoodSync valueForKey:@"gaveMedication"]isEqualToString:@"YES"]) {
        _gaveMedication = YES;
        
    } else  {
        _gaveMedication = NO;
    }
    if ([[visitDetailDictMoodSync valueForKey:@"didFeed"]isEqualToString:@"YES"]) {
        _didFeed = YES;
    } else {
        _didFeed = NO;
        
    }
    if([[visitDetailDictMoodSync valueForKey:@"didPlay"]isEqualToString:@"YES"]) {
        _didPlay = YES;
    } else {
        _didPlay = NO;
    }
}
-(NSMutableDictionary *)getMyVisitDetails:(NSString *)visitID {
    
    NSMutableDictionary *visitDetails = [[NSMutableDictionary alloc]init];
    [visitDetails setValue:self.appointmentid forKey:@"appointmentid"];
    [visitDetails setValue:self.arrived forKey:@"arrived"];
    [visitDetails setValue:self.completed forKey:@"completed"];
    [visitDetails setValue:self.dateTimeMarkArrive forKey:@"dateTimeMarkArrive"];
    [visitDetails setValue:self.dateTimeMarkComplete forKey:@"dateTimeMarkComplete"];
    [visitDetails setValue:self.dateTimeVisitReportSubmit forKey:@"dateTimeVisitReportSubmit"];
    [visitDetails setValue:self.dateTimeFinishVisitReport forKey:@"dateTimeFinishVisitReport"];
    [visitDetails setValue:self.photoSentDate forKey:@"photoSentDate"];

    [visitDetails setValue:self.coordinateLatitudeMarkArrive forKey:@"coordinateLatitudeMarkArrive"];
    [visitDetails setValue:self.coordinateLongitudeMarkArrive forKey:@"coordinateLongitudeMarkArrive"];
    [visitDetails setValue:self.coordinateLongitudeMarkComplete forKey:@"coordinateLongitudeMarkComplete"];
    [visitDetails setValue:self.coordinateLatitudeMarkComplete forKey:@"coordinateLatitudeMarkComplete"];
    
    [visitDetails setValue:self.currentArriveVisitStatus forKey:@"currentArriveVisitStatus"];
    [visitDetails setValue:self.currentCompleteVisitStatus forKey:@"currentCompleteVisitStatus"];
    [visitDetails setValue:self.mapSnapTakeStatus forKey:@"mapSnapTakeStatus"];
    [visitDetails setValue:self.mapSnapUploadStatus forKey:@"mapSnapUploadStatus"];
    [visitDetails setValue:self.imageUploadStatus forKey:@"imageUploadStatus"];
    [visitDetails setValue:self.visitReportUploadStatus forKey:@"visitReportUploadStatus"];
    
    NSLog(@"MAP SNAP file: %@", mapSnapShotFilename);
    
    [visitDetails setValue:mapSnapShotFilename forKey:@"mapSnapShotFilename"];

    NSLog(@"Writing pet image file: %@", petImageFile);

    [visitDetails setValue:petImageFile forKey:@"petImageFile"];

    [visitDetails setValue:self.visitNoteBySitter forKey:@"visitNoteBySitter"];
    [visitDetails setValue:self.status forKey:@"visitStatus"];
    
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
    if (_gaveTreat) {
        [visitDetails setValue:@"YES" forKey:@"gaveTreat"];
    } else {
        [visitDetails setValue:@"NO" forKey:@"gaveTreat"];
    }
    if (_gaveWater) {
        [visitDetails setValue:@"YES" forKey:@"gaveWater"];
    } else {
        [visitDetails setValue:@"NO" forKey:@"gaveWater"];
    }
    if (_dryTowel) {
        [visitDetails setValue:@"YES" forKey:@"dryTowel"];
    } else {
        [visitDetails setValue:@"NO" forKey:@"dryTowel"];
    }
    if (_gaveInjection) {
        [visitDetails setValue:@"YES" forKey:@"gaveInjection"];
    } else {
        [visitDetails setValue:@"NO" forKey:@"gaveInjection"];
    }
    if (_gaveMedication) {
        [visitDetails setValue:@"YES" forKey:@"gaveMedication"];
    } else {
        [visitDetails setValue:@"NO" forKey:@"gaveMedication"];
    }
    if (_didFeed) {
        [visitDetails setValue:@"YES" forKey:@"didFeed"];
    } else {
        [visitDetails setValue:@"NO" forKey:@"didFeed"];
    }
    if (_didPlay) {
        [visitDetails setValue:@"YES" forKey:@"didPlay"];
    } else {
        [visitDetails setValue:@"NO" forKey:@"didPlay"];
    }


    //NSLog(@"-------------------------------------------------------------------");
    //NSLog(@"------WRITE VISIT ID: %@, CLIENT: %@ -----------", _appointmentid, _clientname);
    //NSLog(@"SITTER VISIT NOTE: %@", self.visitNoteBySitter);
    /*NSLog(@"-------------------------------------------------------------------");
     NSLog(@"------WRITE VISIT ID: %@, CLIENT: %@ -----------", _appointmentid, _clientname);
     NSLog(@"ARRIVED: %@ (%@)", _arrived, _currentArriveVisitStatus);
     NSLog(@"COMPLETED: %@ (%@)", _completed, _currentCompleteVisitStatus);
     NSLog(@"REPORT: %@ (%@)", _dateTimeVisitReportSubmit, _visitReportUploadStatus);
     NSLog(@"IMAGE: %@ (%@)", _petImageFile, _imageUploadStatus);
     NSLog(@"MAP: %@ (%@)", _mapSnapShotFilename, _mapSnapShotFilename);*/
        
    
    return visitDetails;

}
-(void) syncVisitDetailFromFile {
    
    //fileManager = [NSFileManager new];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *filename = [NSString stringWithFormat:@"%@-visitdetails",self.appointmentid];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:filename];
    
    if ([[NSFileManager new]fileExistsAtPath:plistPath]) {
        NSDictionary *visitDetail = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
        
        [self dateCheckSyncFromFile:visitDetail];
        [self uploadStatusSync:visitDetail];
        [self moodButtonSyncFromFile:visitDetail];
        
        self.coordinateLatitudeMarkArrive =[visitDetail valueForKey:@"coordinateLatitudeMarkArrive"];
        self.coordinateLongitudeMarkArrive = [visitDetail valueForKey:@"coordinateLongitudeMarkArrive"];
        self.coordinateLongitudeMarkComplete = [visitDetail valueForKey:@"coordinateLongitudeMarkComplete"];
        self.coordinateLatitudeMarkComplete = [visitDetail valueForKey:@"coordinateLatitudeMarkComplete"];
        
        petImageFile = [visitDetail valueForKey:@"petImageFile"];
        NSString *petImagePath = [documentsPath stringByAppendingPathComponent:petImageFile]; //_petImageFile];
        currentPetImage = [[UIImage alloc]initWithContentsOfFile:petImagePath];
                
        mapSnapShotFilename = [visitDetail valueForKey:@"mapSnapShotFilename"];
        NSString *mapImgPath = [documentsPath stringByAppendingPathComponent:mapSnapShotFilename];
        mapSnapShotImage = [[UIImage alloc]initWithContentsOfFile:mapImgPath];
        self.visitNoteBySitter = [visitDetail valueForKey:@"visitNoteBySitter"];
        if(![self.status isEqualToString:[visitDetail valueForKey:@"visitStatus"]]) {
            NSLog(@"********Status conflict");
        } else {
            self.status = [visitDetail valueForKey:@"visitStatus"];

        }
        self.mapSentDate = [visitDetail valueForKey:@"mapSentDate"];
        self.photoSentDate = [visitDetail valueForKey:@"photoSentDate"];
    }
}

-(void) addPointForRouteUsingCLLocation:(CLLocation*)location {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setLocale:[NSLocale currentLocale]];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setDateFormat:@"hhMMss"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *filename = [NSString stringWithFormat:@"%@-coordinates",self.appointmentid];
    NSString *coordinateFilePath = [documentsPath stringByAppendingPathComponent:filename];

    NSData *pointData = [NSKeyedArchiver archivedDataWithRootObject:location 
                                              requiringSecureCoding:NO 
                                                              error:nil];
    
    //if([fileManager fileExistsAtPath:coordinateFilePath]) {
    if ([[NSFileManager new]fileExistsAtPath:coordinateFilePath]) {
        
        NSArray *coordinateArray = [[NSArray alloc]initWithContentsOfFile:coordinateFilePath];
        _routePoints = [[NSMutableArray alloc]initWithArray:coordinateArray];
        [_routePoints addObject:pointData];
        NSArray *coordinateArrayFile = [[NSArray alloc]initWithArray:_routePoints];
        
        BOOL wroteCoordArr = [coordinateArrayFile writeToFile:coordinateFilePath atomically:YES];
        
        if(wroteCoordArr) {
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
-(NSArray*) rebuildPointsForVisit {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *filename = [NSString stringWithFormat:@"%@-coordinates",self.appointmentid];
    NSString *coordinateFilePath = [documentsPath stringByAppendingPathComponent:filename];
    //NSLog(@">>>> MAP SNAPSHOT FILE PATH: %@", coordinateFilePath);
    if([[NSFileManager new]fileExistsAtPath:coordinateFilePath]) {
        
        NSArray *coordinateArray = [[NSArray alloc]initWithContentsOfFile:coordinateFilePath];
        return coordinateArray;
        
    }
    return nil;
    
}

-(void)addImageForPet:(UIImage*)petImage {
    
    currentPetImage = petImage;
    petImageFile = [self imageFilenameForPet];
    NSData *imageData = UIImagePNGRepresentation(currentPetImage);
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                          inDomain:NSUserDomainMask
                                                                 appropriateForURL:nil
                                                                            create:NO
                                                                             error:nil];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:petImageFile];
    dispatch_queue_t writeFilePetImage = dispatch_queue_create("PetImageWrite", NULL);
    dispatch_async(writeFilePetImage, ^{
            if ([imageData writeToURL:documentsDirectoryURL atomically:YES]) {
                NSLog(@"SUCCESSFUL write to file");
            } else {
                NSLog(@"NOT SUCCESSFUL write to file");
            }
           
    });

    [[VisitsAndTracking sharedInstance]sendPhotoViaAFNetwork:documentsDirectoryURL
                                                   imageData:imageData
                                         imageFileNameString:petImageFile
                                             forVisitDetails:self];
}


-(void)sendMapSnapshotViaAFNetwork:(NSURL*) filePathURL
                         imageData:(NSData*)imageData
               imageFileNameString:(NSString*)imageFileNameString {
    
    NSString *scriptName = @"https://leashtime.com/appointment-map-upload.php";
    NSDictionary *creds = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
    NSDictionary *parameters = @{@"loginid":  [creds objectForKey:@"username"],
                                 @"password":  [creds objectForKey:@"password"],
                                 @"appointmentid": self.appointmentid};
        
    AFHTTPSessionManager *manager =  [AFHTTPSessionManager manager];
    AFHTTPResponseSerializer *serializerInstance = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = serializerInstance;
        
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]multipartFormRequestWithMethod:@"POST"
                                                                                             URLString:scriptName
                                                                                            parameters:parameters
                                                                             constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData
                                    name:@"map"
                                fileName:imageFileNameString
                                mimeType:@"image/png"];
        
    } error:nil];
    
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:^(NSProgress * _Nonnull uploadProgress) {

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"ERROR: %@", error);
            [self setUploadStatusForMap:@"FAIL"];
            
            dispatch_queue_t writeVisit = dispatch_queue_create("Write File", NULL);
            dispatch_async(writeVisit, ^{
                @synchronized (@"WriteAndUpdate") {
                    [self writeVisitDataToFile];
                }
            });
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateTable" object:nil];
            });


            
        } else {
            
            if ([self.imageUploadStatus isEqualToString:@"FAIL"]) {
                
                [self setUploadStatusForMap:@"SUCCESS"];
                
                
            } else {
                

                [self setUploadStatusForMap:@"SUCCESS"];
                    
                
                @synchronized (@"WriteUpdate") {
                
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateTable" object:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"uploadMapSnapShot" object:self];
                    
                    [self writeVisitDataToFile];
                }
            }

        }
    }];
    [uploadTask resume];
}



-(void) addMapsnapShotImageToVisit:(UIImage*) mapImg {
    NSData *imageData = UIImagePNGRepresentation(mapImg);
    NSString *nameOfImageFile = [NSString stringWithFormat:@"mapSnap-%@.png",self.appointmentid];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:nameOfImageFile];
    mapSnapShotImage = mapImg;
    mapSnapShotFilename = nameOfImageFile;
    [imageData writeToFile:imagePath atomically:YES];
    NSURL *filePathURL = [[NSURL alloc]initFileURLWithPath:imagePath];
    [self sendMapSnapshotViaAFNetwork:filePathURL imageData:imageData imageFileNameString:nameOfImageFile];

}
-(void) addMapSnapToVisit:(UIImage*) mapImg withStatus:(NSString*)status {
    if (mapImg != nil) {
        NSLog(@"ADDING MAP SNAP SHOT (NOT NIL) TO VISIT DETAILS with status: %@", status);
        _mapSnapTakeStatus = status;
        [self addMapsnapShotImageToVisit:mapImg];
    } else {
        NSLog(@"MAP SNAP FAIL with status: %@", status);
        _mapSnapTakeStatus = status;
        _mapSnapUploadStatus = status;
    }
}
-(NSArray*) getPointForRoutes {
        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *filename = [NSString stringWithFormat:@"%@-coordinates",self.appointmentid];
    NSString *coordinateFilePath = [documentsPath stringByAppendingPathComponent:filename];
    NSMutableArray *convertLocArray = [[NSMutableArray alloc]init];
    
    if ([[NSFileManager new]fileExistsAtPath:coordinateFilePath]) {
        NSArray *coordinateArray = [[NSArray alloc]initWithContentsOfFile:coordinateFilePath];
        for(NSData *locationArc in coordinateArray) {
            if ([locationArc isKindOfClass:[NSData class]]) {
                CLLocation *locConvert = [NSKeyedUnarchiver unarchivedObjectOfClass:[CLLocation class]
                                                                           fromData:locationArc
                                                                              error:nil];
                if (locConvert != nil) {
                    [convertLocArray addObject:locConvert];
                } else {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"failPointConvert" object:self];
                }
            }
        }
    }  else {
        return nil;
    }
    
    NSLog(@"Converted number of: %lu coordinates from read file", [convertLocArray count]);
    
    return convertLocArray;
    
}
-(void) createMapSnapshot {
    
    float markVisitComplateLon = [_coordinateLongitudeMarkComplete floatValue];
    float markVisitCompleteLat = [_coordinateLatitudeMarkComplete floatValue];
    CLLocationCoordinate2D completeVisit = CLLocationCoordinate2DMake(markVisitCompleteLat,markVisitComplateLon);
    NSArray *redrawVisitPoints = [NSArray arrayWithArray:[self getPointForRoutes]];
    //NSLog(@"Number coordinates to create map snap with: %lu", [redrawVisitPoints count]);
    
    MKMapSnapshotOptions *mapSnapOp = [[MKMapSnapshotOptions alloc]init];
    mapSnapOp.size = CGSizeMake(500, 500);
    mapSnapOp.scale = [[UIScreen mainScreen]scale];
    mapSnapOp.mapType = MKMapTypeStandard;
    mapSnapOp.showsBuildings = YES;
    
    MKMapCamera *mapViewVC = [[MKMapCamera alloc]init];
    mapViewVC.pitch = 45;
    mapViewVC.altitude = 400;
    mapSnapOp.camera = mapViewVC;
    
    MKCoordinateRegion region;
    
    if (_latitude != nil && _longitude != nil) {
        CLLocationCoordinate2D clientHome = CLLocationCoordinate2DMake([_latitude floatValue], [_longitude floatValue]);
        
        if([redrawVisitPoints count] > 4) {
            region = [self regionForAnnotations:redrawVisitPoints];
            mapSnapOp.region = region;
            mapViewVC.centerCoordinate = completeVisit;
        } else {
            double maxLatSpan = clientHome.latitude;
            double maxLonSpan = clientHome.longitude;
            maxLatSpan = 0.002611;
            maxLonSpan = 0.002964;
            CLLocationCoordinate2D clientLoc = CLLocationCoordinate2DMake(maxLatSpan, maxLonSpan);
            MKCoordinateSpan span = MKCoordinateSpanMake(clientLoc.latitude, clientLoc.longitude);
            MKCoordinateRegion region = MKCoordinateRegionMake(clientHome, span);
            mapViewVC.centerCoordinate = completeVisit;
            mapSnapOp.region = region;
        }
        
        MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc]initWithOptions:mapSnapOp];
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
                
                for(int i=0;i<[redrawVisitPoints count];i++) {
                    CLLocation *thePoint = [redrawVisitPoints objectAtIndex:i];
                    if ([thePoint isKindOfClass:[CLLocation class]]) {
                        coordinates[i] = thePoint.coordinate;
                    }
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
                
                MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
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
                [self addMapSnapToVisit:res withStatus:@"SUCCESS"];
  
                
            } else {
                NSUserDefaults *failMapSnap = [NSUserDefaults standardUserDefaults];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd 'at' HH:mm";
                NSDate *date = [NSDate date]; // your NSDate object
                NSString *dateString = [dateFormatter stringFromDate:date];
                [failMapSnap setObject:@"Map Snap"  forKey:dateString];
                
                [self addMapSnapToVisit:nil withStatus:@"FAIL"];
                [self writeVisitDataToFile];
            }
        }];
        
                
    }
    else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"invalidHomeLatLon" object:self];
        
    }
}
- (MKCoordinateRegion) regionForAnnotations:(NSArray *)annotations {
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    
    for (CLLocation *location in annotations) {
        if([location isKindOfClass:[CLLocation class]]) {
            //NSLog(@"Valid coordinate class");
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
-(void) addVisitNoteToVisit:(NSString*)visitNote {
    self.visitNoteBySitter = [NSString stringWithString:visitNote];
    dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
    dispatch_async(myWrite, ^{
        [self writeVisitDataToFile];
    });
    
}

-(void) markComplete:(NSString*)timeMarkComplete
            latitude:(NSString *)coordinateLatitudeMarkComplete
           longitude:(NSString *)coordinateLongitudeMarkComplete {


    _isComplete = YES;
    _inProcess = NO;
    _coordinateLatitudeMarkComplete = [NSString stringWithString:coordinateLatitudeMarkComplete];
    _coordinateLongitudeMarkComplete = [NSString stringWithString:coordinateLongitudeMarkComplete];
    //dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL);
    //dispatch_async(myQueue, ^{
        //[self writeVisitDataToFile];
    //});
}
-(void)markArrive:(NSString*)timeMarkArrive
         latitude:(NSString *)coordinateLatitudeMarkArrive
         longitude:(NSString *)coordinateLongitudeMarkArrive   {
    
    _inProcess = YES;
    _hasArrived = YES;
    _coordinateLatitudeMarkArrive = [NSString stringWithString:coordinateLatitudeMarkArrive];
    _coordinateLongitudeMarkArrive = [NSString stringWithString:coordinateLongitudeMarkArrive];
    //   dispatch_queue_t myQueue = dispatch_queue_create("ArriveUpdateQueue", NULL);
    //dispatch_async(myQueue, ^{
        //[self writeVisitDataToFile];
    //});
}

-(UIImage*)getPetPhoto {
    //NSLog(@"Returning pet profile image with size: %f, %f", imageSize.width, imageSize.height);
    return currentPetImage;
}
-(UIImage*)getMapImage {
    return mapSnapShotImage;
}
-(BOOL) isPetImage {
    if (currentPetImage != nil) {
        return TRUE;
    } else {
        return FALSE;
    }
}
-(BOOL)isMapSnapShotImage {
    if (mapSnapShotImage != nil) {
        return TRUE;
    } else {
        return FALSE;
    }
}
-(void)outputVisitDetail:(NSDictionary*)visitDetailSync {
    /* NSLog(@"-------------------------------------------------------------------");
     NSLog(@"-------SYNC FROM FILE FOR VISIT ID: %@, client: %@---------", _appointmentid, _clientname);
     NSLog(@"-------------------------------------------------------------------");
     NSLog(@"DT MARK ARRIVE:          %@", _dateTimeMarkArrive);
     NSLog(@"DT MARK ARRIVE LOCAL:    %@", [visitDetailSync valueForKey:@"dateTimeMarkArrive"]);
     NSLog(@"ARRIVED:                 %@", _arrived);
     NSLog(@"ARRIVED SYNC:            %@",[visitDetailSync valueForKey:@"arrived"]);
     NSLog(@"-------------------------------------------------------------------");
     NSLog(@"DT MARK COMPLETE:        %@", _dateTimeMarkComplete);
     NSLog(@"DT MARK COMPLETED LOCAL: %@", [visitDetailSync valueForKey:@"dateTimeMarkComplete"]);
     NSLog(@"COMPLETED:               %@",  _completed);
     NSLog(@"COMPLETED SYNC:          %@",[visitDetailSync valueForKey:@"completed"]);*/
}
-(NSString*) imageFilenameForPet {
    
    NSString *dateForImageFilename = [self stringForCurrentDateAndTime];
    NSString *nameOfImageFile = [NSString stringWithFormat:@"image-%@-%@.png", self.appointmentid, dateForImageFilename];
    return nameOfImageFile;
    
}
/*-(NSString *) stringForCurrentDay {
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *now = [NSDate date];
    NSString *dateString = [format stringFromDate:now];
    return dateString;
}*/
-(NSString *) stringForCurrentDateAndTime {
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *now = [NSDate date];
    NSString *dateString = [format stringFromDate:now];
    return dateString;
}
-(void) resendMapSnapShot {
    NSLog(@"Creating map image data");
    
    NSData *imageData = UIImagePNGRepresentation(mapSnapShotImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"%@",mapSnapShotFilename]];
    [imageData writeToFile:imagePath atomically:YES];
    NSURL *filePathURL = [[NSURL alloc]initFileURLWithPath:imagePath];
    
    [self sendMapSnapshotViaAFNetwork:filePathURL imageData:imageData imageFileNameString:mapSnapShotFilename];
    
}
-(void) resendImageForPet {
    
    NSData *imageData = UIImagePNGRepresentation(currentPetImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:petImageFile];
    [imageData writeToFile:imagePath atomically:YES];
    NSURL *filePathURL = [[NSURL alloc]initFileURLWithPath:imagePath];
    NSLog(@"-------------------------------------------------------------------");
    NSLog(@"-------------------RESENDING PHOTO----------------------------------");
    NSLog(@"-------------------------------------------------------------------");
    NSLog(@"Params: filePathURL: %@, imageFileNameString: %@", filePathURL, petImageFile);
    NSLog(@"With data: %@", imageData);
    NSLog(@"-------------------------------------------------------------------");

    [[VisitsAndTracking sharedInstance]sendPhotoViaAFNetwork:filePathURL
                                                   imageData:imageData
                                         imageFileNameString:petImageFile
                                             forVisitDetails:self];
}
-(void)addErrataData:(NSArray*)errataArray {
    for(NSDictionary *errataDic in errataArray) {
        [docItems addObject:errataDic];
    }
}
-(NSMutableArray*)getErrataDocItems {
    return docItems;
}
-(NSArray*)getPetPhotos {
    return petPhotos;
}
-(void) setMarkArriveCompleteStatus:(NSString*)type andStatus:(NSString*)status {
    
    if([type isEqualToString:@"arrived"]) {
        _currentArriveVisitStatus = status;
    } else if ([type isEqualToString:@"completed"]) {
        _currentCompleteVisitStatus = status;
    } else if ([type isEqualToString:@"visitReport"]) {
        _visitReportUploadStatus = status;
    }
}
-(void) setTimestampVisitReportUpload:(NSString*)visitReportUploadTime {
    
    _dateTimeFinishVisitReport = visitReportUploadTime;
    
}
-(void) setUploadStatusForMap:(NSString*)status {
    
    self.mapSnapUploadStatus = status;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"hh:mm:ss a"];
    NSDate *sendSuccessDate = [NSDate date];
    self.mapSentDate = [dateFormat stringFromDate:sendSuccessDate];
    
    NSLog(@"Map snap upload status: %@", self.mapSnapUploadStatus);
    
}
-(void) setUploadStatusForPhoto:(NSString*)status {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"h:mm a"];
    NSDate *sendSuccessDate = [NSDate date];
    self.photoSentDate = [dateFormat stringFromDate:sendSuccessDate];
    self.imageUploadStatus = status;
    NSLog(@"Image upload status: %@", self.imageUploadStatus);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"photoFinishUpload" object:nil];
    
}
-(void) setCoordinatesUpload:(NSString*)status {
    
}
-(void) dateCheckSyncFromFile:(NSDictionary*) visitDetailDictSync {
    
    NSDateFormatter *dateString = [[NSDateFormatter alloc]init];
    [dateString setDateFormat:@"HH:mm a"];
    /*NSLog(@"---------------------- VISIT DETAILS -----------------------------");
    NSLog(@"CURRENT DATE SETTINGS SYNC SERVER: %@, %@, %@, %@", self.arrived, self.completed, self.dateTimeMarkArrive, self.dateTimeMarkComplete);
    NSLog(@"DATE CHECK SYNC FROM FILE: %@ %@",[visitDetailDictSync objectForKey:@"arrived"], [visitDetailDictSync objectForKey:@"completed"]);
    NSLog(@"Datetimemark arrive: %@ complete: %@", [visitDetailDictSync objectForKey:@"dateTimeMarkArrive"], [visitDetailDictSync objectForKey:@"dateTimeMarkComplete"]);

    */
    if(self.dateTimeMarkArrive == NULL) {
        self.dateTimeMarkArrive = [visitDetailDictSync valueForKey:@"dateTimeMarkArrive"];
        //NSLog(@"DATE TIME MARK ARRIVE NULL: %@", [visitDetailDictSync valueForKey:@"dateTimeMarkArrive"]);
    }
    if (self.arrived == NULL) {
        self.arrived = [visitDetailDictSync valueForKey:@"arrived"];
    }
    if (self.completed == NULL) {
        self.completed = [visitDetailDictSync valueForKey:@"completed"];
    } else {
        //NSLog(@"COMPLETED NOT NULL ON SYNC");
    }
    
    //NSLog(@"A: %@, C: %@ , stat: %@    [SYNC]", self.arrived, self.completed,self.status);
    
    self.dateTimeVisitReportSubmit = [visitDetailDictSync valueForKey:@"dateTimeVisitReportSubmit"];
    self.NSDateMarkComplete = [dateString dateFromString:self.dateTimeMarkComplete];
    self.NSDateMarkArrive = [dateString dateFromString:self.dateTimeMarkArrive];
    
}
-(void) uploadStatusSync:(NSDictionary*) statusDictionary {
    self.dateTimeFinishVisitReport = [statusDictionary valueForKey:@"dateTimeFinishVisitReport"];
    self.currentArriveVisitStatus = [statusDictionary valueForKey:@"currentArriveVisitStatus"];
    self.currentCompleteVisitStatus = [statusDictionary valueForKey:@"currentCompleteVisitStatus"];
    self.visitReportUploadStatus = [statusDictionary valueForKey:@"visitReportUploadStatus"];
    self.mapSnapUploadStatus = [statusDictionary valueForKey:@"mapSnapUploadStatus"];
    self.imageUploadStatus = [statusDictionary valueForKey:@"imageUploadStatus"];
}

@end
