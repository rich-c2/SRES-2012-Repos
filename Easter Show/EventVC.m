//
//  EventVC.m
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "EventVC.h"
#import "Event.h"
#import "SRESAppDelegate.h"
#import "MapVC.h"
//#import "GANTracker.h"
#import "SHK.h"
#import "Favourite.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "EventDateTime.h"

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kEntertainmentPlaceholderImage = @"placeholder-events-entertainment.jpg";
static NSString* kAnimalsPlaceholderImage = @"placeholder-events-animals.jpg";
static NSString* kCompetitionsPlaceholderImage = @"placeholder-events-competitions.jpg";

@implementation EventVC

@synthesize eventDateTime, managedObjectContext;
@synthesize dateLabel, descriptionLabel, titleLabel, eventImage;
@synthesize eventTypeFilter, eventDay;
@synthesize navigationTitle;
@synthesize shareButton, addToPlannerButton, mapButton;


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
	
	// Is it already added to favourites?
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
	
	self.eventDateTime = nil;
	self.dateLabel = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.eventImage = nil;
	self.eventDay = nil;
	self.eventTypeFilter = nil;
	self.navigationTitle = nil;
}


- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:NO];
	
	[self recordPageView];
	
	[self updateAddToFavouritesButton];
	
}


- (void)viewWillDisappear:(BOOL)animated {
	
    [super viewWillDisappear:animated];
}


- (void)showShareOptions:(id)sender {
	
	// Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://www.eastershow.com.au/"];
	NSString *message = [NSString stringWithFormat:@"Sydney Royal Easter Show: %@", [self.eventDateTime.forEvent title]];
	SHKItem *item = [SHKItem URL:url title:message];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)addToFavourites:(id)sender {
	
	NSMutableDictionary *favouriteData = [NSMutableDictionary dictionary];
	[favouriteData setObject:[self.eventDateTime dateTimeID] forKey:@"id"];
	[favouriteData setObject:[self.eventDateTime dateTimeID] forKey:@"itemID"];
	[favouriteData setObject:[self.eventDateTime.forEvent title] forKey:@"title"];
	[favouriteData setObject:@"Events" forKey:@"favouriteType"];
	
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
	self.titleLabel.text = [self.eventDateTime.forEvent.title uppercaseString];
	[self resizeTextView:self.titleLabel];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM dd h:mm a"];
	
	self.dateLabel.contentInset = UIEdgeInsetsMake(-12,-8,0,0);
	self.dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormat stringFromDate:self.eventDateTime.startDate], [dateFormat stringFromDate:self.eventDateTime.endDate]];
	[self resizeTextView:self.dateLabel];

	[dateFormat release];
	
	CGRect currFrame = self.dateLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 12.0;
	[self.dateLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(16,-8,0,0);
	self.descriptionLabel.text = self.eventDateTime.forEvent.eventDescription;
	//[self resizeTextView:self.descriptionLabel];
	
	// Adjust the scroll view content size
	//[self adjustScrollViewContentHeight];	
	
	// Event image
	[self initImage];
}


- (void)resizeTextView:(UITextView *)_textView {
	
	CGRect frame;
	frame = _textView.frame;
	frame.size.height = [_textView contentSize].height;
	_textView.frame = frame;
	
}

/*
- (void)adjustScrollViewContentHeight {
	
	CGFloat bottomPadding = 15.0;
	CGSize currSize = [self.contentScrollView contentSize];
	CGFloat newContentHeight = [self.descriptionLabel frame].origin.y + [self.descriptionLabel frame].size.height + bottomPadding;
	
	[self.contentScrollView setContentSize:CGSizeMake(currSize.width, newContentHeight)];
}*/


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setupNavBar {
	
	// Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
	
	// Set the navigation bar's title label
	[self.navigationTitle setText:[self.eventDateTime.forEvent.title uppercaseString]];
	
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



/* 
// Images are not being dynamically generated for Event objects.
// Thus, the image displayed will be a generic one based on
// what category the current Event is part of. (e.g. Entertainment)
*/
- (void)initImage {
	
	UIImage *img;
	
	if ([self.eventDateTime.forEvent.category isEqualToString:@"Animals"]) 
		img = [UIImage imageNamed:kAnimalsPlaceholderImage];
	
	else if ([self.eventDateTime.forEvent.category isEqualToString:@"Entertainment"]) 
		img = [UIImage imageNamed:kEntertainmentPlaceholderImage];
	
	else if ([self.eventDateTime.forEvent.category isEqualToString:@"Competitons"]) 
		img = [UIImage imageNamed:kCompetitionsPlaceholderImage];
	
	else img = [UIImage imageNamed:kEntertainmentPlaceholderImage];
	
	// Set the image to the image view
	[self.eventImage setImage:img];
}


- (void)dealloc {
	
	[eventDateTime release];
	[dateLabel release];
	[descriptionLabel release];
	[titleLabel release];
	[eventImage release];
	[eventDay release];
	[eventTypeFilter release];
	[navigationTitle release];
	
    [super dealloc];
}


@end
