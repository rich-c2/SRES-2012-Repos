//
//  OfferVC.h
//  SRES
//
//  Created by Richard Lee on 13/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Offer;
@class JSONFetcher;

@interface OfferVC : UIViewController {

	NSManagedObjectContext *managedObjectContext;
	
	JSONFetcher *fetcher;
	BOOL successfulRedeem;
	
	Offer *offer;
	NSURL *selectedURL;
		
	UIScrollView *contentScrollView;
	
	// Display
	UITextView *descriptionLabel;
	UITextView *titleLabel;
	UITextView *providerLabel;
	UIImageView *offerImage;
	UIImageView *stitchedBorder;
	
	// Buttons
	UIButton *shareButton;
	UIButton *addToPlannerButton;
	UIButton *redeemButton;
		
	UIActivityIndicatorView *loadingSpinner;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) Offer *offer;
@property (nonatomic, retain) NSURL *selectedURL;

@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UITextView *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *providerLabel;
@property (nonatomic, retain) IBOutlet UIImageView *offerImage;
@property (nonatomic, retain) IBOutlet UIImageView *stitchedBorder;

@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *addToPlannerButton;
@property (nonatomic, retain) IBOutlet UIButton *redeemButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;

- (void)setDetailFields;
- (void)addToFavourites:(id)sender;
- (void)resizeTextView:(UITextView *)_textView;
- (void)showShareOptions:(id)sender;
- (void)setupNavBar;
- (void)recordPageView;
- (void)updateAddToFavouritesButton;
- (void)initImage:(NSString *)urlString;
- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url;
- (IBAction)redeemButtonClicked:(id)sender;
- (IBAction)goBack:(id)sender;
- (void)showLoading;
- (void)hideLoading;
- (void)pushRedeemToAPI;


@end
