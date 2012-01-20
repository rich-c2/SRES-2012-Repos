//
//  FoodMenuVC.m
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "FoodMenuVC.h"
#import "SRESAppDelegate.h"
#import "FoodVenueVC.h"
#import "FoodVenue.h"
#import "FoodTableCell.h"
#import "StringHelper.h"
#import "XMLFetcher.h"
#import "SVProgressHUD.h"

@implementation FoodMenuVC

@synthesize fetchedResultsController, managedObjectContext;
@synthesize menuTable, searchTable, filteredListContent;
@synthesize search, loadCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.filteredListContent = [NSMutableArray array];
	
	[self setupNavBar];
	
	[self fetchVenuesFromCoreData];
}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;
	
	self.menuTable = nil; 
	self.searchTable = nil; 
	self.filteredListContent = nil;
	self.search = nil; 
	self.loadCell = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
	
	// If this view has not already been loaded 
	//(i.e not coming back from an Offer detail view)
	if (!venuesLoaded && !loading) {
		
		[self showLoading];
		
		[self retrieveXML];
	}
}


#pragma mark
#pragma mark Search Bar Delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	[self.searchTable setHidden:NO];
	
	NSString *searchTerm = [searchBar text];
	[self handleSearchForTerm:searchTerm];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
	NSLog(@"textDidChange");
	
	if ([searchText length] == 0) {
		
		NSLog(@"length == 0");
		
		[self resetSearch];
		[self.searchTable reloadData];
		return;
	}
	
	[self handleSearchForTerm:searchText];
}


- (void)resetSearch {
	
	NSLog(@"reset search");
	
	if ([self.filteredListContent count] > 0) self.filteredListContent = [NSMutableArray array];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	
	NSLog(@"searchBarCancelButtonClicked");
	
	search.text = @"";
	[self resetSearch];
	[self.searchTable reloadData];
	[searchBar resignFirstResponder];
	
	//CGFloat keyboardHeight = 166.0;
	CGRect newFrame = self.searchTable.frame;
	newFrame.size.height = 157.0; //(newFrame.size.height + keyboardHeight);
	[self.searchTable setFrame:newFrame];
	
	[self.searchTable setHidden:YES];
	[self.search setHidden:YES];
}


- (void)handleSearchForTerm:(NSString *)searchTerm {
	
	NSLog(@"handleSearchForTerm");
	
	self.filteredListContent = (NSMutableArray *)[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title BEGINSWITH[c] %@", searchTerm]];
	
	[self.searchTable reloadData];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
		
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		fetchRequest.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:managedObjectContext];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
		//fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"price >= %.2f AND price < %.2f", minPrice, maxPrice]];
		fetchRequest.fetchBatchSize = 20;
        
        // Edit the section name key path and cache name if appropriate.
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
	
	UITableView *tableView;	
	if (searching) tableView = self.searchTable;
	else tableView = self.menuTable;
	
	FoodVenue *foodVenue;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			if (searching) foodVenue = (FoodVenue *)[fetchedResultsController objectAtIndexPath:indexPath];
			else foodVenue = (FoodVenue *)[self.filteredListContent objectAtIndex:[indexPath row]];
			[self configureCell:(FoodTableCell *)[tableView cellForRowAtIndexPath:indexPath] withFoodVenue:foodVenue];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
	if (count == 0) {
		count = 1;
	}
	
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    NSInteger numberOfRows = 0;
	
	if (tableView == self.menuTable) {
		
        if ([[fetchedResultsController sections] count] > 0) {
			id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
			numberOfRows = [sectionInfo numberOfObjects];
		}
    }
	else numberOfRows = [self.filteredListContent count];
    
    return numberOfRows;
}


- (void)configureCell:(FoodTableCell *)cell withFoodVenue:(FoodVenue *)foodVenue {
	
	cell.nameLabel.text = foodVenue.title;
	cell.dateLabel.text = [NSString stringWithFormat:@"%@", [foodVenue venueDescription]];
	
	[cell initImage:foodVenue.thumbURL];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FoodTableCell *cell = (FoodTableCell *)[tableView dequeueReusableCellWithIdentifier:[FoodTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"FoodTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
    }
	
	FoodVenue *foodVenue;
	
	// Retrieve the Showbag object
	if (tableView == self.menuTable)
		foodVenue = (FoodVenue *)[fetchedResultsController objectAtIndexPath:indexPath];
	else
		foodVenue = (FoodVenue *)[self.filteredListContent objectAtIndex:[indexPath row]];
	
	// Retrieve FoodVenue object and set it's name to the cell
	[self configureCell:cell withFoodVenue:foodVenue];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FoodVenue *foodVenue;
	
	// Retrieve the FoodVenue object
	if (tableView == self.menuTable)
		foodVenue = (FoodVenue *)[fetchedResultsController objectAtIndexPath:indexPath];
	else
		foodVenue = (FoodVenue *)[self.filteredListContent objectAtIndex:[indexPath row]];
	
	FoodVenueVC *foodVenueVC = [[FoodVenueVC alloc] initWithNibName:@"FoodVenueVC" bundle:nil];
	[foodVenueVC setFoodVenue:foodVenue];
	[foodVenueVC setManagedObjectContext:self.managedObjectContext];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:foodVenueVC animated:YES];
	[foodVenueVC release];
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
	
	NSString *docName = @"foodvenues.xml";
	NSInteger lastShowbagID = 0;
	NSString *queryString = [NSString stringWithFormat:@"?id=%i", lastShowbagID];
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@", API_SERVER_ADDRESS, docName, queryString];
	NSLog(@"FOOD VENUES URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];	
	
	// XML Fetcher
	fetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//add | //update | //remove" receiver:self action:@selector(receiveResponse:)];
	[fetcher start];
}


// The API Request has finished being processed. Deal with the return data.
- (void)receiveResponse:(HTTPFetcher *)aFetcher {
    
    XMLFetcher *theXMLFetcher = (XMLFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	venuesLoaded = YES;
	
	if ([theXMLFetcher.data length] > 0) {
        
        // loop through the XPathResultNode objects that the XMLFetcher fetched
        for (XPathResultNode *node in theXMLFetcher.results) { 
			
			if ([[node name] isEqualToString:@"add"]) {
				
				for (XPathResultNode *venueNode in node.childNodes) { 
					
					NSMutableDictionary *venueData = [NSMutableDictionary dictionary];
					
					// Store the showbag's ID
					[venueData setObject:[[venueNode attributes] objectForKey:@"id"] forKey:@"id"];
					
					// Store the rest of the showbag's attributes
					for (XPathResultNode *venueChild in venueNode.childNodes) {
						
						if ([[venueChild contentString] length] > 0)
							[venueData setObject:[venueChild contentString] forKey:[venueChild name]];
					}
					
					// Store FoodVenue data in Core Data persistent store
					[FoodVenue venueWithVenueData:venueData inManagedObjectContext:self.managedObjectContext];
				}
			}
			else if ([[node name] isEqualToString:@"update"]) {
				
				for (XPathResultNode *venueNode in node.childNodes) { 
					
					NSMutableDictionary *venueData = [NSMutableDictionary dictionary];
					
					// Store the showbag's ID
					[venueData setObject:[[venueNode attributes] objectForKey:@"id"] forKey:@"id"];
					
					// Store the rest of the showbag's attributes
					for (XPathResultNode *venueChild in venueNode.childNodes) {
						
						if ([[venueChild contentString] length] > 0)
							[venueData setObject:[venueChild contentString] forKey:[venueChild name]];
					}
					
					// Store FoodVenue data in Core Data persistent store
					[FoodVenue updateVenueWithVenueData:venueData inManagedObjectContext:self.managedObjectContext];
				}
			}
			else if ([[node name] isEqualToString:@"remove"]) {
				
				for (XPathResultNode *venueNode in node.childNodes) {
					
					NSString *idString = [[venueNode attributes] objectForKey:@"id"];
					NSNumber *showbagID = [NSNumber numberWithInt:[idString intValue]];
					
					// Delete FoodVenue from the persistent store
					FoodVenue *foodVenue = [FoodVenue venueWithID:showbagID inManagedObjectContext:self.managedObjectContext];
					
					if (foodVenue) [self.managedObjectContext deleteObject:foodVenue];
				}
			}
		}		
	}
	
	// Save the object context
	[[self appDelegate] saveContext];
	
	// Fetch Food venue objets from Core Data
	[self fetchVenuesFromCoreData];
	
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


- (void)fetchVenuesFromCoreData {
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	else self.filteredListContent = [[self.fetchedResultsController fetchedObjects] mutableCopy];
}


- (void)setupNavBar {
	
	// Add button to Navigation Title 
	/*UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 118.0, 22.0)];
	 [image setBackgroundColor:[UIColor clearColor]];
	 [image setImage:[UIImage imageNamed:@"screenTitle-showbags.png"]];
	 
	 self.navigationItem.titleView = image;
	 [image release];
	 
	 // Add back button to nav bar
	 CGRect btnFrame = CGRectMake(0.0, 0.0, 50.0, 30.0);
	 UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [backButton setBackgroundImage:[UIImage imageNamed:@"backButton-Offers.png"] forState:UIControlStateNormal];
	 [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	 backButton.frame = btnFrame;
	 
	 UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	 backItem.target = self;
	 self.navigationItem.leftBarButtonItem = backItem;*/
	
	
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[searchButton addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
	searchItem.target = self;
	self.navigationItem.rightBarButtonItem = searchItem;
}


- (void)startSearch:(id)sender {
	
	// MAKE THE SEARCH RESULTS TABLE VISIBLE
	// MAKE THE SEARCH BAR VISIBLE 
	[self.search setHidden:NO];
	[self.searchTable setHidden:NO];
	
	// Put the focus on the search bar field. 
	// Keyboard will now be visible
	[self.search becomeFirstResponder];
	
	// Reset the height of the Table's frame and hide it from view
	//CGFloat keyboardHeight = 166.0;
	CGRect newTableFrame = self.searchTable.frame;
	newTableFrame.size.height = 157.0; //(newTableFrame.size.height - (keyboardHeight));
	[self.searchTable setFrame:newTableFrame];
}


- (void)dealloc {
	
	[fetchedResultsController release];
	[managedObjectContext release];
	
	[menuTable release];
	[filteredListContent release];
	[searchTable release];
	[search release];
	[loadCell release];
	
    [super dealloc];
}

@end
