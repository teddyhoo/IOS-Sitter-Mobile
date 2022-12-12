//
//  FloatingModalView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 9/24/17.
//  Copyright © 2017 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "FloatingModalView.h"
#import "VisitsAndTracking.h"
#import "VisitDetails.h"
#import "DataClient.h"
#import "tgmath.h"


@interface FloatingModalView() {
	
	VisitDetails *currentVisit;
	DataClient *currentClient;
	WKWebView *webView;
    NSMutableArray *moodButtonArray;
    UIImageView *noteTextBorderBox;
    UIView *flagDetailView;
    BOOL keyboardVisible;
    CGRect keyboardRect;
    CGFloat height;
    CGFloat width;    
    int char_per_line;
    int globalFontSize;
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
    
}
@end


@implementation FloatingModalView  

-(id)init {
	self = [super init];
	if(self){
	}
	return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+200, self.frame.size.width, self.frame.size.height-150)];
        [self addSubview:webView];
        
        NSURL *doc = [NSURL URLWithString:@"http://training.leashtime.com/newsletters/LeashTime-Newsletter-JANUARY-2017.pdf"];
        NSData *docData = [NSData dataWithContentsOfURL:doc];
        [webView loadData:docData MIMEType:@"application/pdf" characterEncodingName:@"" baseURL:doc];
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = CGRectMake(self.frame.origin.x, self.frame.size.height-50, self.frame.size.width, 50);
        dismissButton.backgroundColor = [UIColor whiteColor];
        [dismissButton setTitle:@"FINISHED" forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    [[UIColor colorWithWhite:0.1 alpha:0.9] setFill];
    UIBezierPath *clippath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:1];
    [clippath fill];
    
    CGContextRestoreGState(ctx);
}

- (instancetype)initWithFrame:(CGRect)frame 
			   appointmentID:(NSString*)appointmentID 
					itemType:(NSString*)itemType {
	
	if (self = [super initWithFrame:frame]) {
		
		VisitsAndTracking *sharedVisits = [VisitsAndTracking sharedInstance];
		for(VisitDetails *visitInfo in sharedVisits.visitData) {
			if ([visitInfo.appointmentid isEqualToString:appointmentID]) {
				currentVisit = visitInfo;
				for(DataClient *client in sharedVisits.clientData) {
					if([currentVisit.clientptr isEqualToString:client.clientID]) {
						currentClient = client;
					}
				}
			}
		}

		[self setBackgroundColor:[UIColor clearColor]];
        if ([sharedVisits.tellDeviceType isEqualToString:@"XR"]) {
            char_per_line = 24;
            globalFontSize = 18;
        } else if ([sharedVisits.tellDeviceType isEqualToString:@"iPhone6P"]) {
            char_per_line = 20;
            globalFontSize = 18;
        } else if ([sharedVisits.tellDeviceType isEqualToString:@"iPhone5"]) {
            char_per_line = 18;
            globalFontSize = 16;
        } else if ([sharedVisits.tellDeviceType isEqualToString:@"iPhoneX"]) {
            char_per_line = 20;
            globalFontSize = 18;
        }
        
		if ([itemType isEqualToString:@"oneDoc"]) {
			webView= [[WKWebView alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+20, self.frame.size.width-10, self.frame.size.height)];
			[self addSubview:webView];
			
			NSDictionary *errataDic = [[currentVisit getErrataDocItems]objectAtIndex:0];
			NSString *label = [errataDic objectForKey:@"label"];
			NSString *mimeType = [errataDic objectForKey:@"mimetype"];
			NSString *errataURL = [errataDic objectForKey:@"url"];
			NSURL *doc = [NSURL URLWithString:errataURL];
			NSData *docData = [NSData dataWithContentsOfURL:doc];
			[webView loadData:docData MIMEType:mimeType characterEncodingName:@"" baseURL:doc];
			
			UILabel *docLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, webView.frame.size.width-40, 40)];
			[docLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
			[docLabel setTextColor:[UIColor whiteColor]];
			[docLabel setTextAlignment:NSTextAlignmentCenter];
			docLabel.numberOfLines = 2;
			[docLabel setText:label];
			[self addSubview:docLabel];
			
			UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
			exitButton.frame = CGRectMake(5,5,32,32);
			[exitButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
			[exitButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:exitButton];
		
		}
        else if ([itemType isEqualToString:@"multiDoc"]) {
			
			int y  = 60;
			int numDoc = (int)[[currentVisit getErrataDocItems] count];
			
			UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.frame.size.width - 40, 24)];
			[headerLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
			[headerLabel setTextColor:[UIColor whiteColor]];
			[headerLabel setText:@"Document Attachments"];
			[headerLabel setTextAlignment:NSTextAlignmentCenter];
			[self addSubview:headerLabel];
			UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width, 1)];
			[divider setImage:[UIImage imageNamed:@"white-line-1px"]];
			[self addSubview:divider];
			
			UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
			exitButton.frame = CGRectMake(5,5,24,24);
			[exitButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
			[exitButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:exitButton];
			
			for (int i = 0; i < numDoc; i++) {
				
				NSDictionary *docAttachDic = [[currentVisit getErrataDocItems]objectAtIndex:i];
				NSString *petID;
				NSString *petName;
				
				if ([docAttachDic objectForKey:@"petid"] != NULL) {
					petID =  [docAttachDic objectForKey:@"petid"] ;
                    NSArray *petInfo = [currentClient getPetInfo];
					for (NSDictionary *petDict in petInfo) {
						
						NSString *petIDinfo = [petDict objectForKey:@"petid"];
											  
						if ([petIDinfo isEqualToString:petID]) {							
							petName = [petDict objectForKey:@"name"];
							UILabel *petNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,  y, 120, 26)];
							[petNameLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
							[petNameLabel setTextColor:[UIColor whiteColor]];
							[petNameLabel setText:petName];
							[self addSubview:petNameLabel];
							y = y + 30;
						}
					}
				}
				NSString *fieldText = [docAttachDic objectForKey:@"fieldlabel"];
				
				UILabel *fieldLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, y, self.frame.size.width - 80, 28)];
				[fieldLabel setFont:[UIFont fontWithName:@"Lato-Light" size:20]];
				[fieldLabel setTextColor:[UIColor whiteColor]];
				[fieldLabel setText:fieldText];
				[self addSubview:fieldLabel];
				
				
				UIButton *buttonDoc  = [UIButton buttonWithType:UIButtonTypeCustom];
				buttonDoc.frame = CGRectMake(20, y, 32, 32);
				[buttonDoc setBackgroundImage:[UIImage imageNamed:@"fileFolder-profile"]
									 forState:UIControlStateNormal];
				[buttonDoc addTarget:self 
							  action:@selector(buttonDisplayDoc:)
					forControlEvents:UIControlEventTouchUpInside];
				buttonDoc.tag = i;
				[self addSubview:buttonDoc];
				
				y = y + 60;
			
			}
		}
        else if ([itemType isEqualToString:@"alarmInfo"]) {
            
            NSLog(@"ALARM INFO FLOATING VIEW");
            
            UIView *clientDetailView = [self buildClientHeaderView:appointmentID];
            [self addSubview:clientDetailView];

            UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(15, clientDetailView.frame.origin.y + clientDetailView.frame.size.height +20, self.frame.size.width-40, self.frame.size.height-80)];
            UIEdgeInsets inset = UIEdgeInsetsMake(3, 3, 3,3);
            scrollView.contentInset = inset;
            scrollView.contentSize = CGSizeMake(self.frame.size.width-50, 2000);
            scrollView.contentOffset = CGPointZero;
            
            [scrollView setScrollEnabled:YES];
            scrollView.showsVerticalScrollIndicator = YES;
            scrollView.delegate = self;
            [self addSubview:scrollView];
        
            [self buildAlarmInfoView:scrollView];
            
        }
        else if ([itemType isEqualToString:@"keyHomeInfo"]) {
            
            NSLog(@"Key Home Info");
            
            UIView *clientDetailView = [self buildClientHeaderView:appointmentID];
            [self addSubview:clientDetailView];
            
            UIView *keyView = [self buildKeyView:appointmentID 
                                       atYoffset:clientDetailView.frame.origin.y + clientDetailView.frame.size.height];
            [self addSubview:keyView];
            
        } else if ([itemType isEqualToString:@"justHome"]) {
            
            NSLog(@"Key Home Info");
            UIView *clientDetailView = [self buildClientHeaderView:appointmentID];
            [self addSubview:clientDetailView];
            
            UIView *keyView = [self buildKeyView:appointmentID 
                                       atYoffset:clientDetailView.frame.origin.y + clientDetailView.frame.size.height];
            [self addSubview:keyView];
        }
	}
	return self;
}


-(UIView*) buildClientHeaderView:(NSString*)appointmentID {
    
    UIView *clientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 80)];
    
    UILabel *clientNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, self.frame.size.width - 40, 24)];
    [clientNameLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
    [clientNameLabel setTextColor:[UIColor whiteColor]];
    [clientNameLabel setText:currentClient.clientName];
    [clientNameLabel setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 74, self.frame.size.width - 40, 24)];
    [addressLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
    [addressLabel setTextColor:[UIColor whiteColor]];
    
    if (![currentClient.street1 isEqual:[NSNull null]] && [currentClient.street1 length] > 0
        && ![currentClient.street2 isEqual:[NSNull null]] && [currentClient.street2 length] > 0) {
        
        NSString *addressString;
        addressString = [NSString stringWithFormat:@"%@, %@", currentClient.street1, currentClient.street2];
        [addressLabel setText:currentClient.street1];
        [addressLabel setTextAlignment:NSTextAlignmentCenter];
        
    } else if (![currentClient.street1 isEqual:[NSNull null]] && [currentClient.street1 length] > 0) {
        
        [addressLabel setText:currentClient.street1];
        [addressLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    UIImageView *divider = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressLabel.frame.origin.y + addressLabel.frame.size.height +4, self.frame.size.width, 1)];
    [divider setImage:[UIImage imageNamed:@"white-line-1px"]];
    
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.frame = CGRectMake(self.frame.size.width - 40,5,32,32);
    [exitButton setBackgroundImage:[UIImage imageNamed:@"x-button"] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];

    [clientView addSubview:exitButton];
    [clientView addSubview:clientNameLabel];
    [clientView addSubview:addressLabel];
    [clientView addSubview:divider];
    
    return clientView;

}

-(UIView*) buildKeyView:(NSString*) appointmentID atYoffset:(int)yOffset{
    
    UIView *keyView = [[UIView alloc]initWithFrame:CGRectMake(10, 110, self.frame.size.width,60)];
    UIButton *keyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    keyButton.frame = CGRectMake(10, 5, 32, 60);
    [keyButton setBackgroundImage:[UIImage imageNamed:@"keyInfo"] forState:UIControlStateNormal];
    [keyView addSubview:keyButton];
    
    UILabel *keyIDLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 5, self.frame.size.width-50, 22)];
    UILabel *keyDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, keyIDLabel.frame.size.height, self.frame.size.width - 50, 36)];
    [keyIDLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [keyIDLabel setTextColor:[UIColor whiteColor]];
    
    [keyDescriptionLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    keyDescriptionLabel.numberOfLines = 2;
    [keyDescriptionLabel setTextColor:[UIColor whiteColor]];
    
    NSString *keyInfo = [NSString stringWithFormat:@"%@", currentVisit.keyID];
    NSString *keyDescription = currentVisit.keyDescriptionText;
    NSString *keyID = currentVisit.keyID;
    
    //NSLog(@"Key ID: %@, Description: %@, keyID:%@", keyInfo, keyDescription,keyID);
    
    if (currentVisit.useKeyDescriptionInstead && ![keyDescription isEqual:[NSNull null]] && [keyDescription length] > 0) {
        
        NSLog(@"Use key description instead");
        keyInfo = currentVisit.keyDescriptionText;
        [keyDescriptionLabel setText:keyInfo];
        if (![keyID isEqual:[NSNull null]] && [keyID length] > 0) {
            [keyIDLabel setText:keyInfo];
            [keyView addSubview:keyIDLabel];
            [keyView addSubview:keyDescriptionLabel];
        }
    } else if (currentVisit.noKeyRequired) {
        NSLog(@"No key required");
        keyInfo = [NSString stringWithFormat:@"NO KEY REQUIRED"];
        [keyIDLabel setText:keyInfo];
        [keyView addSubview:keyIDLabel];

        
    } else {
        if (currentVisit.hasKey) {
            NSLog(@"Has key");
            keyInfo = [NSString stringWithFormat:@"%@", keyInfo];
            [keyIDLabel setText:keyInfo];
            [keyView addSubview:keyIDLabel];

        } else {
            NSLog(@"Does not have key");
            keyInfo = [NSString stringWithFormat:@"NEED KEY: %@", currentVisit.keyID];
            [keyIDLabel setText:keyInfo];
            [keyView addSubview:keyIDLabel];

        }
    }
    
    return keyView;
    
}

-(void) buildAlarmInfoView:(UIScrollView*) scrollViewBase {
    
    int charPerLine = 20;
    int labelHeight = 0;
    int labelNumLines = 0;
    

    UILabel *alarmPhoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, scrollViewBase.frame.size.width, 40)];
    [alarmPhoneLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [alarmPhoneLabel setTextColor:[UIColor whiteColor]];
    
    UILabel *alarmPhoneDetail  = [[UILabel alloc]initWithFrame:CGRectMake(25, alarmPhoneLabel.frame.origin.y + alarmPhoneLabel.frame.size.height, scrollViewBase.frame.size.width, 40)];
    [alarmPhoneDetail setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [alarmPhoneDetail setTextColor:[UIColor whiteColor]];
    
    
    if (![currentClient.alarmCompanyPhone isEqual:[NSNull null]] && [currentClient.alarmCompanyPhone length] > 0) {
        alarmPhoneDetail.numberOfLines = 2;
        labelHeight += alarmPhoneDetail.frame.size.height;
        [alarmPhoneLabel setText:@"ALARM COMPANY PHONE"];
        [alarmPhoneDetail setText:currentClient.alarmCompanyPhone];
        [scrollViewBase addSubview:alarmPhoneLabel];
        [scrollViewBase addSubview:alarmPhoneDetail];
    }
    
    UILabel *alarmCompany = [[UILabel alloc]initWithFrame:CGRectMake(25, alarmPhoneDetail.frame.origin.y + labelHeight + 30, scrollViewBase.frame.size.width, 20)];
    [alarmCompany setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [alarmCompany setTextColor:[UIColor whiteColor]];
    [alarmCompany setText:@"ALARM COMPANY"];
    
    
    
    UILabel *alarmCompanyDetail = [[UILabel alloc]initWithFrame:CGRectMake(25 , alarmCompany.frame.origin.y + alarmCompany.frame.size.height, self.frame.size.width, 40)];
    [alarmCompanyDetail setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [alarmCompanyDetail setTextColor:[UIColor whiteColor]];
    
   
    
    if (![currentClient.alarmCompany isEqual:[NSNull null]] && [currentClient.alarmCompany length] > 0) {
        alarmCompanyDetail.numberOfLines = 2;
        [alarmCompanyDetail setText:currentClient.alarmCompany];
        [scrollViewBase addSubview:alarmCompany];
        [scrollViewBase addSubview:alarmCompanyDetail];
    }
    
    UILabel *alarmInfoDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, alarmCompany.frame.origin.y + labelHeight + 30, self.frame.size.width-80, 20)];
    [alarmInfoDetailLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:20]];
    [alarmInfoDetailLabel setTextColor:[UIColor whiteColor]];
    [alarmInfoDetailLabel setText:@"ALARM INFORMATION"];
    
    UIImageView *alarmIcon = [[UIImageView alloc]initWithFrame:CGRectMake(alarmInfoDetailLabel.frame.origin.x - 25, alarmInfoDetailLabel.frame.origin.y, 25, 25)];
    [alarmIcon setImage:[UIImage imageNamed:@"alarmCode"]];
    
    UILabel *alarmInfoDetail;
    
    if (![currentClient.alarmInfo isEqual:[NSNull null]] && [currentClient.alarmInfo length] > 0) {
        labelHeight = [self heightForLabel:currentClient.alarmInfo fontSize:18];
        labelNumLines = labelHeight / charPerLine;

        if (labelHeight < 42) {
            labelHeight = 44;
        }
        if(labelNumLines <= 1) {
            labelNumLines = 2;
        }
        alarmInfoDetail= [[UILabel alloc]initWithFrame:CGRectMake(25,alarmInfoDetailLabel.frame.origin.y + 20, self.frame.size.width-80, labelHeight)];
        alarmInfoDetail.numberOfLines = labelNumLines;
        [alarmInfoDetail setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [alarmInfoDetail setTextColor:[UIColor whiteColor]];
        [alarmInfoDetail setText:currentClient.alarmInfo];
        [scrollViewBase addSubview:alarmInfoDetailLabel];
        [scrollViewBase addSubview:alarmIcon];
        [scrollViewBase addSubview:alarmInfoDetail];
    }

    UILabel *garageGateCodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, alarmInfoDetail.frame.size.height + alarmInfoDetail.frame.origin.y +30, self.frame.size.width-40, 24)];
    [garageGateCodeLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [garageGateCodeLabel setTextColor:[UIColor whiteColor]];
    [garageGateCodeLabel setText:@"GARAGE / GATE CODE"];
    UIImageView *garageGateIcon = [[UIImageView alloc]initWithFrame:CGRectMake(garageGateCodeLabel.frame.origin.x - 20, garageGateCodeLabel.frame.origin.y, 20, 20)];
    [garageGateIcon setImage:[UIImage imageNamed:@"garageGateCode"]]; 
    UILabel *garageGateCodeDetail;
     
    if (![currentClient.garageGateCode isEqual:[NSNull null]] && [currentClient.garageGateCode length] > 0) {
        int garageLabelHeight = [self heightForLabel:currentClient.garageGateCode fontSize:18];
        int gLines = garageLabelHeight / charPerLine;
        if (garageLabelHeight < 42) {
            garageLabelHeight = 44;
        }
        if (gLines <= 1) {
            gLines = 2;
        }
        garageGateCodeDetail= [[UILabel alloc]initWithFrame:CGRectMake(25, garageGateCodeLabel.frame.origin.y + 30, self.frame.size.width-80, garageLabelHeight)];
        garageGateCodeDetail.numberOfLines = gLines;
        [garageGateCodeDetail setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [garageGateCodeDetail setTextColor:[UIColor whiteColor]];
        [garageGateCodeDetail setText:currentClient.garageGateCode];
        [scrollViewBase addSubview:garageGateCodeDetail];
        [scrollViewBase addSubview:garageGateIcon];
        [scrollViewBase addSubview:garageGateCodeLabel];
    }   
    
    UILabel *parkingLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, garageGateCodeDetail.frame.size.height + garageGateCodeLabel.frame.origin.y +30, self.frame.size.width-40, 24)];
    [parkingLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [parkingLabel setTextColor:[UIColor whiteColor]];
    [parkingLabel setText:@"PARKING INFO"];
    UILabel *parkingDetails;
     
    if (![currentClient.parkingInfo isEqual:[NSNull null]] && [currentClient.parkingInfo length] > 0) {
        int parkingInfoLabelHeight = [self heightForLabel:currentClient.parkingInfo fontSize:18];
        int pLines = parkingInfoLabelHeight / charPerLine;
        
        if (parkingInfoLabelHeight < 42) {
            parkingInfoLabelHeight = 44;
        }
        if (pLines <= 1) {
            pLines = 2;
        }
        parkingDetails= [[UILabel alloc]initWithFrame:CGRectMake(25, parkingLabel.frame.origin.y + 30, self.frame.size.width-80, parkingInfoLabelHeight)];
        parkingDetails.numberOfLines = pLines;
        
        //NSLog(@"height: %f, num line: %li", parkingDetails.frame.size.height, (long)parkingDetails.numberOfLines);
        
        [parkingDetails setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [parkingDetails setTextColor:[UIColor whiteColor]];
        [parkingDetails setText:currentClient.parkingInfo];
        [scrollViewBase addSubview:parkingDetails];
        [scrollViewBase addSubview:parkingLabel];
    }   
    
    UILabel *directionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, parkingDetails.frame.size.height + parkingDetails.frame.origin.y +30, self.frame.size.width-40, 20)];
    [directionsLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:18]];
    [directionsLabel setTextColor:[UIColor whiteColor]];
    [directionsLabel setText:@"DIRECTIONS INFO"];
    UILabel *directionsDetails;
     
    if (![currentClient.directionsInfo isEqual:[NSNull null]] && [currentClient.directionsInfo length] > 0) {
        int directionsLabelHeight = [self heightForLabel:currentClient.directionsInfo fontSize:18];
        int dLines = directionsLabelHeight / charPerLine;
        
        if (directionsLabelHeight < 42) {
            directionsLabelHeight = 44;
        }
        if (dLines <= 1) {
            dLines = 2;
        }
        
        directionsDetails= [[UILabel alloc]initWithFrame:CGRectMake(25, directionsLabel.frame.size.height + directionsLabel.frame.origin.y + 30, self.frame.size.width-80, directionsLabelHeight)];
        directionsDetails.numberOfLines = dLines;
        [directionsDetails setFont:[UIFont fontWithName:@"Lato-Regular" size:18]];
        [directionsDetails setTextColor:[UIColor whiteColor]];
        [directionsDetails setText:currentClient.directionsInfo];
        [scrollViewBase addSubview:directionsDetails];
        [scrollViewBase addSubview:directionsLabel];
    } 
}

-(void) showDocAttach:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *docButton = (UIButton *)sender;
        NSString *appointmentIDString = [NSString stringWithFormat:@"%li", (long)docButton.tag];
        
        FloatingModalView *docAttachView = [[FloatingModalView alloc]initWithFrame:self.frame appointmentID:appointmentIDString itemType:@"oneDoc" ];
        [docAttachView show];
    }
}
-(void) showDocAttachMulti:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *docButton = (UIButton *)sender;
        NSString *appointmentIDString = [NSString stringWithFormat:@"%li", (long)docButton.tag];
        
        FloatingModalView *docAttachView = [[FloatingModalView alloc]initWithFrame:self.frame appointmentID:appointmentIDString itemType:@"multiDoc" ];
        [docAttachView show];
    }
}
-(void) buttonDisplayDoc:(id)sender {
	
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *buttonDoc = (UIButton*) sender;
		int indexDoc = (int)buttonDoc.tag;
		[buttonDoc removeFromSuperview];
		
		NSArray *childrenView = [self subviews];
		for (UIView *view in childrenView) {
			[view removeFromSuperview];
		}
		
		webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 40, self.frame.size.width, self.frame.size.height)];
		[self addSubview:webView];
		if ([[currentVisit getErrataDocItems] objectAtIndex:indexDoc] != NULL) {
			NSDictionary *errataDic = [[currentVisit getErrataDocItems] objectAtIndex:indexDoc];
			NSString *label = [errataDic objectForKey:@"label"];
			//NSString *mimeType = [errataDic objectForKey:@"mimetype"];
			NSString *errataURL = [errataDic objectForKey:@"url"];
			NSURL *doc = [NSURL URLWithString:errataURL];
			NSURLRequest *request = [NSURLRequest requestWithURL:doc];
			[webView loadRequest:request];
			
			UILabel *docLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, webView.frame.size.width-40, 40)];
			[docLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:16]];
			[docLabel setTextColor:[UIColor whiteColor]];
			[docLabel setTextAlignment:NSTextAlignmentCenter];
			docLabel.numberOfLines = 2;
			[docLabel setText:label];
			[self addSubview:docLabel];
			
			UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
			exitButton.frame = CGRectMake(5,5,24,24);
			[exitButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
			[exitButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:exitButton];
		
		} else { 
		}
	}
	
}

-(void)show {
	UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (topController.presentedViewController) {
		topController = topController.presentedViewController;
	}
	
	UIView *superview = topController.view;
	[superview addSubview:self];
	[superview layoutIfNeeded];
	[self layoutIfNeeded];
	[UIView animateWithDuration:0.2
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 [superview layoutIfNeeded];
					 }
					 completion:nil];

}

-(void) dismissView:(id)sender {
	
    NSLog(@"Dismiss edit view");
	if([sender isKindOfClass:[UIButton class]]) {
		UIButton *dismiss = (UIButton*)sender;
		[dismiss removeFromSuperview];
		[webView removeFromSuperview];
		webView = nil;
		dismiss = nil;
	}
	
	[self removeFromSuperview];
}

-(int)heightForLabel:(NSString*)label fontSize:(int)fontSize {
    
    int numChar = (int)[label length];

    NSLog(@"Num char per line: %i  len: %i", char_per_line, numChar);
    //NSLog(@"%@",label);
    
    int heightLabel = (numChar / char_per_line) * 22 + 5;
    if (heightLabel == 0) {
        heightLabel = 24;
    }
    

    return heightLabel;
    
}                   


@end

