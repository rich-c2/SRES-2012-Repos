//
//  CarnivalRideVC.m
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "CarnivalRideVC.h"
#import "SRESAppDelegate.h"
#import "CarnivalRide.h"
#import "SHK.h"
#import "MapVC.h"
#import "GANTracker.h"
#import "ImageManager.h"
#import "StringHelper.h"
#import "Favourite.h"
#import "Constants.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-carnivals.jpg";

@implementation CarnivalRideVC

@synthesize carnivalRide, managedObjectContext, stitchedBorder;
@synthesize descriptionLabel, titleLabel, rideImage;
@synthesize shareButton, addToPlannerButton, mapButton;
@synthesize loadingSpinner, selectedURL, navigationTitle;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
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
	
	self.stitchedBorder = nil;
	self.managedObjectContext = nil;
	self.selectedURL = nil;
	self.carnivalRide = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.rideImage = nil;
	self.loadingSpinner = nil;
	self.navigationTitle = nil;
	self.shareButton = nil;
	self.mapButton = nil;
	self.addToPlannerButton = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	// If the viewing of this CarnivalRide has not already been recorded in Google Analytics
	// then record it as a page view
	if (!pageViewRecorded) [self recordPageView];
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.carnivalRide title]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)addToFavourites:(id)sender {
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.carnivalRide rideID] forKey:@"id"];
	[favouriteData setObject:[self.carnivalRide rideID] forKey:@"itemID"];
	[favouriteData setObject:self.carnivalRide.title forKey:@"title"];
	[favouriteData setObject:@"Carnival rides" forKey:@"favouriteType"];
	
	[Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
	
	// Record this as an event in Google Analytics
	if (![[GANTracker sharedTracker] trackEvent:@"Showbags" action:@"Favourite" 
										  label:[self.carnivalRide title] value:-1 withError:nil]) {
		NSLog(@"error recording Showbag as Favourite");
	}
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	// RIDE TITLE
	self.titleLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.titleLabel.text = self.carnivalRide.title;
	[self resizeTextView:self.titleLabel];
	
	// STITCHED BORDER
	CGRect borderFrame = self.stitchedBorder.frame;
	borderFrame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 4.0; 
	[self.stitchedBorder setFrame:borderFrame];
	
	// DESCRIPTION
	CGRect descFrame = self.descriptionLabel.frame;
	descFrame.origin.y = self.stitchedBorder.frame.origin.y + 4.0;
	[self.descriptionLabel setFrame:descFrame];
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.descriptionLabel.text = self.carnivalRide.rideDescription;
	
	// IMAGE
	[self initImage:self.carnivalRide.imageURL];
}


- (void)resizeTextView:(UITextView *)_textView {
	
	CGRect frame;
	frame = _textView.frame;
	frame.size.height = [_textView contentSize].height;
	_textView.frame = frame;
}


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)goToMap:(id)sender {
	
	double lat = [self.carnivalRide.latitude doubleValue];
	double lon = [self.carnivalRide.longitude doubleValue];
	
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	[mapVC setTitleText:self.carnivalRide.title];
	[mapVC setMapID:MAP_ID_CARNIVALS];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
}


- (void)setupNavBar {
	
	/*
	// Add button to Navigation Title 
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 97.0, 22.0)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:[UIImage imageNamed:@"screenTitle-carnival.png"]];
	
	self.navigationItem.titleView = image;
	[image release];
	*/
}


- (void)recordPageView {
	
	NSError **error;
	NSString *urlString = [NSString stringWithFormat:@"/carnivalrides/%@.html", self.carnivalRide.title];
	NSLog(@"CARNIVAL PAGE VIEW URL:%@", urlString);
	
	pageViewRecorded = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (pageViewRecorded ? @"CARNIVAL RIDE PAGE VIEW RECORDED" : @"CARNIVAL RIDE PAGE VIEW FAILED"));
}


- (void)updateAddToFavouritesButton {
	
	BOOL favourite = [Favourite isItemFavourite:[self.carnivalRide rideID] favouriteType:@"Carnival rides" inManagedObjectContext:self.managedObjectContext];
	
	if (favourite) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		self.selectedURL = [urlString convertToURL];
		
		NSLog(@"LOADING MAIN IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:self.selectedURL];
		
		if (img) {
			
			[self.loadingSpinner setHidden:YES];
			[self.rideImage setImage:img];
		}	
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		[self.loadingSpinner setHidden:YES];
		[self.rideImage setImage:image];
	}
}


- (void)dealloc {
	
	[stitchedBorder release];
	[managedObjectContext release];
	[selectedURL release];
	[carnivalRide release];
	
	[descriptionLabel release];
	[titleLabel release];
	[rideImage release];
	[loadingSpinner release];
	[navigationTitle release];
	
	[shareButton release];
	[mapButton release];
	[addToPlannerButton release];
	
    [super dealloc];
}


@end
