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

NSString* const API_SERVER_ADDRESS = @"http://sres2012.supergloo.net.au/api/";
//OLD API @"http://sres.c2gloo.net/xml/";

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


- (CGFloat)getAppVersion {

	// Store the current version to NSUserDefaults
	return [[NSUserDefaults standardUserDefaults] floatForKey:kAppVersionKey];
}


- (NSString *)replaceHtmlEntities:(NSString *)htmlCode {
	
	//NSLog(@"replace:%@", htmlCode);
	
	NSError *error = NULL;
    NSMutableString *temp = [NSMutableString stringWithString:htmlCode];
	
	[temp replaceOccurrencesOfString:@"#128;" withString:@"€" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#129;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#130;" withString:@"‚" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#131;" withString:@"ƒ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#132;" withString:@"„" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#133;" withString:@"…" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#134;" withString:@"†" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#135;" withString:@"‡" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#136;" withString:@"ˆ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#137;" withString:@"‰" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#138;" withString:@"Š" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#139;" withString:@"‹" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#140;" withString:@"Œ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#141;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#142;" withString:@"Ž" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#143;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#144;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#145;" withString:@"‘" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#146;" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#147;" withString:@"“" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#148;" withString:@"”" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#149;" withString:@"•" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#150;" withString:@"–" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#151;" withString:@"—" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#152;" withString:@"˜" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#153;" withString:@"™" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#154;" withString:@"š" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#155;" withString:@"›" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#156;" withString:@"œ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#157;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#158;" withString:@"ž" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#159;" withString:@"Ÿ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	[temp replaceOccurrencesOfString:@"#160;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#161;" withString:@"¡" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#162;" withString:@"¢" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#163;" withString:@"£" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#164;" withString:@"¤" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#165;" withString:@"¥" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#166;" withString:@"¦" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#167;" withString:@"§" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#168;" withString:@"¨" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#169;" withString:@"©" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#170;" withString:@"ª" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#171;" withString:@"«" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#172;" withString:@"¬" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#173;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#174;" withString:@"®" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	[temp replaceOccurrencesOfString:@"#175;" withString:@"¯" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#176;" withString:@"°" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#177;" withString:@"±" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#178;" withString:@"²" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#179;" withString:@"³" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#180;" withString:@"´" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#181;" withString:@"µ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#182;" withString:@"¶" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#183;" withString:@"·" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#184;" withString:@"¸" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#185;" withString:@"¹" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#186;" withString:@"º" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#187;" withString:@"»" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#188;" withString:@"¼" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#189;" withString:@"½" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#190;" withString:@"¾" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#191;" withString:@"¿" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	[temp replaceOccurrencesOfString:@"#192;" withString:@"À" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#193;" withString:@"Á" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#194;" withString:@"Â" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#195;" withString:@"Ã" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#196;" withString:@"Ä" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#197;" withString:@"Å" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#198;" withString:@"Æ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#199;" withString:@"Ç" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#200;" withString:@"È" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#201;" withString:@"É" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#202;" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#203;" withString:@"Ë" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#204;" withString:@"Ì" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#205;" withString:@"Í" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#206;" withString:@"Î" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#207;" withString:@"Ï" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#208;" withString:@"Ð" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#209;" withString:@"Ñ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#210;" withString:@"Ò" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#211;" withString:@"Ó" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#212;" withString:@"Ô" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#213;" withString:@"Õ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#214;" withString:@"Ö" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#216;" withString:@"Ø" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#217;" withString:@"Ù" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#218;" withString:@"Ú" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#219;" withString:@"Û" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#220;" withString:@"Ü" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#221;" withString:@"Ý" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#222;" withString:@"Þ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#223;" withString:@"ß" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#224;" withString:@"à" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#225;" withString:@"á" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#226;" withString:@"â" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#227;" withString:@"ã" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#228;" withString:@"ä" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#229;" withString:@"å" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#230;" withString:@"æ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#231;" withString:@"ç" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#232;" withString:@"è" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#233;" withString:@"é" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#234;" withString:@"ê" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#235;" withString:@"ë" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#236;" withString:@"ì" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#237;" withString:@"í" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#238;" withString:@"î" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#239;" withString:@"ï" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#240;" withString:@"ð" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#241;" withString:@"ñ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#242;" withString:@"ò" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#243;" withString:@"ó" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#244;" withString:@"ô" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#245;" withString:@"õ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#246;" withString:@"ö" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#248;" withString:@"ø" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#249;" withString:@"ù" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#250;" withString:@"ú" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#251;" withString:@"û" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#252;" withString:@"ü" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#253;" withString:@"ý" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#254;" withString:@"þ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"#255;" withString:@"ÿ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	
	
	// Create reg ex
	//NSString *regexString = @"#[0-9]{1,2}";
	NSString *regexString2 = @"&?#([0-9]{1,3});";
	
	// Cretea reg ex Object and find matches
	NSRegularExpression *regExpressionObj = [NSRegularExpression regularExpressionWithPattern:regexString2 options:NSRegularExpressionCaseInsensitive error:&error];
	NSArray *matches = [regExpressionObj matchesInString:temp options:0 range:NSMakeRange(0, [temp length])]; 
	
	NSMutableArray *stringNumericMatches = [NSMutableArray array];
	NSMutableArray *stringMatches = [NSMutableArray array];
	
	// Gather and store and the matches that were found
	for (NSTextCheckingResult *match in matches) {
		
		// Get the match
		NSRange matchRange = [match rangeAtIndex:1]; // e.g 39
		NSRange matchRange2 = [match rangeAtIndex:0]; // e.g &#39;
		
		// Convert to string
		NSString *matchResult = [temp substringWithRange:matchRange]; // e.g. "39"
		
		// Retain in the numeric array
		[stringNumericMatches addObject:matchResult];
		
		NSString *matchResult2 = [temp substringWithRange:matchRange2]; // e.g. "&#39;"
		
		// Retain the string in our array
		[stringMatches addObject:matchResult2];
	}
	
	//NSLog(@"stringNumericMatches:%@", stringNumericMatches);
	//NSLog(@"stringMatches:%@", stringMatches);
	
	// Lopp through the matches and replace them with the appropriate char
	for (int i = 0; i < [stringNumericMatches count]; i++) {
		
		NSString *numericResult = [stringNumericMatches objectAtIndex:i]; // e.g. "39"
		NSString *stringResult = [stringMatches objectAtIndex:i]; // e.g. "&#39;"
		
		// Convert to int
		int myInt = [numericResult intValue];
		
		// Convert back to string
		NSString *convertedString = [NSString stringWithFormat:@"%c", myInt];
		//NSLog(@"convertedString:%@", convertedString);
		
		[temp replaceOccurrencesOfString:stringResult withString:convertedString options:NSLiteralSearch range:NSMakeRange(0, [temp length])];	
	}
	
	//NSLog(@"FINAL:%@", temp);
	
    return [NSString stringWithString:temp];
	
}


@end
