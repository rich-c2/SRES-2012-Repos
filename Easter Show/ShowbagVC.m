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
//#import "SHK.h"
//#import "MapVC.h"
//#import "GANTracker.h"
#import "ImageManager.h"
#import "StringHelper.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-showbags.jpg";

@implementation ShowbagVC

@synthesize showbag, minPrice, maxPrice, rrPriceLabel;
@synthesize contentScrollView, priceLabel, descriptionLabel, titleLabel, showbagImage;
@synthesize shareButton, addToPlannerButton, mapButton, loadingSpinner, downloads;
@synthesize selectedURL;


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
	
	self.titleLabel.font = [UIFont fontWithName:kTitleFont size:16.0];
	self.priceLabel.font = [UIFont fontWithName:kTitleFont size:12.0];
	self.rrPriceLabel.font = [UIFont fontWithName:kTitleFont size:12.0];
	self.descriptionLabel.font = [UIFont fontWithName:kDescriptionFont size:12.0];
	
	// Assign the data to their appropriate UI elements
	[self setDetailFields];
	
	// ADD TO FAVOURITES BUTTON ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"addToFavouritesButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[self updateAddToFavouritesButton];
	
	// Setup navigation bar elements
	//[self setupNavBar];
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
	
	self.selectedURL = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	/*NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.showbag showbagTitle]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];*/
}


- (void)addToFavourites:(id)sender {
	
	// Check if Showbag has already been 'Favourited'
	/*BOOL added = [appDelegate alreadyAddedToFavourites:[self.showbag.showbagID intValue] favType:FAVOURITE_TYPE_SHOWBAG];
	
	// If it's already been added - delete it from database
	if (added) {
		
		// Delete Event from Favourites table in DB
		[appDelegate removeFromFavourites:[self.showbag.showbagID intValue] favType:FAVOURITE_TYPE_SHOWBAG];
		
		[self.addToPlannerButton setSelected:NO];
	}
	else {
		
		// Add to Favourites table in DB
		[appDelegate addToFavourites:[self.showbag.showbagID intValue] itemType:FAVOURITE_TYPE_SHOWBAG];
		
		[self.addToPlannerButton setSelected:YES];
		
		// Record this as an event in Google Analytics
		BOOL success = [[GANTracker sharedTracker] trackEvent:@"Showbags" action:@"Favourite" 
														label:[self.showbag showbagTitle] value:-1 withError:nil];
		
		NSLog(@"%@", (success ? @"SHOWBAG TRACKED!" : @"SHOWBAG FAILED TO BE TRACKED"));
	}*/
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.titleLabel.text = self.showbag.title;
	self.titleLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.titleLabel];
	
	self.priceLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.priceLabel.text = [NSString stringWithFormat:@"Price: $%.2f", [[self.showbag price] floatValue]];
	self.priceLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.priceLabel];
	
	
	CGRect currFrame = self.priceLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	[self.priceLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	
	self.rrPriceLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.rrPriceLabel.text = [NSString stringWithFormat:@"RRP: $%.2f", [[self.showbag rrPrice] floatValue]];
	self.rrPriceLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.rrPriceLabel];
	
	
	CGRect currFrame2 = self.rrPriceLabel.frame;
	CGFloat newYPos2 = (self.priceLabel.frame.origin.y + self.priceLabel.frame.size.height) - 12.0;
	[self.rrPriceLabel setFrame:CGRectMake(currFrame2.origin.x, newYPos2, currFrame2.size.width, currFrame2.size.height)];
	
	
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
	
	NSString *description;
	if ([self.showbag.showbagDescription length] > 0) 
		description = [self.showbag.showbagDescription stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
	else description = @"";
	
	self.descriptionLabel.text = description;
	[self resizeTextView:self.descriptionLabel];
	
	// Adjust the scroll view content size
	[self adjustScrollViewContentHeight];
	
	// Showbag image
	[self initImage:self.showbag.imageURL];
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


- (void)goToMap:(id)sender {
	
	/*double lat = [[self.showbag showbagLatitude] doubleValue];
	double lon = [[self.showbag showbagLongitude] doubleValue];
	
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	[mapVC setMapID:MAP_ID_SHOPPING];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
	*/
}


- (void)setupNavBar {
	
	// Add button to Navigation Title 
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 118.0, 22.0)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:[UIImage imageNamed:@"screenTitle-showbags.png"]];
	
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
	[backItem release];
}


- (void)recordPageView {

	//NSError **error;
	/*NSString *urlString = [NSString stringWithFormat:@"/showbags/%@.html", self.showbag.showbagTitle];
	NSLog(@"SHOWBAGS PAGE VIEW URL:%@", urlString);
	
	BOOL success = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (success ? @"YES - SHOWBAG PAGE VIEW RECORDED" : @"NO - SHOWBAG PAGE VIEW FAILED"));*/

}


- (void)updateAddToFavouritesButton {
	
	/*BOOL alreadyFavourite = [appDelegate alreadyAddedToFavourites:[self.showbag.showbagID intValue] favType:FAVOURITE_TYPE_SHOWBAG];
	
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
			[self.showbagImage setImage:img];
		}
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		[self.loadingSpinner setHidden:YES];
		[self.showbagImage setImage:image];
	}
}


- (void)dealloc {
	
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
	
	[selectedURL release];
	
    [super dealloc];
}


@end
