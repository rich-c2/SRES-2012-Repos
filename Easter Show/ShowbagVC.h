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
#import "ImageDownload.h"

@class SRESAppDelegate;
@class Showbag;

@interface ShowbagVC : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, ImageDownloadDelegate> {
	
	SRESAppDelegate *appDelegate;

	Showbag *showbag;
	
	Reachability *reach;
	BOOL internetConnectionPresent;
	
	BOOL enableQuickSelection;
	
	UIScrollView *contentScrollView;
	
	NSMutableArray *downloads;
	
	// Display
	UITextView *rrPriceLabel;
	UITextView *priceLabel;
	UITextView *descriptionLabel;
	UITextView *titleLabel;
	UIImageView *showbagImage;
	
	UIButton *previousButton;
	UIButton *nextButton;
	
	NSNumber *minPrice;
	NSNumber *maxPrice;
	
	// Buttons
	UIButton *shareButton;
	UIButton *addToPlannerButton;
	UIButton *mapButton;
	
	UIActionSheet *shareActionSheet;
	
	UIActivityIndicatorView *loadingSpinner;
}

@property (nonatomic, retain) Showbag *showbag;

@property (assign) BOOL internetConnectionPresent;

@property (assign) BOOL enableQuickSelection;

@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, retain) NSMutableArray *downloads;
@property (nonatomic, retain) IBOutlet UITextView *rrPriceLabel;
@property (nonatomic, retain) IBOutlet UITextView *priceLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UITextView *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *showbagImage;

@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

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
- (void)initPreviousNextButtons;
- (void)configurePreviousNextButtons;
- (void)goToPrevious:(id)sender;
- (void)goToNext:(id)sender;
- (void)goToMap:(id)sender;
- (void)recordPageView;
- (void)setupNavBar;
- (void)updateAddToFavouritesButton;
- (void)disableDownloads;

@end
