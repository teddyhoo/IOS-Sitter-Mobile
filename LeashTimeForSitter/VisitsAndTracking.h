//
//  VisitsAndTracking.h
//  LeashTimeSitter
//
//  Created by Ted Hooban on 8/13/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "LocationTracker.h"
#import "LocationShareModel.h"
#import "Reachability.h"
#import "VisitDetails.h"

@interface VisitsAndTracking : NSObject <CLLocationManagerDelegate, NSURLSessionDelegate> {
    
    //NSMutableData *_responseData;
    NSString *deviceType;
    NSMutableDictionary *coordinatesForVisits;
    
}

+(VisitsAndTracking *)sharedInstance;

extern NSString *const pollingCompleteWithChanges;
extern NSString *const pollingFailed;

@property (strong,nonatomic) LocationTracker * locationTracker;
@property (nonatomic,strong) NSMutableArray *clientData;
@property (nonatomic,strong) NSMutableArray *visitData;
@property (nonatomic,strong) NSMutableArray *flagTable;

//@property (nonatomic,strong) NSString *userAgentLT;
@property NSString *pollingFailReasonCode;
@property(nonatomic,copy)NSString *onWhichVisitID;
@property(nonatomic,copy)NSString *onSequence;
@property(nonatomic,strong)NSMutableArray *onSequenceArray;
@property(nonatomic,strong)NSDate *todayDate;
@property(nonatomic,strong)NSDate *showingWhichDate;
@property(nonatomic,strong)LocationShareModel* shareLocationManager;



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
//@property int numFutureDaysVisitInformation;
@property double numMinutesEarlyArrive;

-(NSDate*) getDateFromStringArriveComplete:(NSString*)stringDate;
-(NSString*) getStringForDateArriveComplete:(NSDate*)date;
-(NSDate*) getDateRequestResponse:(NSString*)stringDate;
-(NSString*)getStringFromDateRequestResponse:(NSDate*)date;
-(NSString *) getTimeShortString:(NSDate*)date;


-(NSString *) getArriveCompleteDataFormatter:(NSDate*) date;
//-(NSString*) getyyyyMMdd:(NSDate*)date;
//-(NSString*) get_yyyy_MM_dd:(NSDate*)date;
//-(NSString*) get_MM__dd__yyyy:(NSDate*) date;
-(NSString*) get_yyyyMMddHHmmss:(NSDate*) date;
-(NSString*) get_HH_mm_ss:(NSDate*)date;
-(NSString*) get_h_mm_a:(NSDate*)date;
-(NSString*)  get__yyyy__MM__dd:(NSDate*)date;


-(void)networkRequest:(NSDate*)forDate toDate:(NSDate*)toDate;
-(void)networkRequest:(NSDate *)forDate toDate:(NSDate *)toDate pollRequest:(NSString*)pollingRequest;

-(void) getTodayVisits;
-(void)getNextPrevDay:(NSDate*)dateGet;
-(NSMutableArray*) sortVisitsByStatus:(NSArray*)currentVisitData;
-(void) copyTempVisitArrayToVisitData:(NSMutableArray*)tempArray;
-(void) updateArriveCompleteInTodayYesterdayTomorrow:(VisitDetails*)visitItem withStatus:(NSString*)status; 
-(void) addLocationForMultiArrive:(CLLocation*)location;
-(void) addLocationCoordinate:(CLLocation*)location;
-(NSArray*) getCoordinatesForVisit:(NSString*)visitID;

-(void) readSettings;
-(NSString*) getUserAgent;
-(void)setUserAgent:(NSString*) userAgentInfoString;
-(NSMutableDictionary*)getColorPalette;
-(void) changePollingFrequency:(NSNumber*)changePollingFrequencyTo;
-(void) turnOffGPSTracking;
-(void) changeDistanceFilter:(NSNumber*)changeDistanceFilterTo;
-(void)setDeviceType:(NSString*)typeDev;
-(NSString*)tellDeviceType;
-(void) logoutCleanup; 
-(void) backgroundClean;
-(void) logLowMem;
-(void) logFailedUpload:(NSString*)uploadType forVisitID:(NSString*)visitID;

CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize);

-(BOOL) checkForBadResendBeforeSync;
-(BOOL) checkReachability;
-(void) sendVisitReport:(VisitDetails*)visit;
-(void) sendMarkArriveOrComplete:(VisitDetails*)visitInfo status:(NSString*)arriveOrComplete;
-(void) sendPhotoOrMapImage:(UIImage*)imageFile fullPathFileName:(NSString*)filenameString;
-(void) markVisitUnarrive:(NSString*)visitID;
-(void) changeTempPassword:(NSString*)currentTemp loginID:(NSString*)loginID newPass:(NSString*)newPass;
-(void) sendVisitNote:(NSString*)consolidatedVisitNote moods:(NSString*)moodButtons latitude:(NSString*)currentLatitude longitude:(NSString*)curentLongitude markArrive:(NSString*)arriveTime markComplete:(NSString*)completeTime forAppointmentID:(NSString*)appointmentID;

-(void) sendPhotoViaAFNetwork:(NSURL*)filePathURL
                    imageData:(NSData*)imageData
          imageFileNameString:(NSString*)imageFileNameString
              forVisitDetails:(VisitDetails*)visitDetails;

//-(void) optimizeRoute;

/*
@property (nonatomic,weak) NSString *pollingFailReasonCode;
@property(nonatomic,weak)NSString *onWhichVisitID;
@property(nonatomic,weak)NSString *onSequence;
@property(nonatomic,weak)NSMutableArray *onSequenceArray;
@property(nonatomic,weak)NSDate *todayDate;
@property(nonatomic,weak)NSDate *showingWhichDate;
@property(nonatomic,weak)LocationShareModel* shareLocationManager;
@property (nonatomic,weak) LocationTracker * locationTracker;
@property (nonatomic,weak) NSMutableArray *clientData;
@property (nonatomic,weak) NSMutableArray *visitData;
@property (nonatomic,weak) NSMutableArray *flagTable;
*/


@end
