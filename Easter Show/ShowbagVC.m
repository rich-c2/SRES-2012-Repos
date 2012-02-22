//
//  ShowbagVC.m
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "ShowbagVC.h"
#import "Showbag.h"
#import "SRESAppDelegate.h"
#import "SHK.h"
#import "MapVC.h"
#import "GANTracker.h"
#import "ImageManager.h"
#import "StringHelper.h"
#import "Favourite.h"
#import "Constants.h"

@implementation ShowbagVC

@synthesize showbag, minPrice, maxPrice, rrPriceLabel, managedObjectContext;
@synthesize contentScrollView, priceLabel, descriptionLabel, titleLabel, showbagImage;
@synthesize shareButton, addToPlannerButton, mapButton, loadingSpinner, downloads;
@synthesize selectedURL, stitchedBorder;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	self.title = @"Showbag";
	
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
	self.showbag = nil;
	self.contentScrollView = nil;
	self.rrPriceLabel = nil;
	self.priceLabel = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.showbagImage = nil;
	self.minPrice = nil;
	self.maxPrice = nil;
	self.loadingSpinner = nil;
	self.stitchedBorder = nil;
	
	self.selectedURL = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	// If the viewing of this Showbag has not already been recorded in Google Analytics
	// then record it as a page view
	if (!pageViewRecorded) [self recordPageView];
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.showbag title]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)addToFavourites:(id)sender {
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.showbag showbagID] forKey:@"id"];
	[favouriteData setObject:self.showbag.showbagID forKey:@"itemID"];
	[favouriteData setObject:self.showbag.title forKey:@"title"];
	[favouriteData setObject:@"Showbags" forKey:@"favouriteType"];
	
	Favourite *fav = [Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
	
	// Update the ADD TO FAVES button
	if (fav) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
	
	// Record this as an event in Google Analytics
	if (![[GANTracker sharedTracker] trackEvent:@"Showbags" action:@"Favourite" 
										  label:[self.showbag title] value:-1 withError:nil]) {
		NSLog(@"error recording Showbag as Favourite");
	}
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	
	// TITLE
	self.titleLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.titleLabel.text = self.showbag.title;
	[self resizeTextView:self.titleLabel];
	
	// PRICE 
	self.priceLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.priceLabel.text = [NSString stringWithFormat:@"Price: $%.2f", [[self.showbag price] floatValue]];
	[self resizeTextView:self.priceLabel];
	
	CGRect currFrame = self.priceLabel.frame;
	currFrame.origin.y = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 16.0;
	[self.priceLabel setFrame:currFrame];
	
	// RRP 
	self.rrPriceLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.rrPriceLabel.text = [NSString stringWithFormat:@"RRP: $%.2f", [[self.showbag rrPrice] floatValue]];
	[self resizeTextView:self.rrPriceLabel];
	
	CGRect currFrame2 = self.rrPriceLabel.frame;
	currFrame2.origin.y = self.priceLabel.frame.origin.y;
	[self.rrPriceLabel setFrame:currFrame2];
	
	// STITCHED BORDER
	CGRect borderFrame = self.stitchedBorder.frame;
	borderFrame.origin.y = self.rrPriceLabel.frame.origin.y + self.rrPriceLabel.frame.size.height + 4.0; 
	[self.stitchedBorder setFrame:borderFrame];
	
	// DESCRIPTION
	CGRect descFrame = self.descriptionLabel.frame;
	descFrame.origin.y = self.stitchedBorder.frame.origin.y + 4.0;
	[self.descriptionLabel setFrame:descFrame];
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	NSString *description;
	if ([self.showbag.showbagDescription length] > 0) 
		description = [self.showbag.showbagDescription stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
	else description = @"";
	
	self.descriptionLabel.text = description;
	
	// Showbag image
	[self initImage:self.showbag.imageURL];
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
	
	double lat = [[self.showbag latitude] doubleValue];
	double lon = [[self.showbag longitude] doubleValue];
	
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	[mapVC setTitleText:self.showbag.title];
	[mapVC setMapID:MAP_ID_SHOWBAGS];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
}


- (void)setupNavBar {
	
	// Hide default navigation bar
	[self.navigationController setNavigationBarHidden:YES];
	
	// Add button to Navigation Title 
	/*UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 118.0, 22.0)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:[UIImage imageNamed:@"screenTitle-showbags.png"]];
	
	self.navigationItem.titleView = image;
	[image release];*/
}


- (void)recordPageView {

	NSError **error;
	NSString *urlString = [NSString stringWithFormat:@"/showbags/%@.html", self.showbag.title];
	NSLog(@"SHOWBAGS PAGE VIEW URL:%@", urlString);
	
	pageViewRecorded = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (pageViewRecorded ? @"SHOWBAG PAGE VIEW RECORDED" : @"SHOWBAG PAGE VIEW FAILED"));
}


- (void)updateAddToFavouritesButton {
	
	BOOL favourite = [Favourite isItemFavourite:[self.showbag showbagID] favouriteType:@"Showbags" inManagedObjectContext:self.managedObjectContext];
	
	if (favourite) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
}


- (void)initImage:(NSString *)urlString {
	
	// TEST CODE
	if (urlString && ![urlString isEqualToString:@"http://sres2012.supergloo.net.au"]) {
		
		[self.loadingSpinner startAnimating];
		
		self.selectedURL = [urlString convertToURL];
		
		NSLog(@"LOADING MAIN IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:self.selectedURL];
		
		if (img) {
			
			[self.loadingSpinner stopAnimating];
			[self.showbagImage setImage:img];
		}
    }
	
	else [self.loadingSpinner stopAnimating];
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		if (image != nil) {
		
			NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
			
			[self.loadingSpinner setHidden:YES];
			[self.showbagImage setImage:image];
		}
		
		else [self.loadingSpinner stopAnimating];
	}
}


- (void)dealloc {
	
	[managedObjectContext release];
	[showbag release];
	[contentScrollView release];
	[rrPriceLabel release];
	[priceLabel release];
	[descriptionLabel release];
	[titleLabel release];
	[showbagImage release];
	[minPrice release];
	[maxPrice release];
	[loadingSpinner release];
	[stitchedBorder release];
	
	[selectedURL release];
	
    [super dealloc];
}


@end
