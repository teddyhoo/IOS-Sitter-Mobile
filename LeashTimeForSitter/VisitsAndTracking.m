//
//  VisitsAndTracking.m
//  LeashTimeSitter
//
//  Created by Ted Hooban on 8/13/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "VisitsAndTracking.h"
#import "DateTools.h"
#import "DataClient.h"
#import "PetProfile.h"
#import "AFNetworking.h"
#import "PetProfile.h"
//#import <UserNotifications/UserNotifications.h>
//#import <MapKit/MapKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <ImageIO/ImageIO.h>

@interface VisitsAndTracking() {
    
    NSMutableArray *yesterdayVisits;
    NSMutableArray *tomorrowVisits;
    NSMutableArray *todaysVisits;
    
    NSURLSession *mySession;
    NSURLSessionConfiguration *sessionConfiguration;
    
    NSDateFormatter *oldFormatter;                                      // HH:mm:ss
    NSDateFormatter *newFormatter;                                    // h:mm a
    NSDateFormatter *timerFormat;                                       //mm:ss
    NSDateFormatter *arriveCompleteDateFormatter;         // HH:mm:ss mmm dd yyy
    NSDateFormatter *formatNextTwo;                                   // yyyy/MM/dd
    NSDateFormatter *todayNextDayFormatter;                     // yyyyMMdd
    NSDateFormatter *formatFutureDate;                              // yyyy-MM-dd
    NSDateFormatter *dateTimeRequestResponseFormat;   // yyyy-MM-dd HH:mm:ss
    NSDateFormatter *shortDateFormatter;                          // MM/dd/yyyy

    NSString *pollFailCode;
    NSString *userAgentLT;
    int numFutureDaysVisitInformation;
}

@end

@implementation VisitsAndTracking 
NSString *const pollingCompleteWithChanges = @"pollingCompleteWithChanges";
NSString *const pollingFailed = @"pollingFailed";
int NUMBER_MIN_LATE_NOTIFICATION = -30;
int totalCoordinatesInSession;
//**************************************************************************
//*                                                                        *
//*           DATE FORMATTER GLOBALS                     *
//*                                                                        *
//**************************************************************************

-(void)         setupDateFormatters {
    oldFormatter = [[NSDateFormatter alloc] init];
    newFormatter = [[NSDateFormatter alloc] init];
    dateTimeRequestResponseFormat = [[NSDateFormatter alloc]init];
    formatFutureDate = [[NSDateFormatter alloc]init];
    shortDateFormatter = [[NSDateFormatter alloc]init];
    formatNextTwo = [[NSDateFormatter alloc]init];
    todayNextDayFormatter = [[NSDateFormatter alloc]init];
    arriveCompleteDateFormatter =[[NSDateFormatter alloc]init];
    timerFormat = [[NSDateFormatter alloc]init];
    
    [todayNextDayFormatter setDateFormat:@"yyyyMMdd"];
    [oldFormatter setDateFormat:@"HH:mm:ss" ]; // The old format
    [newFormatter setDateFormat:@"h:mm a"]; // The new format
    [formatFutureDate setDateFormat:@"yyyy-MM-dd"];
    [shortDateFormatter setDateFormat:@"MM/dd/yyyy"];
    [formatNextTwo setDateFormat:@"yyyy/MM/dd"];
    [arriveCompleteDateFormatter setDateFormat:@"HH:mm:ss MMM dd YYYY"];
    [dateTimeRequestResponseFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
}
-(NSDate*) getDateFromStringArriveComplete:(NSString*)stringDate {
    //"HH:mm:ss MMM dd yyyy"
    NSDate *date = [arriveCompleteDateFormatter dateFromString:stringDate];
    return date;
}
-(NSString*) getStringForDateArriveComplete:(NSDate*)date {
    //"HH:mm:ss MMM dd yyyy"
    return [arriveCompleteDateFormatter stringFromDate:date];
}
-(NSDate*) getDateRequestResponse:(NSString*)stringDate {
    // @"yyyy-MM-dd HH:mm:ss"
    NSDate *date =[dateTimeRequestResponseFormat dateFromString:stringDate];
    return date;
    
}
-(NSString *) getTimeShortString:(NSDate*)date {
    NSString *shortTimeString = [newFormatter stringFromDate:date];
    return shortTimeString;
}
-(NSString*)getStringFromDateRequestResponse:(NSDate*)date {
    // @"yyyy-MM-dd HH:mm:ss"
    return [dateTimeRequestResponseFormat stringFromDate:date];
}
-(NSString *) getArriveCompleteDataFormatter:(NSDate*) date {
    return [arriveCompleteDateFormatter stringFromDate:date];
}

//**************************************************************************
//*                                                                        *
//*           NETWORK REQUESTS WITH AF NETWORK LIB                         *
//*                                                                        *
//**************************************************************************

-(void) getCachedPetImages:(NSArray*)clientDataTemp {
        
    NSString *userName;
    NSString *password;
    NSMutableArray *cachedPetImages = [self localPetImagesList];
    NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
    
    if ([loginSettings objectForKey:@"username"] != NULL) {
        userName = [loginSettings objectForKey:@"username"];
    }
    if ([loginSettings objectForKey:@"password"]) {
        password = [loginSettings objectForKey:@"password"];
    }
    
    AFURLSessionManager *sessionMgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:sessionConfiguration];

    for (DataClient *clientProfile in clientDataTemp) {
        if([[clientProfile getPetInfo] count] > 0){
            for (PetProfile *petProfile in [clientProfile getPetInfo]) {
                NSString *petID = [petProfile  getPetID];
                NSString *nameOfImageFile = [NSString stringWithFormat:@"profile-%@-%@.png",clientProfile.clientID,petID];
                    BOOL imageCached = FALSE;
                    for (NSString *petIDForImage in cachedPetImages) {
                        if ([petIDForImage isEqualToString:nameOfImageFile]) {
                            imageCached = TRUE;
                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                  inDomain:NSUserDomainMask
                                                                                         appropriateForURL:nil
                                                                                                    create:NO
                                                                                                     error:nil];
                            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:nameOfImageFile];
                            NSData *petProfileImage = [NSData dataWithContentsOfURL:documentsDirectoryURL];
                            CGImageRef thumbnail = MyCreateThumbnailImageFromData(petProfileImage, 100);
                            UIImage *petImageJpeg = [UIImage imageWithCGImage:thumbnail];
                            CFRelease(thumbnail);
                            dispatch_queue_t mergeClientInfo = dispatch_queue_create("MergeClientInfo", NULL);
                            dispatch_async(mergeClientInfo, ^{
                                if (petProfileImage != nil) {
                                    [petProfile addProfileImage:petImageJpeg];
                                }
                            });
                        }
                    }
                    if (!imageCached) {
                        NSString *petImgReq = [NSString stringWithFormat:@"https://leashtime.com/pet-photo-sessionless.php?id=%@&loginid=%@&password=%@",petID,userName,password];
                        NSURL *urlRequest = [NSURL URLWithString:petImgReq];
                        NSURLRequest *request = [NSURLRequest requestWithURL:urlRequest];
                        
                        NSURLSessionDownloadTask *downloadTask =[sessionMgr downloadTaskWithRequest:request
                                                                                           progress:nil
                                                                                        destination:^NSURL * _Nonnull (NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                            
                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                  inDomain:NSUserDomainMask
                                                                                         appropriateForURL:nil
                                                                                                    create:YES
                                                                                                     error:nil];
                            return [documentsDirectoryURL URLByAppendingPathComponent:nameOfImageFile];
                            
                        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                            NSData *imageData = [NSData dataWithContentsOfURL:filePath];
                            dispatch_queue_t mergeClientInfo = dispatch_queue_create("MergeClientInfo", NULL);
                            dispatch_async(mergeClientInfo, ^{
                                if (imageData != nil) {
                                    CGImageRef thumbnail = MyCreateThumbnailImageFromData(imageData, 100);
                                    UIImage *petImageJpeg = [UIImage imageWithCGImage:thumbnail];
                                    CFRelease(thumbnail);
                                    [loginSettings setObject:@"cachedImage" forKey:nameOfImageFile];
                                    [petProfile addProfileImage:petImageJpeg];
                                }
                            });
                        }];
                        [downloadTask resume];
                    }
            }
        }
    }
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"updateTable" object:self];

}

-(void) sendPhotoViaAFNetwork:(NSURL*)filePathURL
                    imageData:(NSData*)imageData
          imageFileNameString:(NSString*)imageFileNameString
             forVisitDetails:(VisitDetails*)visitDetails {
    
    
    //NSLog(@"SENDING PHOTO VIA VISITS TRACKING SINGLETON from file path URL: %@", [filePathURL absoluteString]);
    //NSLog(@"Size of the data: %lul",[imageData length]);

    NSDictionary *creds = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
    NSString *username = [creds objectForKey:@"username"];
    NSString *pass = [creds objectForKey:@"password"];
    NSString *scriptName = @"https://leashtime.com/appointment-photo-upload.php";
    
    NSDictionary *parameters = @{@"loginid":  username,@"password": pass,@"appointmentid": visitDetails.appointmentid};
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:sessionConfig];
    AFHTTPResponseSerializer *serializerInstance = [AFHTTPResponseSerializer serializer];
    serializerInstance.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    manager.responseSerializer = serializerInstance;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:scriptName
                                                                                             parameters:parameters
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    
        [formData appendPartWithFileData:imageData
                                    name:@"image"
                                fileName:imageFileNameString
                                mimeType:@"image/png"];
    
        
    } error:nil];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
                
    }
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error) {
            [visitDetails setUploadStatusForPhoto:@"FAIL"];
            [visitDetails writeVisitDataToFile];
            NSLog(@"ERROR: %@", error);
            NSLog(@"-------------------XXX--------------------------------------------------------------");
            NSLog(@"-------------------XXX---IMAGE UPLOAD FAILURE %@ with upload status value: %@" , visitDetails.appointmentid, visitDetails.imageUploadStatus);
            NSLog(@"-------------------XXX--------------------------------------------------------------");
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateTable"
                                                               object:self];
            
        } else {
            
            if ([visitDetails.imageUploadStatus isEqualToString:@"FAIL"]) {
             
                [[NSNotificationCenter defaultCenter]postNotificationName:@"checkBadResend"
                                                                   object:self];
                NSLog(@"RESEND IS SUCCESSFUL");
                
            }
            [visitDetails setUploadStatusForPhoto:@"SUCCESS"];
            NSLog(@"PHOTO UPLOAD SUCCESS -- UPDATING THE PROGRESS VIEW");
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"photoFinishUpload"
                                                                   object:self];
            
            dispatch_queue_t myQueue = dispatch_queue_create("WritePhotoDetailFile", NULL);
            dispatch_async(myQueue, ^{
                [visitDetails writeVisitDataToFile];
            });
        }
    }];
    [uploadTask resume];
    
    
}

-(void) sendMapSnapshotViaAFNetwork:(NSURL*)filePathURL
                          imageData:(NSData*)imageData
                imageFileNameString:(NSString*)imageFileNameString
                    forVisitDetails:(VisitDetails*) visitDetails {

}

-(void) markVisitArriveOrComplete:(NSString*)visitStatus andAppointmentID:(NSString*)appointmentID {
    
}


-(NSString*) createVisitReportMoodButtons:(VisitDetails*) currentVisit {
    NSString *moodButton = @"buttons={";
    
    if(currentVisit.didPoo) {
        moodButton = [moodButton stringByAppendingString:@"\"poo\":\"yes\""];
    } else if (!currentVisit.didPoo) {
        moodButton = [moodButton stringByAppendingString:@"\"poo\":\"no\""];
    }
    if(currentVisit.didPee) {
        moodButton = [moodButton stringByAppendingString:@",\"pee\":\"yes\""];
    } else if (!currentVisit.didPee) {
        moodButton = [moodButton stringByAppendingString:@",\"poo\":\"no\""];
    }
    if(currentVisit.gaveTreat) {
        moodButton = [moodButton stringByAppendingString:@",\"treat\":\"yes\""];
    } else if (!currentVisit.gaveTreat) {
        moodButton = [moodButton stringByAppendingString:@",\"treat\":\"no\""];
    }
    if(currentVisit.gaveWater) {
        moodButton = [moodButton stringByAppendingString:@",\"water\":\"yes\""];
    } else if (!currentVisit.gaveWater) {
        moodButton = [moodButton stringByAppendingString:@",\"water\":\"no\""];
    }
    if(currentVisit.dryTowel) {
        moodButton = [moodButton stringByAppendingString:@",\"towel\":\"yes\""];
    } else if (!currentVisit.dryTowel) {
        moodButton = [moodButton stringByAppendingString:@",\"towel\":\"no\""];
    }
    if(currentVisit.gaveInjection) {
        moodButton = [moodButton stringByAppendingString:@",\"injection\":\"yes\""];
    } else if (!currentVisit.gaveInjection) {
        moodButton = [moodButton stringByAppendingString:@",\"injection\":\"no\""];
    }
    if(currentVisit.gaveMedication) {
        moodButton = [moodButton stringByAppendingString:@",\"medication\":\"yes\""];
    } else if (!currentVisit.gaveMedication) {
        moodButton = [moodButton stringByAppendingString:@",\"medication\":\"no\""];
    }
    if(currentVisit.didFeed) {
        moodButton = [moodButton stringByAppendingString:@",\"feed\":\"yes\""];
    } else if (!currentVisit.didFeed) {
        moodButton = [moodButton stringByAppendingString:@",\"feed\":\"no\""];
    }
    if(currentVisit.didPlay) {
        moodButton = [moodButton stringByAppendingString:@",\"play\":\"yes\""];
    } else if (!currentVisit.didPlay) {
        moodButton = [moodButton stringByAppendingString:@",\"play\":\"no\""];
    }
    
    NSString *closeMood = @"}";
    moodButton = [moodButton stringByAppendingString:closeMood];
    return moodButton;
    
}

-(void) transmitVisitReport:(NSData*)reportInfo {
    
    
}
-(void) sendVisitReport:(VisitDetails*) currentVisit {
    
    NSDate *rightNow = [NSDate date];
    NSString *dateTimeString = [self getTimeShortString:rightNow];
    currentVisit.dateTimeVisitReportSubmit = dateTimeString;
    NSString *moodButtons  =[self createVisitReportMoodButtons:currentVisit];

    //LocationShareModel *locationShare = [LocationShareModel sharedModel];
    //NSString *latSendNote = [NSString stringWithFormat:@"%f",locationShare.lastValidLocation.latitude];
    //NSString *lonSendNote = [NSString stringWithFormat:@"%f",locationShare.lastValidLocation.longitude];
    
    NSString *consolidatedVisitNote = [NSString stringWithFormat:@"[VISIT: %@] ",dateTimeString];
    if(![currentVisit.visitNoteBySitter isEqual:[NSNull null]] && [currentVisit.visitNoteBySitter length] > 0) {
        consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.visitNoteBySitter];
    }
    consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:@"  [MGR NOTE] "];
    if(![currentVisit.note isEqual:[NSNull null]] && [currentVisit.note length] > 0) {
        consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.note];
    }
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    /*NSUInteger numberOfMatches = [regex numberOfMatchesInString:consolidatedVisitNote
                                                        options:0
                                                          range:NSMakeRange(0, [consolidatedVisitNote length])];
    */
    NSString *modifiedNote = [regex stringByReplacingMatchesInString:consolidatedVisitNote
                                                               options:0
                                                                 range:NSMakeRange(0, [consolidatedVisitNote length])
                                                          withTemplate:@"\%26"];
        
    
    
    [currentVisit setMarkArriveCompleteStatus:@"visitReport" andStatus:@"SUCCESS"];
    
    NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
    NSString *username = [loginSetting objectForKey:@"username"];
    NSString *pass = [loginSetting objectForKey:@"password"];
    NSString *paramTemp = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&appointmentptr=%@&note=%@&%@",
                           username,pass,dateTimeString,currentVisit.appointmentid,modifiedNote,moodButtons];
    
    NSString *paramData = [paramTemp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSData *requestBodyData = [paramData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [self transmitVisitReport:requestBodyData];
    
    
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
     
     
     NSError *error = NULL;
     NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:&error];
     /*NSUInteger numberOfMatches = [regex numberOfMatchesInString:note
                                                         options:0
                                                           range:NSMakeRange(0, [note length])];
     */
     NSString *modifiedNote = [regex stringByReplacingMatchesInString:note
                                                                options:0
                                                                  range:NSMakeRange(0, [note length])
                                                           withTemplate:@"\%26"];
         
     if( _isReachable) {
         NSDate *rightNow = [NSDate date];
         NSString *dateTimeString = [dateTimeRequestResponseFormat stringFromDate:rightNow];
         NSUserDefaults *loginSetting = [NSUserDefaults standardUserDefaults];
         NSString *username = [loginSetting objectForKey:@"username"];
         NSString *pass = [loginSetting objectForKey:@"password"];
         NSString *paramTemp = [NSString stringWithFormat:@"loginid=%@&password=%@&datetime=%@&appointmentptr=%@&note=%@&%@",
                                username,pass,dateTimeString,appointmentID,modifiedNote,moodButtons];
         
         NSString *paramData = [paramTemp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
         NSData *requestBodyData = [paramData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
         NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBodyData length]];
         NSURL *urlLogin = [NSURL URLWithString:@"https://leashtime.com/native-visit-update.php"];
         
         NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
         [request setHTTPMethod:@"POST"];
         [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
         [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
         [request setTimeoutInterval:20.0];
         [request setValue:userAgentLT forHTTPHeaderField:@"User-Agent"];
         [request setHTTPBody:requestBodyData];
         
         //NSURLSessionConfiguration *urlConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
         //NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConfig];
         
         mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                    delegate:self
                                               delegateQueue:nil];
                      
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
                                                                        
                                                                   if ([responseDic isEqual:[NSNull null]]) {
                                                                       NSLog(@"No data in the response");
                                                                       
                                                                   }
                                                                   dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
                                                                   dispatch_async(myWrite, ^ {
                                                                       [currentVisit writeVisitDataToFile];
                                                                       [[NSNotificationCenter defaultCenter]postNotificationName:@"sentVisitReport"
                                                                                                                          object:self];
                                                                   });
                                                                   
                                                                   [currentVisit createMapSnapshot];
                                                               
                                                               } else {
                                                                   [currentVisit setMarkArriveCompleteStatus:@"visitReport" andStatus:@"FAIL"];
                                                                   dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
                                                                   dispatch_async(myWrite, ^ {
                                                                       [currentVisit writeVisitDataToFile];
                                                                       [[NSNotificationCenter defaultCenter]postNotificationName:@"sentVisitReport"
                                                                                                                          object:self];
                                                                   });
                                                                }
                                                           }];
         
         [postDataTask resume];
         [[NSURLCache sharedURLCache] removeAllCachedResponses];
         [mySession finishTasksAndInvalidate];
         
     } else {
         
         currentVisit.visitReportUploadStatus = @"FAIL";
         dispatch_queue_t myWrite = dispatch_queue_create("MyWrite", NULL);
         dispatch_async(myWrite, ^{
             [currentVisit writeVisitDataToFile];
         });
         
     }
}



-(void) networkRequest:(NSDate*)forDate
                toDate:(NSDate*)toDate
            pollUpdate:(NSString*)pollUpdate {
    
    sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.URLCache = [[NSURLCache alloc]initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    NSString *userName;
    NSString *password;
    
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
    NSDate *yesterday = [forDate dateBySubtractingDays:numFutureDaysVisitInformation];
    NSString *date_String=[formatFutureDate stringFromDate:yesterday];
    NSString *endDateString = [self stringForNextTwoWeeks:numFutureDaysVisitInformation fromDate:forDate];
        
    //NSDateFormatter * = [[NSDateFormatter alloc]init];
    
    if(!_firstLogin) {
        requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&firstLogin=1"
                         ,urlLoginStr,urlPassStr,date_String,endDateString];
    } else {
        requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@",urlLoginStr,urlPassStr,date_String,endDateString];
    }
    
    NSURL *urlLogin = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
    [request setTimeoutInterval:10.0];
    [request setValue:userAgentLT forHTTPHeaderField:@"User-Agent"];

    mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                              delegate:self
                                         delegateQueue:[NSOperationQueue mainQueue]];
    
    //mySession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *postDataTask = [mySession dataTaskWithRequest:request
                                                      completionHandler:^(NSData * _Nullable data,
                                                                          NSURLResponse * _Nullable responseDic,
                                                                          NSError * _Nullable error) {
                                                        
                                                          NSDictionary *errorDic = [error userInfo];
                                                          
                                                          NSString *errorCodeResponse = [self checkErrorCodes:data];
        
                                                          if(errorDic == NULL || error == NULL) {
                                                              if ([errorCodeResponse isEqualToString:@"OK"]) {
                                                                  NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                              options:
                                                                                               NSJSONReadingMutableContainers|
                                                                                               NSJSONReadingAllowFragments|
                                                                                               NSJSONWritingPrettyPrinted|
                                                                                               NSJSONReadingMutableLeaves
                                                                                                                                error:&error];
                                                                  
                                                                  if (responseDic != NULL) {
                                                                      //NSLog(@"POLL UPDATE NETWORK REQUEST, %@", responseDic);
                                                                      [self parseDataResponsePolling:responseDic];
                                                                      
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
                                                              
                                                              else if ([errorCodeResponse isEqualToString:@"P"]) {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      [[NSNotificationCenter defaultCenter]
                                                                       postNotificationName:pollingFailed
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
    //[mySession finishTasksAndInvalidate];
}



/*-(void) networkRequest:(NSDate *)forDate toDate:(NSDate *)toDate isPolling:(BOOL)pollRequest {
    
    
}*/
-(void) networkRequest:(NSDate*)forDate
                toDate:(NSDate*)toDate {
    
    //NSString *loginString = [self createLoginString:forDate tilEndDate:toDate];
    
    NSString *userName;
    NSString *password;

    NSUserDefaults *loginSettings = [NSUserDefaults standardUserDefaults];
    
    if ([loginSettings objectForKey:@"username"] != NULL) {
        userName = [loginSettings objectForKey:@"username"];
    }
    if ([loginSettings objectForKey:@"password"]) {
        password = [loginSettings objectForKey:@"password"];
    }
    
    NSString *urlLoginStr = [userName stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *urlPassStr = [password stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *dateBegin = [formatFutureDate stringFromDate:forDate];
    NSString *dateEnd = [formatFutureDate stringFromDate:toDate];

    NSString *urlString = @"https://leashtime.com/native-prov-multiday-list.php";
    NSDictionary *parameters = @{@"loginid":urlLoginStr,
                                 @"password":urlPassStr,
                                 @"start":dateBegin,
                                 @"end":dateEnd,
                                 @"firstLogin":@"1",
                                 @"clientdocs":@"complete"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments|
                                  NSJSONReadingMutableLeaves|
                                  NSJSONReadingMutableContainers];
    
    [manager GET:urlString
      parameters:parameters
         headers:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableDictionary *responseData =[[NSMutableDictionary alloc]init];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            responseData  = (NSMutableDictionary*)responseObject;
            [[VisitsAndTracking sharedInstance]parseDataResponseMulti:responseData];
            [[VisitsAndTracking sharedInstance]updateCoordinateData];
        }

        
        if (![VisitsAndTracking sharedInstance].firstLogin) {
            [[VisitsAndTracking sharedInstance]loginSuccessBlock];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
    }];
    /*
    if(!_firstLogin) {
        requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&firstLogin=1&clientdocs=complete",urlLoginStr,urlPassStr,dateBegin,dateEnd];
    } else {
        requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&clientdocs=complete",urlLoginStr,urlPassStr,dateBegin,dateEnd];
    }

    

    NSURL *urlLogin = [NSURL URLWithString:loginString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc
     ]initWithURL:urlLogin];
    [request setTimeoutInterval:40.0];
    [request setValue:userAgentLT forHTTPHeaderField:@"User-Agent"];

    //mySession = [NSURLSession sharedSession];

    mySession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                              delegate:self
                                         delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *postDataTask = [mySession dataTaskWithRequest:request
                                                      completionHandler:^(NSData * _Nullable data,
                                                                          NSURLResponse * _Nullable responseDic,
                                                                          NSError * _Nullable error) {
                                                                  
       
                                                          NSString *errorCodeResponse = [[VisitsAndTracking sharedInstance] checkErrorCodes:data];
                                                          
                                                          if(error == nil) {
                                                              if (responseDic != NULL) {
                                                                  if ([errorCodeResponse isEqualToString:@"OK"]) {
                                                                      NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                   options:
                                                                                                    NSJSONReadingMutableContainers|
                                                                                                    NSJSONReadingAllowFragments|
                                                                                                    NSJSONReadingMutableLeaves
                                                                                                                                     error:&error];
                 
                                                                      [[VisitsAndTracking sharedInstance]parseDataResponseMulti:responseJSON];
                                                                      [[VisitsAndTracking sharedInstance]updateCoordinateData];
                                                                      
                                                                      if (![VisitsAndTracking sharedInstance].firstLogin) {
                                                                          [[VisitsAndTracking sharedInstance]loginSuccessBlock];
                                                                      }
                                                                  }  else {
                                                                      [[VisitsAndTracking sharedInstance] pollingFailedBroadcast];
                                                                  }
                                                              }
                                                              else if ([errorCodeResponse isEqualToString:@"T"]) {
                                                                  [[VisitsAndTracking sharedInstance] pollingSetTempPwd];
                                                              }
                                                              
                                                          } else {
                                                              [[VisitsAndTracking sharedInstance] pollingFailedBroadcast];
                                                          }
                                                      }];
    
    [postDataTask resume];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //[mySession finishTasksAndInvalidate];*/
    
    
    
}

-(void) markVisitUnarrive:(NSString*)visitID {
    
    BOOL foundVisitInQueue = NO;
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
        
        NSDateFormatter *formatterWindowUnarrive = [[NSDateFormatter alloc] init];
        [formatterWindowUnarrive setDateFormat:@"mm/dd/yyyy hh:mm:ss"];
        NSDate *rightNow2 = [NSDate date];
        NSString *dateString2 = [formatterWindowUnarrive stringFromDate:rightNow2];
         
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



-(void) unarriveNetwork:(NSDictionary*)sendDictionary {
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
    //[request setValue:_userAgentLT forHTTPHeaderField:@"User-Agent"];
    [request setValue:userAgentLT forHTTPHeaderField:@"User-Agent"];

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
            if ([errorCodeResponse isEqualToString:@"OK"]) {
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:
                                             NSJSONReadingMutableContainers|
                                             NSJSONReadingAllowFragments|
                                             NSJSONWritingPrettyPrinted|
                                             NSJSONReadingMutableLeaves
                                                                              error:&error];
                if ([responseDic isEqual:[NSNull null]]) {
                    NSLog(@"Response dic null: %@",responseDic);
                }
            }
        }
    }];
    
    
    
    [postDataTask resume];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [mySession finishTasksAndInvalidate];
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


-(NSString*) createLoginString:(NSDate*)startDate tilEndDate:(NSDate*)endDate {
    
    NSString *userName;
    NSString *password;

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

    
    NSString *dateBegin = [formatFutureDate stringFromDate:startDate];
    NSString *dateEnd = [formatFutureDate stringFromDate:endDate];

    if(!_firstLogin) {
        requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&firstLogin=1&clientdocs=complete",urlLoginStr,urlPassStr,dateBegin,dateEnd];
    } else {
        requestString = [NSString stringWithFormat:@"https://leashtime.com/native-prov-multiday-list.php?loginid=%@&password=%@&start=%@&end=%@&clientdocs=complete",urlLoginStr,urlPassStr,dateBegin,dateEnd];
    }
    
    return requestString;
}
-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    [session invalidateAndCancel];
    session = nil;
}
-(void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
    [session invalidateAndCancel];
    session = nil;
}
-(void) loginSuccessBlock {
    NSLog(@"LOGIN SUCCESS BLOCK");
    self.firstLogin = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loginSuccess" object:NULL];
    
}
-(void) pollingFailedBroadcast {
    NSString *_tmpPollingFailed = pollingFailed;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:_tmpPollingFailed object:nil];
    });
    
}
-(void) pollingSetTempPwd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"tempPassword"
         object:self];
    });
}

+(VisitsAndTracking *)sharedInstance {
    
    static VisitsAndTracking *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance =[[VisitsAndTracking alloc]init];
    });
    return _sharedInstance;
}

-(id) init {
    self = [super init];
    if (self) {
        
        //_userAgentLT = @"LEASHTIME V4.3/AUGUST 2019/IOS 12.4";
        
        _onSequence = @"000";
        _onSequenceArray = [[NSMutableArray alloc]init];
        _onWhichVisitID = NULL;
		_todayDate = [NSDate date];
        _showingWhichDate = _todayDate;        
        _clientData = [[NSMutableArray alloc]init];
        _visitData = [[NSMutableArray alloc]init];
        
        
        userAgentLT = @"LEASHTIME V5.0/JUNE 2021/IOS 13.X.X.";
        coordinatesForVisits = [[NSMutableDictionary alloc]init];
        numFutureDaysVisitInformation = 20;
		yesterdayVisits = [[NSMutableArray alloc]init];
		tomorrowVisits = [[NSMutableArray alloc]init];
        todaysVisits = [[NSMutableArray alloc]init];
         
        [self setupDateFormatters];
        [self setUpReachability];
        [self readSettings];

        
    }
    return self;
}


//**************************************************************************
//*                                                                        *
//*           PROCESS / PARSE NETWORK REESPONSES                           *
//*                                                                        *
//**************************************************************************
-(void) parseDataResponsePolling:(NSDictionary *)responseDic {
    //NSLog(@"[VT] PARSE RESPONSE FROM POLLING UPDATE");
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
                NSDate *evalVisitDate = [shortDateFormatter dateFromString:[visitDic objectForKey:@"shortDate"]];
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

-(void) parseDataResponseMulti:(NSDictionary *)responseDic {
    NSArray *visitsArray = [responseDic objectForKey:@"visits"];
    NSDictionary *clientsDic = [responseDic objectForKey:@"clients"];
    
    [self setUpFlags:[responseDic objectForKey:@"flags"]];
    [self readPreferencesDic:[responseDic objectForKey:@"preferences"]];

    NSString *dateString  = [shortDateFormatter stringFromDate:_todayDate];
        
    for(int i = 0; i < [todaysVisits count]; i++) {
        NSDictionary *visit = [todaysVisits objectAtIndex:i];
        visit = nil;
    }
    [todaysVisits removeAllObjects];
    
    if([[responseDic objectForKey:@"visits"]isKindOfClass:[NSArray class]]) {
        NSMutableArray *todayVisitArray = [[NSMutableArray alloc]init];    
        for(NSDictionary *visitDic in visitsArray) {
            
            NSString *shortDateString = [visitDic objectForKey:@"shortDate"];
            NSDate *evalVisitDate = [shortDateFormatter dateFromString:shortDateString];
                    
            NSTimeInterval timeDifference = [_todayDate timeIntervalSinceDate:evalVisitDate];
            double minutes = timeDifference / 60;
            double days = minutes / 1440;
            
            
            if (days > 0.0 && days < 1.0) {
                [todaysVisits addObject:visitDic];
            } 
            if ([[visitDic objectForKey:@"shortDate"] isEqualToString:dateString]) {
                [todayVisitArray addObject:visitDic];
            }
        }
        
        NSInteger payloadCount = [todayVisitArray count];
        NSInteger visitListCount = [_visitData count];
        
        NSMutableDictionary *visitDictionary = [[NSMutableDictionary alloc]init];
        [visitDictionary setObject:todayVisitArray forKey:@"visits"];
        [visitDictionary setObject:clientsDic forKey:@"clients"];
        NSDate *today = [NSDate date];
        
        if (payloadCount <= 0) {
            [self.visitData removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"noVisits" object:nil];
            });
        }
        else if (payloadCount > 0 && visitListCount <= 0 && _showingWhichDate == _todayDate) {
            [self setUpNewData:visitDictionary];
        }
        else if (_showingWhichDate != _todayDate) {
            [self setUpNewData:visitDictionary];
        }
        else if (payloadCount > 0 && visitListCount > 0) {
            [self setUpNewData:visitDictionary];
        }
        [self networkRequest:today toDate:today pollUpdate:@"append"];
    }
}

-(void) setUpNewData:(NSDictionary *)responseDic {
        
    if([responseDic objectForKey:@"clients"] != NULL) {
        NSDictionary *clientDic = [responseDic objectForKey:@"clients"];
        [self createClientData:clientDic];
    }
    
    if ([responseDic objectForKey:@"visits"] != NULL) {
        NSArray *visitsDic = [responseDic objectForKey:@"visits"];
        //NSLog(@"Visits Dic: %@", visitsDic);
        [self createVisitData:visitsDic dataNew:@"YES"];
    }
    
}

-(void) readPreferencesDic: (NSDictionary *)preferenceDic {
    
    if([[preferenceDic objectForKey:@"showDocAttachListView"]isEqualToString:@"YES"]) {
        self.showDocAttachListView = TRUE;
    } else {
        self.showDocAttachListView = TRUE;
    }
}

-(void) setupKeyInfoForClient:(DataClient*)clientKeyInfo withDataDic:(NSDictionary*) clientDictionary {
    
    if ([clientKeyInfo.hasKey isEqualToString:@"Yes"]) {
        clientKeyInfo.hasKey = @"Yes";
    } else if (clientKeyInfo.hasKey == NULL)  {
        clientKeyInfo.hasKey = @"No";
    }else  {
        clientKeyInfo.hasKey = @"No";
    }
    
    clientKeyInfo.keyID = [clientDictionary objectForKey:@"keyid"];
    
    if ([[clientDictionary objectForKey:@"nokeyrequired"]isEqualToString:@"1"]) {
        clientKeyInfo.noKeyRequired = YES;
    } else if ([clientDictionary objectForKey:@"nokeyrequired"] == NULL) {
        clientKeyInfo.noKeyRequired = NO;
    }else {
        clientKeyInfo.noKeyRequired = NO;
    }
    
    if ([[clientDictionary objectForKey:@"showkeydescriptionnotkeyid"]isEqualToString:@"Yes"]) {
        clientKeyInfo.useKeyDescriptionInstead = YES;
        clientKeyInfo.keyDescriptionText = [clientDictionary objectForKey:@"keydescription"];
    } else {
        clientKeyInfo.useKeyDescriptionInstead = NO;
        clientKeyInfo.keyDescriptionText = [clientDictionary objectForKey:@"keydescription"];
    }
    
}

-(void) createClientData:(NSDictionary *)clientDic {

    NSMutableArray *clientDataTemp = [[NSMutableArray alloc]init];
    
    for (NSString *clientIDNum in clientDic) {
        DataClient *clientProfile = [[DataClient alloc]init];
        NSDictionary *clientInformation  = [clientDic objectForKey:clientIDNum];
        [clientProfile createClientProfile:clientInformation];
        [self setupKeyInfoForClient:clientProfile withDataDic:clientInformation];
        [clientDataTemp addObject:clientProfile];
    }
        
    [self getCachedPetImages:clientDataTemp];

    @synchronized(self) {
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

-(NSMutableArray*) localPetImagesList {
    
    NSMutableArray *cacheImage = [[NSMutableArray alloc]init];
    
    NSArray *userDefaultKeys = [[[NSUserDefaults standardUserDefaults]dictionaryRepresentation]allKeys];
    NSArray *values = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]allValues];
       
    for (int i = 0; i < userDefaultKeys.count; i++) {
        if([[userDefaultKeys objectAtIndex:i]isKindOfClass:[NSString class]]) {
            NSString *keyValStr = (NSString*)[userDefaultKeys objectAtIndex:i];
            if ([[values objectAtIndex:i]isKindOfClass:[NSString class]]) {
                NSString *valStr = (NSString*)[values objectAtIndex:i];
                if([valStr isEqualToString:@"cachedImage"]) {
                    if (![keyValStr isEqual:[NSNull null]] && [keyValStr length] > 0 ) {
                        //NSLog(@"Key Val String: %@",keyValStr);
                        [cacheImage addObject:keyValStr];
                    }
                }
            }
        }
    }
    return cacheImage;
}

CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize) {
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
 
   myImageSource = CGImageSourceCreateWithData((CFDataRef)data,NULL);
   if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
   }
 
   thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);

    
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;
 
   myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,(const void **) myValues, 2,&kCFTypeDictionaryKeyCallBacks,& kCFTypeDictionaryValueCallBacks);
 
  myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,0,myOptions);

  CFRelease(thumbnailSize);
  CFRelease(myOptions);
  CFRelease(myImageSource);
 
   if (myThumbnailImage == NULL){
         fprintf(stderr, "Thumbnail image not created from image source.");
         return NULL;
   }
 
   return myThumbnailImage;
}

-(void) createVisitData:(NSArray *)visitsDic dataNew:(NSString*)dataNew {
    
    
    NSMutableArray *visitDataTemp = [[NSMutableArray alloc]init];
    [_onSequenceArray removeAllObjects];
    NSMutableDictionary *globalVisitInfo;
    
    if (visitsDic == NULL) {
        return;
    }
    int i = 100;    
    for (NSDictionary *key in visitsDic) {
        VisitDetails *detailsVisit = [[VisitDetails alloc]init];
        NSDictionary *visitInfo = key;
        detailsVisit.appointmentid = [visitInfo objectForKey:@"appointmentid"];
        detailsVisit.sequenceID = [NSString stringWithFormat:@"%i",i];
        detailsVisit.clientptr = [visitInfo valueForKey:@"clientptr"];
        detailsVisit.service = [visitInfo objectForKey:@"service"];
        detailsVisit.petName = [visitInfo objectForKey:@"petNames"];
        detailsVisit.latitude = [visitInfo objectForKey:@"lat"];
        detailsVisit.longitude = [visitInfo objectForKey:@"lon"];
        detailsVisit.status = [visitInfo objectForKey:@"status"];
        NSString *timeFrom = [visitInfo objectForKey:@"starttime"];
        NSString *timeTo = [visitInfo objectForKey:@"endtime"];
        NSDate *dateFrom = [oldFormatter dateFromString:timeFrom];
        NSDate *dateTo = [oldFormatter dateFromString:timeTo];
        NSString *newTimeFrom = [newFormatter stringFromDate:dateFrom];
        NSString *newTimeTo = [newFormatter stringFromDate:dateTo];
        detailsVisit.timeofday = [visitInfo objectForKey:@"timeofday"];
        detailsVisit.date = [visitInfo objectForKey:@"shortDate"];
        detailsVisit.starttime = newTimeFrom;
        detailsVisit.endtime = newTimeTo;
        detailsVisit.endDateTime = [visitInfo objectForKey:@"endDateTime"];
        detailsVisit.rawStartTime = [visitInfo objectForKey:@"starttime"];

        if((![[visitInfo objectForKey:@"arrived"]isEqual:[NSNull null]] )
           && ( [[visitInfo objectForKey:@"arrived"] length] != 0 )) {
            detailsVisit.arrived = [visitInfo objectForKey:@"arrived"];
            detailsVisit.dateTimeMarkArrive = [visitInfo objectForKey:@"arrived"];
        }
        if((![[visitInfo objectForKey:@"completed"]isEqual:[NSNull null]] )
           && ( [[visitInfo objectForKey:@"completed"] length] != 0 )) {
            detailsVisit.completed = [visitInfo objectForKey:@"completed"];
            detailsVisit.dateTimeMarkComplete = [visitInfo objectForKey:@"completed"];
        }
        if((![[visitInfo objectForKey:@"canceled"]isEqual:[NSNull null]] )
           && ( [[visitInfo objectForKey:@"canceled"] length] != 0 )) {
            detailsVisit.canceled = [visitInfo objectForKey:@"canceled"];
            detailsVisit.isCanceled = YES;
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
            
        if ([detailsVisit.status isEqualToString:@"arrived"]) {
            detailsVisit.hasArrived = YES;
            self.onWhichVisitID = detailsVisit.appointmentid;
            self.onSequence = detailsVisit.sequenceID;
            [_onSequenceArray addObject:detailsVisit];
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
            }
        }
        
        [self addPawPrintForVisits:(int)i forVisit:detailsVisit];
        [visitDataTemp addObject:detailsVisit];
        i++;
    }

        
    @synchronized (self) {
        for (VisitDetails *visitDetail in visitDataTemp) {
            [visitDetail syncVisitDetailFromFile];
            if ([visitDetail.status isEqualToString:@"arrived"] && [[globalVisitInfo objectForKey:@"status"]isEqualToString:@"completed"]) {
                if (visitDetail.completed == NULL) {
                    NSLog(@"CONFLICT MISMATCH WITH COMPLETED TIME");
                }
            }
        }
            
        
        NSMutableArray *sortedArrayTemp = [self sortVisitsByStatus:visitDataTemp];
        [self copyTempVisitArrayToVisitData:sortedArrayTemp];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:pollingCompleteWithChanges
         object:self];
        [sortedArrayTemp removeAllObjects];
    }
}

-(void)reconcileVisitStatusMistmatch:(VisitDetails*)visit withServerStatus:(NSString*)serverStatus {
    visit.status = serverStatus;    
}

-(void)copyTempVisitArrayToVisitData:(NSMutableArray*)tempArray {
    [_visitData removeAllObjects];

    for (VisitDetails *visitDetail in tempArray) { 
        [_visitData addObject:visitDetail];
    }
}

-(NSMutableArray*)sortVisitsByStatus:(NSArray*)currentVisitData {
    NSMutableArray *completedVisitArray = [[NSMutableArray alloc]init];
    NSMutableArray *arrivedVisitArray = [[NSMutableArray alloc]init];
    NSMutableArray *futureVisitArray = [[NSMutableArray alloc]init];
    NSMutableArray *visitReportArray = [[NSMutableArray alloc]init];
    
    for (VisitDetails *visitDetail in currentVisitData) {
        if ([visitDetail.status isEqualToString:@"completed"] && 
            [visitDetail.visitReportUploadStatus isEqualToString:@"SUCCESS"] && 
            ![visitDetail.dateTimeVisitReportSubmit isEqual:[NSNull null]]) { 
            
            [completedVisitArray addObject:visitDetail];
            
        } else if ([visitDetail.status isEqualToString:@"completed"] && 
                   ![visitDetail.visitNoteBySitter isEqual:[NSNull null]] &&
                   [visitDetail.dateTimeVisitReportSubmit isEqual:[NSNull null]] && 
                   ![visitDetail.visitReportUploadStatus isEqualToString:@"SUCCESS"]) {
            [visitReportArray addObject:visitDetail];
        } else if ([visitDetail.status isEqualToString:@"arrived"]) {
            [arrivedVisitArray addObject:visitDetail];
        } else {            
            [futureVisitArray addObject:visitDetail];
        }
    }
    
    NSMutableArray *sortedArray = [[NSMutableArray alloc]init];
    [sortedArray addObjectsFromArray:arrivedVisitArray];
    [sortedArray addObjectsFromArray:visitReportArray];
    [sortedArray addObjectsFromArray:futureVisitArray];    
    [sortedArray addObjectsFromArray:completedVisitArray];
    return sortedArray;
}

-(BOOL)checkReachabilityStatus {
    
    return TRUE;
    
}

-(void) setUpReachability {
    __block VisitsAndTracking *weakSelf = self;
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        
        if (status == -1 || status == 0) {

            weakSelf.isReachable = NO;
            weakSelf.isUnreachable = YES;
            weakSelf.isReachableViaWiFi = NO;
            weakSelf.isReachableViaWWAN = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"unreachable" object:nil];
        
        } else if (status == 1) {
 

            weakSelf.isReachable = YES;
            weakSelf.isUnreachable = NO;
            weakSelf.isReachableViaWiFi = NO;
            weakSelf.isReachableViaWWAN = YES;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reachable" object:nil];
            
        } else if (status == 2) {

            weakSelf.isReachable = YES;
            weakSelf.isUnreachable = NO;
            weakSelf.isReachableViaWiFi = YES;
            weakSelf.isReachableViaWWAN = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reachable" object:nil];
            
        }
    }];
}

-(void) setUpFlags:(NSArray*)flagArray {
    
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

-(void) addPawPrintForVisits:(int)pawprintID
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


//**************************************************************************
//*                                                                        *
//*           OTHER DATA ITEMS TO HANDLE                                   *
//*                                                                        *
//**************************************************************************

-(NSString *)checkErrorCodes:(NSData*)responseCode {
    
    NSString *receivedDataString = [[NSString alloc] initWithData:responseCode encoding:NSUTF8StringEncoding];
    if ([receivedDataString isEqualToString:@"U"]) {
        _pollingFailReasonCode = @"U";

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

-(void) updateCoordinateData {
    
    for (VisitDetails *visit in _visitData) {
        
        NSArray *coordinatesForVisitArray = [visit rebuildPointsForVisit];
	
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

-(void) getTodayVisits {
    
    //NSLog(@"Getting todays visits");
    NSMutableArray *sortedArrayTemp = [self sortVisitsByStatus:_visitData];
    [_visitData removeAllObjects];

    for (VisitDetails *visitDetail in sortedArrayTemp) {
        [_visitData addObject:visitDetail];
        dispatch_async(dispatch_get_main_queue(), ^{
            [visitDetail syncVisitDetailFromFile];
        });
        
    }
    [sortedArrayTemp removeAllObjects];
}
-(void) getNextPrevDay:(NSDate*)dateGet {
	
	NSString *todayDateString = [shortDateFormatter stringFromDate:_todayDate];
	NSString *getDateString = [shortDateFormatter stringFromDate:dateGet];

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
//-(void) updateArriveCompleteInTodayYesterdayTomorrow:(VisitDetails*)visitItem withStatus:(NSString*)status {
	
-(void) updateArriveCompleteInTodayYesterdayTomorrow:(VisitDetails *)visitItem withStatus:(NSString *)status {
    
	NSMutableDictionary *matchVisit;
	@synchronized(self) {
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
	}
	
	if([status isEqualToString:@"arrived"] && matchVisit != NULL) {
				
		[matchVisit setObject:visitItem.status forKey:@"status"];
		[matchVisit setObject:visitItem.arrived forKey:@"arrived"];
	}
	
	if([status isEqualToString:@"completed"]) {
		[matchVisit setObject:visitItem.status forKey:@"status"];
		//[matchVisit setObject:visitItem.completed forKey:@"completed"];
	}
}

-(void) addLocationForMultiArrive:(CLLocation*)point {

    //NSLog(@"Adding point for route multi location");
	if(_multiVisitArrive) {
		
		if(_onWhichVisitID != NULL && _onSequenceArray != NULL && point != NULL) {
			for(VisitDetails *onSequence in _onSequenceArray) {
				for(VisitDetails *visitInfo in _visitData) {
					if([visitInfo.sequenceID isEqualToString:onSequence.sequenceID]
					   && ![visitInfo.status isEqualToString:@"completed"]) {
                        //NSLog(@"VISITS TRACKING ADDING COORDINATE TO VISIT: %@", visitInfo.appointmentid);

						[visitInfo addPointForRouteUsingCLLocation:point];
					}
				}
			}
		}
	}
}
-(void) addLocationCoordinate:(CLLocation*)point {
    //NSLog(@"VISITS TRACKING ADDING SINGLE VISIT COORDINATE TO VISIT OBJECT");
    
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
	
    //NSLog(@"Acquiring visit coordinate array for visit with ID: %@", visitID);
	NSMutableArray *rebuildVisitPoints = [[NSMutableArray alloc]init];
	VisitDetails *currentVisit;
	
	for (VisitDetails *visitInfo in _visitData) {
		if ([visitID isEqualToString:visitInfo.appointmentid]) {
			currentVisit = visitInfo;
			NSArray *rawCoordinates = [[NSArray alloc]initWithArray:[visitInfo rebuildPointsForVisit]];
            //Wg(@"Raw coordinates from visit: %@", rawCoordinates);
			for (NSData *locationDic in rawCoordinates) {
                CLLocation *locationPoint = [NSKeyedUnarchiver unarchivedObjectOfClass:[CLLocation class] 
                                                                              fromData:locationDic 
                                                                                 error:nil];
				//CLLocation *locationPoint = [NSKeyedUnarchiver unarchiveObjectWithData:locationDic];
                [rebuildVisitPoints addObject:locationPoint];

			}
		}
	}

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"timestamp" ascending:YES];
	[rebuildVisitPoints sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	return rebuildVisitPoints;
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
    
    _showPetPicInCell = YES;
	
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
    _showTimer = YES;
	
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
    _multiVisitArrive = NO;
	
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

//**************************************************************************
//*                                                                        *
//*           SET UP AND BREAK DOWN                                        *
//*                                                                        *
//**************************************************************************

-(void)       logoutCleanup {
    
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
}
-(NSString *) tellDeviceType {
    
    return deviceType;
    
}
-(NSString *) getCurrentSystemVersion {
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = [currentDevice systemVersion];
    return systemVersion;
    
}
-(void)       logLowMem {
    
    NSUserDefaults *memWarning = [NSUserDefaults standardUserDefaults];    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd  HH:mm:ss";
    NSDate *date = [NSDate date]; 
    NSString *dateString = [dateFormatter stringFromDate:date];
    [memWarning setObject:@"Memory Warning"  forKey:dateString];
    
    
}
-(void)       logFailedUpload:(NSString *)uploadType
                   forVisitID:(NSString *)visitID {
    NSUserDefaults *memWarning = [NSUserDefaults standardUserDefaults];    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd  HH:mm:ss";
    NSDate *date = [NSDate date]; 
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *visitError = [NSString stringWithFormat:@"%@-%@", uploadType, visitID];
    [memWarning setObject:visitError  forKey:dateString];
}
-(NSDictionary*)getColorPalette {
 
    NSString *pListData = [[NSBundle mainBundle]pathForResource:@"ColorPalette" ofType:@"plist"];
    NSMutableArray *colorPalette = [[NSMutableArray alloc]initWithContentsOfFile:pListData];
    
    NSMutableDictionary *returnableColorPalette = [[NSMutableDictionary alloc]init];
    
    for (NSDictionary *colorDic in colorPalette) {
        
        NSNumber* rValue = (NSNumber*)[colorDic objectForKey:@"R"];
        NSNumber* gValue = (NSNumber*)[colorDic objectForKey:@"G"];
        NSNumber* bValue = (NSNumber*)[colorDic objectForKey:@"B"];

        if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-success"]) {
            
            UIColor *cellSuccess = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellSuccess forKey:@"success"];
       
        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-success-dark"]) {
            
            UIColor *cellSuccessDark = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellSuccessDark forKey:@"successDark"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-info"]) {
            
            UIColor *cellInfo = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellInfo forKey:@"info"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-info-dark"]) {
            
            UIColor *cellInfoDark = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellInfoDark forKey:@"infoDark"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-danger"]) {
            
            UIColor *cellDanger = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellDanger forKey:@"danger"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-danger-dark"]) {
            
            UIColor *cellDangerDark = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellDangerDark forKey:@"dangerDark"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-warning"]) {
            
            UIColor *cellWarning= [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellWarning forKey:@"warning"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-warning-dark"]) {
            
            UIColor *cellWarningDark = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellWarningDark forKey:@"warningDark"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-default"]) {
            
            UIColor *cellDefault = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellDefault forKey:@"default"];

        }
        else  if ([[colorDic objectForKey:@"name"]isEqualToString:@"cell-mdefault-dark"]) {
            
            UIColor *cellMDefaultDark = [UIColor colorWithRed:[rValue floatValue]/256 green:[gValue floatValue]/256 blue:[bValue floatValue]/256 alpha:1.0];
            [returnableColorPalette setObject:cellMDefaultDark forKey:@"defaultDark"];

        }
    }
    return returnableColorPalette;
}
-(void)         backgroundClean {

}
-(NSString*)    getUserAgent {
    
    return userAgentLT;
}
-(void)         setUserAgent:(NSString*) userAgentInfoString {
    
    userAgentLT = userAgentInfoString;
}


-(NSString *) stringForNextTwoWeeks:(int)numDays fromDate:(NSDate*)startDate {
    

    NSCalendar *newCalendar = [NSCalendar currentCalendar];
    NSDate *twoWeeksFrom = [newCalendar dateByAddingUnit:NSCalendarUnitDay
                                     value:numDays
                                    toDate:startDate
                                   options:kNilOptions];
    NSString *twoWeeksFromString = [formatNextTwo stringFromDate:twoWeeksFrom];
    
    return twoWeeksFromString;
    
}

-(NSString *) stringForPrevTwoWeeks:(int)numDays fromDate:(NSDate *)startDate {
    
    NSDate *tomorrow = [startDate dateByAddingDays:1];
    NSDate *yesterday = [tomorrow dateBySubtractingDays:numDays];
    NSString *twoWeeksString = [formatNextTwo stringFromDate:yesterday];
    return twoWeeksString;
    
}

-(NSString *) stringForYesterday:(int)numDays {

    NSDate *now = [NSDate date];
    NSDate *yesterday = [now dateByAddingDays:numDays];
    NSString *dateString = [todayNextDayFormatter stringFromDate:yesterday];
    return dateString;
}

-(NSString *) stringForCurrentDay {
    
    NSDate *now = [NSDate date];
    NSString *dateString = [todayNextDayFormatter stringFromDate:now];
    return dateString;
}

-(NSString*)  formatTime:(NSString*)theTimeString {
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

-(void)       shouldStartLocationTracker {
    
    bool isOnArriveVisit = FALSE;

    for(VisitDetails *visit in _visitData) {
        if([visit.status isEqualToString:@"arrived"]) {
            isOnArriveVisit = TRUE;
            NSLog(@"There is an arrived visit status");
        }
    }
    LocationTracker *location = [LocationTracker sharedLocationManager];

    if (isOnArriveVisit) {
        if  (!location.isLocationTracking) {
            [location startLocationTracking];
            //NSLog(@"IS ON ARRIVE VISIT starting location tracker");
        } else {
            //NSLog(@"IS ON ARRIVE VISIT Location tracker is already tracking");
        }
    } else {
        //NSLog(@"NOT ON ARRIVE VISIT The location tracker status not changed");
    }
}

-(void)       optimizeRoute {
        //DistanceMatrix *distanceMatrix = [[DistanceMatrix alloc]initWithVisitData:self.visitData];
}

@end


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



