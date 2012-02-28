//
//  OffersMenuVC.m
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OffersMenuVC.h"
#import "CustomTabBarItem.h"
#import "SRESAppDelegate.h"
#import "OfferTableCell.h"
#import "Offer.h"
#import "SVProgressHUD.h"
#import "StringHelper.h"
#import "OfferVC.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "Favourite.h"

@implementation OffersMenuVC

@synthesize fetchedResultsController, managedObjectContext;
@synthesize menuTable, loadCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"offers-tab-button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"offers-tab-button.png"];
        self.tabBarItem = tabItem;
        [tabItem release];
        tabItem = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// Hide default navigation bar
	[self.navigationController setNavigationBarHidden:YES];
	
	[self fetchOffersFromCoreData];
}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.fetchedResultsController = nil; 
	self.managedObjectContext = nil;
	self.menuTable = nil; 
	self.loadCell = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
		
	if (!offersLoaded) {
	
		BOOL previouslyLoaded = [[self appDelegate] offersLoaded];
		
		if (previouslyLoaded) {
		
			// Fetch Offer objets from Core Data
			[self fetchOffersFromCoreData];
			
			offersLoaded = YES;
		}
	
		// If the offer data is not already being loaded
		// AND the app is not in offlineMode
		else if (!loading && ![[self appDelegate] offlineMode]) {
			
			[self showLoading];
			
			[self retrieveXML];
		}
	}
	
	// Deselect the selected table cell
	[self.menuTable deselectRowAtIndexPath:[self.menuTable indexPathForSelectedRow] animated:YES];
}



#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
		
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		fetchRequest.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:managedObjectContext];
		
		NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"title"
											ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:sorter];
		[sorter release];
		
		fetchRequest.predicate = [NSPredicate predicateWithFormat:@"redeemed != 1"];
		fetchRequest.fetchBatchSize = 20;
        
        // Edit the section name key ppath and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		[fetchRequest release];
		
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        [aFetchedResultsController release];
    }
	
	return fetchedResultsController;
}  


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	
	// The fetch controller is about to start sending change notifications, 
	// so prepare the table view for updates.
	[self.menuTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.menuTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.menuTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(OfferTableCell *)[self.menuTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.menuTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.menuTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.menuTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.menuTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.menuTable endUpdates];
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	NSInteger count = [[fetchedResultsController sections] count];
    
	if (count == 0) count = 1;
	
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    NSInteger numberOfRows = 0;
	
	if ([[fetchedResultsController sections] count] > 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		numberOfRows = [sectionInfo numberOfObjects];
	}
    
    return numberOfRows;
}


- (void)configureCell:(OfferTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Offer *offer = (Offer *)[fetchedResultsController objectAtIndexPath:indexPath];
	
	UIImage *bgViewImage = [UIImage imageNamed:@"table-cell-background.png"];
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bgViewImage];
	cell.backgroundView = bgView;
	[bgView release];
	
	UIImage *selBGViewImage = [UIImage imageNamed:@"table-cell-background-on.png"];
	UIImageView *selBGView = [[UIImageView alloc] initWithImage:selBGViewImage];
	cell.selectedBackgroundView = selBGView;
	[selBGView release];
	
	cell.nameLabel.text = [offer.title uppercaseString];
	cell.descriptionLabel.text = [NSString stringWithFormat:@"%@", [offer offerDescription]];
	
	[cell initImage:offer.thumbURL];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OfferTableCell *cell = (OfferTableCell *)[tableView dequeueReusableCellWithIdentifier:[OfferTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"OfferTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
    }
	
	// Retrieve FoodVenue object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Offer *offer = (Offer *)[fetchedResultsController objectAtIndexPath:indexPath];
	
	OfferVC *offerVC = [[OfferVC alloc] initWithNibName:@"OfferVC" bundle:nil];
	[offerVC setOffer:offer];
	[offerVC setManagedObjectContext:self.managedObjectContext];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:offerVC animated:YES];
	[offerVC release];
}


- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url {
	
	NSArray *cells = [self.menuTable visibleCells];
    [cells retain];
    SEL selector = @selector(imageLoaded:withURL:);
	
    for (int i = 0; i < [cells count]; i++) {
		
		UITableViewCell* c = [[cells objectAtIndex: i] retain];
        if ([c respondsToSelector:selector]) {
            [c performSelector:selector withObject:image withObject:url];
        }
        [c release];
		c = nil;
    }
	
    [cells release];
}


- (void)retrieveXML {
	
	NSString *docName = @"get_offers.json";
	
	NSString *deviceID = [[self appDelegate] getDeviceID];
	
	NSMutableString *mutableXML = [NSMutableString string];
	[mutableXML appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	
	if ([[fetchedResultsController fetchedObjects] count] > 0) {
		
		[mutableXML appendFormat:@"<offers uid=\"%@\">", deviceID];
		
		for (Offer *offer in [fetchedResultsController fetchedObjects]) {
			
			[mutableXML appendFormat:@"<o id=\"%i\" v=\"%i\" r=\"%i\" />", [offer.offerID intValue], [offer.version intValue], [offer.redeemed intValue]];
		}
		
		[mutableXML appendString:@"</offers>"];
	}
	else [mutableXML appendFormat:@"<offers uid=\"%@\" />", deviceID];
	
	
	NSLog(@"XML:%@", mutableXML);
	
	// Change the string to NSData for transmission
	NSData *requestBody = [mutableXML dataUsingEncoding:NSASCIIStringEncoding];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_SERVER_ADDRESS, docName];
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:requestBody];
	
	// JSONFetcher
	fetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedFeedResponse:)];
	[fetcher start];
}


// Example fetcher response handling
- (void)receivedFeedResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// The API call has finished
	loading = NO;
	
	// IF STATUS CODE WAS OKAY (200)
	if ([theJSONFetcher statusCode] == 200) {
	
		if ([theJSONFetcher.data length] > 0) {
			
			// Store incoming data into a string
			NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
			
			// Create a dictionary from the JSON string
			NSDictionary *results = [jsonString JSONValue];
			
			// Build an array from the dictionary for easy access to each entry
			NSDictionary *addObjects = [results objectForKey:@"offers"];
			
			// ADD DATA ////////////////////////////////////////////////////////////////////////
			NSDictionary *adds = [addObjects objectForKey:@"add"];
			NSMutableArray *offersDict = [adds objectForKey:@"offer"];
			
			for (int i = 0; i < [offersDict count]; i++) {
				
				NSDictionary *offer = [offersDict objectAtIndex:i];
				
				// Store Offer data in Core Data persistent store
				[Offer newOfferWithData:offer inManagedObjectContext:self.managedObjectContext];
			}

			
			// UPDATE DATA ////////////////////////////////////////////////////////////////////////
			NSDictionary *updates = [addObjects objectForKey:@"update"];
			NSMutableArray *updatesDict = [updates objectForKey:@"offer"];
			
			for (int i = 0; i < [updatesDict count]; i++) {
				
				NSDictionary *offerData = [updatesDict objectAtIndex:i];
				
				// Store Offer data in Core Data persistent store
				Offer *offer = [Offer updateOfferWithOfferData:offerData inManagedObjectContext:self.managedObjectContext];
				
				if ([offer.isFavourite boolValue]) {
				
					[Favourite updateFavouriteItemID:offer.offerID withNewID:[offer.offerID intValue] title:offer.title inManagedObjectContext:self.managedObjectContext];
				}
			}				
			
			
			// REMOVE DATA ////////////////////////////////////////////////////////////////////////
			NSDictionary *removes = [addObjects objectForKey:@"remove"];
			NSMutableArray *removeObjects = [removes objectForKey:@"offer"];
			
			for (int i = 0; i < [removeObjects count]; i++) { 
				
				NSDictionary *offerDict = [removeObjects objectAtIndex:i];
				NSNumber *idNum = [NSNumber numberWithInt:[[offerDict objectForKey:@"offerID"] intValue]];
			
				Offer *offer = [Offer getOfferWithID:idNum inManagedObjectContext:self.managedObjectContext];
				
				if (offer) {
					
					if ([offer.isFavourite boolValue]) {
					
						Favourite *fav = [Favourite favouriteWithItemID:[offer offerID] favouriteType:@"Offers" inManagedObjectContext:self.managedObjectContext];
						
						// Check if it's a Fav - if so, delete the Fav
						if (fav) [self.managedObjectContext deleteObject:fav];
					}
					
					// Delete Offer object from current context
					[self.managedObjectContext deleteObject:offer];
				}
			}
			
			////////////////////////////////////////////////////////////////////////////////////////////////
			
			[jsonString release];
		}
		
		// Save the object context
		[[self appDelegate] saveContext];
		
		// The API call was successful
		offersLoaded = YES;
		
		// Set offersLoaded in the NSUserDefaults
		[[self appDelegate] setOffersLoaded:YES];
	}
	
	// Hide loading view
	[self hideLoading];
	
	[fetcher release];
	fetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
} 


- (void)fetchOffersFromCoreData {
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc {

	[fetchedResultsController release]; 
	[managedObjectContext release];
	[menuTable release]; 
	[loadCell release];
	
    [super dealloc];
}

@end
