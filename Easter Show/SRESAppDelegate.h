//
//  SRESAppDelegate.h
//  Easter Show
//
//  Created by Richard Lee on 10/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const API_SERVER_ADDRESS;

@class MoreVC;
@class EventsLandingVC;
@class OffersMenuVC;
@class FavouritesMenuVC;

@interface SRESAppDelegate : UIResponder <UIApplicationDelegate> {

	CGFloat appVersion;
	
	UITabBarController *tabBarController;
	
	FavouritesMenuVC *favsMenuVC;
	OffersMenuVC *offersMenuVC;
	MoreVC *moreVC;
	EventsLandingVC *eventsLandingVC;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UITabBarController *tabBarController;

@property (nonatomic, retain) FavouritesMenuVC *favsMenuVC;
@property (nonatomic, retain) OffersMenuVC *offersMenuVC;
@property (nonatomic, retain) MoreVC *moreVC;
@property (nonatomic, retain) EventsLandingVC *eventsLandingVC;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)getDeviceID;
- (CGFloat)getAppVersion;
- (NSString *)replaceHtmlEntities:(NSString *)htmlCode;

@end
