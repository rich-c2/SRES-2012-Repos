//
//  ShoppingVendorVC.m
//  Easter Show
//
//  Created by Richard Lee on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShoppingVendorVC.h"
#import "SRESAppDelegate.h"
#import "SRESAppDelegate.h"
#import "MapVC.h"
#import "GANTracker.h"
#import "SHK.h"
#import "Favourite.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "ShoppingVendor.h"
#import "ImageManager.h"
#import "Constants.h"

@implementation ShoppingVendorVC

@synthesize shoppingVendor, managedObjectContext;
@synthesize dateLabel, descriptionLabel, titleLabel, vendorImage;
@synthesize eventTypeFilter, eventDay, stitchedBorder, selectedURL;
@synthesize shareButton, addToPlannerButton, mapButton;
@synthesize loadingSpinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self setupNavBar];
	
	[self setDetailFields];
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"fav-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
	// Update add to favs button
	[self updateAddToFavouritesButton];
}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.selectedURL = nil;
	self.shoppingVendor = nil;
	self.dateLabel = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.vendorImage = nil;
	self.eventDay = nil;
	self.eventTypeFilter = nil;
	self.stitchedBorder = nil;
	self.loadingSpinner = nil;
	self.addToPlannerButton = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	
	// If the viewing of this ShoppingVendor has not already been recorded 
	// in Google Analytics then record it as a page view
	if (!pageViewRecorded) [self recordPageView];
}


- (IBAction)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.shoppingVendor title]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (IBAction)addToFavourites:(id)sender {
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.shoppingVendor shopID] forKey:@"id"];
	[favouriteData setObject:[self.shoppingVendor shopID] forKey:@"itemID"];
	[favouriteData setObject:self.shoppingVendor.title forKey:@"title"];
	[favouriteData setObject:@"Shopping vendors" forKey:@"favouriteType"];
	
	Favourite *fav = [Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
	
	// Update the ADD TO FAVES button
	if (fav) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
	
	// Record this as an event in Google Analytics
	if (![[GANTracker sharedTracker] trackEvent:@"Shopping vendors" action:@"Favourite" 
										  label:[self.shoppingVendor title] value:-1 withError:nil]) {
		NSLog(@"error recording Showbag as Favourite");
	}
}


- (IBAction)goToVendorMap:(id)sender {
	
	double lat = [self.shoppingVendor.latitude doubleValue];
	double lon = [self.shoppingVendor.longitude doubleValue];
		 
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	[mapVC setTitleText:self.shoppingVendor.title];
	[mapVC setMapID:MAP_ID_SHOPPING];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	 
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.titleLabel.text = self.shoppingVendor.title;
	[self resizeTextView:self.titleLabel];
	
	// STITCHED BORDER
	CGRect borderFrame = self.stitchedBorder.frame;
	borderFrame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 4.0; 
	[self.stitchedBorder setFrame:borderFrame];
	
	CGRect descFrame = self.descriptionLabel.frame;
	descFrame.origin.y = self.stitchedBorder.frame.origin.y + 4.0;
	[self.descriptionLabel setFrame:descFrame];
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.descriptionLabel.text = self.shoppingVendor.vendorDescription;
	
	// Event image
	[self initImage:self.shoppingVendor.imageURL];
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


- (void)setupNavBar {
	
	// Hide the default navigation bar
	[self.navigationController setNavigationBarHidden:YES];
}


- (void)recordPageView {
	
	NSError **error;
	NSString *urlString = [NSString stringWithFormat:@"/shoppingvendors/%@.html", self.shoppingVendor.title];
	NSLog(@"SHOPPING VENDOR PAGE VIEW URL:%@", urlString);
	 
	pageViewRecorded = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (pageViewRecorded ? @"SHOPPING VENDOR PAGE VIEW RECORDED" : @"SHOPPING VENDOR PAGE VIEW FAILED"));
}


- (void)updateAddToFavouritesButton {
	
	BOOL favourite = [Favourite isItemFavourite:[self.shoppingVendor shopID] favouriteType:@"Shopping vendors" inManagedObjectContext:self.managedObjectContext];
	
	if (favourite) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
}


- (void)initImage:(NSString *)urlString {
	
	UIImage *img = [UIImage imageNamed:urlString];
	if (img) {
		
		[self.loadingSpinner stopAnimating];
		[self.vendorImage setImage:img];
	}
	
	else {
		
		if ([urlString length] > 0) {
		
			self.selectedURL = [urlString convertToURL];
			
			NSLog(@"LOADING MAIN IMAGE:%@", urlString);
			
			UIImage* img = [ImageManager loadImage:self.selectedURL];
			
			if (img) {
				
				[self.loadingSpinner stopAnimating];
				[self.vendorImage setImage:img];
			}
				
			else [self.loadingSpinner stopAnimating];
		}
		
		else [self.loadingSpinner stopAnimating];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		[self.loadingSpinner stopAnimating];
		[self.vendorImage setImage:image];
	}
}


- (void)dealloc {
	
	[addToPlannerButton release];
	[selectedURL release];
	[shoppingVendor release];
	[dateLabel release];
	[descriptionLabel release];
	[titleLabel release];
	[vendorImage release];
	[eventDay release];
	[eventTypeFilter release];
	[stitchedBorder release];
	[loadingSpinner release];
	
    [super dealloc];
}


@end
