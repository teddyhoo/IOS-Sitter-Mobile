//
//  EMAccordionTableViewController.m
//  UChat
//
//  Created by Ennio Masi on 10/01/14.
//  Copyright (c) 2014 Hippocrates Sintech. All rights reserved.
//

#import "EMAccordionTableViewController.h"
#import "EMAccordionTableParallaxHeaderView.h"
#import "PharmaStyle.h"
#import <QuartzCore/QuartzCore.h>

#define kSectionTag 1110
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface EMAccordionTableViewController () {
    UITableViewStyle emTableStyle;
    NSMutableArray *sections;
    NSMutableArray *sectionsOpened;
    NSObject <EMAccordionTableDelegate> *emDelegate;
    EMAnimationType animationType;
    NSInteger showedCell;
    //UITableView *dTableView;
    UIImage *closedSectionIcon;
    UIImage *openedSectionIcon;
}

@end

@implementation EMAccordionTableViewController

//@synthesize closedSectionIcon = _closedSectionIcon;
//@synthesize openedSectionIcon = _openedSectionIcon;
//@synthesize parallaxHeaderView = _parallaxHeaderView;
@synthesize tableView = _tableView;
@synthesize sectionsHeaders = _sectionsHeaders;
@synthesize defaultOpenedSection = _defaultOpenedSection;

- (void)viewDidLoad {
    [super viewDidLoad];
    showedCell = 0;
}

-(void) setClosedSectionIcon:(UIImage*)closeIcon {
    closedSectionIcon = closeIcon;
}

-(void) setOpenedSectionIcon:(UIImage*)openIcon {
    openedSectionIcon = openIcon;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Exposed Methods
- (void) setEmTableView:(UITableView *)tv {
    self.view = [[UIView alloc] initWithFrame:tv.frame];
    
    //dTableView  = tv;
    //[dTableView setDataSource:self];
    //[dTableView setDelegate:self];
    //[self.view addSubview:dTableView];
    _tableView = tv;
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    
    
}

- (id) initWithTable:(UITableView *)tableView withAnimationType:(EMAnimationType) type {
    if (self = [super init]) {
        self.view = [[UIView alloc] initWithFrame:tableView.frame];
        //dTableView = tableView;
        //[dTableView setDataSource:self];
        //[dTableView setDelegate:self];
        
        _tableView = tableView;
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        
        animationType = type;
        sections = [[NSMutableArray alloc] initWithCapacity:10];
        sectionsOpened = [[NSMutableArray alloc] initWithCapacity:10];
        _openedSection = -1;
        
        self.sectionsHeaders = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void) addAccordionSection: (EMAccordionSection *) section initiallyOpened:(BOOL)opened {
    [sections addObject:section];
	NSUInteger count = [sections count]-1;
    if (opened) {
        [sectionsOpened setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:count];
	} else {
		[sectionsOpened setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:count];

	}
}

- (void) setParallaxHeaderView:(EMAccordionTableParallaxHeaderView *)parallaxHeaderView {
    //_parallaxHeaderView = parallaxHeaderView;
    if(_tableView) {
        [_tableView setTableHeaderView:parallaxHeaderView];
    }
   // if (dTableView) {
    //    [dTableView setTableHeaderView:_parallaxHeaderView];
    //}
}


#pragma mark UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return sections.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    BOOL value = [[sectionsOpened objectAtIndex:section] boolValue];
    if (value) {
        return 1;
    } else {
        return 0;
    }
	return 1;
}


- (void) setDelegate: (NSObject <EMAccordionTableDelegate> *) delegate {
	emDelegate = delegate;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"EMTV: cell for row index path: %li",(long)indexPath.row);
    if ([emDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return [emDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        [NSException raise:@"The delegate doesn't respond tableView:cellForRowAtIndexPath:" format:@"The delegate doesn't respond tableView:cellForRowAtIndexPath:"];
        return NULL;
    }
    
    //return NULL;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([emDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
		//NSLog(@"Did select row EM: %li", (long)indexPath.row);
		return [emDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
	else {
		[NSException raise:@"The delegate doesn't respond tableView:didSelectRowAtIndexPath:" format:@"The delegate doesn't respond tableView:didSelectRowAtIndexPath:"];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([emDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
		return [emDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
	} else {
		[NSException raise:@"The delegate doesn't respond ew:heightForRowAtIndexP:" format:@"The delegate doesn't respond ew:heightForRowAtIndexP:"];
		return 0.0;
	}
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if (indexPath.section == _openedSection && animationType != EMAnimationTypeNone) {
        CGPoint offsetPositioning = CGPointMake(cell.frame.size.width / 2.0f, 20.0f);
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
        
        UIView *card = (UITableViewCell * )cell ;
        card.layer.transform = transform;
        card.layer.opacity = 0.5;
        
        [UIView animateWithDuration:1.3f
                              delay:0.5f
             usingSpringWithDamping:0.99f
              initialSpringVelocity:0.01f
                            options:UIViewAnimationOptionLayoutSubviews
						 animations:^{
            
                                card.layer.transform = CATransform3DIdentity;
                                card.layer.opacity = 1;


        } completion:^(BOOL finished) {

			//[dTableView reloadData];

						}];
    }*/
}



#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableView.sectionHeaderHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *sectionView = [self constructSectionBackground:section];
	[self.sectionsHeaders insertObject:sectionView atIndex:section];

	return sectionView;
}

- (UIView *) constructSectionBackground:(NSInteger)section {
    EMAccordionSection *emAccordionSection = [sections objectAtIndex:section];

    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, _tableView.sectionHeaderHeight)];
    [sectionView setBackgroundColor:[PharmaStyle colorBlueHighlight]];
    [sectionView setTag:section];
    
    UIView *sectionView2 = [[UIView alloc]initWithFrame:sectionView.frame];
    [sectionView2 setBackgroundColor:[PharmaStyle colorBlue]];
    sectionView2.alpha = 0.7;
    
    UIView *sectionView3 = [[UIView alloc]initWithFrame:sectionView.frame];
    [sectionView3 setBackgroundColor:[PharmaStyle colorAppWhite]];
    
    UILabel *cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(45.0f, 0.0f, self.tableView.frame.size.width - 50.0f, sectionView.bounds.size.height)];
    [cellTitle setFont:[UIFont fontWithName:@"Lato-Regular" size:28]];
    [cellTitle setText:emAccordionSection.title];
    [cellTitle setTextColor:[PharmaStyle colorAppBlack]];
    [cellTitle setBackgroundColor:[UIColor clearColor]];
    
    [sectionView addSubview:sectionView3];
    [sectionView addSubview:sectionView2];
    [sectionView addSubview:cellTitle];
    
    UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,sectionView.frame.size.width, sectionView.frame.size.height)];
    [sectionBtn addTarget:self action:@selector(openTheSection:) forControlEvents:UIControlEventTouchDown];
    [sectionBtn setTag:section];
    [sectionView addSubview:sectionBtn];
    
    UIImageView *accessoryIV = [[UIImageView alloc] initWithFrame:CGRectMake(sectionView.frame.size.width - 40.0f, (sectionView.frame.size.height / 2) - 15.0f, 20.0f, 20.0f)];
    BOOL value = [[sectionsOpened objectAtIndex:section] boolValue];
    [accessoryIV setBackgroundColor:[UIColor clearColor]];
    [accessoryIV setTag:section];
    
    if (value) {
       // [accessoryIV setImage:self.openedSectionIcon];
        [accessoryIV setImage:closedSectionIcon];

    } else {
    
        //[accessoryIV setImage:self.closedSectionIcon];
        [accessoryIV setImage:closedSectionIcon];
    
    }
    [sectionView addSubview:accessoryIV];
    UIView *thinLine = [[UIView alloc]initWithFrame:CGRectMake(0, sectionView.frame.size.height-1, sectionView.frame.size.width,1)];
    [thinLine setBackgroundColor:[PharmaStyle colorBlueShadow]];
    [sectionView addSubview:thinLine];
    return sectionView;
}

-(void)openTheSection:(id)sender{
    int index = (int)[sender tag]; //- kSectionTag;
	NSIndexSet *sectionSet;
	if([sectionsOpened count] > 0) {
		NSUInteger sectionCount = [sectionsOpened count];
		NSRange indexRange = NSMakeRange(0, sectionCount);
		sectionSet = [[NSIndexSet alloc]initWithIndexesInRange:indexRange];
	}
    BOOL value = [[sectionsOpened objectAtIndex:index] boolValue];

	for (int i = 0; i < [sectionsOpened count]; i++) {
		if (i != index) {
			BOOL value = [[sectionsOpened objectAtIndex:i] boolValue];
			if(value) {
				[sectionsOpened setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:i];
			}
			else {
			}
		}
	}
	//[dTableView reloadData];
    [_tableView reloadData];
    NSNumber *updatedValue = [NSNumber numberWithBool:!value];
    [sectionsOpened setObject:updatedValue atIndexedSubscript:index];

    _openedSection = index;
	if(sectionSet != nil)
		[self.tableView reloadSections:sectionSet withRowAnimation:UITableViewRowAnimationAutomatic];

    [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:NO];
	//[dTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:NO];
	//if (!value)
	//	[self showCellsWithAnimation];
    
    [emDelegate latestSectionOpenedID:index];

}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.parallaxHeaderView updateLayout:scrollView];
}

- (void) showCellsWithAnimation {
    NSArray *cells = self.tableView.visibleCells;
    
    if (showedCell >= cells.count)
        return;
//    for (UIView *card in cells) {
    
    UIView *card = [cells objectAtIndex:showedCell];
    
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -200.0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(90), 1.0f, 0.0f, 0.0f);
    card.layer.transform = rotationAndPerspectiveTransform;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(-90), 1.0f, 0.0f, 0.0f);

	
    UITableView *tempTable = _tableView;
    
    [UIView animateWithDuration:0.5f
                          delay:0.2f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            card.alpha = 1.0f;
                            card.layer.transform = rotationAndPerspectiveTransform;
                        } completion:^(BOOL finished) {
                            self->showedCell++;
                            //[self showCellsWithAnimation];
                            [tempTable reloadData];
                            
                        }];
    
}

@end
