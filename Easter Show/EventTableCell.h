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

	UILabel *nameLabel;
	UILabel *detailLabel;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;

+ (NSString *)reuseIdentifier;
- (void)initImage;

@end
