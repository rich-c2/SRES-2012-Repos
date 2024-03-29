//
//  ShoppingMenuVC.m
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShoppingMenuVC.h"
#import "ShoppingTableCell.h"
#import "SVProgressHUD.h"
#import "SRESAppDelegate.h"
#import "XPathResultNode.h"
#import "ShoppingVendor.h"
#import "ShoppingVendorVC.h"

static NSString *kShoppingVendorsPreviouslyLoadedKey = @"vendorsPreviouslyLoadedKey";

@implementation ShoppingMenuVC

@synthesize fetchedResultsController, managedObjectContext;
@synthesize menuTable, loadCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
	
	[self setupNavBar];
	
	[self fetchVendorsFromCoreData];
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
	
	// Check in the NSUSerDefaults whether this is the 
	// first time the Carnival Rides are being loaded. If so, we need to load the data from the xml
	// file and add the data to Core Data for future use.
	BOOL previouslyLoaded = [[NSUserDefaults standardUserDefaults] boolForKey:kShoppingVendorsPreviouslyLoadedKey];
	
	// Show the loading animation
	if (!viewLoaded || !previouslyLoaded) [self showLoading];
	
	// Load the Shopping objects from the relevant XML file
	if (!previouslyLoaded) {
				
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"shoppingVendors" ofType:@"xml"];  
		NSData *myData = [NSData dataWithContentsOfFile:filePath];  
		NSString *xPathQuery;
		
		if (myData) {  
			
			xPathQuery = @"//shop";
			NSArray *results = [[XPathResultNode nodesForXPathQuery:xPathQuery onXML:myData] retain];
			
			// Add Rides to Core Data
			if (results) {
			
				[self addShoppingVendorsToCoreData:results];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShoppingVendorsPreviouslyLoadedKey];
			}
		}  
	}
	
	if (!viewLoaded) {
	
		[self fetchVendorsFromCoreData];
		
		viewLoaded = YES;
		
		[self hideLoading];
	}
	
	
	// Deselect the selected table cell
	[self.menuTable deselectRowAtIndexPath:[self.menuTable indexPathForSelectedRow] animated:YES];
	//[self.searchTable deselectRowAtIndexPath:[self.searchTable indexPathForSelectedRow] animated:YES];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
		
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		fetchRequest.entity = [NSEntityDescription entityForName:@"ShoppingVendor" inManagedObjectContext:managedObjectContext];
		
		NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"title"
														ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:sorter];
		[sorter release];
		
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
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.menuTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.menuTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(ShoppingTableCell *)[self.menuTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
    
	if (count == 0) {
		count = 1;
	}
	
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


- (void)configureCell:(ShoppingTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	ShoppingVendor *vendor = [fetchedResultsController objectAtIndexPath:indexPath];
	
	UIImage *bgViewImage = [UIImage imageNamed:@"table-cell-background.png"];
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bgViewImage];
	cell.backgroundView = bgView;
	[bgView release];
	
	UIImage *selBGViewImage = [UIImage imageNamed:@"table-cell-background-on.png"];
	UIImageView *selBGView = [[UIImageView alloc] initWithImage:selBGViewImage];
	cell.selectedBackgroundView = selBGView;
	[selBGView release];
	
	cell.nameLabel.text = [vendor.title uppercaseString];
	cell.descriptionLabel.text = [NSString stringWithFormat:@"%@", [vendor vendorDescription]];
	
	[cell initImage:vendor.thumbURL];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShoppingTableCell *cell = (ShoppingTableCell *)[tableView dequeueReusableCellWithIdentifier:[ShoppingTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"ShoppingTableCell" owner:self options:nil];
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
	
	 ShoppingVendor *shoppingVendor = [fetchedResultsController objectAtIndexPath:indexPath];
	 
	 ShoppingVendorVC *shoppingVendorVC = [[ShoppingVendorVC alloc] initWithNibName:@"ShoppingVendorVC" bundle:nil];
	 [shoppingVendorVC setShoppingVendor:shoppingVendor];
	 [shoppingVendorVC setManagedObjectContext:self.managedObjectContext];
	 
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:shoppingVendorVC animated:YES];
	 [shoppingVendorVC release];
}


- (void)addShoppingVendorsToCoreData:(NSArray *)vendorNodes {
	
	for (XPathResultNode *node in vendorNodes) { 
		
		NSMutableDictionary *vendorData = [NSMutableDictionary dictionary];
		
		// Store the CarnivalRide's ID
		[vendorData setObject:[[node attributes] objectForKey:@"id"] forKey:@"id"];
		
		for (XPathResultNode *vendorNode in node.childNodes) { 
			
			if ([[vendorNode contentString] length] > 0)
				[vendorData setObject:[vendorNode contentString] forKey:[vendorNode name]];
			
		}
		
		// Store ShoppingVendor data in Core Data persistent store
		[ShoppingVendor vendorWithVendorData:vendorData inManagedObjectContext:self.managedObjectContext];
	}
	
	// Save the object context
	[[self appDelegate] saveContext];
}


- (void)fetchVendorsFromCoreData {
	
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


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
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
