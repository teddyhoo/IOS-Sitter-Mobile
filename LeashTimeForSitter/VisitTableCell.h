//
//  VisitTableCell.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/25/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "VisitDetails.h"


/*@interface VisitIndicatorView : UIView

@property (nonatomic,strong)UIColor *indicatorColor;
@property (nonatomic,strong)UIColor *innerColor;

@end*/



@interface VisitTableCell : MGSwipeTableCell
@property (nonatomic,strong) VisitDetails *visitInfo;
@property (nonatomic,strong) UIView *backgroundIV;


-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andSize:(CGSize)cellSize;
-(void)setVisitDetail:(VisitDetails*)visitInfo;
-(void)setStatus:(NSString*)visitStatus widthOffset:(int)widthOffset fontSize:(int)fontSize;
-(void)showKeyInfo;
-(void)showFlags;
-(void)showPetPicInCell;
-(void)addManagerNote:(UIButton*)managerNoteButton;
-(void)startVisitTimer;
-(void) stopVisitTimer;
@end


