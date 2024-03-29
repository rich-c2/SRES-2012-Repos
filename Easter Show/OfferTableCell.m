//
//  OfferTableCell.m
//  SRES
//
//  Created by Richard Lee on 17/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "OfferTableCell.h"
#import "ImageManager.h"
#import "StringHelper.h"

@implementation OfferTableCell

@synthesize nameLabel, descriptionLabel, thumbView, cellSpinner;
@synthesize imageURL;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)OFFER_CELL_IDENTIFIER;
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
	
	// TEST CODE
	if (urlString && ![urlString isEqualToString:@"http://sres2012.supergloo.net.au"]) {
		
		self.imageURL = [urlString convertToURL];
		
		NSLog(@"LOADING GRID IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:imageURL];
		if (img) {
			
			[self.cellSpinner setHidden:YES];
			[self.thumbView setImage:img];
		}
    }
	
	else {
		
		[self.cellSpinner setHidden:YES];
		[self.thumbView setImage:[UIImage imageNamed:@"placeholder-offers-thumb.jpg"]];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([imageURL isEqual:url]) {
		
		NSLog(@"IMAGE LOADED:%@", [url description]);
		
		[self.thumbView setImage:image];
		[self.cellSpinner setHidden:YES];
	}
}


- (void)dealloc {
	
	[imageURL release];
	[cellSpinner release];
	[descriptionLabel release];
	[thumbView release];
	[nameLabel release];
    [super dealloc];
}



@end
