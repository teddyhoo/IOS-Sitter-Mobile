//
//  PetPicture.h
//  LeashTimeSitter
//
//  Created by Ted Hooban on 10/24/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PetPicture : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

-(void)setVisitID:(NSString*)visitID;

@end
