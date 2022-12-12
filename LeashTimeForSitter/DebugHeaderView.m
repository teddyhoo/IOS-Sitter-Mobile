//
//  DebugHeaderView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 6/17/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import "DebugHeaderView.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"
#import "DataClient.h"
#import "LocationTracker.h"


@interface DebugHeaderView() {
    UILabel *onWhichVisitID;
    UILabel *onSequenceID;
    UILabel *currentVisitID;
    UILabel *gpsStatus;
    UILabel *networkStatus;

    VisitsAndTracking *sharedVisits;
    LocationTracker *locationTracking;
    VisitDetails *currentVisit;
}


@end

@implementation DebugHeaderView
-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        sharedVisits = [VisitsAndTracking sharedInstance];
        locationTracking = [LocationTracker sharedLocationManager];

        onWhichVisitID = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, frame.size.width / 2, 20)];
        onWhichVisitID.tag = 1;
        onSequenceID = [[UILabel alloc]initWithFrame:CGRectMake(onWhichVisitID.frame.origin.x, onWhichVisitID.frame.origin.y  + 24,  frame.size.width / 2, 20)];
        onSequenceID.tag = 1;
        gpsStatus = [[UILabel alloc]initWithFrame:CGRectMake(onWhichVisitID.frame.origin.x, onSequenceID.frame.origin.y + 24,  frame.size.width, 20)];
        gpsStatus.tag = 1;
        currentVisitID = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 200, 66,  frame.size.width / 2, 20)];
        currentVisitID.tag = 1;
        
        [onWhichVisitID setTextColor:[UIColor whiteColor]];
        [currentVisitID setTextColor:[UIColor whiteColor]];
        [onSequenceID setTextColor:[UIColor whiteColor]];
        [gpsStatus setTextColor:[UIColor whiteColor]];

        [onWhichVisitID setFont:[UIFont fontWithName:@"Lato-Light" size:18]];
        [currentVisitID setFont:[UIFont fontWithName:@"Lato-Light" size:18]];
        [onSequenceID setFont:[UIFont fontWithName:@"Lato-Light" size:18]];
        [gpsStatus setFont:[UIFont fontWithName:@"Lato-Light" size:18]];
    
        NSString *onWhichText = [NSString stringWithFormat:@"ON: %@", sharedVisits.onWhichVisitID];
        NSString *onWhichSequence = [NSString stringWithFormat:@"SEQ  : %@", sharedVisits.onSequence];
        

        if (![sharedVisits.onWhichVisitID isEqualToString:@"000"]) {
            for(VisitDetails *visit in sharedVisits.visitData) {
                if ([visit.appointmentid isEqualToString:sharedVisits.onWhichVisitID]) {
                    NSArray *pointsForVisit = [visit getPointForRoutes];
                    int numCoord = (int) [pointsForVisit count];
                    if(numCoord > 0) {
                        NSString *gpsStatusText = [NSString stringWithFormat:@"GPS pt: %i", numCoord];
                        [gpsStatus setText:gpsStatusText];
                    } else {
                        [gpsStatus setText:@"NO COORD"];
                    }
                }
            }
        }  else {
            [gpsStatus setText:@"Not on visit"];            
        }

        [onWhichVisitID setText:onWhichText];
        [onSequenceID setText:onWhichSequence];
        
        [self addSubview:onWhichVisitID];
        [self addSubview:onSequenceID];
        [self addSubview:gpsStatus];
        [self addSubview:currentVisitID];
        
        
        float frameY =  gpsStatus.frame.origin.y  + gpsStatus.frame.size.height  + 20;
        
        [self checkFailedUploads:frameY];
        

        /*
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(updateUploadStatusComplete)
                                                    name:@"sentVisitComplete"
                                                  object:nil];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(updateUploadStatusMap)
                                                    name:@"uploadMapSnapShot"
                                                  object:nil];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(updateWriteToFile)
                                                    name:@"writeToFile"
                                                  object:nil];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(updateFlushCoords)
                                                    name:@"flushCoordinates"
                                                  object:nil];*/
    }
    return self;
}

-(void)showUserErrorLog {
    
    
}
-(void)checkFailedUploads:(float)frameY {
    for(VisitDetails *visit in sharedVisits.visitData) {
        
        if ([visit.imageUploadStatus isEqualToString:@"FAIL"]) {
                
            UILabel  *failLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,frameY,self.frame.size.width,  20)];
            [failLabel setTextColor:[UIColor redColor]];
            [failLabel setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
            NSString *errorMessage = [NSString stringWithFormat:@" PHOTO, %@ (%@)", visit.clientname, visit.appointmentid];
            [failLabel setText:errorMessage];
            [self addSubview:failLabel];
            frameY = frameY  + 30;
            
            [self addSubview:failLabel];
            
        }
        if ([visit.mapSnapTakeStatus isEqualToString:@"FAIL"]) {
            UILabel  *failLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,frameY,self.frame.size.width,  20)];
            [failLabel setTextColor:[UIColor redColor]];
            [failLabel setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
            NSString *errorMessage = [NSString stringWithFormat:@"MAP,%@ (%@)", visit.clientname,visit.appointmentid];
            [failLabel setText:errorMessage];
            [self addSubview:failLabel];
            frameY = frameY  + 30;
            [self addSubview:failLabel];

        }
        
        if ([visit.currentArriveVisitStatus isEqualToString:@"FAIL"]) {
            UILabel  *failLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,frameY,self.frame.size.width,  20)];
            [failLabel setTextColor:[UIColor redColor]];
            [failLabel setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
            NSString *errorMessage = [NSString stringWithFormat:@"ARR, %@ (%@)", visit.clientname, visit.appointmentid];
            [failLabel setText:errorMessage];
            [self addSubview:failLabel];
            frameY = frameY  + 30;
            [self addSubview:failLabel];

        }
        
        if ([visit.currentCompleteVisitStatus isEqualToString:@"FAIL"]) {
            UILabel  *failLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,frameY,self.frame.size.width,  20)];
            [failLabel setTextColor:[UIColor redColor]];
            [failLabel setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
            NSString *errorMessage = [NSString stringWithFormat:@"COMP, %@ (%@)", visit.clientname,visit.appointmentid];
            [failLabel setText:errorMessage];
            [self addSubview:failLabel];
            frameY = frameY  + 30;
            [self addSubview:failLabel];

        }
        
        
        if ([visit.mapSnapUploadStatus isEqualToString:@"FAIL"]) {
            UILabel  *failLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,frameY,self.frame.size.width,  20)];
            [failLabel setTextColor:[UIColor redColor]];
            [failLabel setFont:[UIFont fontWithName:@"Lato-Light" size:12]];
            NSString *errorMessage = [NSString stringWithFormat:@"MAPSNAP, %@ (%@)", visit.clientname, visit.appointmentid];
            [failLabel setText:errorMessage];
            [self addSubview:failLabel];
            frameY = frameY  + 30;
            [self addSubview:failLabel];

        }
        
        if ([visit.visitReportUploadStatus isEqualToString:@"FAIL"]) {
            UILabel  *failLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,frameY,self.frame.size.width,  20)];
            [failLabel setTextColor:[UIColor redColor]];
            [failLabel setFont:[UIFont fontWithName:@"Lato-Light" size:14]];
            NSString *errorMessage = [NSString stringWithFormat:@"VISIT REPORT,%@ (%@)", visit.clientname, visit.appointmentid];
            [failLabel setText:errorMessage];
            [self addSubview:failLabel];
            frameY = frameY  + 30;
            [self addSubview:failLabel];
        }            
    }
    
    [self showUserErrorLog:frameY ];
        
}
-(void)showUserErrorLog:(float)frameY {
    NSUserDefaults *memWarning = [NSUserDefaults standardUserDefaults];
    NSArray *userDefaultKeys = [[[NSUserDefaults standardUserDefaults]dictionaryRepresentation]allKeys];
    
    if ([userDefaultKeys count] > 0 ) {
        for (id key in userDefaultKeys) {
            if ([key isKindOfClass:[NSString class]]) {
                NSString *keyStr = (NSString*)key;
                NSObject *valType = [memWarning objectForKey:key];
                
                if ([valType isKindOfClass:[NSString class]]) {
                    NSString *valString = (NSString*)valType;
                    NSString *keyValString = [NSString stringWithFormat:@"%@ --> %@", keyStr, valString];
                    //NSLog(@"%@ --> %@", keyStr, valString);
                    UILabel *errorLogLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, frameY, self.frame.size.width, 20)];
                    [errorLogLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
                    [errorLogLabel setTextColor:[UIColor yellowColor]];
                    [errorLogLabel setText:keyValString];
                    //[self addSubview:errorLogLabel];
                    frameY = frameY  +  20;
                }
            }
        }
    }
    
}
-(void)cleanView {
    
    for(UIView *rView in self.subviews) {
        if(rView.tag > 99) {
            [rView removeFromSuperview];
        }
    }
 
    
}


-(void)updateFlushCoords {
    for(VisitDetails *visit in sharedVisits.visitData) {
        if ([sharedVisits.onWhichVisitID isEqualToString:visit.appointmentid]) {
            currentVisit = visit;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel * flushCoords = [[UILabel alloc]initWithFrame:CGRectMake(5, 45, 60, 15)];
        [flushCoords setTextColor:[UIColor whiteColor]];
        [flushCoords setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
        [flushCoords setText:@"FLUSH"];        
        flushCoords.tag = 100;
        [self addSubview:flushCoords];
        [self setAlpha:1.0];
        [UIView animateWithDuration:5.0 animations:^{
            [self setAlpha:0.0];
        }];

    });
}
-(void)updateWriteToFile {
    for(VisitDetails *visit in sharedVisits.visitData) {
        if ([sharedVisits.onWhichVisitID isEqualToString:visit.appointmentid]) {
            currentVisit = visit;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel * writeToFile = [[UILabel alloc]initWithFrame:CGRectMake(5, 30, 60, 15)];
        [writeToFile setTextColor:[UIColor whiteColor]];
        [writeToFile setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
        [writeToFile setText:@"WRITE"];
        writeToFile.tag = 100;
        [self addSubview:writeToFile];
        [self setAlpha:1.0];
        [UIView animateWithDuration:5.0 animations:^{
            [self setAlpha:0.0];
        }];
    });
}
-(void)updateUploadStatusMap {
    for(VisitDetails *visit in sharedVisits.visitData) {
        if ([sharedVisits.onWhichVisitID isEqualToString:visit.appointmentid]) {
            currentVisit = visit;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UILabel *uploadMap = [[UILabel alloc]initWithFrame:CGRectMake(5, 15, 60, 15)];
        [uploadMap setTextColor:[UIColor whiteColor]];
        [uploadMap setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
        [uploadMap setText:@"MAP"];
        uploadMap.tag = 100;
        [self addSubview:uploadMap];
        [self setAlpha:1.0];
        [UIView animateWithDuration:5.0 animations:^{
            [self setAlpha:0.0];
        }];

    });
}
-(void)updateUploadStatusComplete {
    for(VisitDetails *visit in sharedVisits.visitData) {
        if ([sharedVisits.onWhichVisitID isEqualToString:visit.appointmentid]) {
            currentVisit = visit;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UILabel *sentComplete = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 60, 15)];
        [sentComplete setTextColor:[UIColor whiteColor]];
        [sentComplete setFont:[UIFont fontWithName:@"Lato-Regular" size:12]];
        [sentComplete setText:@"COMPLETE"];
        sentComplete.tag = 100;
        [self addSubview:sentComplete];
        [self setAlpha:1.0];
        [UIView animateWithDuration:5.0 animations:^{
            [self setAlpha:0.0];
        }];

    });
}
-(void)updateViewMarkComplete {


}
@end
