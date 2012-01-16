//
//  FoodVenueVC.h
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class SRESAppDelegate;
@class FoodVenue;

@interface FoodVenueVC : UIViewController {

	SRESAppDelegate *appDelegate;
	
	FoodVenue *foodVenue;
	
	UIScrollView *contentScrollView;
	
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

@property (nonatomic, retain) FoodVenue *foodVenue;

@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

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
- (void)adjustScrollViewContentHeight;
- (void)goToMap:(id)sender;
- (void)setupNavBar;
- (void)goBack:(id)sender;
- (void)recordPageView;
- (void)updateAddToFavouritesButton;

@end
