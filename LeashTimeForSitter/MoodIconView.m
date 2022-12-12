//
//  MoodIconView.m
//  LeashTimeForSitter
//
//  Created by Edward Hooban on 9/4/19.
//  Copyright © 2019 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoodIconView.h"
#import "VisitsAndTracking.h"

@interface MoodIconView() {
    VisitsAndTracking *sharedVisits;
    VisitDetails *visitInfo;
    __weak  VisitProgressView *parentViewRef;    
    
    NSMutableArray *moodButtonArray;
    NSNumber *clientID;
    NSNumber *currentVisitID;
    int char_per_line;
    BOOL keyboardVisible;
    
}
@end

@implementation MoodIconView 

-(instancetype)initWithFrame:(CGRect)frame 
                   visitInfo:(VisitDetails*)visit 
                  clientInfo:(DataClient*)client 
                  parentView:(VisitProgressView*)parent {
    
    parentViewRef = parent;
    visitInfo = visit;
    currentVisitID =[[[NSNumberFormatter alloc] init] numberFromString:visit.appointmentid];
    clientID = [[[NSNumberFormatter alloc] init] numberFromString:client.clientID];

    return [self initWithFrame:frame];
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        sharedVisits = [VisitsAndTracking sharedInstance];
        [self setBackgroundColor:[[sharedVisits getColorPalette] objectForKey:@"defaultDark"]];
        
        NSString *pListData = [[NSBundle mainBundle]
                               pathForResource:@"MoodButtons"
                               ofType:@"plist"];
        moodButtonArray = [[NSMutableArray alloc]initWithContentsOfFile:pListData];
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = CGRectMake(5, 30, 160, 30);
        [dismissButton setBackgroundImage:[UIImage imageNamed:@"btn-small-saveclose"] 
                                 forState:UIControlStateNormal];
        [dismissButton addTarget:self 
                          action:@selector(moodDismiss:) 
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
        
        int yButton = 120;
        int xButton = 40;
        int tagID = 0;
        int rowCount = 1;
        
        for (NSDictionary *moodDic in moodButtonArray) {
            NSString *moodText = [moodDic objectForKey:@"Label"];
            
            UIImage *buttonImage = [UIImage imageNamed:[moodDic objectForKey:@"Filename"]];
            UIImage *buttonOnImage = [UIImage imageNamed:[moodDic objectForKey:@"Color"]];
            
            UIButton *moodButton = [UIButton buttonWithType:UIButtonTypeCustom];
            moodButton.frame = CGRectMake(xButton,yButton,60,60);
            [moodButton setImage:buttonImage forState:UIControlStateNormal];
            [moodButton setImage:buttonOnImage forState:UIControlStateSelected];
            [moodButton addTarget:self
                           action:@selector(tapMoodButton:)
                 forControlEvents:UIControlEventTouchUpInside];
            moodButton.tag = tagID;
            tagID++;

            if (rowCount == 3 || rowCount ==6) {
                xButton = 40;
                yButton = yButton + 120;
            } else {
                xButton  = xButton + 80;
            }
            
            UILabel *moodNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(moodButton.frame.origin.x, moodButton.frame.origin.y-15, self.frame.size.width - moodButton.frame.origin.x + (moodButton.frame.size.width), 20)];
            [moodNameLabel setTextAlignment:NSTextAlignmentLeft];
            [moodNameLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:12
                                    ]];
            [moodNameLabel setTextColor:[UIColor blackColor]];
            [moodNameLabel setText:[moodDic objectForKey:@"Label"]];

            
            if([self checkVisitMood:moodText]) {
                [moodButton setSelected:YES];
            }
            [self addSubview:moodButton];
            [self addSubview:moodNameLabel];
            rowCount++;
        }
    }
    return self;
}
-(void) moodDismiss:(id)sender {

    [visitInfo writeVisitDataToFile];
    [parentViewRef updateMoodView:sender];

    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
-(BOOL) checkVisitMood:(NSString *)moodDescription {    
    if ([moodDescription isEqualToString:@"PEE"] && visitInfo.didPee) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"POO"] && visitInfo.didPoo) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"TREAT"] && visitInfo.gaveTreat) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"WATER"] && visitInfo.gaveWater) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"TOWEL"] && visitInfo.dryTowel) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"INJECTION"] && visitInfo.gaveInjection) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"MEDICATION"] && visitInfo.gaveMedication) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"FEED"] && visitInfo.didFeed) {
        return TRUE;
    } else if ([moodDescription isEqualToString:@"PLAY"] && visitInfo.didPlay) {
        return TRUE;
    } else {
        return FALSE;
    }
}
-(void) tapMoodButton:(id)sender {
    UIButton *moodButton;

    //moodButtonTag = moodButtonTag + 1;
    if([sender isKindOfClass:[UIButton class]]) {
        moodButton = (UIButton*)sender;
        int moodButtonTag = (int)moodButton.tag;
        if ([moodButton isSelected]) {
            NSDictionary *moodDic = [moodButtonArray objectAtIndex:moodButtonTag];
            [self setVisitMoodOff:[moodDic objectForKey:@"Label"]];
            [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [moodButton setAlpha:0.5];
            } completion:^(BOOL finished) {
                [moodButton setSelected:NO];
            }];
        }  else {
            
            //CGRect originalFrame = moodButton.frame;
            NSDictionary *moodDic = [moodButtonArray objectAtIndex:moodButtonTag];
            [self setVisitMood:[moodDic objectForKey:@"Label"]];
            [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [moodButton setAlpha:1.0];
                } completion:^(BOOL finished) {
                    [moodButton setSelected:YES];
            }];
        }
    }
}


-(void) setVisitMood:(NSString *)moodDescription {
            
    if ([moodDescription isEqualToString:@"PEE"]) {
        visitInfo.didPee = YES;
    } else if ([moodDescription isEqualToString:@"POO"]) {
        visitInfo.didPoo = YES;
    } else if ([moodDescription isEqualToString:@"TREAT"]) {
        visitInfo.gaveTreat = YES;
    } else if ([moodDescription isEqualToString:@"WATER"]) {
        visitInfo.gaveWater = YES;
    } else if ([moodDescription isEqualToString:@"TOWEL"]) {
        visitInfo.dryTowel = YES;
    } else if ([moodDescription isEqualToString:@"INJECTION"]) {
        visitInfo.gaveInjection = YES;
    } else if ([moodDescription isEqualToString:@"MEDICATION"]) {
        visitInfo.gaveMedication= YES;
    } else if ([moodDescription isEqualToString:@"FEED"]) {
        visitInfo.didFeed = YES;
    } else if ([moodDescription isEqualToString:@"PLAY"]) {
        visitInfo.didPlay= YES;
    } 
    
}
-(void) setVisitMoodOff:(NSString *)moodDescription {
    
    if ([moodDescription isEqualToString:@"PEE"]) {
        visitInfo.didPee = NO;
    } else if ([moodDescription isEqualToString:@"POO"]) {
        visitInfo.didPoo = NO;
    } else if ([moodDescription isEqualToString:@"TREAT"]) {
        visitInfo.gaveTreat = NO;
    } else if ([moodDescription isEqualToString:@"WATER"]) {
        visitInfo.gaveWater = NO;
    } else if ([moodDescription isEqualToString:@"TOWEL"]) {
        visitInfo.dryTowel = NO;
    } else if ([moodDescription isEqualToString:@"INJECTION"]) {
        visitInfo.gaveInjection = NO;
    } else if ([moodDescription isEqualToString:@"MEDICATION"]) {
        visitInfo.gaveMedication= NO;
    } else if ([moodDescription isEqualToString:@"FEED"]) {
        visitInfo.didFeed= NO;
    } else if ([moodDescription isEqualToString:@"PLAY"]) {
        visitInfo.didPlay= NO;
    } 
}

@end
