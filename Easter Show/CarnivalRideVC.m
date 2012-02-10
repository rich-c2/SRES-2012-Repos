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
//#import "GANTracker.h"
#import "ImageManager.h"
#import "StringHelper.h"
#import "Favourite.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kPlaceholderImage = @"placeholder-carnivals.jpg";

@implementation CarnivalRideVC

@synthesize carnivalRide, contentScrollView, managedObjectContext;
@synthesize descriptionLabel, titleLabel, subTitleLabel, rideImage;
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
	
	self.titleLabel.font = [UIFont fontWithName:kTitleFont size:16.0];
	self.descriptionLabel.font = [UIFont fontWithName:kDescriptionFont size:12.0];
	self.subTitleLabel.font = [UIFont fontWithName:kDescriptionFont size:12.0];
	
	
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
	self.selectedURL = nil;
	self.carnivalRide = nil;
	self.contentScrollView = nil;
	self.descriptionLabel = nil;
	self.subTitleLabel = nil;
	self.titleLabel = nil;
	self.rideImage = nil;
	self.loadingSpinner = nil;
	self.navigationTitle = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:NO];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
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
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	self.titleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	self.titleLabel.text = self.carnivalRide.title;
	self.titleLabel.backgroundColor = [UIColor clearColor];
	[self resizeTextView:self.titleLabel];
	
	//NSString *subtitle;
	
	//if ([self.carnivalRide.subTitle length] != 0) subtitle = self.carnivalRide.s;
	//else subtitle = @"";
	
	//self.subTitleLabel.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	//self.subTitleLabel.text = subtitle;
	//[self resizeTextView:self.subTitleLabel];
	
	//CGRect currFrame = self.subTitleLabel.frame;
	//CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	//[self.subTitleLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
	self.descriptionLabel.text = self.carnivalRide.rideDescription;
	[self resizeTextView:self.descriptionLabel];
	
	// Adjust the scroll view content size
	[self adjustScrollViewContentHeight];
	
	// Event image
	[self initImage:self.carnivalRide.imageURL];
}


- (void)adjustScrollViewContentHeight {
	
	CGFloat bottomPadding = 15.0;
	CGSize currSize = [self.contentScrollView contentSize];
	CGFloat newContentHeight = [self.descriptionLabel frame].origin.y + [self.descriptionLabel frame].size.height + bottomPadding;
	
	[self.contentScrollView setContentSize:CGSizeMake(currSize.width, newContentHeight)];
	
	
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
	
	/*double lat;
	double lon;
	
	if ([self.carnivalRide rideType] == RideTypeCocaCola) {
	
		lat = -33.84462;
		lon = 151.07213;
	}
	else if ([self.carnivalRide rideType] == RideTypeKids) {
		
		lat = -33.84422;
		lon = 151.06363;
	}
	else {
		
		lat = -33.84462;
		lon = 151.07213;
	}
	
	
	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	[mapVC setMapID:MAP_ID_CARNIVALS];
	[mapVC setCenterLatitude:lat];
	[mapVC setCenterLongitude:lon];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
	*/
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
	
	//NSError **error;
	/*NSString *urlString = [NSString stringWithFormat:@"/carnivalrides/%@.html", self.carnivalRide.rideTitle];
	NSLog(@"CARNIVAL PAGE VIEW URL:%@", urlString);
	
	BOOL success = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (success ? @"YES - CARNIVAL RIDE PAGE VIEW RECORDED" : @"NO - CARNIVAL RIDE PAGE VIEW FAILED"));*/
}


- (void)updateAddToFavouritesButton {
	
	/*BOOL alreadyFavourite = [appDelegate alreadyAddedToFavourites:[self.carnivalRide.rideID intValue] favType:FAVOURITE_TYPE_CARNIVAL];
	
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
			[self.rideImage setImage:img];
		}
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		[self.loadingSpinner stopAnimating];
		[self.rideImage setImage:image];
	}
}


- (void)dealloc {
	
	[managedObjectContext release];
	[selectedURL release];
	[carnivalRide release];
	[contentScrollView release];
	[descriptionLabel release];
	[titleLabel release];
	[subTitleLabel release];
	[rideImage release];
	[loadingSpinner release];
	[navigationTitle release];
	
    [super dealloc];
}


@end
