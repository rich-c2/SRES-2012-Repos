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
#import "GANTracker.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "Favourite.h"
#import "Constants.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-food.jpg";

@implementation FoodVenueVC

@synthesize foodVenue, managedObjectContext;
@synthesize stitchedBorder;
@synthesize descriptionLabel, titleLabel, subTitleLabel;
@synthesize shareButton, addToPlannerButton, mapButton;


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
	
	// Assign the data to their appropriate UI elements
	[self setDetailFields];
	
	
	// ADD TO FAVOURITES BUTTON ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"fav-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
	[self updateAddToFavouritesButton];
	
	// Setup navigation bar elements
	[self setupNavBar];
}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
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
	
	self.managedObjectContext = nil;
	self.foodVenue = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.subTitleLabel = nil;
	self.stitchedBorder = nil;
	
	self.shareButton = nil; 
	self.addToPlannerButton = nil; 
	self.mapButton = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	// If the viewing of this FoodVenue has not already been recorded in Google Analytics
	// then record it as a page view
	if (!pageViewRecorded) [self recordPageView];
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
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.foodVenue venueID] forKey:@"id"];
	[favouriteData setObject:self.foodVenue.venueID forKey:@"itemID"];
	[favouriteData setObject:self.foodVenue.title forKey:@"title"];
	[favouriteData setObject:@"Food venues" forKey:@"favouriteType"];
	
	Favourite *fav = [Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
	
	// Update the ADD TO FAVES button
	if (fav) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
	
	// Record this as an event in Google Analytics
	if (![[GANTracker sharedTracker] trackEvent:@"FoodVenues" action:@"Favourite" 
										  label:[self.foodVenue title] value:-1 withError:nil]) {
		NSLog(@"error recording FoodVenue as Favourite");
	}
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.titleLabel.text = self.foodVenue.title;
	[self resizeTextView:self.titleLabel];
	
	// SUBTITLE
	NSString *subtitle;
	self.subTitleLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	if ([self.foodVenue.subtitle length] != 0) subtitle = [NSString stringWithFormat:@"%@", self.foodVenue.subtitle];
	else subtitle = @"";
	
	self.subTitleLabel.text = subtitle;
	[self resizeTextView:self.subTitleLabel];
	
	CGRect currFrame = self.subTitleLabel.frame;
	currFrame.origin.y = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 16.0;
	[self.subTitleLabel setFrame:currFrame];
	
	// STITCHED BORDER
	CGRect borderFrame = self.stitchedBorder.frame;
	borderFrame.origin.y = self.subTitleLabel.frame.origin.y + self.subTitleLabel.frame.size.height + 4.0; 
	[self.stitchedBorder setFrame:borderFrame];
	
	CGRect descFrame = self.descriptionLabel.frame;
	descFrame.origin.y = self.stitchedBorder.frame.origin.y + 4.0;
	[self.descriptionLabel setFrame:descFrame];
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.descriptionLabel.text = self.foodVenue.venueDescription;
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
	[mapVC setTitleText:self.foodVenue.title];
	[mapVC setMapID:MAP_ID_FOOD];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];

}


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
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
	
	NSError **error;
	NSString *urlString = [NSString stringWithFormat:@"/foodvenues/%@.html", self.foodVenue.title];
	NSLog(@"FOOD PAGE VIEW URL:%@", urlString);
	
	pageViewRecorded = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (pageViewRecorded ? @"FOOD VENUE PAGE VIEW RECORDED" : @"FOOD VENUE PAGE VIEW FAILED"));
}


- (void)updateAddToFavouritesButton {
	
	BOOL favourite = [Favourite isItemFavourite:[self.foodVenue venueID] favouriteType:@"Food venues" inManagedObjectContext:self.managedObjectContext];
	
	if (favourite) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
}


- (void)dealloc {
	
	[stitchedBorder release];
	[managedObjectContext release];
	[foodVenue release];
	[descriptionLabel release];
	[titleLabel release];
	[subTitleLabel release];
    [super dealloc];
}


@end
