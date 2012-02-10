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
#import "SVProgressHUD.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "StringHelper.h"
#import "JSONFetcher.h"
#import "SBJson.h"


static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-offers.jpg";

@implementation OfferVC

@synthesize offer, managedObjectContext, contentScrollView;
@synthesize descriptionLabel, titleLabel, providerLabel, offerImage;
@synthesize shareButton, addToPlannerButton, redeemButton;
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
	
	// Setup navigation bar elements
	[self setupNavBar];
		
	// Assign the data to their appropriate UI elements
	[self setDetailFields];
	
	
	// ADD TO FAVOURITES BUTTON ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"addToFavouritesButton-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[self updateAddToFavouritesButton];	

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
	self.addToPlannerButton = nil;
	self.shareButton = nil;
	self.redeemButton = nil;
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
	
	// Only show the redeem button if this is a single redeem offer
	if ([self.offer.offerType isEqualToString:@"single"]) [self.redeemButton setHidden:NO];
	
	// OFFER TITLE
	self.titleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.titleLabel.text = self.offer.title;
	self.titleLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.titleLabel];
	
	
	// PROVIDER LABEL
	self.providerLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	
	NSString *providerText = [NSString	stringWithFormat:@"%@", self.offer.provider];
	if ([providerText length] <= 0) providerText = @"";
	
	self.providerLabel.text = providerText;
	[self resizeTextView:self.providerLabel];
	
	CGRect currFrame = self.providerLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	[self.providerLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	// DESCRIPTION
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


- (void)setupNavBar {
	
	// Hide default navigation bar
	[self.navigationController setNavigationBarHidden:YES];
	
	// Add button to Navigation Title 
	/*UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 79.0, 22.0)];
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


- (IBAction)redeemButtonClicked:(id)sender {
	
	if ([self.offer.offerType isEqualToString:@"single"]) {
		
		// Set the object's redeemed property to 1
		self.offer.redeemed = [NSNumber numberWithInt:1];
		[[self appDelegate] saveContext];
		
		[self showLoading];
	
		// Disable redeem button
		[self.redeemButton setEnabled:NO];

		NSString *docName = @"put_redeem";
		
		NSMutableString *mutableXML = [NSMutableString string];
		[mutableXML appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"]; 
		[mutableXML appendString:@"<redeem>"];
		[mutableXML appendFormat:@"<uID>%@</uID>", [[self appDelegate] getDeviceID]];
		[mutableXML appendFormat:@"<offerID>%i</offerID>", [self.offer.offerID intValue]];
		[mutableXML appendString:@"</redeem>"];
		
		NSLog(@"XML:%@", mutableXML);
		
		// Change the string to NSData for transmission
		NSData *requestBody = [mutableXML dataUsingEncoding:NSASCIIStringEncoding];
		
		NSString *urlString = [NSString stringWithFormat:@"%@%@", API_SERVER_ADDRESS, docName];
		NSLog(@"FOOD VENUES URL:%@", urlString);
		
		NSURL *url = [urlString convertToURL];
		
		// Create the request.
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
															   cachePolicy:NSURLRequestUseProtocolCachePolicy
														   timeoutInterval:45.0];
		
		//[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
		[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:requestBody];
		
		
		// JSONFetcher
		fetcher = [[JSONFetcher alloc] initWithURLRequest:request
												 receiver:self
												   action:@selector(receivedFeedResponse:)];
		[fetcher start];
	}
}


// Example fetcher response handling
- (void)receivedFeedResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSString *result;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		result = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding];
	}
	
	// Hide loading view
	[self hideLoading];
	
	NSString *title;
	NSString *message;
	
	if ([result length] > 0) {
	
		if ([result isEqualToString:@"success"]) {
		
			title = @"Success!";
			message = [NSString stringWithFormat:@"You successfully redeemed %@", self.offer.title];
		}
		
		else {
			
			title = @"Sorry!";
			message = [NSString stringWithFormat:@"There was an error redeeming %@. Check your network connection and try again.", self.offer.title];
		}
	}
	
	else {
	
		title = @"Sorry!";
		message = [NSString stringWithFormat:@"There was an error redeeming %@. Check your network connection and try again.", self.offer.title];
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message 
	 delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
	[alert show];    
	[alert release];
	
	[result release];
	
	[fetcher release];
	fetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
} 


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
	[redeemButton release];
	
	[loadingSpinner release];
	
    [super dealloc];
}


@end
