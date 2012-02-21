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
#import "GANTracker.h"
#import "SHK.h"
#import "Favourite.h"
#import "SVProgressHUD.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "StringHelper.h"
#import "JSONFetcher.h"
#import "SBJson.h"

static NSInteger kConfirmRedeemAlertTag = 5000;
static NSInteger kRedeemResponseAlertTag = 5001;
static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-offers.jpg";

@implementation OfferVC

@synthesize offer, managedObjectContext, contentScrollView;
@synthesize descriptionLabel, titleLabel, providerLabel, offerImage;
@synthesize shareButton, addToPlannerButton, redeemButton;
@synthesize loadingSpinner, selectedURL, stitchedBorder;


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
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"fav-button-large-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
	[self updateAddToFavouritesButton];	

}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	// If the viewing of this Offer has not already been recorded in Google Analytics
	// then record it as a page view
	if (!pageViewRecorded) [self recordPageView];
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
	self.stitchedBorder = nil;
}


- (void)viewWillDisappear:(BOOL)animated {
	
	// Stop any ImageDownloads that are still downloading
	
    [super viewWillDisappear:animated];
}


#pragma UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	// Check that the alertView in question is in fact the confirm redeem alert view
	// Also check that the button that was pressed was the 'Yes' one before
	// making the call to the API
	if (alertView.tag == kConfirmRedeemAlertTag &&  buttonIndex == 0) {
		
		// Push redeem to API
		[self pushRedeemToAPI];
	}
	
	
	// If it was the pop-up for the API response and it was a successful redeem
	// then pop the user back to the Offers menu
	else if (alertView.tag == kRedeemResponseAlertTag && successfulRedeem) {
	
		[self goBack:nil];
	}
}


#pragma mark MY METHODS

// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	// Only show the redeem button if this is a single redeem offer
	if ([self.offer.offerType isEqualToString:@"single"]) {
		
		// Show the button
		[self.redeemButton setHidden:NO];
		
		// Adjust the description text view's frame accordingly
		CGRect descFrame =	self.descriptionLabel.frame;
		descFrame.size.height -= self.redeemButton.frame.size.height;
		[self.descriptionLabel setFrame:descFrame];
	}
	
	// OFFER TITLE
	self.titleLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.titleLabel.text = self.offer.title;
	[self resizeTextView:self.titleLabel];
	
	
	// PROVIDER LABEL
	self.providerLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	
	NSString *providerText = [NSString	stringWithFormat:@"%@", self.offer.provider];
	if ([providerText length] <= 0) providerText = @"";
	
	self.providerLabel.text = providerText;
	[self resizeTextView:self.providerLabel];
	
	CGRect currFrame = self.providerLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 16.0;
	[self.providerLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	
	// STITCHED BORDER
	CGRect borderFrame = self.stitchedBorder.frame;
	borderFrame.origin.y = self.providerLabel.frame.origin.y + self.providerLabel.frame.size.height + 4.0; 
	[self.stitchedBorder setFrame:borderFrame];
	
	
	// DESCRIPTION
	CGRect descFrame = self.descriptionLabel.frame;
	descFrame.origin.y = self.stitchedBorder.frame.origin.y + 4.0;
	[self.descriptionLabel setFrame:descFrame];
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.descriptionLabel.text = self.offer.offerDescription;
	
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
	
	// Record this as an event in Google Analytics
	if (![[GANTracker sharedTracker] trackEvent:@"Offers" action:@"Favourite" 
										  label:[self.offer title] value:-1 withError:nil]) {
		NSLog(@"error recording Offer as Favourite");
	}
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
	
	NSError **error;
	NSString *urlString = [NSString stringWithFormat:@"/offers/%@.html", self.offer.title];
	NSLog(@"OFFER PAGE VIEW URL:%@", urlString);
	
	pageViewRecorded = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (pageViewRecorded ? @"OFFER PAGE VIEW RECORDED" : @"OFFER PAGE VIEW FAILED"));
}


- (void)updateAddToFavouritesButton {

	BOOL favourite = [Favourite isItemFavourite:[self.offer offerID] favouriteType:@"Offers" inManagedObjectContext:self.managedObjectContext];
	
	if (favourite) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
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
	
	// Double check that we're dealing with an Offer
	// that is redeemed with the click of a button
	if ([self.offer.offerType isEqualToString:@"single"]) {
		
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you want to proceed - this offer can only be redeemed once."
													   delegate:self cancelButtonTitle:nil otherButtonTitles: @"YES", nil];
		[alert addButtonWithTitle:@"NO"];
		[alert setTag:kConfirmRedeemAlertTag];
		
		[alert show];	
		[alert release];
	}
}


- (void)pushRedeemToAPI {

	// Set the object's redeemed property to 1
	self.offer.redeemed = [NSNumber numberWithInt:1];
	[[self appDelegate] saveContext];
	
	// Check if it's a Fav - if so, delete the Fav
	Favourite *fav = [Favourite favouriteWithItemID:[self.offer offerID] favouriteType:@"Offers" 
							 inManagedObjectContext:self.managedObjectContext];
	
	if (fav) [self.managedObjectContext deleteObject:fav];
	
	
	// If the app is not currently in offlineMode
	// Then initiate the redeem API with the offerID
	// as well as the deviceID 
	if (![[self appDelegate] offlineMode]) {
	
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
		fetcher = [[JSONFetcher alloc] initWithURLRequest:request receiver:self
												   action:@selector(receivedFeedResponse:)];
		[fetcher start];
	}
	
	
	// Show a success pop-up for user feedback
	// Then pop the user back to the Offers menu
	else {
		
		successfulRedeem = YES;
		
		NSString *title = @"Success!";
		NSString *message = [NSString stringWithFormat:@"You successfully redeemed %@", self.offer.title];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message 
													   delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
		[alert setTag:kRedeemResponseAlertTag];
		
		[alert show];    
		[alert release];
	}
}


// Example fetcher response handling
- (void)receivedFeedResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSString *result;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		result = [results objectForKey:@"response"];
	}
	
	// Hide loading view
	[self hideLoading];
	
	NSString *title;
	NSString *message;
	
	if ([result length] > 0) {
	
		if ([result isEqualToString:@"success"]) {
		
			successfulRedeem = YES;
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
	[alert setTag:kRedeemResponseAlertTag];
	
	[alert show];    
	[alert release];
	
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
	[stitchedBorder release];
	
    [super dealloc];
}


@end
