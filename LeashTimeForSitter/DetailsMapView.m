//
//  DetailsMapView.m
//  LeashTimeForSitter
//
//  Created by Ted Hooban on 12/8/15.
//  Copyright © 2015 Ted Hooban. All rights reserved.
//

#import "DetailsMapView.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"
#import "VisitAnnotation.h"
#import "VisitAnnotationView.h"
#import "LocationShareModel.h"
#import "PawPrintAnnotation.h"
#import "PawPrintAnnotationView.h"
#import "UIImage+Resize.h"
#import "LocationTracker.h"

#define KM_TO_MILES 0.621371
#define SECONDS 60


@implementation DetailsMapView {
    VisitsAndTracking *sharedVisitsTracking;
    LocationShareModel *sharedLocationModel;
    CLLocationCoordinate2D currentLocation;
    CLLocationCoordinate2D clientHomeLocation;
    CLGeocoder *geocodeAddress;
    MKDirectionsResponse *responseForRoute;
	BOOL isIphone4;
	BOOL isIphone5;
	BOOL isIphone6;
	BOOL isIphone6P;
	BOOL mapOnScreen;
	UIView *directionsView;
	UIScrollView *directionsScrollView;
	UIButton *removeDirectionsView;
	UIButton *getDirectionsButton;
}

-(instancetype) initWithFrame:(CGRect)frame {
    
    if (self=[super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
		self.backgroundColor = [UIColor whiteColor];
		VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
		NSString *theDeviceType = [sharedVisits tellDeviceType];
		
		if ([theDeviceType isEqualToString:@"iPhone6P"]) {
			isIphone6P = YES;
			isIphone6 = NO;
			isIphone5 = NO;
			isIphone4 = NO;
			
		} else if ([theDeviceType isEqualToString:@"iPhone6"]) {
			isIphone6P = NO;
			
			isIphone6 = YES;
			isIphone5 = NO;
			isIphone4 = NO;
			
		} else if ([theDeviceType isEqualToString:@"iPhone5"]) {
			isIphone5 = YES;
			isIphone4 = NO;
			isIphone6P = NO;
			isIphone6 = NO;
			
		} else {
			isIphone4 = YES;
			isIphone5 = NO;
			isIphone6P = NO;
			isIphone6 = NO;
		}
		
		_myMapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		_myMapView.mapType = MKMapTypeStandard;
		[_myMapView setDelegate:self];
		[self addSubview:_myMapView];
        
    }
    
    return self;
    
}
-(instancetype)initWithClientLocation:(CLLocationCoordinate2D)clientLoc
                          vetLocation:(CLLocationCoordinate2D)vetLoc
                            withFrame:(CGRect)frame {
    
    self = [self initWithFrame:frame];
    
    _onScreen = NO;
    
    LocationShareModel *sharedModel = [LocationShareModel sharedModel];
    
    currentLocation = sharedModel.lastValidLocation;
    clientHomeLocation = clientLoc;
    
    
    if ((clientHomeLocation.latitude != -9999.0) &&
        (clientHomeLocation.longitude != -9999.0) &&
        (clientHomeLocation.latitude != 0.0) &&
        (clientHomeLocation.longitude != 0.0)) {
        
        [self zoomToVisitLocation:clientHomeLocation];

        VisitAnnotation *startAnnotation = [[VisitAnnotation alloc]init];
        startAnnotation.coordinate = currentLocation;
        startAnnotation.title = @"Current Location";
        startAnnotation.typeOfAnnotation = SitterLocation;
        startAnnotation.subtitle = @"You are Here";
        [_myMapView addAnnotation:startAnnotation];
        
        
        VisitAnnotation *clientAnnotation = [[VisitAnnotation alloc]init];
        clientAnnotation.coordinate = clientHomeLocation;
        clientAnnotation.title = @"Client Home";
        clientAnnotation.typeOfAnnotation = ClientLocation;
        clientAnnotation.type =
        clientAnnotation.subtitle = @"Client Home";
        [_myMapView addAnnotation:clientAnnotation];
        
        
        getDirectionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        getDirectionsButton.frame = CGRectMake(0, 0, 300,30);
        [getDirectionsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        getDirectionsButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:24];
        [getDirectionsButton setTitle:@"DIRECTIONS" forState:UIControlStateNormal];
        [getDirectionsButton addTarget:self action:@selector(getDirections:) forControlEvents:UIControlEventTouchUpInside];
        
        [_myMapView addSubview:getDirectionsButton];

    }

    return self;
}


-(void)getDirections:(id)sender {
    
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *directionsButton = (UIButton*)sender;
        [directionsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [directionsButton setTitle:@"FINDING" forState:UIControlStateNormal];
        removeDirectionsView = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *removeDirectionsTmp = removeDirectionsView;
        MKPlacemark *placeBegin = [[MKPlacemark alloc]initWithCoordinate:currentLocation addressDictionary:nil];
        MKPlacemark *placeEnd  = [[MKPlacemark alloc]initWithCoordinate:clientHomeLocation addressDictionary:nil];
        MKMapItem *mapItemSrc = [[MKMapItem alloc]initWithPlacemark:placeBegin];
        MKMapItem *mapItemDest = [[MKMapItem alloc]initWithPlacemark:placeEnd];
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source = mapItemSrc;
        request.destination = mapItemDest;
        request.transportType = MKDirectionsTransportTypeAutomobile;
        
        UIView *directionsViewTmp = directionsView;
        directionsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 40, self.frame.size.width-60, 340)];
        UIScrollView *directionsScrollTmp = directionsScrollView;
        MKMapView *mapTmp = _myMapView;
        MKCoordinateRegion region;
        float spanX = 0.11225;
        float spanY = 0.11225;
        region.center.latitude = currentLocation.latitude;
        region.center.longitude = currentLocation.longitude;
        region.span.latitudeDelta = spanX;
        region.span.longitudeDelta = spanY;

        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:
         ^(MKDirectionsResponse *response, NSError *error) {
             
             
             if (error) {

                 [directionsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                 [directionsButton setTitle:@"CANNOT GET GPS" forState:UIControlStateNormal];
                 
             } else {
                 MKRoute *route = [response.routes firstObject];
                 NSArray *stepRoute = route.steps;
                 int yCoord = 10;
                //int numberDirections = (int)[stepRoute count];
                 directionsScrollTmp.contentSize = CGSizeMake(directionsScrollTmp.frame.size.width, 2000);
                 int dirStepNum = 1;
                
                 for (MKRouteStep *step in stepRoute) {
                     UILabel *directionsLabel;
                     
                    if ([step.instructions length] > 30) {
                         directionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yCoord, 350, 40)];
                         directionsLabel.numberOfLines = 2;
                         yCoord += 40;
                     } else {
                         directionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yCoord, 350, 20)];
                         directionsLabel.numberOfLines = 1;
                         yCoord += 20;
                     }
                     
                     NSString *dirStepStr = [NSString stringWithFormat:@"%i. %@",dirStepNum, step.instructions];
                     [directionsLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
                     [directionsLabel setTextColor:[UIColor whiteColor]];
                     [directionsLabel setText:dirStepStr];
                     [directionsViewTmp addSubview:directionsLabel];
					 [directionsScrollTmp addSubview:directionsLabel];
                     dirStepNum++;
                     
                 }
                 
                 directionsScrollTmp.backgroundColor = [UIColor blackColor];
                 directionsScrollTmp.alpha = 0.7;
                 directionsScrollTmp.scrollEnabled = YES;
			 
				 [self addSubview:directionsScrollTmp];
                 [mapTmp addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
                 
                 [directionsButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                 [directionsButton setTitle:@"FOUND DIRECTIONS" forState:UIControlStateNormal];
				 
                 removeDirectionsTmp.frame = directionsButton.frame;
				 [removeDirectionsTmp removeFromSuperview];
				 [removeDirectionsTmp setTitle:@"REMOVE DIRECTIONS" forState:UIControlStateNormal];
				 [removeDirectionsTmp setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
				 [removeDirectionsTmp addTarget:self action:@selector(clickRemoveDirections:) forControlEvents:UIControlEventTouchUpInside];
				 [self addSubview:removeDirectionsTmp];
    
                 
                 [mapTmp setRegion:region animated:YES];

             }
         }];
        
    }
}
-(void)clickRemoveDirections:(id)sender {
	
	[directionsScrollView removeFromSuperview];
	[removeDirectionsView removeFromSuperview];
	[self addSubview:getDirectionsButton];
	[getDirectionsButton setTitle:@"GET DIRECTIONS" forState:UIControlStateNormal];
	
}
-(MKOverlayRenderer *)_mapView:(MKMapView *)_mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polylineRender.lineWidth = 3.0f;
    polylineRender.strokeColor = [UIColor redColor];
    return polylineRender;
}
-(void)zoomToVisitLocation:(CLLocationCoordinate2D)visitCoord {

    float spanX = 0.00125;
    float spanY = 0.00125;
    MKCoordinateRegion region;
    region.center.latitude = visitCoord.latitude;
    region.center.longitude = visitCoord.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [_myMapView setRegion:region animated:YES];
}
-(void)removeAnnotations {
    
    for (id<MKAnnotation> annotation in _myMapView.annotations) {
        
        
        if (![annotation isKindOfClass:[MKUserLocation class]] && ![annotation isKindOfClass:[VisitAnnotation class]]) {
            [_myMapView removeAnnotation:annotation];
        }
    }
    
    for (id<MKOverlay> overlay in _myMapView.overlays) {
        [_myMapView removeOverlay:overlay];
    }
    [_myMapView removeOverlays:_myMapView.overlays];
    
}
-(void)_mapView:(MKMapView *)_mapView didAddAnnotationViews:(NSArray *)views {
}
-(MKAnnotationView *)_mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    
    MKAnnotationView* theAnnotationView = nil;

    if ([annotation isKindOfClass:[VisitAnnotation class]]) {
        
        VisitAnnotation *myVisit = (VisitAnnotation *)annotation;
        
        UIImage *imageForAnnotation;
        
        static NSString* ident = @"VisitAnnotation";
        
        if ([myVisit.type isEqualToString:@"arrived"]) {
            
            imageForAnnotation = [UIImage imageNamed:@"arrive-blue-100x100"];
            
        } else if ([myVisit.type isEqualToString:@"completed"]) {
            
            imageForAnnotation = [UIImage imageNamed:@"check-mark-circle"];
            
        } else if ([myVisit.type isEqualToString:@"markArrive"]){
            
            imageForAnnotation =[UIImage imageNamed:@"arrival-yellow-flag128x128"];
            
        } else if ([myVisit.type isEqualToString:@"markComplete"]) {
            
            imageForAnnotation =[UIImage imageNamed:@"completion-green-flag128x128"];
            
        } else {
            
            imageForAnnotation = [UIImage imageNamed:@"dog-annotation-2"];
        }
        
        theAnnotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:ident];
        [theAnnotationView setImage:nil];
        [theAnnotationView setImage:imageForAnnotation];
        
        if (theAnnotationView == nil) {
            theAnnotationView = [[VisitAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:ident];
            [theAnnotationView setImage:imageForAnnotation];
            theAnnotationView.canShowCallout = YES;
        }
        
        theAnnotationView.annotation = myVisit;
    }
    
    return theAnnotationView;
}
-(MKPolyline *) polyLine:(NSArray *)routePoints {
    
    CLLocationCoordinate2D coords[[routePoints count]];
    
    for (int i = 0; i < [routePoints count]; i++) {
        CLLocation *thePoint = [routePoints objectAtIndex:i];
        coords[i] = thePoint.coordinate;
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:[routePoints count]];
    
}
-(void)cleanDetailMapView {
    
    [self removeAnnotations];
	_myMapView.showsUserLocation = NO;
	_myMapView.delegate = nil;
	[_myMapView removeFromSuperview];
	_myMapView = nil;
    
}

@end
