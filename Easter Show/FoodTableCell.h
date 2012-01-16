//
//  FoodTableCell.h
//  SRES
//
//  Created by Richard Lee on 21/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FOOD_CELL_IDENTIFIER @"Food Cell Identifier"

@interface FoodTableCell : UITableViewCell <NSFetchedResultsControllerDelegate> {

	UILabel *nameLabel;
	UILabel *dateLabel;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
	NSURL *imageURL;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cellSpinner;
@property (nonatomic, retain) NSURL *imageURL;

- (void)initImage:(NSString *)urlString;
+ (NSString *)reuseIdentifier;

@end
