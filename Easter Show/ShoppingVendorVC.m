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
//#import "GANTracker.h"
#import "SHK.h"
#import "Favourite.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "ShoppingVendor.h"
#import "ImageManager.h"

@implementation ShoppingVendorVC

@synthesize shoppingVendor, managedObjectContext;
@synthesize dateLabel, descriptionLabel, titleLabel, vendorImage;
@synthesize eventTypeFilter, eventDay, contentScrollView, selectedURL;
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
	self.contentScrollView = nil;
	self.loadingSpinner = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
	
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.shoppingVendor title]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)addToFavourites:(id)sender {
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.shoppingVendor shopID] forKey:@"id"];
	[favouriteData setObject:[self.shoppingVendor shopID] forKey:@"itemID"];
	[favouriteData setObject:self.shoppingVendor.title forKey:@"title"];
	[favouriteData setObject:@"Shopping vendors" forKey:@"favouriteType"];
	
	[Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
}


- (void)goToEventMap:(id)sender {
	
	/*double lat;
	 double lon;
	 
	 if ([[self.event eventID] intValue] == COKE_EVENT_ID1) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID2) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID3) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID4) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID5) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID6) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID7) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID8) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID9) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID10) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID11) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID12) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID13) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else if ([[self.event eventID] intValue] == COKE_EVENT_ID14) {
	 
	 lat = -33.84462;
	 lon = 151.07213;
	 }
	 else {
	 
	 lat = [[self.event eventLatitude] doubleValue];
	 lon = [[self.event eventLongitude] doubleValue];
	 }
	 
	 
	 MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	 [mapVC setMapID:[[self.event eventMap] intValue]];
	 [mapVC setCenterLatitude:lat];
	 [mapVC setCenterLongitude:lon];
	 
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:mapVC animated:YES];
	 [mapVC release];*/
	
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.titleLabel.text = self.shoppingVendor.title;
	[self resizeTextView:self.titleLabel];
	
	/*self.dateLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.dateLabel.text = [NSString	stringWithFormat:@"%@", self.shoppingVendor.eventDate];
	[self resizeTextView:self.dateLabel];
	
	CGRect currFrame = self.dateLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	[self.dateLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];*/
	
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
	self.descriptionLabel.text = self.shoppingVendor.vendorDescription;
	[self resizeTextView:self.descriptionLabel];
	
	// Adjust the scroll view content size
	[self adjustScrollViewContentHeight];	
	
	// Event image
	[self initImage:self.shoppingVendor.imageURL];
}


- (void)resizeTextView:(UITextView *)_textView {
	
	CGRect frame;
	frame = _textView.frame;
	frame.size.height = [_textView contentSize].height;
	_textView.frame = frame;
	
}


- (void)adjustScrollViewContentHeight {
	
	CGFloat bottomPadding = 15.0;
	CGSize currSize = [self.contentScrollView contentSize];
	CGFloat newContentHeight = [self.descriptionLabel frame].origin.y + [self.descriptionLabel frame].size.height + bottomPadding;
	
	[self.contentScrollView setContentSize:CGSizeMake(currSize.width, newContentHeight)];
}


- (void)goBack:(id)sender { 
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)setupNavBar {
	
	// Add back button to nav bar
	/*CGRect btnFrame = CGRectMake(0.0, 0.0, 50.0, 30.0);
	 UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [backButton setBackgroundImage:[UIImage imageNamed:@"backButton-Offers.png"] forState:UIControlStateNormal];
	 [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	 backButton.frame = btnFrame;
	 
	 UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	 backItem.target = self;
	 self.navigationItem.leftBarButtonItem = backItem;
	 [backItem release];
	 
	 NSArray *stringParts = [self.eventDay componentsSeparatedByString:@" "];
	 NSString *titleImageName = [NSString stringWithFormat:@"screenTitle-%@%@.png", [stringParts objectAtIndex:0], [stringParts objectAtIndex:1]];
	 UIImage *titleImage = [UIImage imageNamed:titleImageName];
	 
	 // Add button to Navigation Title 
	 UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, titleImage.size.width, titleImage.size.height)];
	 [image setBackgroundColor:[UIColor clearColor]];
	 [image setImage:titleImage];
	 
	 self.navigationItem.titleView = image;
	 [image release];*/
	
}


- (void)recordPageView {
	
	//NSError **error;
	/*NSString *urlString = [NSString stringWithFormat:@"/events/%@.html", self.event.eventTitle];
	 NSLog(@"EVENTS PAGE VIEW URL:%@", urlString);
	 
	 BOOL success = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	 NSLog(@"%@", (success ? @"YES EVENTS PAGE VIEW RECORDED" : @"NO - EVENTS PAGE VIEW FAILED"));*/
}


- (void)updateAddToFavouritesButton {
	
	/*BOOL alreadyFavourite = [appDelegate alreadyAddedToFavourites:[self.event.eventID intValue] favType:FAVOURITE_TYPE_EVENT];
	 
	 if (alreadyFavourite) [self.addToPlannerButton setSelected:YES];
	 else [self.addToPlannerButton setSelected:NO];*/
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		self.selectedURL = [urlString convertToURL];
		
		NSLog(@"LOADING MAIN IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:self.selectedURL];
		
		if (img) {
			
			[self.loadingSpinner stopAnimating];
			[self.vendorImage setImage:img];
		}
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
	
	[selectedURL release];
	[shoppingVendor release];
	[dateLabel release];
	[descriptionLabel release];
	[titleLabel release];
	[vendorImage release];
	[eventDay release];
	[eventTypeFilter release];
	[contentScrollView release];
	[loadingSpinner release];
	
    [super dealloc];
}


@end
