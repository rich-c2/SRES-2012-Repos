//
//  CarnivalMenuVC.m
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CarnivalMenuVC.h"
#import "XPathResultNode.h"
#import "CarnivalRide.h"
#import "CarnivalTableCell.h"
#import "SVProgressHUD.h"
#import "SRESAppDelegate.h"
#import "CarnivalRideVC.h"

static NSString *kCarnivalsPreviouslyLoadedKey = @"carnivalsPreviouslyLoadedKey";

@implementation CarnivalMenuVC

@synthesize fetchedResultsController, managedObjectContext;
@synthesize menuTable, loadCell, cokeFilterButton, kidsFilterButton;

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

- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self setupNavBar];
	
	[self.cokeFilterButton setBackgroundImage:[UIImage imageNamed:@"coke-carnival-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	[self.kidsFilterButton setBackgroundImage:[UIImage imageNamed:@"kids-carnival-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
	[self.cokeFilterButton setSelected:YES];
    [self.cokeFilterButton setHighlighted:NO];
    [self.cokeFilterButton setUserInteractionEnabled:NO];	
	
	// By default we're viewing coke rides
	viewingCoke = YES;
	
	// Show the loading animation
	[self showLoading];
	
	[self fetchRidesFromCoreData];
	
	
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
	self.loadCell = nil;
	
	self.cokeFilterButton = nil;
	self.kidsFilterButton = nil;
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
	BOOL previouslyLoaded = [[NSUserDefaults standardUserDefaults] boolForKey:kCarnivalsPreviouslyLoadedKey];
	
	// Load the Shopping objects from the relevant XML file
	if (!previouslyLoaded) {
	
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"carnivalrides" ofType:@"xml"];  
		NSData *myData = [NSData dataWithContentsOfFile:filePath];  
		NSString *xPathQuery;
		
		if (myData) {  
		
			xPathQuery = @"//ride";
			NSArray *results = [[XPathResultNode nodesForXPathQuery:xPathQuery onXML:myData] retain];
			
			// Add Rides to Core Data
			if (results) {
				
				[self addCarnivaRidesToCoreData:results];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCarnivalsPreviouslyLoadedKey];
			}
		}  
	}
	
	if (!viewLoaded) {
		
		[self fetchRidesFromCoreData];
		
		viewLoaded = YES;
		
		[self hideLoading];
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
		fetchRequest.entity = [NSEntityDescription entityForName:@"CarnivalRide" inManagedObjectContext:managedObjectContext];
		
		NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"title"
										ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:sorter];
		[sorter release];
		
		fetchRequest.fetchBatchSize = 20;
		fetchRequest.predicate = [self getPredicateForSelectedFilter];
        
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
			[self configureCell:(CarnivalTableCell *)[self.menuTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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


- (void)configureCell:(CarnivalTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	CarnivalRide *ride = [fetchedResultsController objectAtIndexPath:indexPath];
	
	UIImage *bgViewImage = [UIImage imageNamed:@"table-cell-background.png"];
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bgViewImage];
	cell.backgroundView = bgView;
	[bgView release];
	
	UIImage *selBGViewImage = [UIImage imageNamed:@"table-cell-background-on.png"];
	UIImageView *selBGView = [[UIImageView alloc] initWithImage:selBGViewImage];
	cell.selectedBackgroundView = selBGView;
	[selBGView release];

	cell.nameLabel.text = [ride.title uppercaseString];;
	cell.descriptionLabel.text = [NSString stringWithFormat:@"%@", [ride rideDescription]];
	
	[cell initImage:ride.thumbURL];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CarnivalTableCell *cell = (CarnivalTableCell *)[tableView dequeueReusableCellWithIdentifier:[CarnivalTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"CarnivalTableCell" owner:self options:nil];
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
	
	CarnivalRide *carnivalRide = [fetchedResultsController objectAtIndexPath:indexPath];
	
	CarnivalRideVC *carnivalRideVC = [[CarnivalRideVC alloc] initWithNibName:@"CarnivalRideVC" bundle:nil];
	[carnivalRideVC setCarnivalRide:carnivalRide];
	[carnivalRideVC setManagedObjectContext:self.managedObjectContext];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:carnivalRideVC animated:YES];
	[carnivalRideVC release];
}


- (void)addCarnivaRidesToCoreData:(NSArray *)rideNodes {
	
	for (XPathResultNode *node in rideNodes) { 
	
		NSMutableDictionary *rideData = [NSMutableDictionary dictionary];
		
		// Store the CarnivalRide's ID
		[rideData setObject:[[node attributes] objectForKey:@"id"] forKey:@"id"];
		
		for (XPathResultNode *rideNode in node.childNodes) { 

			if ([[rideNode contentString] length] > 0)
				[rideData setObject:[rideNode contentString] forKey:[rideNode name]];
		}
		
		// Store CarnivalRide data in Core Data persistent store
		[CarnivalRide rideWithRideData:rideData inManagedObjectContext:self.managedObjectContext];
	}
	
	// Save the object context
	[[self appDelegate] saveContext];
}


- (void)fetchRidesFromCoreData {
	
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


- (IBAction)cocaColaCarnivalButtonClicked:(id)sender {
	
	[self.cokeFilterButton setSelected:YES];
	[self.cokeFilterButton setUserInteractionEnabled:NO];
	
	[self.kidsFilterButton setSelected:NO];
    [self.kidsFilterButton setHighlighted:NO];
	[self.kidsFilterButton setUserInteractionEnabled:YES];
	
	viewingCoke = YES;
	
	[NSFetchedResultsController deleteCacheWithName:nil];
	self.fetchedResultsController.fetchRequest.predicate = [self getPredicateForSelectedFilter];
	
	// Query the persistent store
	[self fetchRidesFromCoreData];
	
	[self.menuTable reloadData];
}


- (IBAction)kidsCarnivalButtonClicked:(id)sender {

	[self.kidsFilterButton setSelected:YES];
	[self.kidsFilterButton setUserInteractionEnabled:NO];
	
	[self.cokeFilterButton setSelected:NO];
    [self.cokeFilterButton setHighlighted:NO];
	[self.cokeFilterButton setUserInteractionEnabled:YES];
	
	viewingCoke = NO;
	
	[NSFetchedResultsController deleteCacheWithName:nil];
	self.fetchedResultsController.fetchRequest.predicate = [self getPredicateForSelectedFilter];
	
	// Query the persistent store
	[self fetchRidesFromCoreData];
	
	[self.menuTable reloadData];
}


- (NSPredicate *)getPredicateForSelectedFilter {
		
	NSPredicate *predicate;
	
	if (viewingCoke) predicate = [NSPredicate predicateWithFormat:@"type = 'Coca-Cola Carnival'"];
	else predicate = [NSPredicate predicateWithFormat:@"type = 'Kids Carnival'"];
	
	return predicate;
}


- (void)dealloc {
	
	[cokeFilterButton release];
	[kidsFilterButton release];
	
	[fetchedResultsController release];
	[managedObjectContext release];
	[menuTable release];
	[loadCell release];
    [super dealloc];
}

@end
