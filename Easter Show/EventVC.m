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
#import "GANTracker.h"
#import "SHK.h"
#import "Favourite.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "EventDateTime.h"
#import "Constants.h"

#define MAIN_CONTENT_HEIGHT 411

static NSString* kTitleFont = @"HelveticaNeue-Bold";
static NSString* kDescriptionFont = @"HelveticaNeue";
static NSString* kEntertainmentPlaceholderImage = @"placeholder-events-entertainment.jpg";
static NSString* kAnimalsPlaceholderImage = @"placeholder-events-animals.jpg";
static NSString* kCompetitionsPlaceholderImage = @"placeholder-events-competitions.jpg";

@implementation EventVC

@synthesize eventDateTime, managedObjectContext, navigationTitle;
@synthesize dateLabel, descriptionLabel, titleLabel, stitchedBorder;
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
	
	[self.addToPlannerButton setImage:[UIImage imageNamed:@"fav-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
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
	self.eventDateTime = nil;
	self.dateLabel = nil;
	self.descriptionLabel = nil;
	self.titleLabel = nil;
	self.navigationTitle = nil;
	self.shareButton = nil;
	self.mapButton = nil;
	self.addToPlannerButton = nil;
	self.stitchedBorder = nil;
}


- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:NO];
	
	// If the viewing of this Event has not already been recorded in Google Analytics
	// then record it as a page view
	if (!pageViewRecorded) [self recordPageView];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// Update add to faves button
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
	
	// Update EventDateTime object isFavourite property
	[self.eventDateTime setIsFavourite:[NSNumber numberWithBool:YES]];
	
	// Create Favourite object
	Favourite *fav = [Favourite favouriteWithFavouriteData:favouriteData inManagedObjectContext:self.managedObjectContext];
	
	[[self appDelegate] saveContext];
	
	// Update the ADD TO FAVES button
	if (fav) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
	
	// Record this as an event in Google Analytics
	if (![[GANTracker sharedTracker] trackEvent:@"Events" action:@"Favourite" 
													label:[self.eventDateTime.forEvent title] value:-1 withError:nil]) {
		NSLog(@"error recording Event as Favourite");
	}
}


- (void)goToEventMap:(id)sender {
	
	NSInteger mapID;
	
	if ([self.eventDateTime.forEvent.category isEqualToString:@"Entertainment"]) {
		mapID = MAP_ID_ENTERTAINMENT;
	}
	
	else if ([self.eventDateTime.forEvent.category isEqualToString:@"Animals"]) {
		mapID = MAP_ID_ANIMALS;
	}
	
	else if ([self.eventDateTime.forEvent.category isEqualToString:@"Competitions"]) {
		mapID = MAP_ID_COMPETITIONS;
	}
	
	else mapID = MAP_ID_ALL;

	MapVC *mapVC = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
	[mapVC setTitleText:self.eventDateTime.forEvent.title];
	[mapVC setMapID:mapID];
	[mapVC setCenterLatitude:[self.eventDateTime.forEvent.latitude doubleValue]];
	[mapVC setCenterLongitude:[self.eventDateTime.forEvent.longitude doubleValue]];

	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
}


// Assign the data to their appropriate UI elements
- (void)setDetailFields {
	
	
	// EVENT TITLE
	self.titleLabel.contentInset = UIEdgeInsetsMake(0,-8,0,0);
	self.titleLabel.text = [self.eventDateTime.forEvent.title uppercaseString];
	[self resizeTextView:self.titleLabel];
	
	
	// EVENT DATE LABEL
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM dd h:mm a"];
	
	self.dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormat stringFromDate:self.eventDateTime.startDate], [dateFormat stringFromDate:self.eventDateTime.endDate]];
	[dateFormat release];
	
	CGRect currFrame = self.dateLabel.frame;
	CGFloat newYPos = (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height) - 6.0;
	[self.dateLabel setFrame:CGRectMake(currFrame.origin.x, newYPos, currFrame.size.width, currFrame.size.height)];
	
	// STITCHED BORDER
	CGRect borderFrame = self.stitchedBorder.frame;
	borderFrame.origin.y = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 12.0; 
	[self.stitchedBorder setFrame:borderFrame];
	
	// EVENT DESCRIPTION
	CGRect descFrame = self.descriptionLabel.frame;
	descFrame.origin.y = self.stitchedBorder.frame.origin.y + 4.0;
	
	CGFloat newHeight = MAIN_CONTENT_HEIGHT - descFrame.origin.y;
	descFrame.size.height = newHeight;
	
	[self.descriptionLabel setFrame:descFrame];
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(0,-8,20,0);
	self.descriptionLabel.text = self.eventDateTime.forEvent.eventDescription;
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


- (void)setupNavBar {
	
	// Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
	
	// Set the navigation bar's title label
	[self.navigationTitle setText:[self.eventDateTime.forEvent.title uppercaseString]];

	/*
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
	
	NSError **error;
	NSString *urlString = [NSString stringWithFormat:@"/events/%@.html", self.eventDateTime.forEvent.title];
	NSLog(@"EVENTS PAGE VIEW URL:%@", urlString);
	
	pageViewRecorded = [[GANTracker sharedTracker] trackPageview:urlString withError:nil];
	NSLog(@"%@", (pageViewRecorded ? @"EVENTS PAGE VIEW RECORDED" : @"EVENTS PAGE VIEW FAILED"));
}


- (void)updateAddToFavouritesButton {
	
	if ([self.eventDateTime.isFavourite boolValue]) {
		
		[self.addToPlannerButton setSelected:YES];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:NO];
	}
	
	else {
		
		[self.addToPlannerButton setSelected:NO];
		[self.addToPlannerButton setHighlighted:NO];
		[self.addToPlannerButton setUserInteractionEnabled:YES];
	}
}


- (void)dealloc {
	
	[managedObjectContext release];
	[eventDateTime release];
	
	[dateLabel release];
	[descriptionLabel release];
	[titleLabel release];
	[stitchedBorder release];
	
	[navigationTitle release];
	
	[shareButton release];
	[mapButton release];
	[addToPlannerButton release];
	
    [super dealloc];
}


@end
