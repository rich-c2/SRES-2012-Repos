//
//  MapVC.m
//  SRES
//
//  Created by Richard Lee on 12/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "MapVC.h"
//#import "Event.h"
//#import "MyMapAnnotation.h"
#import "Constants.h"
#import "SRESAppDelegate.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

static NSString *kUserLocationIconImage = @"userLocationIcon.png";
static NSString *kItemLocationIconImage = @"mapPinIcon.png";

@implementation MapVC

@synthesize locateMeButton, locationManager, loadingSpinner;
@synthesize mapOverlay, mapScrollView, userLocationView, itemLocationView;
@synthesize navigationTitle, titleText;

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
	
	appDelegate = (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[self setupNavBar];
	
	// Create location manager
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	locationManager.delegate = self;		
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Create map overlay
	[self initMapOverlay];
	
	BOOL useGestures = YES;
	
	float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (ver <= 3.2) {
		
		useGestures = NO;
	}
	
	if (useGestures) {
		
		// Initialise gesture recognizers
		[self initGestureRecognizers];		
	}
	
	// Set initial zoom level
	[self initZoomLevel];
	
	// Create a test item location view so we can see where this specific Event or 
	// what have you is on the map
	[self initItemLocationView];
	
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
	
	self.loadingSpinner = nil;
	self.locationManager = nil;
	
	self.mapOverlay = nil; 
	self.mapScrollView = nil; 
	self.userLocationView = nil; 
	self.itemLocationView = nil;
	
	self.navigationTitle = nil; 
	self.titleText = nil;
}


#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
	[self getMapCornerCoords];
	
    return [self.mapScrollView viewWithTag:ZOOM_VIEW_TAG];
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
		//myCoord.latitude = -33.84271;
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

// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setupNavBar {
	
	// Set the navigation title
	if ([self.titleText length] > 0) 
		[self.navigationTitle setText:self.titleText];
}


- (void)locateMe:(id)sender {
	
	[self.locationManager startUpdatingLocation];
	
	[self.loadingSpinner startAnimating];
	[self.loadingSpinner setHidden:NO];
}


-(void)setMapID:(NSInteger)idInt {
	
	NSNumber *vNum = [[NSNumber alloc] initWithInt:idInt];
	mapID = [vNum retain];
	[vNum release];
}


-(NSNumber *)mapID {
	
	return mapID;
}


-(void)setCenterLatitude:(double)latDouble {

	NSNumber *latNum = [[NSNumber alloc] initWithDouble:latDouble];
	centerLatitude = [latNum retain];
	[latNum release];
}


-(NSNumber *)centerLatitude {
	
	return centerLatitude;
}


-(void)setCenterLongitude:(double)lonDouble {

	NSNumber *lonNum = [[NSNumber alloc] initWithDouble:lonDouble];
	centerLongitude = [lonNum retain];
	[lonNum release];
}


-(NSNumber *)centerLongitude {
	
	return centerLongitude;
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


- (void)initItemLocationView {
	
	// Setup image view that will display this item's location
	CGFloat xPos = 0.0;
	CGFloat yPos = 0.0;
	UIImage *itemLocationImage = [UIImage imageNamed:kItemLocationIconImage];
	self.itemLocationView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, itemLocationImage.size.width, itemLocationImage.size.height)];
	[self.itemLocationView setImage:itemLocationImage];
	[self.itemLocationView setHidden:YES];
	[self.mapOverlay addSubview:self.itemLocationView];
	[self.itemLocationView release];
}


- (void)initUserLocationView {
	
	// Setup image view that will display user location
	CGFloat xPos = 0.0;
	CGFloat yPos = 0.0;
	UIImage *userLocationImage = [UIImage imageNamed:kUserLocationIconImage];
	self.userLocationView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, userLocationImage.size.width, userLocationImage.size.height)];
	[self.userLocationView setImage:userLocationImage];
	[self.userLocationView setHidden:YES];
	[self.mapOverlay addSubview:self.userLocationView];
	[self.userLocationView release];
}


- (void)initZoomLevel {
	
	// calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [mapScrollView frame].size.width  / [mapOverlay frame].size.width;
    [self.mapScrollView setMinimumZoomScale:minimumScale];
    [self.mapScrollView setZoomScale:1.0];
}


- (void)initMapOverlay {
	
	NSString *mapFileName = [appDelegate getMapFileNameWithID:[mapID intValue]];
	
	if (mapFileName != nil) {
		
		UIImage *mapImage = [UIImage imageNamed:mapFileName];
		
		// add touch-sensitive image view to the scroll view
		mapOverlay = [[UIImageView alloc] initWithImage:mapImage];
		[mapOverlay setBackgroundColor:[UIColor purpleColor]];
		[mapOverlay setAlpha:1.0];
		[mapOverlay setTag:ZOOM_VIEW_TAG];
		[mapOverlay setUserInteractionEnabled:YES];
		[mapScrollView setContentSize:[mapOverlay frame].size];
		[mapScrollView addSubview:mapOverlay];
		[mapOverlay release];	
	}
}


- (void)centreMapOverlay {
	
	mapXOffset = ([mapOverlay frame].size.width/2) - (SCREEN_WIDTH/2);
	mapYOffset = ([mapOverlay frame].size.height/2) - (SCREEN_WIDTH/2);
	
	CGPoint newOffset = CGPointMake(mapXOffset, mapYOffset);
	[mapScrollView setContentOffset:newOffset];
	
	NSLog(@"newOffset:%.1f, %.1f", newOffset.x, newOffset.y);
	
	mapWidth = [mapOverlay frame].size.width;
	mapHeight = [mapOverlay frame].size.height;
	
	CLLocationCoordinate2D itemCoord; 
	itemCoord.latitude = [self.centerLatitude doubleValue];
	itemCoord.longitude = [self.centerLongitude doubleValue];
	
	// The point where the item is located
	CGPoint itemPoint = [self translate:itemCoord];
	
	// Place this item's location pin
	CGFloat imgWidth = self.itemLocationView.frame.size.width;
	CGFloat imgHeight = self.itemLocationView.frame.size.height;
	CGFloat xPos = (itemPoint.x - (imgWidth/2));
	CGFloat yPos = (itemPoint.y - (imgHeight/2));
	
	NSLog(@"xPos:%f|yPos:%f", xPos, yPos);
	
	// Place item location view and show
	[self.itemLocationView setFrame:CGRectMake(xPos, yPos, imgWidth, imgHeight)];
	[self.itemLocationView setHidden:NO];
	
	// Center the window on this item's position
	[self focusUserLocationInWindow:itemPoint];
}


- (void)focusUserLocationInWindow:(CGPoint)locationPoint {
	
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


// Seeing as we know the area we're dealing (Sydney Showgrounds)
// we can manually set the Top-left/Bottom-right lat/lon coords
- (void)getMapCornerCoords {
	
	// Syd Showgrounds
	topLeftCoord.latitude = -33.83977;
	topLeftCoord.longitude = 151.0622;
	
	// Syd Showgrounds
	bottomRightCoord.latitude = -33.84785;
	bottomRightCoord.longitude = 151.0721;
}



- (void)dealloc {
	
	[navigationTitle release];
	[titleText release];
	
	[mapOverlay release]; 
	//[mapScrollView release]; 
	[userLocationView release]; 
	[itemLocationView release];
	
	[centerLatitude release];
	[centerLongitude release];
	[loadingSpinner release];
	[locationManager release];
	
    [super dealloc];
}


@end
