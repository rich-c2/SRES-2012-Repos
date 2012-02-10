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
//#import "GANTracker.h"
#import "ImageManager.h"
#import "StringHelper.h"
#import "Favourite.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-showbags.jpg";

@implementation ShowbagVC

@synthesize showbag, minPrice, maxPrice, rrPriceLabel, managedObjectContext;
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
	
	[Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
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


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)goToMap:(id)sender {
	
	double lat = [[self.showbag latitude] doubleValue];
	double lon = [[self.showbag longitude] doubleValue];
	
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
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
	
	[selectedURL release];
	
    [super dealloc];
}


@end
