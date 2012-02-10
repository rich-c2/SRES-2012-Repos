//
//  ShowbagVC.h
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Reachability.h"

@class SRESAppDelegate;
@class Showbag;

@interface ShowbagVC : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	
	SRESAppDelegate *appDelegate;
	NSManagedObjectContext *managedObjectContext;

	Showbag *showbag;
	
	UIScrollView *contentScrollView;
	
	// Display
	UITextView *rrPriceLabel;
	UITextView *priceLabel;
	UITextView *descriptionLabel;
	UITextView *titleLabel;
	UIImageView *showbagImage;
	
	NSURL *selectedURL;
	
	NSNumber *minPrice;
	NSNumber *maxPrice;
	
	// Buttons
	UIButton *shareButton;
	UIButton *addToPlannerButton;
	UIButton *mapButton;
	
	UIActionSheet *shareActionSheet;
	
	UIActivityIndicatorView *loadingSpinner;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) Showbag *showbag;

@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, retain) NSMutableArray *downloads;
@property (nonatomic, retain) IBOutlet UITextView *rrPriceLabel;
@property (nonatomic, retain) IBOutlet UITextView *priceLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UITextView *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *showbagImage;

@property (nonatomic, retain) NSURL *selectedURL;

@property (nonatomic, retain) NSNumber *minPrice;
@property (nonatomic, retain) NSNumber *maxPrice;

@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *addToPlannerButton;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;

- (void)showShareOptions:(id)sender;
- (void)addToFavourites:(id)sender;
- (void)setDetailFields;
- (void)resizeTextView:(UITextView *)_textView;
- (void)adjustScrollViewContentHeight;
- (void)goToMap:(id)sender;
- (void)recordPageView;
- (void)setupNavBar;
- (void)updateAddToFavouritesButton;
- (void)initImage:(NSString *)urlString;
- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url;
- (IBAction)goBack:(id)sender;


@end
