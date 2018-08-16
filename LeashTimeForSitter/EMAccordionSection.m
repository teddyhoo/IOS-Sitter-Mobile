//
//  EMAccordionSection.m
//  UChat
//
//  Created by Ennio Masi on 10/01/14.
//  Copyright (c) 2014 Hippocrates Sintech. All rights reserved.
//

#import "EMAccordionSection.h"

@implementation EMAccordionSection

@synthesize backgroundColor = _backgroundColor;

@synthesize items = _items;
@synthesize title = _title;
@synthesize titleColor = _titleColor;
@synthesize titleFont = _titleFont;

-(instancetype) init {
	
	if (self = [super init]) {
		
		_items = [[NSMutableArray alloc]init];
		
	}
	
	return self;
}
@end
