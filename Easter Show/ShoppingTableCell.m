//
//  ShoppingTableCell.m
//  SRES
//
//  Created by Richard Lee on 21/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "ShoppingTableCell.h"
#import "ImageManager.h"
#import "StringHelper.h"

@implementation ShoppingTableCell

@synthesize nameLabel, descriptionLabel, thumbView, imageURL;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)SHOPPING_CELL_IDENTIFIER;
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
		}
    }
	
	else {
		
		[self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([imageURL isEqual:url]) {
		
		NSLog(@"IMAGE LOADED:%@", [url description]);
		
		[self.thumbView setImage:image];
	}
}


- (void)dealloc {
	
	[imageURL release];
	[descriptionLabel release];
	[thumbView release];
	[nameLabel release];
    [super dealloc];
}


@end
