//
//  ShowbagsTableCell.m
//  SRES
//
//  Created by Richard Lee on 21/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowbagsTableCell.h"


@implementation ShowbagsTableCell

@synthesize nameLabel, dateLable, thumbView, cellSpinner;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)SHOWBAGS_CELL_IDENTIFIER;
}


- (NSString *)reuseIdentifier {
	
    return [[self class] reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
}


- (void)dealloc {
	
	[cellSpinner release];
	[dateLable release];
	[thumbView release];
	[nameLabel release];
    [super dealloc];
}


@end
