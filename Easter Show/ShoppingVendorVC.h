//
//  ShoppingVendorVC.h
//  Easter Show
//
//  Created by Richard Lee on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShoppingVendor;

@interface ShoppingVendorVC : UIViewController {

	ShoppingVendor *shoppingVendor;
	
	NSManagedObjectContext *managedObjectContext;
	
	// Display
	UITextView *dateLabel;
	UITextView *descriptionLabel;
	UITextView *titleLabel;
	UIImageView *vendorImage;
	UIImageView *stitchedBorder;
	
	NSNumber *eventTypeFilter;
	NSString *eventDay;
	NSURL *selectedURL;
		
	// Buttons
	UIButton *shareButton;
	UIButton *addToPlannerButton;
	UIButton *mapButton;
	
	UIActivityIndicatorView *loadingSpinner;
}

@property (nonatomic, retain) ShoppingVendor *shoppingVendor;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITextView *dateLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UITextView *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *vendorImage;
@property (nonatomic, retain) IBOutlet UIImageView *stitchedBorder;

@property (nonatomic, retain) NSNumber *eventTypeFilter;
@property (nonatomic, retain) NSString *eventDay;
@property (nonatomic, retain) NSURL *selectedURL;

@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *addToPlannerButton;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;
- (IBAction)goBack:(id)sender;


- (void)showShareOptions:(id)sender;
- (void)setDetailFields;
- (void)resizeTextView:(UITextView *)_textView;
- (void)addToFavourites:(id)sender;
- (IBAction)goToVendorMap:(id)sender;
- (IBAction)goBack:(id)sender;
- (void)setupNavBar;
- (void)recordPageView;
- (void)updateAddToFavouritesButton;
- (IBAction)showShareOptions:(id)sender;
- (IBAction)addToFavourites:(id)sender;
- (void)initImage:(NSString *)urlString;
- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url;

@end
