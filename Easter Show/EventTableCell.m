//
//  EventTableCell.m
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "EventTableCell.h"

@implementation EventTableCell

@synthesize nameLabel, detailLabel, thumbView;


+ (NSString *)reuseIdentifier {
	
    return (NSString *)EVENT_CELL_IDENTIFIER;
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


- (void)initImage {
	
	[self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
}


- (void)dealloc {
	
	[detailLabel release];
	[thumbView release];
	[nameLabel release];
    [super dealloc];
}


@end
