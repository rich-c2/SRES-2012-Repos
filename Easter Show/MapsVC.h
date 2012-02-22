//
//  MapsVC.h
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LegendVC.h"


@interface MapsVC : UIViewController <CLLocationManagerDelegate, LegendVCDelegate> {

	
	// UI Elements
	UIScrollView *subNavScrollView;
	UIImageView *mapOverlay;
	UIScrollView *mapScrollView;
	UIImageView *userLocationView;
	UIImageView *filterHeading;
	
	UIButton *locateMeButton;
	UIButton *legendButton;
	
	CGFloat mapWidth;
	CGFloat mapHeight;
	
	CGFloat mapXOffset;
	CGFloat mapYOffset;

	// Storage
	NSArray *imageNames;
	NSArray *filterHeaderImageNames;
	
	UIButton *selectedFilterButton;
	
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	CLLocationCoordinate2D topLeftCoord;
	CLLocationCoordinate2D bottomRightCoord;
	
}

@property (nonatomic, retain) IBOutlet UIScrollView *subNavScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *mapOverlay;
@property (nonatomic, retain) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, retain) UIImageView *userLocationView;
@property (nonatomic, retain) IBOutlet UIImageView *filterHeading;

@property (nonatomic, retain) IBOutlet UIButton *locateMeButton;
@property (nonatomic, retain) IBOutlet UIButton *legendButton;

@property (nonatomic, retain) NSArray *imageNames;
@property (nonatomic, retain) NSArray *filterHeaderImageNames;

@property (nonatomic, retain) UIButton *selectedFilterButton;

@property (nonatomic, retain) CLLocationManager *locationManager;


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

- (void)setupNavBar;
- (void)setupSubNav;
- (void)locateMe:(id)sender;
- (void)showLegend:(id)sender;
- (void)swapMap:(id)sender;
- (void)initGestureRecognizers;
- (void)initUserLocationView;
- (void)initZoomLevel;
- (void)initMapOverlay;
- (void)centreMapOverlay;
- (void)getMapCornerCoords;
- (void)placeTestGoogleMarkers;
- (void)placeTestCustomMarker:(CLLocationCoordinate2D)coord;

- (CGPoint)translate:(CLLocationCoordinate2D)_coords;
- (void)focusUserLocationInWindow:(CGPoint)locationPoint;


@end
