//
//  FavouriteTableCell.h
//  Easter Show
//
//  Created by Richard Lee on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FAVOURITE_CELL_IDENTIFIER @"Fav Cell Identifier"

@interface FavouriteTableCell : UITableViewCell {

	UILabel *textLabel;
	UIImageView *tickMark;
}

@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIImageView *tickMark;

+ (NSString *)reuseIdentifier;

@end
