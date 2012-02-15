//
//  OfferTableCell.h
//  SRES
//
//  Created by Richard Lee on 17/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OFFER_CELL_IDENTIFIER @"Offer Cell Identifier"

@interface OfferTableCell : UITableViewCell {

	UILabel *nameLabel;
	UILabel *descriptionLabel;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
	NSURL *imageURL;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cellSpinner;
@property (nonatomic, retain) NSURL *imageURL;

+ (NSString *)reuseIdentifier;
- (void)initImage:(NSString *)urlString;
- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url;

@end
