//
//  EventVC.h
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class EventDateTime;
@class SRESAppDelegate;

@interface EventVC : UIViewController {

	EventDateTime *eventDateTime;
	
	NSManagedObjectContext *managedObjectContext;
	
	// Display
	UILabel *dateLabel;
	UITextView *descriptionLabel;
	UITextView *titleLabel;
	UIImageView *stitchedBorder;
		
	UILabel *navigationTitle;
	
	// Buttons
	UIButton *shareButton;
	UIButton *addToPlannerButton;
	UIButton *mapButton;
}

@property (nonatomic, retain) EventDateTime *eventDateTime;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, retain) IBOutlet UITextView *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *stitchedBorder;

@property (nonatomic, retain) IBOutlet UILabel *navigationTitle;

@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIButton *addToPlannerButton;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;


- (void)showShareOptions:(id)sender;
- (void)setDetailFields;
- (void)resizeTextView:(UITextView *)_textView;
- (void)addToFavourites:(id)sender;
- (void)goToEventMap:(id)sender;
- (IBAction)goBack:(id)sender;
- (void)setupNavBar;
- (void)recordPageView;
- (void)updateAddToFavouritesButton;


@end
