//
//  FoodVenueVC.h
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class FoodVenue;

@interface FoodVenueVC : UIViewController {

	NSManagedObjectContext *managedObjectContext;
	UIImageView *stitchedBorder;
	
	FoodVenue *foodVenue;
		
	// Display
	UITextView *descriptionLabel;
	UITextView *titleLabel;
	UITextView *subTitleLabel;
	UIImageView *venueImage;
	
	// Buttons
	UIButton *shareButton;
	UIButton *addToPlannerButton;
	UIButton *mapButton;
		
	UIActivityIndicatorView *loadingSpinner;
	NSURL *selectedURL;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIImageView *stitchedBorder;

@property (nonatomic, retain) FoodVenue *foodVenue;

@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UITextView *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *subTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *venueImage;

@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *addToPlannerButton;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, retain) NSURL *selectedURL;

- (void)showShareOptions:(id)sender;
- (void)addToFavourites:(id)sender;
- (void)setDetailFields;
- (void)resizeTextView:(UITextView *)_textView;
- (void)goToMap:(id)sender;
- (void)setupNavBar;
- (IBAction)goBack:(id)sender;
- (void)recordPageView;
- (void)updateAddToFavouritesButton;

@end
