//
//  FoodVenueVC.m
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "FoodVenueVC.h"
#import "FoodVenue.h"
#import "SRESAppDelegate.h"
#import "SHK.h"
#import "MapVC.h"
//#import "GANTracker.h"
#import "StringHelper.h"
#import "ImageManager.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-food.jpg";

@implementation FoodVenueVC

@synthesize foodVenue;
@synthesize contentScrollView;
@synthesize descriptionLabel, titleLabel, subTitleLabel, venueImage;
@synthesize shareButton, addToPlannerButton, mapButton;
@synthesize loadingSpinner, selectedURL;


// The designated initializer. Override if you create the controller programmatically 
// and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	self.title = @"Food";
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	appDelegate = (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];

	self.titleLabel.font = [UIFont fontWithName:kTitleFont size:16.0];
	self.subTitleLabel.font = [UIFont fontWithName:kTitleFont size:12.0];
	self.descriptionLabel.font = [UIFont fontWithName:kDescriptionFont size:12.0];
	
	// Assign the data to their appropriate UI elements
	[self setDetailFields];
	
	
	// ADD TO FAVOURITES BUTTON ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"addToFavouritesButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[self updateAddToFavouritesButton];
	
	// Setup navigation bar elements
	[self setupNavBar];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.foodVenue = nil;
	self.contentScrollView = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.subTitleLabel = nil;
	self.venueImage = nil;
	self.loadingSpinner = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.foodVenue title]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)addToFavourites:(id)sender {
	
	// Check if Showbag has already been 'Favourited'
	/*BOOL added = [appDelegate alreadyAddedToFavourites:[self.foodVenue.venueID intValue] favType:FAVOURITE_TYPE_FOOD];
	
	// If it's already been added - delete it from database
	if (added) {
		
		// Delete Event from Favourites table in DB
		[appDelegate removeFromFavourites:[self.foodVenue.venueID intValue] favType:FAVOURITE_TYPE_FOOD];
		
		[self.addToPlannerButton setSelected:NO];
	}
	else {
		
		// Add to Favourites table in DB
		[appDelegate addToFavourites:[self.foodVenue.venueID intValue] itemType:FAVOURITE_TYPE_FOOD];
		
		[self.addToPlannerButton setSelected:YES];
		
		// Record this as an event in Google Analytics
		BOOL success = [[GANTracker sharedTracker] trackEvent:@"Food" action:@"Favourite" 
														label:[self.foodVenue venueTitle] value:-1 withError:nil];
		
		NSLog(@"%@", (success ? @"FOOD TRACKED!" : @"FOOD FAILED TO BE TRACKED"));
	}*/
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.titleLabel.text = self.foodVenue.title;
	[self resizeTextView:self.titleLabel];
	
	NSString *subtitle;
	self.subTitleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	if ([self.foodVenue.subtitle length] != 0) subtitle = [NSString stringWithFormat:@"%@", self.foodVenue.subtitle];
	else subtitle = @"";
	
	self.subTitleLabel.text = subtitle;
	[self resizeTextView:self.subTitleLabel];
	
	CGRect currFrame = self.subTitleLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	[self.subTitleLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
	self.descriptionLabel.text = self.foodVenue.venueDescription;
	[self resizeTextView:self.descriptionLabel];
	
	// Adjust the scroll view content size
	[self adjustScrollViewContentHeight];
	
	UIImage *fImage = [UIImage imageNamed:kPlaceholderImage];
	
	self.venueImage.image = fImage;
}


- (void)adjustScrollViewContentHeight {

	CGFloat bottomPadding = 15.0;
	CGSize currSize = [self.contentScrollView contentSize];
	CGFloat newContentHeight = [self.descriptionLabel frame].origin.y + [self.descriptionLabel frame].size.height + bottomPadding;

	[self.contentScrollView setContentSize:CGSizeMake(currSize.width, newContentHeight)];


}


- (void)resizeTextView:(UITextView *)_textView {
	
	CGRect frame;
	frame = _textView.frame;
	frame.size.height = [_textView contentSize].height;
	_textView.frame = frame;
	
}


- (void)goToMap:(id)sender {

	double lat = [[self.foodVenue latitude] doubleValue];
	double lon = [[self.foodVenue longitude] doubleValue];
	
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	//[mapVC setMapID:MAP_ID_FOOD];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];

}


- (void)goBack:(id)sender { 
	
	[self.navigationController popViewControllerAnimated:YES];
	
}


- (void)setupNavBar {
	
	// Add button to Navigation Title 
	/*UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 66.0, 22.0)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:[UIImage imageNamed:@"screenTitle-food.png"]];
	
	self.navigationItem.titleView = image;
	[image release];
	
	// Add back button to nav bar
	CGRect btnFrame = CGRectMake(0.0, 0.0, 50.0, 30.0);
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton-Offers.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	backButton.frame = btnFrame;
	
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	backItem.target = self;
	self.navigationItem.leftBarButtonItem = backItem;
	[backItem release];*/
	
}


- (void)recordPageView {
	
	//NSError **error;
	/*NSString *urlString = [NSString stringWithFormat:@"/foodvenues/%@.html", self.foodVenue.venueTitle];
	NSLog(@"FOOD PAGE VIEW URL:%@", urlString);
	
	BOOL success = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (success ? @"YES - FOOD VENUE PAGE VIEW RECORDED" : @"NO - FOOD VENUE PAGE VIEW FAILED"));*/
}


- (void)updateAddToFavouritesButton {
	
	/*BOOL alreadyFavourite = [appDelegate alreadyAddedToFavourites:[self.foodVenue.venueID intValue] favType:FAVOURITE_TYPE_FOOD];
	
	if (alreadyFavourite) [self.addToPlannerButton setSelected:YES];
	else [self.addToPlannerButton setSelected:NO];*/
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		[self.loadingSpinner startAnimating];
		
		self.selectedURL = [urlString convertToURL];
		
		NSLog(@"LOADING MAIN IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:self.selectedURL];
		
		if (img) {
			
			[self.loadingSpinner setHidden:YES];
			[self.venueImage setImage:img];
		}
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		[self.loadingSpinner setHidden:YES];
		[self.venueImage setImage:image];
	}
}


- (void)dealloc {
	
	[foodVenue release];
	[contentScrollView release];
	[descriptionLabel release];
	[titleLabel release];
	[subTitleLabel release];
	[venueImage release];
	[loadingSpinner release];
    [super dealloc];
}


@end
