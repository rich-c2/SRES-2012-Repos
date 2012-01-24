//
//  ShoppingTableCell.h
//  SRES
//
//  Created by Richard Lee on 21/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHOPPING_CELL_IDENTIFIER @"Shopping Cell Identifier"

@interface ShoppingTableCell : UITableViewCell {

	UILabel *nameLabel;
	UILabel *descriptionLabel;
	UIImageView *thumbView;
	NSURL *imageURL;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet NSURL *imageURL;

+ (NSString *)reuseIdentifier;
- (void)initImage:(NSString *)urlString;

@end
