//
//  VisitProgressMapView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 4/27/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//


#import "VisitProgressMapView.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"
#import "LocationShareModel.h"
#import "LocationTracker.h"
#import "VisitAnnotation.h"
#import "VisitAnnotationView.h"
#import "PawPrintAnnotation.h"
#import "PawPrintAnnotationView.h"
#import "JzStyleKit.h"
#import "DataClient.h"

@interface VisitProgressMapView () {
    
    VisitsAndTracking *sharedVisitsTracking;
    LocationShareModel *sharedLocationModel;
    LocationTracker *locationTracker;
    MKMapView *myMapView;
    VisitDetails *currentVisit;
    DataClient *currentClient;
    UIView *directionsView;
}


@end

@implementation VisitProgressMapView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        
        myMapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:myMapView];
        
        myMapView.showsUserLocation = YES;
        myMapView.mapType = MKMapTypeStandard;
        myMapView.delegate = self;
                
    }
    return self;
}



-(void)removeDelegate {
 
    myMapView.delegate = nil;
}
-(void)drivingDirections:(id)sender {
 
    UIButton *directionsButton;
    
    if([sender isKindOfClass:[UIButton class]]) {
    
        directionsButton = (UIButton*)sender;
        [directionsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [directionsButton setTitle:@"FINDING" forState:UIControlStateNormal];
    
    }
    CLLocationCoordinate2D currentLocation;
    CLLocationCoordinate2D clientHomeLocation;
    
    NSString *latitudeForVisit = currentVisit.latitude;
    NSString *longitudeForVisit = currentVisit.longitude;
    clientHomeLocation.latitude = [latitudeForVisit floatValue];
    clientHomeLocation.longitude = [longitudeForVisit floatValue];
    
    NSLog(@"Current visit lat, lon: %f, %f", clientHomeLocation.latitude, clientHomeLocation.longitude);
    
    locationTracker = [LocationTracker sharedLocationManager];
    currentLocation = locationTracker.myLastLocation;

    NSLog(@"Current LOCATION lat, lon: %f, %f", currentLocation.latitude, currentLocation.longitude);

    MKPlacemark *placeBegin = [[MKPlacemark alloc]initWithCoordinate:currentLocation addressDictionary:nil];
    MKPlacemark *placeEnd  = [[MKPlacemark alloc]initWithCoordinate:clientHomeLocation addressDictionary:nil];
    MKMapItem *mapItemSrc = [[MKMapItem alloc]initWithPlacemark:placeBegin];
    MKMapItem *mapItemDest = [[MKMapItem alloc]initWithPlacemark:placeEnd];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = mapItemSrc;
    request.destination = mapItemDest;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             
             [directionsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
             [directionsButton setTitle:@"CANNOT GET GPS" forState:UIControlStateNormal];
             
         } else {
             UIScrollView *directionsScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, 150)];
             MKRoute *route = [response.routes firstObject];
             NSArray *stepRoute = route.steps;
             int yCoord = 10;
             int numberDirections = (int)[stepRoute count];
             NSLog(@"Number directions: %i", numberDirections);
             
             directionsScrollView.contentSize = CGSizeMake(directionsScrollView.frame.size.width, 2000);
             int dirStepNum = 1;
             
             for (MKRouteStep *step in stepRoute) {
                 UILabel *directionsLabel;
                 
                 if ([step.instructions length] > 18) {
                     directionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yCoord, 350, 50)];
                     directionsLabel.numberOfLines = 2;
                     yCoord += 50;
                 } else {
                     directionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, yCoord, 350, 20)];
                     directionsLabel.numberOfLines = 1;
                     yCoord += 20;
                 }
                 
                 NSString *dirStepStr = [NSString stringWithFormat:@"%i. %@",dirStepNum, step.instructions];
                 [directionsLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
                 [directionsLabel setTextColor:[UIColor whiteColor]];
                 [directionsLabel setText:dirStepStr];
                 [directionsScrollView addSubview:directionsLabel];
                 dirStepNum++;
                 
             }
             
             directionsScrollView.backgroundColor = [UIColor blackColor];
             directionsScrollView.alpha = 0.7;
             directionsScrollView.scrollEnabled = YES;
             
             [self addSubview:directionsScrollView];
             [self->myMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
             
             [directionsButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
             [directionsButton setTitle:@"FOUND DIRECTIONS" forState:UIControlStateNormal];
             
             UIButton *removeDirectionsView = [UIButton buttonWithType:UIButtonTypeCustom];
             removeDirectionsView.frame = directionsButton.frame;
             [directionsButton removeFromSuperview];
             [removeDirectionsView setTitle:@"REMOVE DIRECTIONS" forState:UIControlStateNormal];
             [removeDirectionsView setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
             [removeDirectionsView addTarget:self action:@selector(clickRemoveDirections:) forControlEvents:UIControlEventTouchUpInside];
             [self addSubview:removeDirectionsView];
             float spanX = 0.11225;
             float spanY = 0.11225;
             MKCoordinateRegion region;
             region.center.latitude = currentLocation.latitude;
             region.center.longitude = currentLocation.longitude;
             region.span.latitudeDelta = spanX;
             region.span.longitudeDelta = spanY;
             
             [self->myMapView setRegion:region animated:YES];
             
         }
    }];
    
}
-(void)clickRemoveDirections:(id)sender {
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *getDirectionsButton = (UIButton*)sender;
        [getDirectionsButton setTitle:@"GET DIRECTIONS" forState:UIControlStateNormal];
    }
    NSArray *childView = directionsView.subviews;
    for (int i=0; i < [childView count]; i++) {
        id subViewItem = [childView objectAtIndex:i];
        if ([subViewItem isKindOfClass:[UIScrollView class]]) {
            UIScrollView *subButton = (UIScrollView*) subViewItem;
            [subButton removeFromSuperview];
        } else if ([subViewItem isKindOfClass:[UILabel class]]) {
            UILabel *subButton = (UILabel*) subViewItem;
            [subButton removeFromSuperview];
        } else if ([subViewItem isKindOfClass:[UIButton class]]) {
            UIButton *subButton = (UIButton*) subViewItem;
            [subButton removeFromSuperview];
        } 
    }

    
}
-(void)addVisitInfo:(VisitDetails*)visitInfo {
    
   currentVisit = visitInfo;
    
    for(DataClient *client in sharedVisitsTracking.clientData) {
        
        if ([visitInfo.clientptr isEqualToString:client.clientID]) {
            if(client.clinicLat != NULL && client.clinicLon != NULL) {
                NSString *latitudeForVisit = client.clinicLat;
                NSString *longitudeForVisit = client.clinicLon;
                CLLocationCoordinate2D vetCoord;
                vetCoord.latitude = [latitudeForVisit floatValue];
                vetCoord.longitude = [longitudeForVisit floatValue];
                currentClient = client;
                VisitAnnotation *visitAnn = [[VisitAnnotation alloc]initWithLocation:vetCoord withTitle:client.clinicName andSubtitle:client.clinicStreet1];
                visitAnn.type = @"Vet Clinic";
                [myMapView addAnnotation:visitAnn];
            }
        }
    }
    
    NSString *latitudeForVisit = visitInfo.latitude;
    NSString *longitudeForVisit = visitInfo.longitude;
    CLLocationCoordinate2D visitCoord;
    CLLocationCoordinate2D firstVisit;

    visitCoord.latitude = [latitudeForVisit floatValue];
    visitCoord.longitude = [longitudeForVisit floatValue];
    if (visitCoord.latitude > -9999.0000 && visitCoord.longitude > -9999.0000) {

        firstVisit.latitude = [latitudeForVisit floatValue];
        firstVisit.longitude = [longitudeForVisit floatValue];
        
        [self zoomToVisitLocation:firstVisit withSpanFactor:0.041100];
        [self drawRouteForVisitID:currentVisit];
        
    }
    
    VisitAnnotation *visitAnn = [[VisitAnnotation alloc]initWithLocation:visitCoord withTitle:visitInfo.petName andSubtitle:visitInfo.street1];
    visitAnn.sequenceID = visitInfo.sequenceID;
    
    if ([visitInfo.status isEqualToString:@"future"]) {
        visitAnn.type = @"future";
    } else if ([visitInfo.status isEqualToString:@"arrived"]) {
        visitAnn.type = @"arrived";
    } else if ([visitInfo.status isEqualToString:@"completed"]) {
        visitAnn.type = @"completed";
    } else if ([visitInfo.status isEqualToString:@"canceled"]) {
        visitAnn.type = @"canceled";
    } else if ([visitInfo.status isEqualToString:@"late"]) {
        visitAnn.type = @"late";
    }
    visitAnn.startTime = @" ";
    visitAnn.finishTime = @" ";
    [myMapView addAnnotation:visitAnn];
    
    [self addRoutePoints];
}

-(void) addRoutePoints {
    
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
        } else if ([myVisit.type isEqualToString:@"e"]) {
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

-(void)zoomToVisitLocation:(CLLocationCoordinate2D)visitCoord withSpanFactor:(float)spanFactor {
    NSLog(@"Zoom to VISIT location for map view");
    float spanX = spanFactor;
    float spanY = spanFactor;
    MKCoordinateRegion region;
    region.center.latitude = visitCoord.latitude;
    region.center.longitude = visitCoord.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [myMapView setRegion:region animated:YES];
}

-(void)removePolylines {
    
    for (id<MKOverlay> overlay in myMapView.overlays) {
        [myMapView removeOverlay:overlay];
    }
}
-(MKPolyline *) polyLine:(NSArray *)routePoints {
    
    CLLocationCoordinate2D coords[[routePoints count]];
    
    for (int i = 0; i < [routePoints count]; i++) {
        CLLocation *thePoint = [routePoints objectAtIndex:i];
        coords[i] = thePoint.coordinate;
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:[routePoints count]];
    
}
-(MKOverlayRenderer *)_mapView:(MKMapView *)_mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polylineRender.lineWidth = 3.0f;
    polylineRender.strokeColor = [UIColor redColor];
    return polylineRender;
}
-(void)drawRouteForVisitID:(VisitDetails*) visit {

    [self removePolylines];
    NSMutableArray *redrawVisitPoints = [NSMutableArray arrayWithArray:[visit getPointForRoutes]];
    NSLog(@"Number of coordinates for visit: %lu", (unsigned long)[redrawVisitPoints count]);
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"timestamp" ascending:YES];
    [redrawVisitPoints sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    MKPolyline *routeDrawPolyline= [self polyLine:redrawVisitPoints];
    [myMapView addOverlay:routeDrawPolyline];
    
}

@end
