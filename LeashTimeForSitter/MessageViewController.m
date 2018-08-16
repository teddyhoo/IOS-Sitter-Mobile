//
//  MessageViewController.m
//  LeashTimeSitter
//
//  Created by Ted Hooban on 10/25/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageViewFormat.h"
#import "VisitDetails.h"
#import "LocationShareModel.h"
#import "PSPDFTextView.h"
#include <tgmath.h>
#import "VisitAnnotation.h"
#import "VisitAnnotationReportView.h"
#import "VisitAnnotation.h"
#import "VisitAnnotationView.h"

@interface MessageViewController ()  {
    
    NSMutableArray *moodButtonArray;
    MessageViewFormat *messageView;
    PSPDFTextView *noteTextField;
	MKMapSnapshotter *snapshotter;
	UIImageView *mapSnapShotImage;
	
    VisitsAndTracking *sharedVisitsTracking;
    VisitDetails *currentVisit;

    UILabel *lastSentDate;
    UIImageView *noteTextBorderBox;
    UIButton *checkMarkNote;
    UIButton *sendMail;
    UIButton *locationResendCoords;
    UIView *buttonPanel;
    
    BOOL showingMap;
    BOOL keyboardVisible;
    CGRect keyboardRect;
    CGFloat height;
    CGFloat width;
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;

}
@end


int imageIndex = 0;
float xMove = 0;
float yMove = -200;

@implementation MessageViewController

-(id)init
{
    self = [super init];
    if(self){
		sharedVisitsTracking = [VisitsAndTracking sharedInstance];
        height = self.view.bounds.size.height;
		NSString *pListData = [[NSBundle mainBundle]
							   pathForResource:@"MoodButtons"
							   ofType:@"plist"];
		
		moodButtonArray = [[NSMutableArray alloc]initWithContentsOfFile:pListData];
    }
    
    return self;
}
-(void)dealloc
{
	NSLog(@"message view controller dealloc");
	[[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillShowNotification];
	[[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillHideNotification];
	[currentVisit writeVisitDataToFile];
	currentVisit = nil;
	noteTextField.delegate = nil;
	
	[messageView removeFromSuperview];
	[noteTextField removeFromSuperview];
	[noteTextBorderBox removeFromSuperview];
	[checkMarkNote removeFromSuperview];
	[locationResendCoords removeFromSuperview];
	[lastSentDate removeFromSuperview];
	[sendMail removeFromSuperview];

	messageView = nil;
	noteTextField.delegate = nil;
	noteTextField = nil;
	noteTextBorderBox = nil;
	checkMarkNote = nil;
	locationResendCoords = nil;
	lastSentDate = nil;
	sendMail = nil;
	
	for (int i = 0; i++; [moodButtonArray count]){
		NSMutableDictionary *moodButton = moodButtonArray[i];
		[moodButton removeAllObjects];
		moodButton = nil;
	}
	[moodButtonArray removeAllObjects];
	moodButtonArray = nil;
	
	
	NSArray *childrenButtonPanel = [buttonPanel subviews];
	for (int i = 0; i < [childrenButtonPanel count]; i++) {
		UIButton *moodButton = [childrenButtonPanel objectAtIndex:i];
		[moodButton removeFromSuperview];
		moodButton = nil;
	}
	
	[buttonPanel removeFromSuperview];
	buttonPanel = nil;
	childrenButtonPanel = nil;

	
	[self.view removeFromSuperview];
	self.view = nil;
	
}

-(void) removeFromParentViewController {
	
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillShowNotification];
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillHideNotification];


    [currentVisit writeVisitDataToFile];
    currentVisit = nil;
    noteTextField.delegate = nil;
    
    [messageView removeFromSuperview];
    [noteTextField removeFromSuperview];
    [noteTextBorderBox removeFromSuperview];
    [checkMarkNote removeFromSuperview];
    [locationResendCoords removeFromSuperview];
    [lastSentDate removeFromSuperview];
    [sendMail removeFromSuperview];


    NSArray *childrenButtonPanel = [buttonPanel subviews];
    for (int i = 0; i < [childrenButtonPanel count]; i++) {
        UIButton *moodButton = [childrenButtonPanel objectAtIndex:i];
        [moodButton removeFromSuperview];
        moodButton = nil;
    }
    [buttonPanel removeFromSuperview];
    buttonPanel = nil;
    messageView = nil;
    sendMail = nil;
    lastSentDate = nil;

    noteTextField = nil;
    noteTextBorderBox = nil;
    checkMarkNote = nil;
    locationResendCoords = nil;
	[self.view removeFromSuperview];
	self.view = nil;


}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void)didMoveToParentViewController:(UIViewController *)parent {
	//NSLog(@"View did move to parent view controller");

    for (VisitDetails *visit in sharedVisitsTracking.visitData) {
        if ([visit.appointmentid isEqualToString:sharedVisitsTracking.onWhichVisitID]) {
            currentVisit = visit;
        }
    }

    if ((sharedVisitsTracking.onWhichVisitID == NULL) &&
		[sharedVisitsTracking.onSequence isEqualToString:@"000"]) {
		UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"YOU ARE CURRENTLY NOT ACTIVE ON A VISIT"
                                      message:@"SELECT A VISIT IN THE LIST VIEW BEFORE EDITING VISIT NOTES"
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:ok];
        
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    int widthSize = self.view.frame.size.width;

    NSString *phoneType = [sharedVisitsTracking tellDeviceType];
	checkMarkNote = [[UIButton alloc]init];
	locationResendCoords = [UIButton buttonWithType:UIButtonTypeCustom];
	sendMail = [UIButton buttonWithType:UIButtonTypeCustom];

	messageView = [[MessageViewFormat alloc]initWithFrame:self.view.frame andVisitID:currentVisit.appointmentid andCheckMarkCoord:checkMarkNote.frame.origin.y];
	buttonPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];


    if ([phoneType isEqualToString:@"iPhone6P"]) {        
        isIphone6P = YES;
        isIphone6 = NO;
        isIphone5 = NO;
        isIphone4 = NO;
		
		noteTextField = [[PSPDFTextView alloc]initWithFrame:CGRectMake(10, 190, self.view.frame.size.width-60, 130)];
		noteTextField.font = [UIFont fontWithName:@"CompassRoseCPC-Regular" size:18];
		noteTextBorderBox = [[UIImageView alloc]initWithFrame:CGRectMake(8, 190, self.view.frame.size.width-56, 154)];
		checkMarkNote.frame = CGRectMake(widthSize-48, noteTextBorderBox.frame.size.height+150, 32, 32);
		locationResendCoords.frame = CGRectMake(checkMarkNote.frame.origin.x+10, checkMarkNote.frame.origin.y+100,20,20);
		lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2,80, 140, 20)];
		[lastSentDate setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];

    }
    else if ([[sharedVisitsTracking tellDeviceType]isEqualToString:@"iPhone6"]) {
        isIphone6 = YES;
        isIphone6P = NO;
        isIphone5 = NO;
        isIphone4 = NO;
		
		noteTextField = [[PSPDFTextView alloc]initWithFrame:CGRectMake(10, 180, self.view.frame.size.width-60, 130)];
		noteTextField.font = [UIFont fontWithName:@"CompassRoseCPC-Regular" size:18];
		noteTextBorderBox = [[UIImageView alloc]initWithFrame:CGRectMake(10, 180, self.view.frame.size.width-56, noteTextField.frame.size.height+20)];
		checkMarkNote.frame = CGRectMake(widthSize-40, noteTextBorderBox.frame.size.height+150, 32, 32);
		locationResendCoords.frame = CGRectMake(checkMarkNote.frame.origin.x, checkMarkNote.frame.origin.y+120,20,20);
		lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2,80,200, 20)];
		[lastSentDate setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];
    }
    else if ([[sharedVisitsTracking tellDeviceType]isEqualToString:@"iPhone5"]) {
        isIphone5 = YES;
        isIphone6P = NO;
        isIphone6 = NO;
        isIphone4 = NO;
		
		noteTextField = [[PSPDFTextView alloc]initWithFrame:CGRectMake(10, 160, 280, 90)];
		noteTextField.font = [UIFont fontWithName:@"CompassRoseCPC-Regular" size:16];
		noteTextBorderBox = [[UIImageView alloc]initWithFrame:CGRectMake(10, 160, noteTextField.frame.size.width, noteTextField.frame.size.height+20)];
		checkMarkNote.frame = CGRectMake(widthSize-30, noteTextBorderBox.frame.origin.y+90, 32, 32);
		
		locationResendCoords.frame = CGRectMake(checkMarkNote.frame.origin.x, checkMarkNote.frame.origin.y+170,20,20);
		lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2,80,200, 20)];
		[lastSentDate setFont:[UIFont fontWithName:@"Lato-Bold" size:14]];
		
    }
    else if ([[sharedVisitsTracking tellDeviceType]isEqualToString:@"iPhone4"]) {
        isIphone5 = NO;
        isIphone6P = NO;
        isIphone6 = NO;
        isIphone4 = YES;
		
		noteTextField = [[PSPDFTextView alloc]initWithFrame:CGRectMake(10, 160, 280, 150)];
		noteTextField.font = [UIFont fontWithName:@"CompassRoseCPC-Regular" size:14];
		noteTextBorderBox = [[UIImageView alloc]initWithFrame:CGRectMake(10, 160, noteTextField.frame.size.width, noteTextField.frame.size.height+20)];
		checkMarkNote.frame = CGRectMake(widthSize-30, noteTextBorderBox.frame.origin.y + noteTextBorderBox.frame.size.height-32, 32, 32);
		locationResendCoords.frame = CGRectMake(checkMarkNote.frame.origin.x, checkMarkNote.frame.origin.y+120,20,20);
		lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2,80, 200, 20)];
		[lastSentDate setFont:[UIFont fontWithName:@"Lato-Bold" size:12]];
    }
    
	noteTextField.delegate = self;
	noteTextField.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
	[noteTextBorderBox setImage:[UIImage imageNamed:@"linefine-textbox"]];
	[checkMarkNote setBackgroundImage:[UIImage imageNamed:@"add-plus-icon-whiteback"]
							 forState:UIControlStateNormal];
	[checkMarkNote addTarget:self
					  action:@selector(dismissKeyboard)
			forControlEvents:UIControlEventTouchUpInside];
	
	[locationResendCoords setBackgroundImage:[UIImage imageNamed:@"location-icon-2"] forState:UIControlStateNormal];
	[locationResendCoords addTarget:self action:@selector(resendAllCoordinatesToServer) forControlEvents:UIControlEventTouchUpInside];
	[lastSentDate setTextColor:[UIColor greenColor]];

	
    if (isIphone6P) {

        if(![currentVisit.dateTimeVisitReportSubmit isEqual:[NSNull null]] && [currentVisit.dateTimeVisitReportSubmit length] != 0) {
            NSString *lastSent = [NSString stringWithFormat:@"%@",currentVisit.dateTimeVisitReportSubmit];
            [lastSentDate setText:lastSent];
            sendMail.frame = CGRectMake(lastSentDate.frame.origin.x - 20, lastSentDate.frame.origin.y, 24, 24);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"]
                                forState:UIControlStateNormal];
            [sendMail addTarget:self
                         action:@selector(sendMessageToClient)
               forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            [lastSentDate setText:@" "];
            sendMail.frame = CGRectMake(checkMarkNote.frame.origin.x, checkMarkNote.frame.origin.y - 100, 32, 32);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"] forState:UIControlStateNormal];
            [sendMail addTarget:self action:@selector(sendMessageToClient) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    else if (isIphone6) {

        if(![currentVisit.dateTimeVisitReportSubmit isEqual:[NSNull null]] && [currentVisit.dateTimeVisitReportSubmit length] != 0) {
            NSString *lastSent = [NSString stringWithFormat:@"%@",currentVisit.dateTimeVisitReportSubmit];
            [lastSentDate setText:lastSent];
            sendMail.frame = CGRectMake(lastSentDate.frame.origin.x - 20, lastSentDate.frame.origin.y, 24, 24);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"] forState:UIControlStateNormal];
            [sendMail addTarget:self action:@selector(sendMessageToClient) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            
            [lastSentDate setText:@" "];
            [sendMail removeFromSuperview];
            sendMail.frame = CGRectMake(330, checkMarkNote.frame.origin.y - 100, 32, 32);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"] forState:UIControlStateNormal];
            [sendMail addTarget:self action:@selector(sendMessageToClient) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if (isIphone5) {
        if(![currentVisit.dateTimeVisitReportSubmit isEqual:[NSNull null]] && [currentVisit.dateTimeVisitReportSubmit length] != 0) {
            NSString *lastSent = [NSString stringWithFormat:@"%@",currentVisit.dateTimeVisitReportSubmit];
            [lastSentDate setText:lastSent];
            sendMail.frame = CGRectMake(lastSentDate.frame.origin.x - 40, lastSentDate.frame.origin.y-5, 20, 20);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"] forState:UIControlStateNormal];
            [sendMail addTarget:self action:@selector(sendMessageToClient) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            
            [lastSentDate setText:@" "];
            [sendMail removeFromSuperview];
            sendMail.frame = CGRectMake(292, checkMarkNote.frame.origin.y - 90, 24, 24);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"] forState:UIControlStateNormal];
            [sendMail addTarget:self action:@selector(sendMessageToClient) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    else if (isIphone4) {
        
        if(![currentVisit.dateTimeVisitReportSubmit isEqual:[NSNull null]] && [currentVisit.dateTimeVisitReportSubmit length] != 0) {
            NSString *lastSent = [NSString stringWithFormat:@"%@",currentVisit.dateTimeVisitReportSubmit];
            [lastSentDate setText:lastSent];
            sendMail.frame = CGRectMake(lastSentDate.frame.origin.x - 20, lastSentDate.frame.origin.y, 20, 20);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"] forState:UIControlStateNormal];
            [sendMail addTarget:self action:@selector(sendMessageToClient) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            
            [lastSentDate setText:@" "];
            [sendMail removeFromSuperview];
            sendMail.frame = CGRectMake(290, checkMarkNote.frame.origin.y + 80, 20, 20);
            [sendMail setBackgroundImage:[UIImage imageNamed:@"envelope128x128"] forState:UIControlStateNormal];
            [sendMail addTarget:self action:@selector(sendMessageToClient) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
	noteTextField.text = currentVisit.visitNoteBySitter;
    [noteTextField setText:currentVisit.visitNoteBySitter];
    
	[self.view addSubview:messageView];
    [self.view addSubview:buttonPanel];
    [self.view addSubview:lastSentDate];
	[self.view addSubview:noteTextField];
    [self.view addSubview:noteTextBorderBox];
    [self.view addSubview:checkMarkNote];
    [self.view addSubview:locationResendCoords];
    [self.view addSubview:sendMail];
    [self addButtons];

}

-(void)viewDidLoad {
    
    [super viewDidLoad];
	//NSLog(@"View did load");

    for (VisitDetails *visit in sharedVisitsTracking.visitData) {
        if ([visit.appointmentid isEqualToString:sharedVisitsTracking.onWhichVisitID]) {
            currentVisit = visit;
        }
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:NO];

	//NSLog(@"View did appear");
	
	if(isIphone6P) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 350, 345, 345)];
		
	} else if (isIphone6) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 335, 310, 310)];
		
	} else if (isIphone5) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 280, 254, 254)];
		
	} else if (isIphone4) {
		mapSnapShotImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 280, 300, 300)];
		
	}
	UIImageView *mapBorder = [[UIImageView alloc]initWithFrame:CGRectMake(mapSnapShotImage.frame.origin.x-6, mapSnapShotImage.frame.origin.y-18, mapSnapShotImage.frame.size.width+12, mapSnapShotImage.frame.size.height+18)];
	[mapBorder setImage:[UIImage imageNamed:@"linefine-textbox"]];
	
	[self.view addSubview:mapBorder];
	[self.view addSubview:mapSnapShotImage];

	if (currentVisit.mapSnapShotImage != NULL) {
		[mapSnapShotImage setImage:currentVisit.mapSnapShotImage];
	} else if(sharedVisitsTracking.isReachable) {
		[self createMapSnapshot];
	} else {
		
		currentVisit.mapSnapTakeStatus = @"FAIL";
		currentVisit.mapSnapUploadStatus = @"FAIL";
		NSMutableDictionary *imgDicResend = [[NSMutableDictionary alloc]init];
		[imgDicResend setObject:currentVisit.appointmentid forKey:@"appointmentptr"];
		[imgDicResend setObject:@"MAP-SNAP" forKey:@"TYPE"];
		[imgDicResend setObject:@"FAIL-NOT REACHABLE" forKey:@"STATUS"];
		[sharedVisitsTracking.arrivalCompleteQueueItems addObject:imgDicResend];
		
	}
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {

	CLLocationDegrees minLat = 90.0;
	CLLocationDegrees maxLat = -90.0;
	CLLocationDegrees minLon = 180.0;
	CLLocationDegrees maxLon = -180.0;

	for (CLLocation *location in annotations) {

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

	double maxLatDouble = maxLat;
	maxLatDouble = maxLatDouble - minLat;
	//maxLatDouble = maxLatDouble + 0.0001;
	double maxLonDouble = maxLon;
	maxLonDouble = maxLonDouble - minLon;
	//maxLonDouble = maxLonDouble + 0.0001;

	CLLocationCoordinate2D convertCoord = CLLocationCoordinate2DMake(maxLatDouble, maxLonDouble);
	CLLocationDegrees maxLatConvert = convertCoord.latitude;
	CLLocationDegrees maxLonConvert = convertCoord.longitude;

	MKCoordinateSpan span = MKCoordinateSpanMake(maxLatConvert, maxLonConvert);

	CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2);
	//CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLatDouble - span.latitudeDelta / 2), maxLonDouble - span.longitudeDelta / 2);

	return MKCoordinateRegionMake(center, span);
}

- (void)createMapSnapshot {




	if (currentVisit.mapSnapShotImage != NULL) {

		[mapSnapShotImage setImage:currentVisit.mapSnapShotImage];
		return;
	}
	else if(sharedVisitsTracking.onWhichVisitID != NULL &&
			[currentVisit.status isEqualToString:@"completed"] &&
			currentVisit.mapSnapShotImage == NULL) {
		
		float markVisitCompleteLat;
		float markVisitComplateLon;

		markVisitComplateLon = [currentVisit.coordinateLongitudeMarkComplete floatValue];
		markVisitCompleteLat = [currentVisit.coordinateLatitudeMarkComplete floatValue];

		CLLocationCoordinate2D completeVisit = CLLocationCoordinate2DMake(markVisitCompleteLat,markVisitComplateLon);

		__block MKMapSnapshotter *snapshotter;
		__block NSArray *redrawVisitPoints = [NSArray arrayWithArray:[sharedVisitsTracking getCoordinatesForVisit:currentVisit.appointmentid]];


		MKMapSnapshotOptions *mapSnapOp = [[MKMapSnapshotOptions alloc]init];

		mapSnapOp.size = CGSizeMake(mapSnapShotImage.frame.size.width, mapSnapShotImage.frame.size.height);

		mapSnapOp.scale = [[UIScreen mainScreen]scale];
		mapSnapOp.mapType = MKMapTypeStandard;
		mapSnapOp.showsBuildings = YES;
		mapSnapOp.showsPointsOfInterest = YES;

		MKMapCamera *mapViewVC = [[MKMapCamera alloc]init];
		mapViewVC.pitch = 45;
		mapViewVC.altitude = 400;
		mapSnapOp.camera = mapViewVC;
		MKCoordinateRegion region;
		CLLocationCoordinate2D clientHome = CLLocationCoordinate2DMake([currentVisit.latitude floatValue], [currentVisit.longitude floatValue]);

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
			mapViewVC.centerCoordinate = clientHome;
			mapSnapOp.region = region;
		}

		snapshotter = [[MKMapSnapshotter alloc]initWithOptions:mapSnapOp];
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

				for(int i=0;i<[redrawVisitPoints count];i++)
				{

					CLLocation *thePoint = [redrawVisitPoints objectAtIndex:i];
					coordinates[i] = thePoint.coordinate;
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
				mapSnapShotImage.image = res;
				currentVisit.mapSnapTakeStatus = @"SUCCESS";
				[currentVisit addMapsnapShotImageToVisit:res];

			} else {
				currentVisit.mapSnapTakeStatus = @"FAIL";
			}
		}];
	}
}

-(void)resendAllCoordinatesToServer {
    
    [sharedVisitsTracking resendAllCoordinatesToServer:currentVisit.appointmentid];
    
    CGRect newFrame = CGRectMake(locationResendCoords.frame.origin.x-100, locationResendCoords.frame.origin.y, 16, 16);
    CGRect oldFrame = CGRectMake(locationResendCoords.frame.origin.x, locationResendCoords.frame.origin.y, 32,32);
    
    [UIView animateWithDuration:.25
                     animations:^{
                         locationResendCoords.frame = newFrame;
                         
                     }
                     completion:^(BOOL finished){
                         locationResendCoords.frame = oldFrame;
                     }];

}
-(void)addVisitInfoToView {

	for (VisitDetails *visit in sharedVisitsTracking.visitData) {
        if ([visit.appointmentid isEqualToString:sharedVisitsTracking.onWhichVisitID]) {
            
            if (isIphone6P) {
                lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(sendMail.frame.origin.x,sendMail.frame.origin.y+30, 200, 20)];

            } else if (isIphone6) {
               
                lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(sendMail.frame.origin.x,sendMail.frame.origin.y+30, 200, 20)];

            } else if (isIphone5) {
                lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(sendMail.frame.origin.x,sendMail.frame.origin.y+30, 200, 20)];

            } else if (isIphone4) {

                lastSentDate = [[UILabel alloc]initWithFrame:CGRectMake(sendMail.frame.origin.x,sendMail.frame.origin.y+30, 200, 20)];
            }
        }
    }
}
-(void)addButtons {

    int tagID = 0;

    for (NSDictionary *moodDic in moodButtonArray) {
        
        NSString *coordXStr = [moodDic objectForKey:@"coordinateX"];
        NSString *coordYStr = [moodDic objectForKey:@"coordinateY"];
        NSString *sizeButton = [moodDic objectForKey:@"size"];
        
        NSString *moodText = [moodDic objectForKey:@"Label"];
        UIImage *buttonImage = [UIImage imageNamed:[moodDic objectForKey:@"Filename"]];
        
        int coordXint = [coordXStr intValue];
        int coordYint = [coordYStr intValue];
        int sizeInt = [sizeButton intValue];

      	if (isIphone5) {
			sizeInt -= 2;
			coordYint -= 15;
			if (tagID > 0) {
				coordXint -= tagID * 8;
			}
		} else if (isIphone6P) {

			coordYint += 10;
			sizeInt += 4;
		}

        UIButton *moodButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moodButton.frame = CGRectMake(coordXint,coordYint,sizeInt,sizeInt);
        [moodButton setImage:buttonImage forState:UIControlStateNormal];
        [moodButton addTarget:self
                       action:@selector(tapMoodButton:)
             forControlEvents:UIControlEventTouchUpInside];
        moodButton.tag = tagID;
        moodButton.alpha = 0.25;
        tagID++;
        
        if([self checkVisitMood:moodText]) {
            moodButton.alpha = 1.0;

            [UIView animateWithDuration:0.3 animations:^{
                
                moodButton.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                
            }];
            
        }
        
        [buttonPanel addSubview:moodButton];
    }
}
	 
-(BOOL)checkVisitMood:(NSString *)moodDescription {    
    if([moodDescription isEqualToString:@"HAPPY"] && currentVisit.wasHappy) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"PEE"] && currentVisit.didPee) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"POO"] && currentVisit.didPoo) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"SAD"] && currentVisit.wasSad) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"ANGRY"] && currentVisit.wasAngry) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"SICK"] && currentVisit.wasSick) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"SHY"] && currentVisit.wasShy) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"CATSIT"] && currentVisit.wasCat) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"LITTER"] && currentVisit.didScoopLitter) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"PLAY"] && currentVisit.didPlay) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"HUNGRY"] && currentVisit.wasHungry) {
        return TRUE;
    } else {
        return FALSE;
    }
    
    
}
-(void)setVisitMood:(NSString *)moodDescription {
    
    if([moodDescription isEqualToString:@"HAPPY"]) {
        currentVisit.wasHappy = YES;
    } else if ([moodDescription isEqualToString:@"PEE"]) {
        currentVisit.didPee = YES;
    } else if ([moodDescription isEqualToString:@"POO"]) {
        currentVisit.didPoo = YES;
    } else if ([moodDescription isEqualToString:@"SAD"]) {
        currentVisit.wasSad = YES;
    } else if ([moodDescription isEqualToString:@"ANGRY"]) {
        currentVisit.wasAngry = YES;
    } else if ([moodDescription isEqualToString:@"SICK"]) {
        currentVisit.wasSick = YES;
    } else if ([moodDescription isEqualToString:@"SHY"]) {
        currentVisit.wasShy = YES;
    } else if ([moodDescription isEqualToString:@"CATSIT"]) {
        currentVisit.wasCat= YES;
    } else if ([moodDescription isEqualToString:@"LITTER"]) {
        currentVisit.didScoopLitter = YES;
    } else if ([moodDescription isEqualToString:@"PLAY"]) {
		currentVisit.didPlay= YES;
    } else if ([moodDescription isEqualToString:@"HUNGRY"]) {
	   currentVisit.wasHungry= YES;
    }
    
}
-(void)setVisitMoodOff:(NSString *)moodDescription {
    
    if([moodDescription isEqualToString:@"HAPPY"]) {
        currentVisit.wasHappy = NO;
    } else if ([moodDescription isEqualToString:@"PEE"]) {
        currentVisit.didPee = NO;
    } else if ([moodDescription isEqualToString:@"POO"]) {
        currentVisit.didPoo = NO;
    } else if ([moodDescription isEqualToString:@"SAD"]) {
        currentVisit.wasSad = NO;
    } else if ([moodDescription isEqualToString:@"ANGRY"]) {
        currentVisit.wasAngry = NO;
    } else if ([moodDescription isEqualToString:@"SICK"]) {
        currentVisit.wasSick = NO;
    } else if ([moodDescription isEqualToString:@"SHY"]) {
        currentVisit.wasShy = NO;
    } else if ([moodDescription isEqualToString:@"CATSIT"]) {
		currentVisit.wasCat= NO;
    } else if ([moodDescription isEqualToString:@"LITTER"]) {
        currentVisit.didScoopLitter= NO;
    } else if ([moodDescription isEqualToString:@"PLAY"]) {
        currentVisit.didPlay= NO;
    } else if ([moodDescription isEqualToString:@"HUNGRY"]) {
        currentVisit.wasHungry= NO;
    }
    
}
-(void)tapMoodButton:(id)sender {
    
    UIButton *moodButton;

	if([sender isKindOfClass:[UIButton class]]) {
        moodButton = (UIButton*)sender;
    }
    
    if (moodButton.alpha < 1.0) {
        
        NSDictionary *moodDic = [moodButtonArray objectAtIndex:moodButton.tag];
        [self setVisitMood:[moodDic objectForKey:@"Label"]];

        [UIView animateWithDuration:0.3 animations:^{
            moodButton.alpha = 1.0;
        } completion:^(BOOL finished) {
		}];
    } else {
        
        NSDictionary *moodDic = [moodButtonArray objectAtIndex:moodButton.tag];
        [self setVisitMoodOff:[moodDic objectForKey:@"Label"]];
        [UIView animateWithDuration:0.3 animations:^{
            moodButton.alpha = 0.25;
        } completion:^(BOOL finished) {
            
        }];
	}
}

//----------------------------------------TRANSMIT TO CLIENT-------------------------------------------------------
-(void)sendMessageToClient {
    NSDate *rightNow = [NSDate date];
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:@"HH:mm a"];
    NSString *dateTimeString = [dateFormat stringFromDate:rightNow];
    
    currentVisit.dateTimeVisitReportSubmit = dateTimeString;
    currentVisit.visitNoteBySitter = noteTextField.text;
	
    
    NSString *moodButton = @"buttons={";

    if(currentVisit.didPee) {
        NSString *peeMood = @"\"pee\":\"yes\"";
        moodButton = [moodButton stringByAppendingString:peeMood];
    } else if (!currentVisit.didPee) {
        NSString *peeMood = @"\"pee\":\"no\"";
        moodButton = [moodButton stringByAppendingString:peeMood];
    }
    if(currentVisit.didPoo) {
        moodButton = [moodButton stringByAppendingString:@",\"poo\":\"yes\""];
    } else if (!currentVisit.didPoo) {
        moodButton = [moodButton stringByAppendingString:@",\"poo\":\"no\""];
    }
    if(currentVisit.didPlay) {
        moodButton = [moodButton stringByAppendingString:@",\"play\":\"yes\""];
    } else if (!currentVisit.didPlay) {
        moodButton = [moodButton stringByAppendingString:@",\"play\":\"no\""];
    }
    if(currentVisit.wasHappy) {
        moodButton = [moodButton stringByAppendingString:@",\"happy\":\"yes\""];
    } else if (!currentVisit.wasHappy) {
        moodButton = [moodButton stringByAppendingString:@",\"happy\":\"no\""];
    }
    if(currentVisit.wasHungry) {
        moodButton = [moodButton stringByAppendingString:@",\"hungry\":\"yes\""];
    } else if (!currentVisit.wasHungry) {
        moodButton = [moodButton stringByAppendingString:@",\"hungry\":\"no\""];
    }
    if(currentVisit.wasAngry) {
        moodButton = [moodButton stringByAppendingString:@",\"angry\":\"yes\""];
    } else if (!currentVisit.didPee) {
        moodButton = [moodButton stringByAppendingString:@",\"angry\":\"no\""];
    }
    if(currentVisit.wasShy) {
        moodButton = [moodButton stringByAppendingString:@",\"shy\":\"yes\""];
    } else if (!currentVisit.wasShy) {
        moodButton = [moodButton stringByAppendingString:@",\"shy\":\"no\""];
    }
    if(currentVisit.wasSad) {
        moodButton = [moodButton stringByAppendingString:@",\"sad\":\"yes\""];
    } else if (!currentVisit.wasSad) {
        moodButton = [moodButton stringByAppendingString:@",\"sad\":\"no\""];
    }
    if(currentVisit.wasSick) {
        moodButton = [moodButton stringByAppendingString:@",\"sick\":\"yes\""];
    } else if (!currentVisit.wasSick) {
        moodButton = [moodButton stringByAppendingString:@",\"sick\":\"no\""];
    }
    if(currentVisit.wasCat) {
        moodButton = [moodButton stringByAppendingString:@",\"cat\":\"yes\""];
    } else if (!currentVisit.wasShy) {
        moodButton = [moodButton stringByAppendingString:@",\"cat\":\"no\""];
    }
    if(currentVisit.didScoopLitter) {
        moodButton = [moodButton stringByAppendingString:@",\"litter\":\"yes\""];
    } else if (!currentVisit.didScoopLitter) {
        moodButton = [moodButton stringByAppendingString:@",\"litter\":\"no\""];
    }
    
    NSString *closeMood = @"}";
    
    moodButton = [moodButton stringByAppendingString:closeMood];
    LocationShareModel *locationShare = [LocationShareModel sharedModel];
    NSString *latSendNote = [NSString stringWithFormat:@"%f",locationShare.lastValidLocation.latitude];
    NSString *lonSendNote = [NSString stringWithFormat:@"%f",locationShare.lastValidLocation.longitude];
    NSString *consolidatedVisitNote = [NSString stringWithFormat:@"[VISIT: %@] ",dateTimeString];
    
    if(![currentVisit.visitNoteBySitter isEqual:[NSNull null]] && [currentVisit.visitNoteBySitter length] > 0) {
        consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.visitNoteBySitter];
    }
    consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:@"  [MGR NOTE] "];
    if(![currentVisit.note isEqual:[NSNull null]] && [currentVisit.note length] > 0) {
		//NSString *tempVisitNote= [consolidatedVisitNote stringByAppendingString:currentVisit.note];
		consolidatedVisitNote = [consolidatedVisitNote stringByAppendingString:currentVisit.note];//[tempVisitNote stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    }
	if ([currentVisit.mapSnapUploadStatus isEqualToString:@"NO CONNECT"] ||
		currentVisit.mapSnapShotImage == NULL) {
		[self createMapSnapshot];
	}
	
	//NSLog(@"MESSAGE VIEW CONTROLLER: SEND NOTE METHOD");
	//NSLog(@"current visit date time mark arrive: %@, complete: %@",currentVisit.dateTimeMarkArrive, currentVisit.dateTimeMarkComplete);
	//NSLog(@"lat: %@, lon: %@, appointmentid: %@, note: %@, mood: %@", latSendNote,lonSendNote,currentVisit.appointmentid,consolidatedVisitNote,moodButton);

	NSString *arrivalTime = currentVisit.arrived;
	NSString *arrivalTime2 = currentVisit.dateTimeMarkArrive;
	//NSLog(@"%@, %@", arrivalTime, arrivalTime2);
	NSString *completionTime = currentVisit.completed;
	//NSLog(@"arrive: %@, complete: %@", arrivalTime, completionTime);

	[self dismissKeyboard];
	if (sharedVisitsTracking.isReachable) {
		[self sendNote:consolidatedVisitNote moods:moodButton latitude:latSendNote longitude:lonSendNote markArrive:arrivalTime markComplete:completionTime];
	} else {
		currentVisit.visitReportUploadStatus = @"FAIL";
		[currentVisit writeVisitDataToFile];

		NSMutableDictionary *reportResend = [[NSMutableDictionary alloc]init];
		[reportResend setObject:@"REPORT" forKey:@"TYPE"];
		[reportResend setObject:@"FAIL-NETWORK RESPONSE" forKey:@"STATUS"];
		[reportResend setObject:currentVisit.appointmentid forKey:@"appointmentptr"];
		[sharedVisitsTracking.arrivalCompleteQueueItems addObject:reportResend];		
		
		CGRect newFrame = CGRectMake(sendMail.frame.origin.x, sendMail.frame.origin.y, sendMail.frame.size.width*2, sendMail.frame.size.height*1.5);
		newFrame.origin.x = lastSentDate.frame.origin.x-20;
		newFrame.origin.y = lastSentDate.frame.origin.y;
		
		[UIView animateWithDuration:.25
						 animations:^{
							 sendMail.frame = newFrame;
						 }
						 completion:^(BOOL finished){
							 [self scaledownMailIcon];
						 }];

	}

}

-(void)sendNote:(NSString*)note
          moods:(NSString*)moodButtons
       latitude:(NSString*)currentLatitude
      longitude:(NSString*)currentLongitude
     markArrive:(NSString*)arriveTime
   markComplete:(NSString*)completionTime {
    
	//NSLog(@"CALLING VISITS AND TRACKING");
	/*NSLog(@"arrive: %@, complete: %@, lat: %@, lon: %@, appointmentid: %@, note: %@, mood: %@", 
		  arriveTime,
		  completionTime,
		  currentLatitude,
		  currentLongitude,
		  currentVisit.appointmentid,
		  note,
		  moodButtons);*/
    
    [sharedVisitsTracking sendVisitNote:note
                                   moods:moodButtons
                                latitude:currentLatitude
                               longitude:currentLongitude
                              markArrive:arriveTime
                            markComplete:completionTime
                        forAppointmentID:currentVisit.appointmentid];
    

    CGRect newFrame = CGRectMake(sendMail.frame.origin.x, sendMail.frame.origin.y, sendMail.frame.size.width*2, sendMail.frame.size.height*1.5);
    newFrame.origin.x = lastSentDate.frame.origin.x-20;
    newFrame.origin.y = lastSentDate.frame.origin.y;

    [UIView animateWithDuration:.25
                     animations:^{
                         sendMail.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         [self scaledownMailIcon];
                     }];
    
}

-(void)scaledownMailIcon {
    
    
    CGRect newFrame = CGRectMake(sendMail.frame.origin.x, sendMail.frame.origin.y, sendMail.frame.size.width/2.5, sendMail.frame.size.height/2.5);
    newFrame.origin.x = lastSentDate.frame.origin.x-30;
    newFrame.origin.y = lastSentDate.frame.origin.y;
    [UIView animateWithDuration:1.5 animations:^{
        sendMail.frame = newFrame;
        sendMail.alpha = 1.0;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

//-------------------------------------------TEXT INPUT NOTES --------------------------------------------
- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    //self.automaticallyAdjustsScrollViewInsets = NO;
	//NSLog(@"text view begin editing");

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    
    //NSLog(@"text view did end editing");
    currentVisit.visitNoteBySitter = noteTextField.text;
    return YES;
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    if (!keyboardVisible) {
        keyboardVisible = YES;
        keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        [self updateTextViewContentInset];
        [(PSPDFTextView *)noteTextField scrollToVisibleCaretAnimated:YES]; // Animating here won't bring us to the correct position.
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    if (keyboardVisible) {
        keyboardVisible = NO;
        keyboardRect = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        [self updateTextViewContentInset];
    }
}

- (void)updateTextViewContentInset {
    // Don't execute this if in a popover.
    if (keyboardVisible) {
        //bottom = __tg_fmin(CGRectGetHeight(_keyboardRect), CGRectGetWidth(_keyboardRect)); // also work in landscape
    }
    
    //self.noteTextField.contentInset = contentInset;
    //self.noteTextField.scrollIndicatorInsets = contentInset;
}

- (void)keyboardDidShow:(NSNotification *)note {
	//NSLog(@"keyboard did show");

    NSValue *keyboardFrameValue = [note userInfo][UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    CGRect r = noteTextField.frame;
    r.size.height -= CGRectGetHeight(keyboardFrame);
    noteTextField.frame = r;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    [textView layoutIfNeeded];
    
    CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    caretRect.size.height += textView.textContainerInset.bottom;
    
    [textView scrollRectToVisible:caretRect animated:NO];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
    //NSLog(@"text view did end editing");
    
    currentVisit.visitNoteBySitter = textView.text;
    
    
}

- (void)dismissKeyboard {
	//NSLog(@"dismiss keyboard");
    [self.view endEditing:YES];
	currentVisit.visitNoteBySitter = noteTextField.text;
    
}



@end
