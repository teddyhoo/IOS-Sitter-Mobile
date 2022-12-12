//
//  PetPicture.m
//  LeashTimeSitter
//
//  Created by Ted Hooban on 10/24/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import "PetPicture.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VisitsAndTracking.h"

@implementation PetPicture  {
    UIImagePickerController *picker;
    NSString *photoVisitID;
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
}


-(instancetype)init {
    self = [super init];
    if(self) {
    }
    return self;
}

-(void)setVisitID:(NSString*)visitID {
    photoVisitID = visitID;
}


- (void)didMoveToParentViewController:(UIViewController *)parent {
    [self setupView];
}

-(void)removeFromParentViewController {
    NSLog(@"Removing photo view controller");
    photoVisitID = nil;
    [picker removeFromParentViewController];
    picker.delegate  = nil;

   // imageViewPhoto.image = nil;
    //imageViewPhoto = nil;
    picker = nil;
}
-(void) setupView {
	//imageViewPhoto = [[UIImageView alloc]init];
	
	if ([[[VisitsAndTracking sharedInstance] tellDeviceType]isEqualToString:@"iPhone6P"]) {
		isIphone6P = YES;
		isIphone6 = NO;
		isIphone5 = NO;
		isIphone4 = NO;
	} else if ([[[VisitsAndTracking sharedInstance] tellDeviceType]isEqualToString:@"iPhone6"]) {
		isIphone6 = YES;
		isIphone6P = NO;
		isIphone5 = NO;
		isIphone4 = NO;
	} else if ([[[VisitsAndTracking sharedInstance] tellDeviceType]isEqualToString:@"iPhone5"]) {
		isIphone5 = YES;
		isIphone6P = NO;
		isIphone4 = NO;
		isIphone6 = NO;
	} else if ([[[VisitsAndTracking sharedInstance] tellDeviceType]isEqualToString:@"iPhone4"]) {
		isIphone4 = YES;
		isIphone6 = NO;
		isIphone5 = NO;
		isIphone6P = NO;
	}
    
    picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                         UIImagePickerControllerSourceTypeCamera];
    picker.delegate = self;
    
    UIImagePickerController *pickerTemp = picker;
    
    [self presentViewController:picker animated:YES completion:^{
        // After pic taken but before edit and Use Photo
        UIButton *galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        galleryButton.frame =CGRectMake(pickerTemp.view.frame.size.width - 140, pickerTemp.view.frame.size.height - 100, 60, 60);
        [galleryButton setBackgroundImage:[UIImage imageNamed:@"btnDefault"] 
                                 forState:UIControlStateNormal];
        [galleryButton addTarget:self 
                          action:@selector(switchGallery:)
                forControlEvents:UIControlEventTouchUpInside];
        [pickerTemp.view addSubview:galleryButton];
        
    }];
}

-(void)switchGallery:(id)sender {
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *tapButton = (UIButton*)sender;
        [self imagePickerControllerDidCancel:picker];
        [self pickPhotoFromPhotoCollection:tapButton];
    }
}
-(void)finishedPhoto {
    
    NSLog(@"Finished photo");
    [picker removeFromParentViewController];
    picker = nil;
    
    /*[self.view removeFromSuperview];
    self.view = nil;*/
}
- (void)takePicture:(UIButton*)sender
{
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.allowsEditing = YES;
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
						 UIImagePickerControllerSourceTypeCamera];
	picker.delegate = self;
	
	[self presentViewController:picker animated:YES completion:^{
        /*UIButton *takePic3 = [UIButton buttonWithType:UIButtonTypeCustom];
        takePic3.frame = CGRectMake(self.view.frame.size.width/1.5, 15, 80, 60);
        [takePic3 setBackgroundImage:[UIImage imageNamed:@"photo-stack-4"] forState:UIControlStateNormal];
        [takePic3 addTarget:self action:@selector(pickPhotoFromPhotoCollection:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:takePic3];       */
        //NSLog(@"SHOULD BE SHOWING CAMERA CONTROLLER");
    }];
}
-(void)pickPhotoFromPhotoCollection:(UIButton *)sender {
    //NSLog(@"Pick photo from photo collection");
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.allowsEditing = YES;
	picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	picker.delegate = self;
	[self presentViewController:picker animated:YES completion:^{
        NSLog(@"Pick photo present view controller");

	}];
}
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage
          didFinishSavingWithError:(NSError*)paramError
                       contextInfo:(void*)paramContextInfo {
    
    NSLog(@"Image saved successfully");
    if (paramError == nil) {
        [self finishedPhoto];
    } else {
        NSLog(@"Error saving image: %@", paramError);

    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	/*NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if(CFStringCompare((CFStringRef) mediaType, kUTTypeImage,0) == kCFCompareEqualTo) {
		UIImage *editedImg = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
        [[VisitsAndTracking sharedInstance]addPictureForPet:editedImg forVisitWithID:photoVisitID];
    NSLog(@"Adding image to VisitDetails");
    
        [[VisitsAndTracking sharedInstance]addPictureForPet:(UIImage*)[info objectForKey:UIImagePickerControllerEditedImage] forVisitWithID:photoVisitID];

    }
 
    */
    [picker setDelegate:nil];
    //[picker removeFromParentViewController];

	[picker dismissViewControllerAnimated:YES completion:^{
        //picker.delegate = nil;
        [picker removeFromParentViewController];

    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    picker.delegate = nil;

    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}
-(BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
-(BOOL)doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}
-(BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType {
    NSLog(@"Camera supports media called");
    
    __block BOOL result = NO;
    
    if([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = YES;
        *stop = YES;
    }];
    return result;
}
- (void)viewDidLoad {
    //NSLog(@"Pet Pic view did load");
    [super viewDidLoad];
}
-(void)dealloc
{
    //NSLog(@"DEALLOC: PET PIC CONTROLLER");
    //[imageViewPhoto removeFromSuperview];
    //imageViewPhoto.image = nil;
   // imageViewPhoto = nil;
    self.view = nil;
}
@end
