//
//  VisitTableCell.h
//  LeashTimeSitterV1
//
//  Created by Ted Hooban on 11/25/14.
//  Copyright (c) 2014 Ted Hooban. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VisitDetails.h"
#import "ClientListViewController.h"

@interface VisitTableCell : UITableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                      andSize:(CGSize)cellSize 
         parentViewController:(ClientListViewController*)parent;

-(void)setVisitDetail:(VisitDetails*)visitInfo withIndexPath:(NSIndexPath*)indexPath;
-(void)setStatus:(NSString*)visitStatus widthOffset:(int)widthOffset fontSize:(int)fontSize;
-(void)addManagerNote;
-(void)startVisitTimer;
-(void) stopVisitTimer;

@end


