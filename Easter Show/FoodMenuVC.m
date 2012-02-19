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
#import "JSONFetcher.h"
#import "SBJson.h"
#import "Constants.h"

@implementation FoodMenuVC

@synthesize fetchedResultsController, managedObjectContext;
@synthesize menuTable, searchTable, filteredListContent;
@synthesize search, loadCell, cancelButton, searchButton;

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
	self.cancelButton = nil;
	self.searchButton = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	
	if (!venuesLoaded) {
		
		BOOL previouslyLoaded = [[self appDelegate] foodVenuesLoaded];
		
		if (previouslyLoaded) {
			
			// Fetch Offer objets from Core Data
			[self fetchVenuesFromCoreData];
			
			venuesLoaded = YES;
		}
	
		// If this view has not already been loaded 
		// AND the app is not in offlineMode
		else if (!loading && ![[self appDelegate] offlineMode]) {
			
			[self showLoading];
			
			[self retrieveXML];
		}
	}
	
	// Deselect the selected table cell
	[self.menuTable deselectRowAtIndexPath:[self.menuTable indexPathForSelectedRow] animated:YES];
	[self.searchTable deselectRowAtIndexPath:[self.searchTable indexPathForSelectedRow] animated:YES];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Hide keyboard
	[self dismissKeyboard];
	
	// Adjust searchTable's frame height
	CGRect newFrame = self.searchTable.frame;
	newFrame.size.height += (KEYBOARD_HEIGHHT - TAB_BAR_HEIGHT);
	[self.searchTable setFrame:newFrame];
	
	return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
	
	[self resetSearch];
	
	[self.searchTable reloadData];
	
	return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if ([textField.text length] == 0) [self resetSearch];
	
	// The new search term - takes what has already been entered in the text field and combines it with 
	// what character has been added/removed
	NSString *searchTerm = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	[self handleSearchForTerm:searchTerm];
	
	return YES;
}


- (void)resetSearch {
	
	if ([self.filteredListContent count] > 0) [self.filteredListContent removeAllObjects];
}


- (void)handleSearchForTerm:(NSString *)searchTerm {
	
	NSMutableArray *filteredObjects = [[NSMutableArray alloc] initWithArray:[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title BEGINSWITH[c] %@", searchTerm]]];

	self.filteredListContent = filteredObjects;
	[filteredObjects release];								   
									   
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
	
	UIImage *bgViewImage = [UIImage imageNamed:@"table-cell-background.png"];
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bgViewImage];
	cell.backgroundView = bgView;
	[bgView release];
	
	UIImage *selBGViewImage = [UIImage imageNamed:@"table-cell-background-on.png"];
	UIImageView *selBGView = [[UIImageView alloc] initWithImage:selBGViewImage];
	cell.selectedBackgroundView = selBGView;
	[selBGView release];
	
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
	
	NSString *docName = @"get_foodvenues.json";
	
	NSMutableString *mutableXML = [NSMutableString string];
	[mutableXML appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"]; 
	
	if ([[fetchedResultsController fetchedObjects] count] > 0) {
	
		[mutableXML appendString:@"<foodvenues>"];
	
		for (FoodVenue *venue in [fetchedResultsController fetchedObjects]) {
			
			[mutableXML appendFormat:@"<f id=\"%i\" v=\"%i\" />", [venue.venueID intValue], [venue.version intValue]];
		}
		
		[mutableXML appendString:@"</foodvenues>"];
	}
	
	else [mutableXML appendString:@"<foodvenues />"];
	
	
	NSLog(@"XML:%@", mutableXML);

	// Change the string to NSData for transmission
	NSData *requestBody = [mutableXML dataUsingEncoding:NSASCIIStringEncoding];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_SERVER_ADDRESS, docName];
	NSLog(@"FOOD VENUES URL:%@", urlString);
	
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
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//The API call has finished
	loading = NO;
	
	// IF STATUS CODE WAS OKAY (200)
	if ([theJSONFetcher statusCode] == 200) {
	
		if ([theJSONFetcher.data length] > 0) {
			
			// Store incoming data into a string
			NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
			
			// Create a dictionary from the JSON string
			NSDictionary *results = [jsonString JSONValue];
			
			// Build an array from the dictionary for easy access to each entry
			NSDictionary *addObjects = [results objectForKey:@"foodVenues"];
			
			// ADD DATA ////////////////////////////////////////////////////////////////////////
			NSDictionary *adds = [addObjects objectForKey:@"add"];
			NSMutableArray *venuesDict = [adds objectForKey:@"venue"];
						
			for (int i = 0; i < [venuesDict count]; i++) {
				
				NSDictionary *venue = [venuesDict objectAtIndex:i];
				
				NSLog(@"venue:%@", venue);
				
				// Store FoodVenue data in Core Data persistent store
				[FoodVenue newFoodVenueWithData:venue inManagedObjectContext:self.managedObjectContext];
			}
			
			
			// UPDATE DATA ////////////////////////////////////////////////////////////////////////
			NSDictionary *updates = [addObjects objectForKey:@"update"];
			NSMutableArray *updatesDict = [updates objectForKey:@"venue"];
			
			for (int i = 0; i < [updatesDict count]; i++) {
				
				NSDictionary *venue = [updatesDict objectAtIndex:i];
				
				// Store FoodVenue data in Core Data persistent store
				[FoodVenue updateVenueWithVenueData:venue inManagedObjectContext:self.managedObjectContext];
			}	
			
			
			// REMOVE DATA ////////////////////////////////////////////////////////////////////////
			NSDictionary *removes = [addObjects objectForKey:@"remove"];
			NSMutableArray *removeObjects = [removes objectForKey:@"venue"];
			
			for (int i = 0; i < [removeObjects count]; i++) { 
				
				NSDictionary *offerDict = [removeObjects objectAtIndex:i];
				NSNumber *idNum = [NSNumber numberWithInt:[[offerDict objectForKey:@"venueID"] intValue]];
				
				FoodVenue *venue = [FoodVenue getFoodVenueWithID:idNum inManagedObjectContext:self.managedObjectContext];
				if (venue) [self.managedObjectContext deleteObject:venue];
			}
			
			////////////////////////////////////////////////////////////////////////////////////////////////
			
			[jsonString release];
		}
		
		// Save the object context
		[[self appDelegate] saveContext];
		
		// The API call was successful
		venuesLoaded = YES;
		
		// Set foodVenuesLoaded in the NSUserDefaults
		[[self appDelegate] setFoodVenuesLoaded:YES];
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
}


- (IBAction)startSearch:(id)sender {
	
	// MAKE THE SEARCH RESULTS TABLE VISIBLE
	// MAKE THE SEARCH BAR VISIBLE 
	// MAKE THE CANCEL BUTTON VISIBLE
	[self.search setHidden:NO];
	[self.searchTable setHidden:NO];
	[self.cancelButton setHidden:NO];
	[self.menuTable setHidden:YES];
	
	// Put the focus on the search bar field. 
	// Keyboard will now be visible
	[self.search becomeFirstResponder];
	
	CGRect newFrame = self.searchTable.frame;
	newFrame.size.height -= (KEYBOARD_HEIGHHT - TAB_BAR_HEIGHT);
	[self.searchTable setFrame:newFrame];
	
	searching = YES;
}


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancelButtonClicked:(id)sender { 
	
	search.text = @"";
	[self resetSearch];
	[self.searchTable reloadData];
	[self.search resignFirstResponder];
	
	// Adjust searchTable's frame height
	if ([self.search isEditing]) {
		
		CGRect newFrame = self.searchTable.frame;
		newFrame.size.height += (KEYBOARD_HEIGHHT - TAB_BAR_HEIGHT);
		[self.searchTable setFrame:newFrame];
	}
	
	// Hide keyboard
	[self dismissKeyboard];
	
	[self.searchTable setHidden:YES];
	[self.search setHidden:YES];
	[self.cancelButton setHidden:YES];
	[self.menuTable setHidden:NO];
	
	searching = NO;
}


-(void)dismissKeyboard {
	
	[self.search resignFirstResponder];
}


- (void)dealloc {
	
	[fetchedResultsController release];
	[managedObjectContext release];
	
	[menuTable release];
	[filteredListContent release];
	[searchTable release];
	[search release];
	[loadCell release];
	[cancelButton release];
	[searchButton release];
	
    [super dealloc];
}

@end
