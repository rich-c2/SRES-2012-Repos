//
//  FavouritesMenuVC.m
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesMenuVC.h"
#import "CustomTabBarItem.h"
#import "Favourite.h"
#import "EventDateTime.h"
#import "EventVC.h"
#import "FoodVenue.h"
#import "FoodVenueVC.h"
#import "Offer.h"
#import "OfferVC.h"
#import "Showbag.h"
#import "ShowbagVC.h"
#import "Constants.h"
#import "FavouriteTableCell.h"
#import "CarnivalRideVC.h"
#import "CarnivalRide.h"
#import "ShoppingVendorVC.h"
#import "ShoppingVendor.h"

#define HEADER_HEIGHT 27.0

@implementation FavouritesMenuVC

@synthesize managedObjectContext, favourites, menuTable, fetchedResultsController;
@synthesize deletePaths, actionsView, loadCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"faves-tab-button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"faves-tab-button.png"];
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

- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.deletePaths = [NSMutableArray array];
	
	[self setupNavBar];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.managedObjectContext = nil; 
	self.favourites = nil; 
	self.menuTable = nil;
	self.fetchedResultsController = nil;
	self.deletePaths = nil;
	self.actionsView = nil;
	self.loadCell = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
	
	if (!loaded) {
	
		[self fetchFavouritesFromCoreData];		
		[self.menuTable reloadData];
		
		loaded = YES;
	}
	
	// Deselect the selected table cell
	[self.menuTable deselectRowAtIndexPath:[self.menuTable indexPathForSelectedRow] animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
	
	// Stop any ImageDownloads that are still downloading
	
    [super viewWillDisappear:animated];
	
	if (!self.actionsView.hidden) {
		
		// Take the table out of editing mode
		editing = NO;
		
		// Hide the actions panel (Delete/Cancel)
		[self.actionsView setHidden:YES];
		
		// Adjust the table's frame
		CGRect tableFrame = self.menuTable.frame;
		tableFrame.size.height += self.actionsView.frame.size.height;
		[self.menuTable setFrame:tableFrame];
		
		// Clear the delete array
		[self.deletePaths removeAllObjects];
		
		// refresh table to clear check marks
		[self.menuTable reloadData];
	}
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"Favourite" 
											inManagedObjectContext:self.managedObjectContext]];
		
		NSSortDescriptor *titleSorter = [[NSSortDescriptor alloc] initWithKey:@"title"
															ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"favouriteType" ascending:YES], titleSorter, nil];
		[titleSorter release];
		
		fetchRequest.fetchBatchSize = 20;
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"favouriteType" cacheName:nil];
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
			[self configureCell:(FavouriteTableCell *)[self.menuTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
	
	if ([[fetchedResultsController sections] count] > 0) {
		
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		numberOfRows = [sectionInfo numberOfObjects];
		
		NSLog(@"NAME:%@|%i", [sectionInfo name], numberOfRows);
	}
    
    return numberOfRows;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FavouriteTableCell *cell = (FavouriteTableCell *)[tableView dequeueReusableCellWithIdentifier:[FavouriteTableCell reuseIdentifier]];
	 
	if (cell == nil) {
	 
		[[NSBundle mainBundle] loadNibNamed:@"FavouriteTableCell" owner:self options:nil];
		cell = loadCell;
		self.loadCell = nil;
	}
	
	// Retrieve FoodVenue object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


- (void)configureCell:(FavouriteTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    // Retrieve the Dictionary at the given index that's in self.followers
	Favourite *favourite = [fetchedResultsController objectAtIndexPath:indexPath];
	
	// Red background for selection
	CGRect bgFrame = cell.frame;
	UIView *selBGView = [[UIView alloc] initWithFrame:bgFrame];
	[selBGView setBackgroundColor:[UIColor colorWithRed:198./255.0 green:26./255.0 blue:36./255.0 alpha:1.0]];
	cell.selectedBackgroundView = selBGView;
	[selBGView release];
	
	// Set the favourite title to the text of the cell
	cell.textLabel.text = favourite.title;
	
	// By default, the cell's tick mark must be hidden
	cell.tickMark.hidden = YES;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	// Track the indexPath in an array so that when a 'Delete' 
	// button is clicked the corresponding Favourites are quickly deleted?
	NSLog(@"TAP");
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return HEADER_HEIGHT;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	// Retrieve the corresponding section title for this section
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    NSString *title = [[sectionInfo name] lowercaseString];
	
	NSString *formatted = [title stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	
	NSString *imageName = [NSString stringWithFormat:@"%@-header.png", formatted];
	UIImage *image = [UIImage imageNamed:imageName];
	
	
	CGRect viewFrame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, HEADER_HEIGHT);
	UIView *headerView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
	[headerView setBackgroundColor:[UIColor colorWithRed:114.0/255.0 green:81.0/255.0 blue:159.0/255.0 alpha:1.0]];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[imageView setFrame:CGRectMake(17.0, 9.0, image.size.width, image.size.height)];
	[headerView addSubview:imageView];
	[imageView release];
	
	return headerView;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editing) {
		
		// Grab the UITableViewCell that was selected
		FavouriteTableCell *cell = (FavouriteTableCell *)[tableView cellForRowAtIndexPath:indexPath];		
		
		if ([self.deletePaths containsObject:indexPath]) {
			
			[cell.tickMark setHidden:YES];
			
			// Remove the indexPaths from the delete array
			[self.deletePaths removeObject:indexPath];
		}
		
		else {
		
			[cell.tickMark setHidden:NO];
			
			// Add the indexPath of the cell to the delete array
			[self.deletePaths addObject:indexPath];
		}
	}
	
	else {
	
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:[indexPath section]];
		Favourite *favourite = (Favourite *)[fetchedResultsController objectAtIndexPath:indexPath];
		
		if ([[sectionInfo name] isEqualToString:@"Events"]) {
			
			EventDateTime *dateTime = [EventDateTime getDateTimeWithID:[favourite itemID] inManagedObjectContext:self.managedObjectContext];
			
			EventVC *eventVC = [[EventVC alloc] initWithNibName:@"EventVC" bundle:nil];
			[eventVC setEventDateTime:dateTime];
			[eventVC setManagedObjectContext:self.managedObjectContext];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:eventVC animated:YES];
			[eventVC release];
		}
		
		else if ([[sectionInfo name] isEqualToString:@"Food venues"]) {
		
			FoodVenue *foodVenue = [FoodVenue getFoodVenueWithID:[favourite itemID] inManagedObjectContext:self.managedObjectContext];
			
			FoodVenueVC *foodVenueVC = [[FoodVenueVC alloc] initWithNibName:@"FoodVenueVC" bundle:nil];
			[foodVenueVC setFoodVenue:foodVenue];
			[foodVenueVC setManagedObjectContext:self.managedObjectContext];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:foodVenueVC animated:YES];
			[foodVenueVC release];
		}
		
		else if ([[sectionInfo name] isEqualToString:@"Carnival rides"]) {
			
			CarnivalRide *carnivalRide = [CarnivalRide getCarnivalRideWithID:[favourite itemID] inManagedObjectContext:self.managedObjectContext];
			
			CarnivalRideVC *carnivalRideVC = [[CarnivalRideVC alloc] initWithNibName:@"CarnivalRideVC" bundle:nil];
			[carnivalRideVC setCarnivalRide:carnivalRide];
			[carnivalRideVC setManagedObjectContext:self.managedObjectContext];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:carnivalRideVC animated:YES];
			[carnivalRideVC release];
		}
			
		else if ([[sectionInfo name] isEqualToString:@"Offers"]) {
		
			Offer *offer = [Offer getOfferWithID:[favourite itemID] inManagedObjectContext:self.managedObjectContext];
			
			OfferVC *offerVC = [[OfferVC alloc] initWithNibName:@"OfferVC" bundle:nil];
			[offerVC setOffer:offer];
			[offerVC setManagedObjectContext:self.managedObjectContext];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:offerVC animated:YES];
			[offerVC release];
		}
				
		else if ([[sectionInfo name] isEqualToString:@"Showbags"]) {
		
			Showbag *showbag = [Showbag getShowbagWithID:[favourite itemID] inManagedObjectContext:self.managedObjectContext];
			
			ShowbagVC *showbagVC = [[ShowbagVC alloc] initWithNibName:@"ShowbagVC" bundle:nil];
			[showbagVC setShowbag:showbag];
			[showbagVC setManagedObjectContext:self.managedObjectContext];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:showbagVC animated:YES];
			[showbagVC release];
		}
		
		else if ([[sectionInfo name] isEqualToString:@"Shopping vendors"]) {
			
			ShoppingVendor *shoppingVendor = [ShoppingVendor getShoppingVendorWithID:[favourite itemID] inManagedObjectContext:self.managedObjectContext];
			
			ShoppingVendorVC *shoppingVendorVC = [[ShoppingVendorVC alloc] initWithNibName:@"ShoppingVendorVC" bundle:nil];
			[shoppingVendorVC setShoppingVendor:shoppingVendor];
			[shoppingVendorVC setManagedObjectContext:self.managedObjectContext];
			
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:shoppingVendorVC animated:YES];
			[shoppingVendorVC release];
		}
	}
}


- (void)fetchFavouritesFromCoreData {
	
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


- (void)setupNavBar {

	// Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
}


- (IBAction)editButtonClicked:(id)sender {

	// Put the table into editing mode
	editing = !editing;
	
	// Show the actions panel (Delete/Cancel)
	[self.actionsView setHidden:!self.actionsView.hidden];
	
	// If the actions panel was just hidden - clear out the delete array
	if (self.actionsView.hidden) {
		
		// Adjust the table's frame
		CGRect tableFrame = self.menuTable.frame;
		tableFrame.size.height += self.actionsView.frame.size.height;
		[self.menuTable setFrame:tableFrame];
		
		// Clear the delete array
		[self.deletePaths removeAllObjects];
		
		// refresh table to clear check marks
		[self.menuTable reloadData];
	}
	
	else {
	
		// Adjust the table's frame
		CGRect tableFrame = self.menuTable.frame;
		tableFrame.size.height -= self.actionsView.frame.size.height;
		[self.menuTable setFrame:tableFrame];
	}
}


- (IBAction)deleteSelectedFavourites:(id)sender {

	// Iterate through the indexPaths that have been marked
	// as the Favs to be deleted.
	for (NSIndexPath *indexPath in self.deletePaths) {
	
		// Retrieve the managed object and delete it from the managed context
		Favourite *fav = [fetchedResultsController objectAtIndexPath:indexPath];
		
		// Update Offer object associated
		if ([[fav favouriteType] isEqualToString:@"Offers"])
			[Offer updateOfferWithID:[fav itemID] isFavourite:NO inManagedObjectContext:self.managedObjectContext];
		
		// Update Event object associated
		else if ([[fav favouriteType] isEqualToString:@"Events"])
			[EventDateTime updateDateTimeWithID:[fav itemID] isFavourite:NO inManagedObjectContext:self.managedObjectContext];
		
		// Update Carnival Ride object associated
		else if ([[fav favouriteType] isEqualToString:@"Carnival rides"])
			[CarnivalRide updateCarnivalRideWithID:[fav itemID] isFavourite:NO inManagedObjectContext:self.managedObjectContext];
		
		// Update Shopping Vendor object associated
		else if ([[fav favouriteType] isEqualToString:@"Shopping vendors"])
			[ShoppingVendor updateVendorWithID:[fav itemID] isFavourite:NO inManagedObjectContext:self.managedObjectContext];
		
		// Update Food Venue object associated
		else if ([[fav favouriteType] isEqualToString:@"Food venues"])
			[FoodVenue updateFoodVenueWithID:[fav itemID] isFavourite:NO inManagedObjectContext:self.managedObjectContext];
		
		// Update Showbag object associated
		else if ([[fav favouriteType] isEqualToString:@"Showbags"])
			[Showbag updateShowbagWithID:[fav itemID] isFavourite:NO inManagedObjectContext:self.managedObjectContext];
		
		// Delete Favourite object
		[self.managedObjectContext deleteObject:fav];
	}
	
	// Clear out the delete array
	[self.deletePaths removeAllObjects];
}


- (IBAction)cancelButtonClicked:(id)sender { 

	// We are not in editing mode anymore
	editing = NO;
	
	// Hide the actions panel
	[self.actionsView setHidden:YES];
	
	// Adjust the table's frame
	CGRect tableFrame = self.menuTable.frame;
	tableFrame.size.height += self.actionsView.frame.size.height;
	[self.menuTable setFrame:tableFrame];
	
	// refresh table to clear check marks
	[self.menuTable reloadData];
	
	// Clear out the delete array
	[self.deletePaths removeAllObjects];
}


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc {
	
	[actionsView release];
	[deletePaths release];
	[fetchedResultsController release];
	[managedObjectContext release];
	[menuTable release]; 
	[favourites release];
	[loadCell release];
	
    [super dealloc];
}


@end
