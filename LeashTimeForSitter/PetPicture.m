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
    

    //UIImageView *petPicture;

    VisitsAndTracking *sharedInstance;
	UIImageView *imageViewPhoto;

	
    BOOL isIphone4;
    BOOL isIphone5;
    BOOL isIphone6;
    BOOL isIphone6P;
	
}


-(instancetype)init {
    
    
    self = [super init];
    
    if(self) {
        
        //NSLog(@"PET PIC VC: INIT");
		sharedInstance = [VisitsAndTracking sharedInstance];
    }
    return self;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    //NSLog(@"PET PIC VC: DID MOVE PARENT VIEW");
    [self setupView];
}

-(void)removeFromParentViewController {
    
	//NSLog(@"PET PIC VC: REMOVE PARENT VIEW");
    [imageViewPhoto removeFromSuperview];
    imageViewPhoto.image = nil;
    imageViewPhoto = nil;
	[self.view removeFromSuperview];
	self.view = nil;

}

-(void)dealloc
{
    
    
    //NSLog(@"DEALLOC: PET PIC CONTROLLER");
	[imageViewPhoto removeFromSuperview];
	imageViewPhoto.image = nil;
	imageViewPhoto = nil;
    self.view = nil;

    
}

-(void) setupView {
	
	imageViewPhoto = [[UIImageView alloc]init];
	//NSLog(@"setup photo view");
	
	
	if ([[sharedInstance tellDeviceType]isEqualToString:@"iPhone6P"]) {
		//NSLog(@"is 6p");
		
		isIphone6P = YES;
		isIphone6 = NO;
		isIphone5 = NO;
		isIphone4 = NO;
		
	} else if ([[sharedInstance tellDeviceType]isEqualToString:@"iPhone6"]) {
		//NSLog(@"is 6");
		
		isIphone6 = YES;
		isIphone6P = NO;
		isIphone5 = NO;
		isIphone4 = NO;
		
	} else if ([[sharedInstance tellDeviceType]isEqualToString:@"iPhone5"]) {
		//NSLog(@"is 5");
		
		isIphone5 = YES;
		isIphone6P = NO;
		isIphone4 = NO;
		isIphone6 = NO;
		
		
	} else if ([[sharedInstance tellDeviceType]isEqualToString:@"iPhone4"]) {
		//NSLog(@"is4");
		
		isIphone4 = YES;
		isIphone6 = NO;
		isIphone5 = NO;
		isIphone6P = NO;
		
		
	}
	
	
	UIImageView *background = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[background setImage:[UIImage imageNamed:@"BG-plainBlue"]];
	background.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:background];
	
	UIButton *takePic = [UIButton buttonWithType:UIButtonTypeCustom];
	takePic.frame = CGRectMake(self.view.frame.size.width/4, 15, 60, 60);
	[takePic setBackgroundImage:[UIImage imageNamed:@"take-pic"] forState:UIControlStateNormal];
	[takePic addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:takePic];
	
	UIButton *takePic3 = [UIButton buttonWithType:UIButtonTypeCustom];
	takePic3.frame = CGRectMake(self.view.frame.size.width/1.5, 15, 80, 60);
	[takePic3 setBackgroundImage:[UIImage imageNamed:@"photo-stack-4"] forState:UIControlStateNormal];
	[takePic3 addTarget:self action:@selector(pickPhotoFromPhotoCollection:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:takePic3];
	
	UIImageView *petPicture;
	
	if (isIphone4) {
		petPicture = [[UIImageView alloc]initWithFrame:CGRectMake(20, 100, 270,300)];
		[petPicture setImage:[UIImage imageNamed:@"photo-frame-513x687"]];
		imageViewPhoto.frame = CGRectMake(30, 110, 250, 230);
		
	} else if (isIphone5) {
		
		petPicture = [[UIImageView alloc]initWithFrame:CGRectMake(20, 100, 288, 352)];
		[petPicture setImage:[UIImage imageNamed:@"photo-frame-513x687"]];
		imageViewPhoto.frame = CGRectMake(25, 107, 278, 292);
		
	} else if (isIphone6) {
		
		petPicture = [[UIImageView alloc]initWithFrame:CGRectMake(25, 125, 320, 380)];
		[petPicture setImage:[UIImage imageNamed:@"photo-frame-513x687"]];
		imageViewPhoto.frame = CGRectMake(30, 132, 308, 310);
		
	} else if (isIphone6P) {
		
		petPicture = [[UIImageView alloc]initWithFrame:CGRectMake(25, 125, 320, 380)];
		[petPicture setImage:[UIImage imageNamed:@"photo-frame-513x687"]];
		imageViewPhoto.frame = CGRectMake(30, 132, 308, 310);
		
	} else {
		petPicture = [[UIImageView alloc]initWithFrame:CGRectMake(25, 125, 320, 380)];
		[petPicture setImage:[UIImage imageNamed:@"photo-frame-513x687"]];
		imageViewPhoto.frame = CGRectMake(30, 132, 308, 310);
		
		
	}
	
	[self.view addSubview:petPicture];
	[self.view addSubview:imageViewPhoto];

	sharedInstance = [VisitsAndTracking sharedInstance];

	/*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths firstObject];


	for(VisitDetails *visitImage in sharedInstance.visitData) {
		if ([visitImage.appointmentid isEqualToString:sharedInstance.onWhichVisitID]) {

			int x = 20;
			int iter = 1;
			int imgDimension = 80;
			for(NSString *imageFileName in visitImage.petPhotosFileNames) {


				NSString *imagePath = [documentsPath stringByAppendingPathComponent:imageFileName];
				UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

				UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
				imageButton.frame = CGRectMake(x, self.view.frame.size.height-200, imgDimension,imgDimension);
				imageButton.tag = iter - 1;
				[imageButton setBackgroundImage:image forState:UIControlStateNormal];
				[imageButton addTarget:self
								action:@selector(imageChose:)
					  forControlEvents:UIControlEventTouchUpInside];
				[self.view addSubview:imageButton];
				x = (iter * imgDimension) +40;
				iter++;


			}
		}
	}*/
}

-(void) imageChose:(id)sender {

	if ([sender isKindOfClass:[UIButton class]]) {

		UIButton *tapButton = (UIButton*) sender;
		[tapButton setAlpha:0.5];
	}
}


- (void)viewDidLoad {
    
    //NSLog(@"Pet Pic view did load");
    
    [super viewDidLoad];


}


-(BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
-(BOOL)doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}
-(BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType {
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
		//NSLog(@"presenting picture taker controller");
	}];
}


-(void)pickPhotoFromPhotoCollection:(UIButton *)sender {

	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.allowsEditing = YES;
	picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
						 UIImagePickerControllerSourceTypePhotoLibrary];
	picker.delegate = self;
	[self presentViewController:picker animated:YES completion:^{
		
		
	}];
		
}

- (void) imageWasSavedSuccessfully:(UIImage *)paramImage
          didFinishSavingWithError:(NSError*)paramError
                       contextInfo:(void*)paramContextInfo {
    
    if (paramError == nil) {

    } else {
        //NSLog(@"Error = %@",paramError);
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	NSLog(@"Chose or took image picture");
	NSString *mediatType = [info objectForKey:UIImagePickerControllerMediaType];
	if(CFStringCompare((CFStringRef) mediatType, kUTTypeImage,0) == kCFCompareEqualTo) {
		UIImage *editedImg = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
		[imageViewPhoto setImage:editedImg];
		[[VisitsAndTracking sharedInstance]addPictureForPet:editedImg];
	}
 
	[picker dismissViewControllerAnimated:YES completion:^{
		picker.delegate = nil;
	}];

	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
