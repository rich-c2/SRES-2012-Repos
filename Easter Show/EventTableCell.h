//
//  EventTableCell.h
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EVENT_CELL_IDENTIFIER @"Event Cell Identifier"

@interface EventTableCell : UITableViewCell {

	NSURL *imageURL;
	UILabel *nameLabel;
	UILabel *dateLable;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLable;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cellSpinner;

+ (NSString *)reuseIdentifier;
- (void)initImage:(NSString *)urlString;

@end
