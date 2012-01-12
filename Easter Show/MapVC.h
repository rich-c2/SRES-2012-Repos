//
//  MapVC.h
//  SRES
//
//  Created by Richard Lee on 12/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class SRESAppDelegate;

@interface MapVC : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
	
	SRESAppDelegate *appDelegate;
	
	NSNumber *mapID;
	
	UIActivityIndicatorView *loadingSpinner;
	
	NSNumber *centerLatitude;
	NSNumber *centerLongitude;
	
	UIButton *locateMeButton;
	
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, retain) IBOutlet UIButton *locateMeButton;

@property (nonatomic, retain) CLLocationManager *locationManager;


-(void)setMapID:(NSInteger)idInt;
-(NSNumber *)mapID;

-(void)setCenterLatitude:(double)latDouble;
-(NSNumber *)centerLatitude;

-(void)setCenterLongitude:(double)lonDouble;
-(NSNumber *)centerLongitude;

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
- (CGPoint)translate:(CLLocationCoordinate2D)_coords;

- (void)setupNavBar;
- (void)initGestureRecognizers;
- (void)initItemLocationView;
- (void)initUserLocationView;
- (void)initZoomLevel;
- (void)initMapOverlay;
- (void)centreMapOverlay;
- (void)getMapCornerCoords;
- (void)focusUserLocationInWindow:(CGPoint)locationPoint;
- (void)locateMe:(id)sender;
- (void)goBack:(id)sender;

@end
