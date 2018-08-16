
//
//  SecondViewController.m
//  LeashTimeSitter
//
//  Created by Ted Hooban on 6/27/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "SecondViewController.h"
#import "VisitAnnotation.h"
#import "VisitAnnotationView.h"
#import "PawPrintAnnotation.h"
#import "PawPrintAnnotationView.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"
#import "LocationShareModel.h"
#import "LocationTracker.h"
#import "JzStyleKit.h"
#import "DataClient.h"

@interface SecondViewController () {
    
    VisitsAndTracking *sharedVisitsTracking;
    LocationShareModel *sharedLocationModel;
    MapHUD *diagMenu;
    CLLocation *lastLocation;
    MKMapView *myMapView;
}


@end

@implementation SecondViewController

float distanceSensitivity = 1;
float distanceMax = 2500;


- (instancetype)init {
    
    self = [super init];
    
    if(self ) {
        
        sharedVisitsTracking = [VisitsAndTracking sharedInstance];
		sharedLocationModel = [LocationShareModel sharedModel];
    }
    
    return self;
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	//NSLog(@"MAP VIEW  did LOAD");
	
}
- (void)addMapHUDWithNumClients:(int)numClients {
	
	int hudSize = (numClients*40)+100;
	diagMenu = [[MapHUD alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, hudSize)];
	[diagMenu setDelegate:self];

	[self.view addSubview:diagMenu];
	
}
- (void)viewDidAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	if(myMapView != nil) {
		myMapView.showsUserLocation = YES;
		myMapView.mapType = MKMapTypeStandard;
	} else {
		myMapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
		[self.view addSubview:myMapView];
		myMapView.showsUserLocation = YES;
		myMapView.mapType = MKMapTypeStandard;
		myMapView.delegate = self;
		
	}

	[self addMapHUDWithNumClients:(int)[sharedVisitsTracking.visitData count]];

	CLLocationCoordinate2D firstVisit;
	int visitCount = 0;


	for(DataClient *client in sharedVisitsTracking.clientData) {
		
		if(client.clinicLat != NULL && client.clinicLon != NULL) {
			NSString *latitudeForVisit = client.clinicLat;
			NSString *longitudeForVisit = client.clinicLon;
			CLLocationCoordinate2D vetCoord;
			vetCoord.latitude = [latitudeForVisit floatValue];
			vetCoord.longitude = [longitudeForVisit floatValue];
			
			VisitAnnotation *visitAnn = [[VisitAnnotation alloc]initWithLocation:vetCoord withTitle:client.clinicName andSubtitle:client.clinicStreet1];
			visitAnn.type = @"Vet Clinic";
			[myMapView addAnnotation:visitAnn];

			
		}
	}


	for (VisitDetails *theVisitDetails in sharedVisitsTracking.visitData) {

		if(!([theVisitDetails.latitude isEqual:[NSNull null]]) &&
		   !([theVisitDetails.longitude isEqual:[NSNull null]])) {
			NSString *latitudeForVisit = theVisitDetails.latitude;
			NSString *longitudeForVisit = theVisitDetails.longitude;
			CLLocationCoordinate2D visitCoord;

			visitCoord.latitude = [latitudeForVisit floatValue];
			visitCoord.longitude = [longitudeForVisit floatValue];


			if (visitCoord.latitude > -9999.0000 && visitCoord.longitude > -9999.0000) {

				if ([sharedVisitsTracking.onSequence isEqualToString:theVisitDetails.sequenceID]) {
					firstVisit.latitude = [latitudeForVisit floatValue];
					firstVisit.longitude = [longitudeForVisit floatValue];
					[self zoomToVisitLocation:firstVisit withSpanFactor:0.041100];
					[self drawRoute:theVisitDetails.sequenceID];

					[diagMenu updateVisitDetailInfo:theVisitDetails];

				} else if (visitCount == 0 && [sharedVisitsTracking.onSequence isEqualToString:@"000"]) {

					firstVisit.latitude = [latitudeForVisit floatValue];
					firstVisit.longitude = [longitudeForVisit floatValue];
					[self zoomToVisitLocation:firstVisit withSpanFactor:0.080000];
				}

				VisitAnnotation *visitAnn = [[VisitAnnotation alloc]initWithLocation:visitCoord withTitle:theVisitDetails.petName andSubtitle:theVisitDetails.street1];
				visitAnn.sequenceID = theVisitDetails.sequenceID;

				if ([theVisitDetails.status isEqualToString:@"future"]) {
					visitAnn.type = @"future";
				} else if ([theVisitDetails.status isEqualToString:@"arrived"]) {
					visitAnn.type = @"arrived";
				} else if ([theVisitDetails.status isEqualToString:@"completed"]) {
					visitAnn.type = @"completed";
				} else if ([theVisitDetails.status isEqualToString:@"canceled"]) {
					visitAnn.type = @"canceled";
				} else if ([theVisitDetails.status isEqualToString:@"late"]) {
					visitAnn.type = @"late";
				}
				visitAnn.startTime = @" ";
				visitAnn.finishTime = @" ";
				visitCount++;
				[myMapView addAnnotation:visitAnn];
			}
		}
	}

}
-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [diagMenu removeFromSuperview];
	[diagMenu setDelegate:nil];
	diagMenu = nil;

    [self removeAnnotations];
    myMapView.mapType = MKMapTypeHybrid;
    myMapView.showsUserLocation = NO;
    myMapView.delegate = nil;
    [myMapView removeFromSuperview];
    myMapView = nil;

}
-(void) didMoveToParentViewController:(UIViewController *)parent {
	
	//NSLog(@"did move to parent MAP VIEW");
	
	
}
-(void) removeFromParentViewController {
	

 }
-(void) dealloc
{

    lastLocation = nil;
    [diagMenu removeFromSuperview];
    [diagMenu setDelegate:nil];
	diagMenu = nil;
	
    [self removeAnnotations];
    myMapView.mapType = MKMapTypeHybrid;
    myMapView.showsUserLocation = NO;
	myMapView.delegate = nil;
    [myMapView removeFromSuperview];
    myMapView = nil;

    [self.view removeFromSuperview];
    self.view = nil;
	
    
}
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;

    VisitAnnotationView *theAnnotationView = nil;
    VisitAnnotation *myVisit = (VisitAnnotation*)annotation;
    UIImage *imageForAnnotation;
    
    
    if ([annotation isKindOfClass:[VisitAnnotation class]]) {

        if ([myVisit.type isEqualToString:@"arrived"]) {
            imageForAnnotation = [UIImage imageNamed:@"arrive-blue-100x100"];
        } else if ([myVisit.type isEqualToString:@"completed"]) {
            imageForAnnotation = [UIImage imageNamed:@"check-mark-green"];
        } else if ([myVisit.type isEqualToString:@"markArrive"]){
            imageForAnnotation =[UIImage imageNamed:@"arrival-yellow-flag128x128"];
        } else if ([myVisit.type isEqualToString:@"markComplete"]) {
            imageForAnnotation =[UIImage imageNamed:@"completion-green-flag128x128"];
		} else if ([myVisit.type isEqualToString:@"Vet Clinic"]) {
			
			imageForAnnotation = [UIImage imageNamed:@"med-map-annotation"];
			
		} else {
                if ([myVisit.sequenceID isEqualToString:@"100"]) {
                    imageForAnnotation = [UIImage imageNamed:@"red-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"101"]) {
                    imageForAnnotation = [UIImage imageNamed:@"teal-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"102"]) {
                    imageForAnnotation = [UIImage imageNamed:@"orange-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"103"]) {
                    imageForAnnotation = [UIImage imageNamed:@"purple-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"104"]) {
                    imageForAnnotation = [UIImage imageNamed:@"lightBlue-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"105"]) {
                    imageForAnnotation = [UIImage imageNamed:@"dark-green-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"106"]) {
                    imageForAnnotation = [UIImage imageNamed:@"magenta-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"107"]) {
                    imageForAnnotation = [UIImage imageNamed:@"brown-paw"];
                } else if ([myVisit.sequenceID isEqualToString:@"108"]) {
                   imageForAnnotation = [UIImage imageNamed:@"pink-paw"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"109"]) {
                    imageForAnnotation = [UIImage imageNamed:@"light-green"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"110"]) {
					imageForAnnotation = [UIImage imageNamed:@"paw-powder-blue-100"];
                }
                else if ([myVisit.sequenceID isEqualToString:@"111"]) {
                    imageForAnnotation = [UIImage imageNamed:@"paw-powder-blue-100"];
                } else {
                    imageForAnnotation = [UIImage imageNamed:@"dog-annotation-2"];
                }
        }

        if (theAnnotationView == nil) {

            theAnnotationView = [[VisitAnnotationView alloc]initWithFrame:CGRectMake(0,0,32,32)];
            [theAnnotationView setImage:imageForAnnotation];
            theAnnotationView.canShowCallout = YES;
        }
    
        theAnnotationView.annotation = myVisit;
    
    
    }
    return theAnnotationView;
}
- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{

    CLLocation *currentLocation = sharedLocationModel.validLocationLast;
    CLLocationDistance distance = [currentLocation distanceFromLocation:lastLocation];

	if  (userLocation.coordinate.latitude == 0.0f || userLocation.coordinate.longitude == 0.0f) {
        distance = 0;
        lastLocation = currentLocation;
        return;
    }
    else if (distance > distanceMax) {
        distance = 0;
        lastLocation = currentLocation;
        return;
    }
    else if (distance < distanceSensitivity) {
        distance = 0;
        lastLocation = currentLocation;
        return;
        
    }
}
- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        UIColor *polyColor;
		polyColor = [UIColor redColor];
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = polyColor;
        aRenderer.lineWidth = 4;
        return aRenderer;
        
    } else if ([overlay isKindOfClass:[MKCircle class]]) {
                
        MKCircle *circle = (MKCircle *)overlay;
        MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithCircle:circle];
        circleRender.strokeColor = [UIColor lightGrayColor];
        circleRender.fillColor = [[UIColor blueColor]colorWithAlphaComponent:0.1];
        circleRender.lineWidth = 2;
        return circleRender;
        
    }
    
    return nil;
}
-(MKPolyline *) polyLine:(NSArray *)routePoints {
    
    CLLocationCoordinate2D coords[[routePoints count]];

    for (int i = 0; i < [routePoints count]; i++) {
        CLLocation *thePoint = [routePoints objectAtIndex:i];
        coords[i] = thePoint.coordinate;
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:[routePoints count]];
    
}
-(void)zoomToCurrentLocation {
    
    float spanX = 0.00125;
    float spanY = 0.00125;
    MKCoordinateRegion region;
    region.center.latitude = myMapView.userLocation.coordinate.latitude;
    region.center.longitude = myMapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [myMapView setRegion:region animated:YES];
    
}
-(void)zoomToVisitLocation:(CLLocationCoordinate2D)visitCoord withSpanFactor:(float)spanFactor {
    
    float spanX = spanFactor;
    float spanY = spanFactor;
    MKCoordinateRegion region;
    region.center.latitude = visitCoord.latitude;
    region.center.longitude = visitCoord.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [myMapView setRegion:region animated:YES];
}
-(void)removeAnnotations {
    
	MKUserLocation *userLocation;
	
    for (id<MKAnnotation> annotation in myMapView.annotations) {

        if ([annotation isKindOfClass:[MKUserLocation class]]) {
			userLocation = (MKUserLocation*)annotation;
        }
		
		[myMapView removeAnnotation:annotation];

    }
	
	myMapView.showsUserLocation = NO;
	[myMapView removeAnnotation:userLocation];
	userLocation = nil;
	
    for (id<MKOverlay> overlay in myMapView.overlays) {
        [myMapView removeOverlay:overlay];
    }
}

-(void)removePolylines {
	
	for (id<MKOverlay> overlay in myMapView.overlays) {
		[myMapView removeOverlay:overlay];
	}
}
-(void)drawRoute:(NSString*)routeName {
    
	NSString *sequenceID;
    NSString *visitID;
    NSString *latitudeChosen;
    NSString *longitudeChosen;
    float markVisitCompleteLat;
    float markVisitArriveLat;
    float markVisitComplateLon;
    float markVisitArriveLon;
    float lonForVisit = 0.0;
    float latForVisit = 0.0;
    [self removePolylines];
	
	
	
    for(VisitDetails *visitDetails in sharedVisitsTracking.visitData) {
		
        if ([visitDetails.sequenceID isEqualToString:routeName]) {

            sequenceID = visitDetails.sequenceID;
            visitID = visitDetails.appointmentid;
            
            NSArray *redrawVisitPoints = [NSArray arrayWithArray:[sharedVisitsTracking getCoordinatesForVisit:visitDetails.appointmentid]];
            latitudeChosen = visitDetails.latitude;
            longitudeChosen = visitDetails.longitude;
            markVisitArriveLat = [visitDetails.coordinateLatitudeMarkArrive floatValue];
            markVisitArriveLon = [visitDetails.coordinateLongitudeMarkArrive floatValue];
            markVisitComplateLon = [visitDetails.coordinateLongitudeMarkComplete floatValue];
            markVisitCompleteLat = [visitDetails.coordinateLatitudeMarkComplete floatValue];
            latForVisit = [latitudeChosen floatValue];
            lonForVisit = [longitudeChosen floatValue];
            
            if (latForVisit == -9999.00000000 || lonForVisit == -9999.00000000) {
                
                
            } else {
                CLLocationCoordinate2D visitCoordZoom = CLLocationCoordinate2DMake(latForVisit,lonForVisit);
                [self zoomToVisitLocation:visitCoordZoom withSpanFactor:0.011111];
                
                if([redrawVisitPoints count] > 0) {
                    
                    CLLocationCoordinate2D startVisit = CLLocationCoordinate2DMake(markVisitArriveLat,markVisitArriveLon);
                    VisitAnnotation *visitAnn = [[VisitAnnotation alloc]initWithLocation:startVisit
                                                                               withTitle:visitDetails.dateTimeMarkArrive
                                                                             andSubtitle:visitDetails.visitNoteBySitter];
                    visitAnn.type = @"markArrive";
                    
                    CLLocationCoordinate2D completeVisit = CLLocationCoordinate2DMake(markVisitCompleteLat,markVisitComplateLon);
                    VisitAnnotation *visitAnn2 = [[VisitAnnotation alloc]initWithLocation:completeVisit
                                                                                withTitle:visitDetails.dateTimeMarkComplete
                                                                              andSubtitle:visitDetails.visitNoteBySitter];
                    visitAnn2.type = @"markComplete";
                    
                    [myMapView addAnnotation:visitAnn];
                    [myMapView addAnnotation:visitAnn2];
                    
                    MKPolyline *routeDrawPolyline= [self polyLine:redrawVisitPoints];
                    [myMapView addOverlay:routeDrawPolyline];
                }
                
            }

        }
    }
}

@end
