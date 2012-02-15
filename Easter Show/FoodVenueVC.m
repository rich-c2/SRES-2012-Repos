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
#import "Favourite.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-food.jpg";

@implementation FoodVenueVC

@synthesize foodVenue, managedObjectContext;
@synthesize stitchedBorder;
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
	
	// Assign the data to their appropriate UI elements
	[self setDetailFields];
	
	
	// ADD TO FAVOURITES BUTTON ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"addToFavouritesButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
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
	self.venueImage = nil;
	self.loadingSpinner = nil;
	self.stitchedBorder = nil;
	
	self.shareButton = nil; 
	self.addToPlannerButton = nil; 
	self.mapButton = nil;
	self.loadingSpinner = nil; 
	self.selectedURL = nil;
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
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.foodVenue venueID] forKey:@"id"];
	[favouriteData setObject:self.foodVenue.venueID forKey:@"itemID"];
	[favouriteData setObject:self.foodVenue.title forKey:@"title"];
	[favouriteData setObject:@"Food venues" forKey:@"favouriteType"];
	
	[Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
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
	//[mapVC setMapID:MAP_ID_FOOD];
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
	
	[stitchedBorder release];
	[managedObjectContext release];
	[foodVenue release];
	[descriptionLabel release];
	[titleLabel release];
	[subTitleLabel release];
	[venueImage release];
	[loadingSpinner release];
    [super dealloc];
}


@end
