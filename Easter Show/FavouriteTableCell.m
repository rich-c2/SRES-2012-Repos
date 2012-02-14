//
//  FavouriteTableCell.m
//  Easter Show
//
//  Created by Richard Lee on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouriteTableCell.h"

@implementation FavouriteTableCell

@synthesize textLabel, tickMark;


+ (NSString *)reuseIdentifier {
	
    return (NSString *)FAVOURITE_CELL_IDENTIFIER;
}


- (NSString *)reuseIdentifier {
	
    return [[self class] reuseIdentifier];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {

	[tickMark release];
	[textLabel release];
	[super dealloc];
}

@end
