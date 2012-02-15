//
//  ShowbagsTableCell.m
//  SRES
//
//  Created by Richard Lee on 21/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowbagsTableCell.h"
#import "ImageManager.h"
#import "StringHelper.h"

@implementation ShowbagsTableCell

@synthesize nameLabel, dateLable, thumbView, cellSpinner, imageURL;

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


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		self.imageURL = [urlString convertToURL];
		
		NSLog(@"LOADING GRID IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:imageURL];
		if (img) {
			
			[self.thumbView setImage:img];
			[self.cellSpinner stopAnimating];
		}
    }
	
	else {
	
		[self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
		[self.cellSpinner stopAnimating];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.imageURL isEqual:url]) {
		
		NSLog(@"IMAGE LOADED:%@", [url description]);
		
		if (image) [self.thumbView setImage:image];
		else [self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
		
		[self.cellSpinner stopAnimating];
	}
}


- (void)dealloc {
	
	[imageURL release];
	[cellSpinner release];
	[dateLable release];
	[thumbView release];
	[nameLabel release];
    [super dealloc];
}


@end
