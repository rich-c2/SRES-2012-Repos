//
//  CarnivalRideVC.h
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class CarnivalRide;

@interface CarnivalRideVC : UIViewController {
	
	NSManagedObjectContext *managedObjectContext;
	CarnivalRide *carnivalRide;
	
	UILabel *navigationTitle;
	UIScrollView *contentScrollView;
	
	// Display
	UITextView *descriptionLabel;
	UITextView *titleLabel;
	UITextView *subTitleLabel;
	UIImageView *rideImage;
	
	// Buttons
	UIButton *shareButton;
	UIButton *addToPlannerButton;
	UIButton *mapButton;
	
	UIActivityIndicatorView *loadingSpinner;
	
	NSURL *selectedURL;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) CarnivalRide *carnivalRide;

@property (nonatomic, retain) UILabel *navigationTitle;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UITextView *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *subTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rideImage;

@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *addToPlannerButton;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, retain) IBOutlet NSURL *selectedURL;

- (void)showShareOptions:(id)sender;
- (void)addToFavourites:(id)sender;
- (void)setDetailFields;
- (void)resizeTextView:(UITextView *)_textView;
- (IBAction)goBack:(id)sender;
- (void)goToMap:(id)sender;
- (void)setupNavBar;
- (void)adjustScrollViewContentHeight;
- (void)recordPageView;
- (void)updateAddToFavouritesButton;
- (void)initImage:(NSString *)urlString;

@end
