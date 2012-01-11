//
//  ShowbagsTableCell.h
//  SRES
//
//  Created by Richard Lee on 21/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHOWBAGS_CELL_IDENTIFIER @"Showbags Cell Identifier"

@interface ShowbagsTableCell : UITableViewCell {

	UILabel *nameLabel;
	UILabel *dateLable;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLable;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cellSpinner;

+ (NSString *)reuseIdentifier;

@end
