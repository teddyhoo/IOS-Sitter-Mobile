//
//  LocationTracker.h
//  Location

//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"

@interface LocationTracker : NSObject <CLLocationManagerDelegate, NSURLSessionDelegate>

@property (strong,nonatomic) LocationShareModel *shareModel;
@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationDistance distanceFilterSetting;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property (strong,nonatomic) CLLocationManager *locationManager;

@property float regionRadius;
@property float updateFrequencySeconds;
@property float minAccuracy;
@property float minNumCoordinatesBeforeSend;
@property BOOL regionMonitoringSetupForDay;
@property BOOL isLocationTracking;
@property (nonatomic) NSTimer* locationUpdateTimer;


+ (instancetype)sharedLocationManager;
- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)restartLocationUpdates;
@end
