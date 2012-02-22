//
//  MapsVC.m
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "MapsVC.h"
#import "CustomTabBarItem.h"
#import "LegendVC.h"
#import "Constants.h"
#import "SRESAppDelegate.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

static NSString *kUserLocationIconImage = @"userLocationIcon.png";

@implementation MapsVC

@synthesize subNavScrollView, mapScrollView, mapOverlay, userLocationView;
@synthesize locateMeButton, legendButton;
@synthesize imageNames, selectedFilterButton;
@synthesize locationManager, filterHeading, filterHeaderImageNames;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"maps-tab-button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"maps-tab-button.png"];
        self.tabBarItem = tabItem;
        [tabItem release];
        tabItem = nil;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	NSArray *headerImageNames = [[NSArray alloc] initWithObjects:@"eventsSectionHeader-all.png", @"eventsSectionHeader-shopping.png", @"eventsSectionHeader-food.png", @"eventsSectionHeader-carnivals.png", @"eventsSectionHeader-animals.png", 
									@"eventsSectionHeader-amenities.png", @"eventsSectionHeader-entertainment.png", @"eventsSectionHeader-help.png", nil];
	
	self.filterHeaderImageNames = headerImageNames;
	[headerImageNames release];
	
	self.imageNames = [NSArray arrayWithObjects:@"maps-all.jpg", @"maps-shopping.jpg", @"maps-food.jpg", @"maps-carnivals.jpg", @"maps-animals.jpg", @"maps-amenities.jpg", @"maps-entertainment.jpg", @"maps-help.jpg", nil];
	
	// Set up navigation bar
	[self setupNavBar];
	
	// Create map overlay
	[self initMapOverlay];
	
	// Create location manager
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	locationManager.delegate = self;		
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Create and populate Sub Nav
	[self setupSubNav];
	
	BOOL useGestures = YES;
	
	float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (ver <= 3.2) useGestures = NO;
	
	if (useGestures) {
	
		// Initialise gesture recognizers
		[self initGestureRecognizers];
	}
		
	// Set initial zoom level
	[self initZoomLevel];
	
	// Create user location view, but don't show it
	[self initUserLocationView];
	
	// Centre the custom map
	[self centreMapOverlay];
	
	// Set the top-left/bottom-right coords
	[self getMapCornerCoords];

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
	
	self.subNavScrollView = nil;
	self.mapOverlay = nil;
	self.mapScrollView = nil;
	self.userLocationView = nil;
	
	self.locateMeButton = nil; 
	self.legendButton = nil; 
	self.selectedFilterButton = nil;
	
	self.filterHeading = nil;
	self.imageNames = nil;
	self.filterHeaderImageNames = nil;
	self.locationManager = nil;	
}


#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
	[self getMapCornerCoords];
	
    return [self.mapScrollView viewWithTag:ZOOM_VIEW_TAG];
}


/************************************** NOTE **************************************/
/* The following delegate method works around a known bug in zoomToRect:animated: */
/* In the next release after 3.0 this workaround will no longer be necessary      */
/**********************************************************************************/
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	
	NSLog(@"DONE:%.3f", [mapScrollView zoomScale]);
	
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}


#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    float newScale = [mapScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [mapScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [mapScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [mapScrollView zoomToRect:zoomRect animated:YES];
}


#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [mapScrollView frame].size.height / scale;
    zoomRect.size.width  = [mapScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// use "buttonIndex" to decide your action
	//
}


- (CGPoint)translate:(CLLocationCoordinate2D)_coords {

	double xwidth = ([mapOverlay frame].size.width/[mapScrollView zoomScale]);
	double yheight = ([mapOverlay frame].size.height/[mapScrollView zoomScale]);
	
	double diffLat = fabs((_coords.latitude) - (topLeftCoord.latitude));				
	double diffLong = fabs(_coords.longitude - topLeftCoord.longitude);
	//NSLog(@"diffLat:%f|diffLong:%f", diffLat, diffLong);
	
	double diffLong2 = fabs(bottomRightCoord.longitude - topLeftCoord.longitude);
	double diffLat2 = fabs(bottomRightCoord.latitude - topLeftCoord.latitude);
	//NSLog(@"diffLat2:%f|diffLong2:%f", diffLat2, diffLong2);
	
	double nx = ((diffLong * (xwidth / diffLong2)));
	double ny = ((diffLat * (yheight / diffLat2)));
	
	CGPoint point = CGPointMake(nx, ny);
	//NSLog(@"nx:%f|ny:%f", nx, ny);
	
	return point;
}	


#pragma mark LegendVCDelegate

- (void)closeLegendVC {
	
	[self dismissModalViewControllerAnimated:YES];
	
}


/* LOCATION FUNCTIONS ******************************************************************************/

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation {	
		
	if (newLocation.horizontalAccuracy <= 200) {
		
		// Release the existing currentLocation from memory
		if (currentLocation) [currentLocation release];
		
		// capture the new currentLocation
		currentLocation = [newLocation retain];
		
		CLLocationCoordinate2D myCoord = (CLLocationCoordinate2D)currentLocation.coordinate;
		
		//CLLocationCoordinate2D myCoord; 
		//myCoord.latitude = -33.84270;
		//myCoord.longitude = 151.0651;
		
		BOOL withinLatBounds = FALSE;
		BOOL withinLonBounds = FALSE;
		
		// Check to see if the User Location coords are within the TL/BR bounds
		if ((fabs(myCoord.latitude) > fabs(topLeftCoord.latitude)) && (fabs(myCoord.latitude) < fabs(bottomRightCoord.latitude))) withinLatBounds = TRUE;
		if ((myCoord.longitude > topLeftCoord.longitude) && (myCoord.longitude < bottomRightCoord.longitude)) withinLonBounds = TRUE;
		
		// If YES
		if (withinLatBounds && withinLonBounds) {
			
			NSLog(@"USER LOCATION ON MAP");
		
			CGPoint viewPoint = [self translate:myCoord];
			
			CGFloat imgWidth = userLocationView.frame.size.width;
			CGFloat imgHeight = userLocationView.frame.size.height;
			CGFloat xPos = (viewPoint.x - (imgWidth/2));
			CGFloat yPos = (viewPoint.y - (imgHeight/2));
				
			NSLog(@"xPos:%f|yPos:%f", xPos, yPos);

			// Place user location view and show
			[userLocationView setFrame:CGRectMake(xPos, yPos, imgWidth, imgHeight)];
			[userLocationView setHidden:NO];
			
			[self focusUserLocationInWindow:viewPoint];
		}
		else {
			
			// open an alert with just an OK button
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not there yet?" 
															message:@"The 'Locate Me' functionality only works once you've reached the showgrounds."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}

		// Stop looking for user location
		[self.locationManager stopUpdatingLocation];
	}
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	
	//NSMutableString *errorString = [[[NSMutableString alloc] init] autorelease];
	
	if ([error domain] == kCLErrorDomain) {
		
		// We handle CoreLocation-related errors here
		
		switch ([error code]) {
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
			case kCLErrorDenied:
				
				NSLog(@"LOCATION DENIED");
				
				break;
				
			default:
				//[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	} 
	
}


#pragma mark MY-FUNCTIONS

- (void)setupNavBar {
	
	// Hide default navigation bar
	[self.navigationController setNavigationBarHidden:YES];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[btn setFrame:CGRectMake(0.0, 0.0, 25.0, 21.0)];
	[btn addTarget:self action:@selector(toggleGoogleMap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	// Set to Left or Right
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
}


- (void)setupSubNav {
	
	NSArray *iconImages = [NSArray arrayWithObjects:@"subNavButton-shopping.png",
						   @"subNavButton-food.png", @"subNavButton-carnivals.png", @"subNavButton-animals.png",
						   @"subNavButton-amenities.png", @"subNavButton-entertainment.png", @"subNavButton-help.png", nil];
	
	CGFloat btnWidth = 26.0;
	CGFloat btnHeight = 26.0;
	
	CGFloat xPos = 8.0;
	CGFloat xPadding = 14.0;
	CGFloat yPos = 7.0;
	
	// Create button for 'ALL'
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn setFrame:CGRectMake(xPos, yPos, btnWidth, btnHeight)];
	[btn addTarget:self action:@selector(swapMap:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTag:0];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all.png"] forState:UIControlStateNormal];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all-on.png"] forState:UIControlStateHighlighted];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all-on.png"] forState:UIControlStateSelected];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[btn setSelected:YES];
	
	[self.selectedFilterButton setSelected:NO];
	self.selectedFilterButton = btn;
	
	// Add button to sub nav scroll view
	[self.subNavScrollView addSubview:btn];
	
	// Update xPos for next button
	xPos += (btnWidth + xPadding);
	
	NSString *imageFilename;
	NSString *selectedImageFilename;
	NSArray *stringParts;
	
	for (NSInteger i = 0; i < [iconImages count]; i++) {
		
		// Create the sub nav button
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(xPos, yPos, btnWidth, btnHeight)];
		[btn addTarget:self action:@selector(swapMap:) forControlEvents:UIControlEventTouchUpInside];
		[btn setBackgroundColor:[UIColor clearColor]];
		[btn setTag:(i+1)];
		
		imageFilename = [iconImages objectAtIndex:i];
		stringParts = [imageFilename componentsSeparatedByString:@"."];
		selectedImageFilename = [NSString stringWithFormat:@"%@-on.%@", [stringParts objectAtIndex:0], [stringParts objectAtIndex:1]];
		
		[btn setBackgroundImage:[UIImage imageNamed:imageFilename] forState:UIControlStateNormal];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateHighlighted];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateSelected];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateHighlighted|UIControlStateSelected];
		
		// Add button to sub nav scroll view
		[self.subNavScrollView addSubview:btn];
		
		// Update xPos for next button
		xPos += (btnWidth + xPadding);
		
		// Update sub nav scroll view content size - using the updated xPos
		[self.subNavScrollView setContentSize:CGSizeMake(xPos, self.subNavScrollView.frame.size.height)];
	}
}


- (void)locateMe:(id)sender {

	[self.locationManager startUpdatingLocation];
	
	BOOL hidden = (userLocationView.hidden ? YES : NO);
	
	if (!hidden) [userLocationView setHidden:YES];
}


- (void)showLegend:(id)sender {

	// launch LegendVC
	LegendVC *legendVC = [[LegendVC alloc] initWithNibName:@"LegendVC" bundle:nil];
	[legendVC setDelegate:self];
	
	[self presentModalViewController:legendVC animated:YES];
	[legendVC release];
}


- (void)testPoint:(id)sender {

	CGPoint testPoint = CGPointMake(237.254028, 83.3860168);

	CGFloat imgWidth = userLocationView.frame.size.width;
	CGFloat imgHeight = userLocationView.frame.size.height;
	CGFloat xPos = testPoint.x - (imgWidth/2);
	CGFloat yPos = testPoint.y - (imgHeight/2);
	[userLocationView setFrame:CGRectMake(xPos, yPos, imgWidth, imgHeight)];
	[userLocationView setHidden:NO];

}


- (void)swapMap:(id)sender {

	UIButton *btn = (UIButton *)sender;
	
	[btn setSelected:YES];
	
	// Make the sub nav the selected button
	[self.selectedFilterButton setSelected:NO];
	self.selectedFilterButton = btn;
	
	// Map image file name
	NSString *imageName = [self.imageNames objectAtIndex:btn.tag];
	
	UIImage *headingImage;
	
	// Get the filter heading image
	if (btn.tag == -1) headingImage = [UIImage imageNamed:@"eventsSectionHeader-all.png"];
	else headingImage = [UIImage imageNamed:[self.filterHeaderImageNames objectAtIndex:btn.tag]];
	
	// Adjust the filter heading image frame
	CGRect currFrame = self.filterHeading.frame;
	[self.filterHeading setFrame:CGRectMake(currFrame.origin.x, currFrame.origin.y, headingImage.size.width, headingImage.size.height)];
	[self.filterHeading setImage:headingImage];
	
	// Get the map image
	UIImage *mapImage = [UIImage imageNamed:imageName];
	
	// Show the map image
	[mapOverlay setImage:mapImage];
}


- (void)toggleGoogleMap:(id)sender {

	BOOL hidden = (mapScrollView.hidden ? YES : NO);
	
	if (hidden) [mapScrollView setHidden:NO];
	else [mapScrollView setHidden:YES];
}


- (void)initGestureRecognizers {

	// add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [mapOverlay addGestureRecognizer:singleTap];
    [mapOverlay addGestureRecognizer:doubleTap];
    [mapOverlay addGestureRecognizer:twoFingerTap];
    
    [singleTap release];
    [doubleTap release];
    [twoFingerTap release];

}


- (void)initUserLocationView {
	
	// Setup image view that will display user location
	CGFloat xPos = 0.0;
	CGFloat yPos = 0.0;
	UIImage *userLocationImage = [UIImage imageNamed:kUserLocationIconImage];
	userLocationView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, userLocationImage.size.width, userLocationImage.size.height)];
	[userLocationView setImage:userLocationImage];
	[userLocationView setHidden:YES];
	[self.mapOverlay addSubview:userLocationView];
	[userLocationView release];
}


- (void)initZoomLevel {

	// calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [mapScrollView frame].size.width  / [mapOverlay frame].size.width;
    [self.mapScrollView setMinimumZoomScale:minimumScale];
    [self.mapScrollView setZoomScale:0.572];
}


- (void)initMapOverlay {

	// add touch-sensitive image view to the scroll view
	mapOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.imageNames objectAtIndex:0]]];
	[mapOverlay setBackgroundColor:[UIColor purpleColor]];
	[mapOverlay setAlpha:1.0];
	[mapOverlay setTag:ZOOM_VIEW_TAG];
	[mapOverlay setUserInteractionEnabled:YES];
	[mapScrollView setContentSize:[mapOverlay frame].size];
	[mapScrollView addSubview:mapOverlay];
	[mapOverlay release];
}


- (void)centreMapOverlay {

	mapXOffset = ([mapOverlay frame].size.width/2) - (SCREEN_WIDTH/2);
	mapYOffset = ([mapOverlay frame].size.height/2) - (SCREEN_WIDTH/2);
	CGPoint newOffset = CGPointMake(mapXOffset, mapYOffset);
	[mapScrollView setContentOffset:newOffset];
	
	mapWidth = [mapOverlay frame].size.width;
	mapHeight = [mapOverlay frame].size.height;
}


// Seeing as we know the area we're dealing (Sydney Showgrounds)
// we can manually set the Top-left/Bottom-right lat/lon coords
- (void)getMapCornerCoords {
	
	// Dudley St and King St
	//(-37.809239, 144.952316)
	
	// Richmond train station
	//(-37.823906, 144.989735)
	
	// Melbourne
	//topLeftCoord.latitude = -37.809239;
	//topLeftCoord.longitude = 144.952316;
	
	// Syd Showgrounds
	topLeftCoord.latitude = -33.83977;
	topLeftCoord.longitude = 151.0622;
	
	// Place a marker so that we can check it's in the right spot on the Google Map
	//[self placeMapAnnotationAtCoord:topLeftCoord];
	
	// Melbourne
	//bottomRightCoord.latitude = -37.823906;
	//bottomRightCoord.longitude = 144.989735;
	
	// Syd Showgrounds
	bottomRightCoord.latitude = -33.84785;
	bottomRightCoord.longitude = 151.0721;
	
	// Place a marker so that we can check it's in the right spot on the Google Map
	//[self placeMapAnnotationAtCoord:bottomRightCoord];
}


- (void)placeTestGoogleMarkers {

	// 100 Flinders St
	// (-37.81632738253033, 144.9714231491089)
	CLLocationCoordinate2D fCoord;
	fCoord.latitude = -37.81632738253033;
	fCoord.longitude = 144.9714231491089;
	//[self placeMapAnnotationAtCoord:fCoord];
	//[self placeTestCustomMarker:fCoord];
	
	// Little Bourke St & Russell St
	// (-37.81181824192457, 144.96756076812744)
	CLLocationCoordinate2D lbCoord;
	lbCoord.latitude = -37.81181824192457;
	lbCoord.longitude = 144.96756076812744;
	//[self placeMapAnnotationAtCoord:lbCoord];
	[self placeTestCustomMarker:lbCoord];
	
	// MacArthurt St
	// (-37.81178433756862, 144.9748992919922)
	CLLocationCoordinate2D mCoord;
	mCoord.latitude = -37.81178433756862;
	mCoord.longitude = 144.9748992919922;
	//[self placeMapAnnotationAtCoord:mCoord];
	[self placeTestCustomMarker:mCoord];
	
	// Batman Avenue
	// (-37.81866660261256, 144.9758005142212)
	CLLocationCoordinate2D bCoord;
	bCoord.latitude = -37.81866660261256;
	bCoord.longitude = 144.9758005142212;
	//[self placeMapAnnotationAtCoord:bCoord];
	[self placeTestCustomMarker:bCoord];
	
	// St Kilda Rd
	// (-37.819954837091565, 144.96850490570068)
	CLLocationCoordinate2D sCoord;
	sCoord.latitude = -37.819954837091565;
	sCoord.longitude = 144.96850490570068;
	//[self placeMapAnnotationAtCoord:sCoord];
	[self placeTestCustomMarker:sCoord];

}


- (void)placeTestCustomMarker:(CLLocationCoordinate2D)coord {

	CGPoint viewPoint = [self translate:coord];
	
	BOOL withinXBounds = FALSE;
	BOOL withinYBounds = FALSE;
	
	CGFloat maxXBounds, maxYBounds;
	CGFloat minXBounds, minYBounds;
	
	maxXBounds = ([mapOverlay frame].size.width/[mapScrollView zoomScale]);
	maxYBounds = ([mapOverlay frame].size.height/[mapScrollView zoomScale]);
	minXBounds = minYBounds = 0.0;
	
	CGFloat imgWidth = userLocationView.frame.size.width;
	CGFloat imgHeight = userLocationView.frame.size.height;
	CGFloat xPos = (viewPoint.x - (imgWidth/2));
	CGFloat yPos = (viewPoint.y - (imgHeight/2));
	
	NSLog(@"xPos:%f|yPos:%f", xPos, yPos);
	
	if ((xPos > minXBounds) && (xPos < maxXBounds)) withinXBounds = TRUE;
	if ((yPos > minYBounds) && (yPos < maxYBounds)) withinYBounds = TRUE;
	
	if ((withinXBounds) && (withinYBounds)) {
		
		NSLog(@"TEST MARKER WITHIN BOUNDS");
		
		UIImageView *coordView = [[UIImageView alloc] init];
		[coordView setFrame:CGRectMake(xPos, yPos, imgWidth, imgHeight)];
		[coordView setHidden:NO];
		[coordView setImage:[UIImage imageNamed:@"stockistMapIcon.png"]];
		[self.mapOverlay addSubview:coordView];
		[coordView release];
	}
	else NSLog(@"NOT WITHIN BOUNDS");
}


- (void)focusUserLocationInWindow:(CGPoint)locationPoint {
	
	[self.mapScrollView setZoomScale:1.0];
	
	CGPoint currOffset = self.mapScrollView.contentOffset;
	mapXOffset = currOffset.x;
	mapYOffset = currOffset.y;
	
	// is the item point within the window?
	CGFloat xMinBounds = fabs(mapXOffset);
	CGFloat xMaxBounds = fabs(mapXOffset) + SCREEN_WIDTH;
	
	CGFloat yMinBounds = fabs(mapYOffset);
	CGFloat yMaxBounds = fabs(mapYOffset) + [self.mapScrollView frame].size.height;
	
	if ((locationPoint.x > xMinBounds) && (locationPoint.x < xMaxBounds)) {
		
		NSLog(@"withinXBounds");
		
		CGFloat centerX = xMinBounds + (SCREEN_WIDTH/2);
		CGFloat xShift = centerX - locationPoint.x;
		
		if (((mapXOffset - xShift) + SCREEN_WIDTH) <= ([self.mapOverlay frame].size.width) && ((mapXOffset - xShift)) >= (0)) 
			mapXOffset -= xShift;
		else if ((mapXOffset - xShift) < 0) 
			mapXOffset = 0;
		else if (((mapXOffset - xShift) + SCREEN_WIDTH) > ([self.mapOverlay frame].size.width)) {
			
			CGFloat difference = ((mapXOffset - xShift) + SCREEN_WIDTH) - ([self.mapOverlay frame].size.width);
			mapXOffset -= (xShift + fabs(difference));
		}
	}
	else {
		
		xMinBounds = fabs(mapXOffset);
		CGFloat centerX = xMinBounds + (SCREEN_WIDTH/2);
		CGFloat xShift = centerX - locationPoint.x;
		
		if (((mapXOffset - xShift) + SCREEN_WIDTH) <= ([self.mapOverlay frame].size.width) && ((mapXOffset - xShift)) >= (0)) mapXOffset -= xShift;
		else if ((mapXOffset - xShift) < 0) {
			
			mapXOffset = 0;
		}
		else if (((mapXOffset - xShift) + SCREEN_WIDTH) > ([self.mapOverlay frame].size.width)) {
			
			CGFloat difference = ((mapXOffset - xShift) + SCREEN_WIDTH) - ([self.mapOverlay frame].size.width);
			mapXOffset -= (xShift + fabs(difference));
		}
	}
	
	
	if ((locationPoint.y > yMinBounds) && (locationPoint.y < yMaxBounds)) {
		
		NSLog(@"withinYBounds");
		
		CGFloat centerY = yMinBounds + ([self.mapScrollView frame].size.height/2);
		CGFloat yShift = centerY - locationPoint.y;
		
		if (((mapYOffset - yShift) + [self.mapScrollView frame].size.height) <= ([self.mapOverlay frame].size.height) && ((mapYOffset - yShift)) >= (0)) 
			mapYOffset -= yShift;
		else if ((mapYOffset - yShift) < 0) {
			
			mapYOffset = 0;
		}
		else if (((mapYOffset - yShift) + [self.mapScrollView frame].size.height) > ([self.mapOverlay frame].size.height)) {
			
			CGFloat difference = ((mapYOffset - yShift) + [self.mapScrollView frame].size.height) - ([self.mapOverlay frame].size.height);
			mapYOffset -= (yShift + fabs(difference));
		}
	}
	else {
		
		yMinBounds = fabs(mapYOffset);
		CGFloat centerY = yMinBounds + ([self.mapScrollView frame].size.height/2);
		CGFloat yShift = centerY - locationPoint.y;
		
		if (((mapYOffset - yShift) + [self.mapScrollView frame].size.height) <= ([self.mapOverlay frame].size.height) && ((mapYOffset - yShift)) >= (0)) 
			mapYOffset -= yShift;
		else if ((mapYOffset - yShift) < 0) {
			
			mapYOffset = 0;
		}
		else if (((mapYOffset - yShift) + [self.mapScrollView frame].size.height) > ([self.mapOverlay frame].size.height)) {
			
			CGFloat difference = ((mapYOffset - yShift) + [self.mapScrollView frame].size.height) - ([self.mapOverlay frame].size.height);
			mapYOffset -= (yShift + fabs(difference));
		}
	}
	
	[self.mapScrollView setZoomScale:1.0];
	
	CGPoint newOffset2 = CGPointMake(mapXOffset, mapYOffset);
	[mapScrollView setContentOffset:newOffset2];
}



- (void)dealloc {
	
	[locateMeButton release];
	[legendButton release];
	[selectedFilterButton release];
	
	[subNavScrollView release];
	[mapOverlay release];
	[mapScrollView release];
	[userLocationView release];
	[filterHeading release];
	[imageNames release];
	[filterHeaderImageNames release];
	[locationManager release];	
	
    [super dealloc];
}


@end
