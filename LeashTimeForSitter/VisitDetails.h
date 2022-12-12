//
//  VisitDetails.h
//  LeashTimeSitter
//
//  Created by Ted Hooban on 7/11/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> 


@interface VisitDetails : NSObject {
}

//@property (nonatomic) NSMutableArray *docItems;

@property (nonatomic) NSString *currentArriveVisitStatus;
@property (nonatomic) NSString *currentCompleteVisitStatus;
@property (nonatomic) NSString *imageUploadStatus;
@property (nonatomic) NSString *mapSnapUploadStatus;
@property (nonatomic) NSString *mapSnapTakeStatus;
@property (nonatomic) NSString *visitReportUploadStatus;
@property (nonatomic) NSString *photoSentDate;
@property (nonatomic) NSString *mapSentDate;
@property (nonatomic) NSString *sentCoordinatesStatus;

// Visit actions

@property (nonatomic) UIImage *pawPrintForSession;
@property (nonatomic,copy) NSMutableArray *routePoints;

@property (nonatomic,copy) NSDate *NSDateMarkArrive;
@property (nonatomic,copy) NSDate *NSDateMarkComplete;
@property (nonatomic,copy) NSString *dateTimeMarkArrive;
@property (nonatomic,copy) NSString *dateTimeMarkComplete;
@property (nonatomic,copy) NSString *dateTimeVisitReportSubmit;
@property (nonatomic,copy) NSString *dateTimeFinishVisitReport;
@property (nonatomic) NSString *starttime;
@property (nonatomic) NSString *endtime;
@property (nonatomic,copy) NSString *endDateTime;
@property (nonatomic,copy) NSString *rawStartTime;
@property NSString *arrived;
@property NSString *completed;
@property NSString *canceled;


@property (nonatomic,copy) NSString *visitNoteBySitter;
@property (nonatomic,copy) NSString *coordinateLatitudeMarkArrive;
@property (nonatomic,copy) NSString *coordinateLongitudeMarkArrive;
@property (nonatomic,copy) NSString *coordinateLatitudeMarkComplete;
@property (nonatomic,copy) NSString *coordinateLongitudeMarkComplete;

// Visit Details
@property (nonatomic) NSString *appointmentid;
@property (nonatomic) NSString *clientptr;
@property (nonatomic) NSString *providerptr;
@property (nonatomic) NSString *service;
@property (nonatomic) NSString *date;

@property (nonatomic) NSString *timeofday;
@property (nonatomic,copy) NSString *note;
@property (nonatomic,copy) NSString *clientname;
@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;
@property (nonatomic,copy) NSString *petName;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSString *sequenceID;
@property NSString *keyID;
@property NSString *keyDescriptionText;

// Client Details

@property (nonatomic,copy) NSString *homeAddress;
@property (nonatomic,copy) NSString *clientEmail;
@property (nonatomic,copy) NSString *street1;


//@property (nonatomic) UIImage *mapSnapShotImage;
//@property (nonatomic) NSString *mapSnapShotFilename;
//@property (nonatomic,copy) NSString *petImageFile;
//@property (nonatomic) UIImage *currentPetImage;
/*@property (nonatomic,copy) NSString *petBreed;
@property (nonatomic,copy) NSString *petAge;
@property (nonatomic,copy) NSString *petNotes;
@property (nonatomic,copy) NSString *petGender;
@property (nonatomic,copy) NSString *alarmCompany;
@property (nonatomic,copy) NSString *alarmCompanyPhone;
@property (nonatomic,copy) NSString *alarmInfo;
@property (nonatomic,copy) NSString *alarmCodeOn;
@property (nonatomic,copy) NSString *alarmCodeOff;
@property (nonatomic,copy) NSString *veterinaryPhone;
@property (nonatomic,copy) NSString *veterinaryClinic;
@property (nonatomic,copy) NSString *vetName;
@property (nonatomic,copy) NSString *clientPhone;
@property (nonatomic,copy) NSString *clientPhone2;
@property (nonatomic,copy) NSString *clientEmail2;
@property (nonatomic,copy) NSString *street2;
@property (nonatomic,copy) NSString *zip;
@property (nonatomic,copy) NSString *city;
@property (nonatomic,copy) NSString *garageGateCode;
@property (nonatomic,copy) NSString *clientNote;
@property (nonatomic,copy) NSString *petNote1;
@property (nonatomic,copy) NSString *petNote2;
@property (nonatomic,copy) NSString *petNote3;
*/


@property BOOL errataDataDoc;
@property BOOL highpriority;
@property BOOL pendingChange;
@property BOOL noKeyRequired;
@property BOOL hasKey;
@property BOOL useKeyDescriptionInstead;
@property BOOL hasArrived;
@property BOOL isCanceled;
@property BOOL isComplete;
@property BOOL inProcess;
@property BOOL isLate;
@property BOOL cancelationPending;
@property BOOL didPoo;
@property BOOL didPee;
@property BOOL gaveTreat;
@property BOOL gaveWater;
@property BOOL dryTowel;
@property BOOL gaveInjection;
@property BOOL gaveMedication;
@property BOOL didFeed;
@property BOOL didPlay;

-(void)addVisitNoteToVisit:(NSString*)visitNote;

-(void)markArrive:(NSString *)timeMarkArrive
         latitude:(NSString *)coordinateLatitudeMarkArrive
        longitude:(NSString *)coordinateLongitudeMarkArrive;

-(void)markComplete:(NSString *)timeMarkComplete
           latitude:(NSString *)coordinateLatitudeMarkComplete
          longitude:(NSString*)coordinateLongitudeMarkComplete;

-(void) setMarkArriveCompleteStatus:(NSString*)type andStatus:(NSString*)status;

-(void) addImageForPet:(UIImage*)petImage;

-(void) resendImageForPet;

-(void) setUploadStatusForPhoto:(NSString*)status;

-(void) createMapSnapshot;

-(void) resendMapSnapShot;

-(void) addMapsnapShotImageToVisit:(UIImage*) mapImg;

-(void) setUploadStatusForMap:(NSString*)status;

-(void) writeVisitDataToFile;

-(void) syncVisitDetailFromFile;

-(void) addPointForRouteUsingCLLocation:(CLLocation*)location;

-(NSArray*) rebuildPointsForVisit;

-(NSMutableDictionary*)getMyVisitDetails:(NSString *)visitID;

-(NSArray*) getPointForRoutes;
-(NSArray*) getErrataDocItems;
-(NSArray*) getPetPhotos;
-(UIImage*) getPetPhoto;
-(UIImage*)getMapImage;
-(BOOL) isPetImage;
-(BOOL)isMapSnapShotImage;


@end

