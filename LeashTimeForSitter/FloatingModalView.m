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


@interface FloatingModalView() {
	
	VisitDetails *currentVisit;
	DataClient *currentClient;
	WKWebView *webView;
	
}
@end


@implementation FloatingModalView  

-(id)init {
	self = [super init];
	if(self){
		
	}
	return self;
}

-(instancetype)initWithFrame:(CGRect)frame 
			   appointmentID:(NSString*)appointmentID 
					itemType:(NSString*)itemType {
	
	if (self = [super initWithFrame:frame]) {
		
		_sharedVisits = [VisitsAndTracking sharedInstance];

		for(VisitDetails *visitInfo in _sharedVisits.visitData) {
			if ([visitInfo.appointmentid isEqualToString:appointmentID]) {
				currentVisit = visitInfo;
				for(DataClient *client in _sharedVisits.clientData) {
					if([currentVisit.clientptr isEqualToString:client.clientID]) {
						currentClient = client;
					}
				}
			}
		}

		[self setBackgroundColor:[UIColor clearColor]];

		if ([itemType isEqualToString:@"oneDoc"]) {
			webView= [[WKWebView alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+20, self.frame.size.width-10, self.frame.size.height)];
			[self addSubview:webView];
			
			NSDictionary *errataDic = [currentVisit.docItems objectAtIndex:0];
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
		
		} else if ([itemType isEqualToString:@"multiDoc"]) {
			
			int y  = 60;
			int numDoc = (int)[currentVisit.docItems count];
			
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
				
				NSDictionary *docAttachDic = [currentVisit.docItems objectAtIndex:i];
				NSString *petID;
				NSString *petName;
				
				if ([docAttachDic objectForKey:@"petid"] != NULL) {
					petID =  [docAttachDic objectForKey:@"petid"] ;
					for (NSDictionary *petDict in currentClient.petInfo) {
						
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
	}
	return self;
}

-(instancetype)initWithFrame:(CGRect)frame 
			   appointmentID:(NSString*)appointmentID 
					itemType:(NSString*)itemType 
				   andTagNum:(int)tagNum {
	
	if (self = [super initWithFrame:frame]) {
		
		_sharedVisits = [VisitsAndTracking sharedInstance];
		
		for(VisitDetails *visitInfo in _sharedVisits.visitData) {
			if ([visitInfo.appointmentid isEqualToString:appointmentID]) {
				currentVisit = visitInfo;
				for(DataClient *client in _sharedVisits.clientData) {
					if([currentVisit.clientptr isEqualToString:client.clientID]) {
						currentClient = client;
					}
				}
			}
		}
		
		NSString *tagNumIndex = [NSString stringWithFormat:@"%i",tagNum];
		
		for (NSDictionary* errataDic in currentClient.errataDoc) {
			NSString *tagIndexMatch = [errataDic objectForKey:@"errataIndex"];
			if ([tagNumIndex isEqualToString:tagIndexMatch]) {
				NSString *label = [errataDic objectForKey:@"label"];
				NSString *mimeType = [errataDic objectForKey:@"mimetype"];
				NSString *errataURL = [errataDic objectForKey:@"url"];
				
				NSURL *doc = [NSURL URLWithString:errataURL];
				NSData *docData = [NSData dataWithContentsOfURL:doc];
				webView= [[WKWebView alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+20, self.frame.size.width-10, self.frame.size.height)];
				[self addSubview:webView];
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
		}
	}
	return self;
	
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
		if ([currentVisit.docItems objectAtIndex:indexDoc] != NULL) {
			NSDictionary *errataDic = [currentVisit.docItems objectAtIndex:indexDoc];
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
	
	if([sender isKindOfClass:[UIButton class]]) {
		UIButton *dismiss = (UIButton*)sender;
		[dismiss removeFromSuperview];
		[webView removeFromSuperview];
		webView = nil;
		dismiss = nil;
	}
	
	[self removeFromSuperview];
}

@end

