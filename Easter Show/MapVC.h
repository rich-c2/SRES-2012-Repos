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
	
	UILabel *navigationTitle;
	NSString *titleText;
	
	NSNumber *mapID;
	
	UIActivityIndicatorView *loadingSpinner;
	
	NSNumber *centerLatitude;
	NSNumber *centerLongitude;
	
	CGFloat mapWidth;
	CGFloat mapHeight;
	
	CGFloat mapXOffset;
	CGFloat mapYOffset;
	
	UIImageView *mapOverlay;
	UIScrollView *mapScrollView;
	UIImageView *userLocationView;
	UIImageView *itemLocationView;
	
	UIButton *locateMeButton;
	
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	CLLocationCoordinate2D topLeftCoord;
	CLLocationCoordinate2D bottomRightCoord;
}

@property (nonatomic, retain) IBOutlet UILabel *navigationTitle;
@property (nonatomic, retain) IBOutlet NSString *titleText;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, retain) IBOutlet UIImageView *mapOverlay;
@property (nonatomic, retain) IBOutlet UIScrollView *mapScrollView;
@property (nonatomic, retain) UIImageView *userLocationView;
@property (nonatomic, retain) UIImageView *itemLocationView;

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
- (void)focusUserLocationInWindow:(CGPoint)locationPoint;
- (void)locateMe:(id)sender;
- (IBAction)goBack:(id)sender;
- (void)initGestureRecognizers;
- (void)initItemLocationView;
- (void)initUserLocationView;
- (void)initZoomLevel;
- (void)initMapOverlay;
- (void)centreMapOverlay;
- (void)getMapCornerCoords;

@end
