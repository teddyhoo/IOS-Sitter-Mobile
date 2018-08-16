//
//  VisitsAndTracking.h
//  LeashTimeSitter
//
//  Created by Ted Hooban on 8/13/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTracker.h"
#import "LocationShareModel.h"
#import "Reachability.h"
#import "VisitDetails.h"
#define kHOSTNAME @"leashtime.com"
#define kHOSTNAMEALT @"https://leashtime.com"

@interface VisitsAndTracking : NSObject <CLLocationManagerDelegate, NSURLSessionDelegate> {
    
    NSMutableData *_responseData;
    NSString *deviceType;
    NSMutableDictionary *coordinatesForVisits;
    
}

+(VisitsAndTracking *)sharedInstance;

extern NSString *const pollingCompleteWithChanges;
extern NSString *const pollingFailed;

@property (nonatomic,strong) NSString *userAgentLT;
@property NSString *pollingFailReasonCode;

@property(nonatomic,copy)NSString *onWhichVisitID;
@property(nonatomic,copy)NSString *onSequence;
@property(nonatomic,strong)NSMutableArray *onSequenceArray;
@property(nonatomic,strong)NSDate *todayDate;
@property(nonatomic,strong)NSDate *showingWhichDate;
@property(nonatomic,strong)LocationShareModel* shareLocationManager;
@property (strong,nonatomic) LocationTracker * locationTracker;
@property (nonatomic,strong) NSMutableArray *arrivalCompleteQueueItems;
@property (nonatomic,strong) NSMutableArray *clientData;
@property (nonatomic,strong) NSMutableArray *visitData;
@property (nonatomic,strong) NSMutableArray *flagTable;
@property (nonatomic,strong) NSMutableArray *cachedPetImages;
@property (nonatomic,strong) NSMutableArray *localNotificationQueue;
@property (nonatomic,strong) NSFileManager *fileManager;
@property (nonatomic,strong) NSMutableArray *lastRequest;

@property BOOL appRunningBackground;
@property BOOL firstLogin;
@property BOOL isReachable;
@property BOOL isUnreachable;
@property BOOL isReachableViaWWAN;
@property BOOL isReachableViaWiFi;
@property BOOL showHeaderDiagnostic;
@property BOOL showReachabilityIcon;
@property BOOL userTracking;
@property BOOL showKeyIcon;
@property BOOL showPetPicInCell;
@property BOOL showFlags;
@property BOOL showTimer;
@property BOOL showClientName;
@property BOOL regionMonitor;
@property BOOL multiVisitArrive;
@property BOOL showDocAttachListView;
@property int pollingFrequency;
@property int distanceSettingForGPS;
@property int minimumGPSAccuracy;
@property int updateFrequencySeconds;
@property int minNumCoordinatesSend;
@property float regionRadius;
@property float checkWeatherFrequency;
@property int numFutureDaysVisitInformation;
@property double numMinutesEarlyArrive;


-(void)setDeviceType:(NSString*)typeDev;
-(NSString*)tellDeviceType;
-(NSMutableArray *)getTodayVisits;
-(NSArray*)getCoordinatesForVisit:(NSString*)visitID;
-(void)getNextPrevDay:(NSDate*)dateGet;
-(void)foregroundBadRequest;
-(void)networkRequest:(NSDate*)forDate toDate:(NSDate*)toDate;

-(void) changeTempPassword:(NSString*)currentTemp loginID:(NSString*)loginID newPass:(NSString*)newPass;

-(void) sendVisitNote:(NSString*)note
               moods:(NSString*)moodButtons
            latitude:(NSString*)currentLatitude
           longitude:(NSString*)currentLongitude
          markArrive:(NSString*)arriveTime
        markComplete:(NSString*)completionTime
    forAppointmentID:(NSString*)appointmentID;


-(void) addLocationCoordinate:(CLLocation*)point;
-(void) addPictureForPet:(UIImage*)petPicture;
-(void) updateArriveCompleteInTodayYesterdayTomorrow:(VisitDetails*)visitItem withStatus:(NSString*)status; 
-(void) addLocationForMultiArrive:(CLLocation*)location;
-(void) logoutCleanup; 
-(void) resendAllCoordinatesToServer:(NSString*)visitID;
-(void) markVisitUnarrive:(NSString*)visitID;
-(void) optimizeRoute;
-(void) changePollingFrequency:(NSNumber*)changePollingFrequencyTo;
-(void) turnOffGPSTracking;
-(void) changeDistanceFilter:(NSNumber*)changeDistanceFilterTo;
-(void) readSettings;


@end
