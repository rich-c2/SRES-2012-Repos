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
//#import "Constants.h"
#import "SRESAppDelegate.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

static NSString *kUserLocationIconImage = @"userLocationIcon.png";
static NSString *kItemLocationIconImage = @"mapPinIcon.png";

@implementation MapVC

@synthesize locateMeButton, locationManager, loadingSpinner;

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
}


/* LOCATION FUNCTIONS ******************************************************************************/

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation {	
	
	if (newLocation.horizontalAccuracy <= 200) {
		
		[self.loadingSpinner stopAnimating];
		[self.loadingSpinner setHidden:YES];
		
		// Release the existing currentLocation from memory
		if (currentLocation) [currentLocation release];
		
		// capture the new currentLocation
		currentLocation = [newLocation retain];
		
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

- (void)goBack:(id)sender { 
	
	[self.navigationController popViewControllerAnimated:YES];
	
}


- (void)setupNavBar {
	
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
	
	self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[self.loadingSpinner setHidden:YES];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.loadingSpinner];
	
	// Set to Left or Right
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
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


- (void)focusUserLocationInWindow:(CGPoint)locationPoint {
	
	
}



- (void)dealloc {
	
	[centerLatitude release];
	[centerLongitude release];
	[loadingSpinner release];
	[locationManager release];
    [super dealloc];
}


@end
