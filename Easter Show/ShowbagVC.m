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
#import "Constants.h"
#import "ImageDownload.h"
#import "SHK.h"
#import "MapVC.h"
#import "GANTracker.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-showbags.jpg";

@implementation ShowbagVC

@synthesize showbag, internetConnectionPresent, enableQuickSelection;
@synthesize minPrice, maxPrice, rrPriceLabel;
@synthesize contentScrollView, priceLabel, descriptionLabel, titleLabel, showbagImage;
@synthesize previousButton, nextButton;
@synthesize shareButton, addToPlannerButton, mapButton, loadingSpinner, downloads;


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
	
	appDelegate = (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Determine network/internet availability
	reach = [[Reachability reachabilityForInternetConnection] retain];
	NetworkStatus status = [reach currentReachabilityStatus];
    self.internetConnectionPresent = [appDelegate boolFromNetworkStatus:status];
	
	self.titleLabel.font = [UIFont fontWithName:kTitleFont size:16.0];
	self.priceLabel.font = [UIFont fontWithName:kTitleFont size:12.0];
	self.rrPriceLabel.font = [UIFont fontWithName:kTitleFont size:12.0];
	self.descriptionLabel.font = [UIFont fontWithName:kDescriptionFont size:12.0];
	
	self.downloads = [[NSMutableArray alloc] init];
	
	// Assign the data to their appropriate UI elements
	[self setDetailFields];
	
	// ADD TO FAVOURITES BUTTON ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"addToFavouritesButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[self updateAddToFavouritesButton];
	
	// Setup previous and next buttons in nav bar
	//[self initPreviousNextButtons];
	
	//[self configurePreviousNextButtons];
	
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
	
	self.showbag = nil;
	self.contentScrollView = nil;
	self.rrPriceLabel = nil;
	self.priceLabel = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.showbagImage = nil;
	self.downloads = nil;
	self.minPrice = nil;
	self.maxPrice = nil;
	self.loadingSpinner = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
}


- (void)viewWillDisappear:(BOOL)animated {
	
	// Stop any ImageDownloads that are still downloading
	[self disableDownloads];
	
    [super viewWillDisappear:animated];
}


#pragma mark ImageDownloadDelegate Methods
- (void)downloadDidFinishDownloading:(ImageDownload *)download {
	
	// Save the image to the Event object
	if (download.downloadID == [[self.showbag showbagID] intValue])  {
		
		[self.showbag setShowbagImage:download.image];
		self.showbagImage.image = download.image;
	}
	
	[self.loadingSpinner stopAnimating];
	
	Showbag *_showbag = [appDelegate getShowbagWithID:download.downloadID];
	
	// Create a user friendly filename from the URL path
	NSString *filename = [appDelegate extractImageNameFromURLString:download.urlString];
	
	// Save image to the relevant sub directory of Documents/
	[appDelegate saveShowbagsImageToDocumentsWithID:[[_showbag showbagID] intValue] imageName:filename obj:download.image];
	
    download.delegate = nil;
	[self.downloads removeObject:download];
}


- (void)download:(ImageDownload *)download didFailWithError:(NSError *)error {
	
    NSLog(@"Error: %@", [error localizedDescription]);
	download.delegate = nil;
	
	if (download.downloadID == [[self.showbag showbagID] intValue]) self.showbagImage.image = [UIImage imageNamed:kPlaceholderImage];
	
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.showbag showbagTitle]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)addToFavourites:(id)sender {
	
	// Check if Showbag has already been 'Favourited'
	BOOL added = [appDelegate alreadyAddedToFavourites:[self.showbag.showbagID intValue] favType:FAVOURITE_TYPE_SHOWBAG];
	
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
	}
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.titleLabel.text = self.showbag.showbagTitle;
	self.titleLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.titleLabel];
	
	self.priceLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.priceLabel.text = [NSString stringWithFormat:@"Price: $%.2f", [[self.showbag showbagPrice] floatValue]];
	self.priceLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.priceLabel];
	
	
	CGRect currFrame = self.priceLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	[self.priceLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	
	self.rrPriceLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.rrPriceLabel.text = [NSString stringWithFormat:@"RRP: $%.2f", [[self.showbag showbagRRPrice] floatValue]];
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
	
	UIImage *sImage = [self.showbag showbagImage];
	
	if (sImage == nil) {
		
		// Get thumbURL
		NSString *imageURL = [self.showbag imageURL];
		
		// get user friendly name for image e.g. 'product1.jpg'
		NSString *filename = [appDelegate extractImageNameFromURLString:imageURL];
		
		sImage = [UIImage imageNamed:filename];
		
		if (sImage == nil) {
			
			// Check Documents/
			sImage = [appDelegate getImageForShowbagWithID:[[self.showbag showbagID] intValue] image:filename];
			
			if (sImage == nil) {
				
				if (self.internetConnectionPresent && ([imageURL length] != 0)) {
					
					// Download Image from URL
					ImageDownload *download = [[ImageDownload alloc] init];
					download.urlString = imageURL;
					download.downloadID = [[self.showbag showbagID] intValue];
					sImage = download.image;
					
					[self.loadingSpinner startAnimating];
					download.delegate = self;
					
					[self.downloads addObject:[download retain]];
					[download release];
				}
				else sImage = [UIImage imageNamed:kPlaceholderImage];
			}
		}
	}
	else [self.loadingSpinner stopAnimating];
	
	self.showbagImage.image = sImage;
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


- (void)goToPrevious:(id)sender {
	
	CGFloat minPriceFloat = [self.minPrice floatValue];
	CGFloat maxPriceFloat = [self.maxPrice floatValue];
	
	Showbag *previousShowbag = [appDelegate goToPreviousShowbag:[[self.showbag showbagID] intValue] minPrice:minPriceFloat maxPrice:maxPriceFloat];
	
	self.showbag = nil;
	
	self.showbag = previousShowbag;
	
	[self setDetailFields];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
	
	//[self configurePreviousNextButtons];
}


- (void)goToNext:(id)sender {
	
	CGFloat minPriceFloat = [self.minPrice floatValue];
	CGFloat maxPriceFloat = [self.maxPrice floatValue];
	
	Showbag *nextShowbag = [appDelegate goToNextShowbag:[[self.showbag showbagID] intValue] minPrice:minPriceFloat maxPrice:maxPriceFloat];
	
	self.showbag = nil;
	
	self.showbag = nextShowbag;
	
	[self setDetailFields];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
	
	//[self configurePreviousNextButtons];
}


- (void)goToMap:(id)sender {
	
	double lat = [[self.showbag showbagLatitude] doubleValue];
	double lon = [[self.showbag showbagLongitude] doubleValue];
	
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	[mapVC setMapID:MAP_ID_SHOPPING];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
	
}


- (void)initPreviousNextButtons {
	
	self.previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.previousButton setFrame:CGRectMake(0, 0, 46, 31)];
	[self.previousButton addTarget:self action:@selector(goToPrevious:) forControlEvents:UIControlEventTouchUpInside];
	[self.previousButton setBackgroundColor:[UIColor clearColor]];
	[self.previousButton setTag:0];
	[self.previousButton setBackgroundImage:[UIImage imageNamed:@"upArrowButton.png"] forState:UIControlStateNormal];
	[self.previousButton setBackgroundImage:[UIImage imageNamed:@"upArrowButton-on.png"] forState:UIControlStateHighlighted];
	[self.previousButton setBackgroundImage:[UIImage imageNamed:@"upArrowButton-on.png"] forState:UIControlStateSelected];
	[self.previousButton setBackgroundImage:[UIImage imageNamed:@"upArrowButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.nextButton setFrame:CGRectMake(46, 0, 45, 31)];
	[self.nextButton addTarget:self action:@selector(goToNext:) forControlEvents:UIControlEventTouchUpInside];
	[self.nextButton setBackgroundColor:[UIColor clearColor]];
	[self.nextButton setTag:1];
	[self.nextButton setBackgroundImage:[UIImage imageNamed:@"downArrowButton.png"] forState:UIControlStateNormal];
	[self.nextButton setBackgroundImage:[UIImage imageNamed:@"downArrowButton-on.png"] forState:UIControlStateHighlighted];
	[self.nextButton setBackgroundImage:[UIImage imageNamed:@"downArrowButton-on.png"] forState:UIControlStateSelected];
	[self.nextButton setBackgroundImage:[UIImage imageNamed:@"downArrowButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	UIView *segmentedControl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 91, 31)];
	[segmentedControl addSubview:self.previousButton];
	[segmentedControl addSubview:self.nextButton];
	
	UIBarButtonItem *arrowsItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	[segmentedControl release];
	
	self.navigationItem.rightBarButtonItem = arrowsItem;
	[arrowsItem release];
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


- (void)configurePreviousNextButtons {
	
	if (self.enableQuickSelection) {
		
		CGFloat minPriceFloat = [self.minPrice floatValue];
		CGFloat maxPriceFloat = [self.maxPrice floatValue];
		
		BOOL first = [appDelegate isFirstShowbag:[[self.showbag showbagID] intValue] minPrice:minPriceFloat maxPrice:maxPriceFloat];
		
		[self.previousButton setEnabled:((first) ? NO : YES)];
		
		BOOL last = [appDelegate isLastShowbag:[[self.showbag showbagID] intValue] minPrice:minPriceFloat maxPrice:maxPriceFloat];
		
		[self.nextButton setEnabled:((last) ? NO : YES)];
	}
	else {
		
		[self.previousButton setHidden:YES];
		[self.nextButton setHidden:YES];
	}
}


- (void)recordPageView {

	//NSError **error;
	NSString *urlString = [NSString stringWithFormat:@"/showbags/%@.html", self.showbag.showbagTitle];
	NSLog(@"SHOWBAGS PAGE VIEW URL:%@", urlString);
	
	BOOL success = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (success ? @"YES - SHOWBAG PAGE VIEW RECORDED" : @"NO - SHOWBAG PAGE VIEW FAILED"));

}


- (void)updateAddToFavouritesButton {
	
	BOOL alreadyFavourite = [appDelegate alreadyAddedToFavourites:[self.showbag.showbagID intValue] favType:FAVOURITE_TYPE_SHOWBAG];
	
	if (alreadyFavourite) [self.addToPlannerButton setSelected:YES];
	else [self.addToPlannerButton setSelected:NO];
}


// Stop any ImageDownloads that are still downloading
- (void)disableDownloads {
	
	for (NSInteger i = 0; i < [self.downloads count]; i++) {
		
		ImageDownload *imageDownload = [self.downloads objectAtIndex:i];
		imageDownload.delegate = nil;
		
	}
}


- (void)dealloc {
	
	[showbag release];
	[contentScrollView release];
	[downloads release];
	[rrPriceLabel release];
	[priceLabel release];
	[descriptionLabel release];
	[titleLabel release];
	[showbagImage release];
	[minPrice release];
	[maxPrice release];
	[loadingSpinner release];
    [super dealloc];
}


@end
