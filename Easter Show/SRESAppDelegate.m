//
//  SRESAppDelegate.m
//  Easter Show
//
//  Created by Richard Lee on 10/01/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "SRESAppDelegate.h"
#import "MoreVC.h"
#import "EventsLandingVC.h"
#import "OffersMenuVC.h"
#import "FavouritesMenuVC.h"

NSString* const API_SERVER_ADDRESS = @"http://sres.c2gloo.net/xml/";

static NSString *kAppVersionKey = @"appVersionKey";
static NSString *kDeviceIDKey = @"deviceIDKey";

@implementation SRESAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tabBarController, moreVC, eventsLandingVC, offersMenuVC, favsMenuVC;

- (void)dealloc {
	
	[_window release];
	[tabBarController release];
	[moreVC release];
	[eventsLandingVC release];
	[offersMenuVC release];
	[favsMenuVC release];
	
	[__managedObjectContext release];
	[__managedObjectModel release];
	[__persistentStoreCoordinator release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
	
	// STATUS BAR STYLE - BLACK
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	
	/* //////////////////////////////////////////////////////////////////////////////////////////
	 
		APP VERSION 
		Set the appVersion variable. 
		Retrieve from the NSUserDefaults what appVersion has been saved.
		This will act as a flag to show that a new version is being loaded. 
		In this instance the NSUserDefaults will need to be cleared.
	*/
	appVersion = 1.0;
	
	CGFloat savedVersion = [[NSUserDefaults standardUserDefaults] floatForKey:kAppVersionKey];
	
    if (appVersion != savedVersion) {
		
        // Do first run view initializaton here //
		[NSUserDefaults resetStandardUserDefaults];
		
		// Store the current version to NSUserDefaults
		[[NSUserDefaults standardUserDefaults] setFloat:appVersion forKey:kAppVersionKey];
    }

	//////////////////////////////////////////////////////////////////////////////////////////
	
	// EventsLandingVC
	eventsLandingVC = [[EventsLandingVC alloc] initWithNibName:@"EventsLandingVC" bundle:nil];
	[eventsLandingVC setManagedObjectContext:self.managedObjectContext];
	
	UINavigationController *navcon2 = [[UINavigationController alloc] init];
	[navcon2.navigationBar setTintColor:[UIColor redColor]];
	[navcon2 pushViewController:eventsLandingVC animated:NO];
	[eventsLandingVC release];
	
	
	// Favs Menu VC
	favsMenuVC = [[FavouritesMenuVC alloc] initWithNibName:@"FavouritesMenuVC" bundle:nil];
	[favsMenuVC setManagedObjectContext:self.managedObjectContext];
	
	UINavigationController *navcon4 = [[UINavigationController alloc] init];
	[navcon4.navigationBar setTintColor:[UIColor redColor]];
	[navcon4 pushViewController:favsMenuVC animated:NO];
	[favsMenuVC release];
	
	// Offers VC
	offersMenuVC = [[OffersMenuVC alloc] initWithNibName:@"OffersMenuVC" bundle:nil];
	[offersMenuVC setManagedObjectContext:self.managedObjectContext];
	
	UINavigationController *navcon3 = [[UINavigationController alloc] init];
	[navcon3.navigationBar setTintColor:[UIColor redColor]];
	[navcon3 pushViewController:offersMenuVC animated:NO];
	[offersMenuVC release];
	
	
	// MoreVC
	moreVC = [[MoreVC alloc] initWithNibName:@"MoreVC" bundle:nil];
	[moreVC setManagedObjectContext:self.managedObjectContext];
	
	UINavigationController *navcon = [[UINavigationController alloc] init];
	[navcon.navigationBar setTintColor:[UIColor redColor]];
	[navcon pushViewController:moreVC animated:NO];
	[moreVC release];
	
	// Create a tabbar controller and an array to contain the view controllers
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:4];
	[localViewControllersArray addObject:navcon2];
	[localViewControllersArray addObject:navcon3];
	[localViewControllersArray addObject:navcon];
	[localViewControllersArray addObject:navcon4];
	
	[navcon release];
	[navcon2 release];
	[navcon3 release];
	[navcon4 release];
	
	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = localViewControllersArray;
	
	// the localViewControllersArray data is now retained by the tabBarController
	// so we can release this version
	[localViewControllersArray release];
	
	[self.window addSubview:[tabBarController view]];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Easter_Show" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Easter_Show.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSString *)getDeviceID {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *deviceID = [defaults objectForKey:kDeviceIDKey];
	
	if ([deviceID length] < 1) {
	
		deviceID = [UIDevice currentDevice].uniqueIdentifier;
		
		[defaults setObject:deviceID forKey:kDeviceIDKey];
	}
	
	return deviceID;
}


@end
