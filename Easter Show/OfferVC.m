//
//  OfferVC.m
//  SRES
//
//  Created by Richard Lee on 13/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "OfferVC.h"
#import "Offer.h"
#import "SRESAppDelegate.h"
//#import "GANTracker.h"
#import "SHK.h"
#import "Favourite.h"
#import "ImageManager.h"
#import "StringHelper.h"


static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-offers.jpg";

@implementation OfferVC

@synthesize offer, managedObjectContext, contentScrollView;
@synthesize descriptionLabel, titleLabel, providerLabel, offerImage;
@synthesize shareButton, addToPlannerButton;
@synthesize loadingSpinner, selectedURL;


// The designated initializer.  Override if you create the controller programmatically 
// and want to perform customization that is not appropriate for viewDidLoad.
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
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"addToFavouritesButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[self updateAddToFavouritesButton];	
	
	// Setup navigation bar elements
	[self setupNavBar];

}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
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
	
	self.selectedURL = nil;
	self.contentScrollView = nil; 
	self.loadingSpinner = nil; 
	self.offer = nil;
	self.descriptionLabel = nil; 
	self.titleLabel = nil;
	self.offerImage = nil;
	self.managedObjectContext = nil;
}


- (void)viewWillDisappear:(BOOL)animated {
	
	// Stop any ImageDownloads that are still downloading
	
    [super viewWillDisappear:animated];
}


#pragma mark TwitterVCDelegate

- (void)closeTwitterVC {
	
	[self dismissModalViewControllerAnimated:YES];
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.titleLabel.text = self.offer.title;
	self.titleLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.titleLabel];
	
	self.providerLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	
	NSString *providerText = [NSString	stringWithFormat:@"%@", self.offer.provider];
	if ([providerText length] <= 0) providerText = @"";
	
	self.providerLabel.text = providerText;
	[self resizeTextView:self.providerLabel];
	
	CGRect currFrame = self.providerLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	[self.providerLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
	self.descriptionLabel.text = self.offer.offerDescription;
	[self resizeTextView:self.descriptionLabel];
	
	// Adjust the scroll view content size
	[self adjustScrollViewContentHeight];
	
	// Showbag image
	[self initImage:self.offer.imageURL];
}


- (void)addToFavourites:(id)sender {
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.offer offerID] forKey:@"id"];
	[favouriteData setObject:self.offer.offerID forKey:@"itemID"];
	[favouriteData setObject:self.offer.title forKey:@"title"];
	[favouriteData setObject:@"Offers" forKey:@"favouriteType"];
	
	[Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
}


- (void)resizeTextView:(UITextView *)_textView {
	
	CGRect frame;
	frame = _textView.frame;
	frame.size.height = [_textView contentSize].height;
	_textView.frame = frame;
	
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
	
	
	// Add button to Navigation Title 
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 79.0, 22.0)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:[UIImage imageNamed:@"screenTitle-offers.png"]];
	
	self.navigationItem.titleView = image;
	[image release];*/
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.offer title]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)recordPageView {
	
	//NSError **error;
	/*NSString *urlString = [NSString stringWithFormat:@"/offers/%@.html", self.offer.offerTitle];
	NSLog(@"OFFER PAGE VIEW URL:%@", urlString);
	
	BOOL success = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (success ? @"YES - OFFER PAGE VIEW RECORDED" : @"NO - OFFER PAGE VIEW FAILED"));*/
}


- (void)updateAddToFavouritesButton {

	/*BOOL alreadyFavourite = [appDelegate alreadyAddedToFavourites:[self.offer.offerID intValue] favType:FAVOURITE_TYPE_OFFER];
	
	if (alreadyFavourite) [self.addToPlannerButton setSelected:YES];
	else [self.addToPlannerButton setSelected:NO];*/
}


- (void)adjustScrollViewContentHeight {
	
	CGFloat bottomPadding = 15.0;
	CGSize currSize = [self.contentScrollView contentSize];
	CGFloat newContentHeight = [self.descriptionLabel frame].origin.y + [self.descriptionLabel frame].size.height + bottomPadding;
	
	[self.contentScrollView setContentSize:CGSizeMake(currSize.width, newContentHeight)];
	
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		[self.loadingSpinner startAnimating];
		
		self.selectedURL = [urlString convertToURL];
		
		NSLog(@"LOADING MAIN IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:self.selectedURL];
		
		if (img) {
			
			[self.loadingSpinner setHidden:YES];
			[self.offerImage setImage:img];
		}
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		[self.loadingSpinner setHidden:YES];
		[self.offerImage setImage:image];
	}
}


- (void)dealloc {
	
	[selectedURL release];
	[managedObjectContext release];
	
	[offer release];
	
	[contentScrollView release];
	[descriptionLabel release]; 
	[titleLabel release];
	[providerLabel release];
	[offerImage release];
	
	[shareButton release];
	[addToPlannerButton release];
	
	[loadingSpinner release];
	
    [super dealloc];
}


@end
