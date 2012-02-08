//
//  ShowbagsMenuVC.m
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "ShowbagsMenuVC.h"
#import "SRESAppDelegate.h"
#import "ShowbagVC.h"
#import "Showbag.h"
#import "ShowbagsTableCell.h"
#import "StringHelper.h"
#import "XMLFetcher.h"
#import "SVProgressHUD.h"

#define UNDER10_TAG 1000
#define OVER10_UNDER1750_TAG 1001
#define OVER1750_TAG 1002

static NSString* kTableCellFont = @"Arial-BoldMT";
static NSString *kCellThumbPlaceholder = @"placeholder-showbags-thumb.jpg";

@implementation ShowbagsMenuVC

@synthesize fetchedResultsController, managedObjectContext;
@synthesize internetConnectionPresent, cokeOfferButton, menuTable, search;
@synthesize priceRanges, viewLoaded, filteredListContent, searchTable;
@synthesize filterButton1, filterButton2, filterButton3, selectedFilterButton;
@synthesize loadCell;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	self.title = @"Showbags";
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.filteredListContent = [NSMutableArray array];
	
	[self.navigationController setNavigationBarHidden:NO];
	
	[self setupNavBar];
	
	[self.filterButton1 setBackgroundImage:[UIImage imageNamed:@"showbagFilter-under10-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[self.filterButton2 setBackgroundImage:[UIImage imageNamed:@"showbagFilter-10-17-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[self.filterButton3 setBackgroundImage:[UIImage imageNamed:@"showbagFilter-over17-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[self.filterButton1 setSelected:YES];
	
	[self.selectedFilterButton setSelected:NO];
	self.selectedFilterButton = self.filterButton1;
	
	[self initPriceRanges];
	
	minPrice = 0.0;
	maxPrice = 9.99;
	
	[self fetchShowbagsFromCoreData];
}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)didReceiveMemoryWarning {
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.fetchedResultsController = nil; 
	self.managedObjectContext = nil;
		
	self.menuTable = nil;
	self.filteredListContent = nil;
	self.searchTable = nil;
	self.search = nil;
	self.priceRanges = nil;
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
	
	// If this view has not already been loaded 
	//(i.e not coming back from an Offer detail view)
	if (!showbagsLoaded && !loading) {

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
	
	CGFloat keyboardHeight = 166.0;
	CGRect newFrame = self.searchTable.frame;
	newFrame.size.height = (newFrame.size.height + keyboardHeight);
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
		fetchRequest.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:managedObjectContext];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
		fetchRequest.predicate = [self getQueryForSelectedFilter];
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
	
	Showbag *showbag;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			if (searching) showbag = (Showbag *)[fetchedResultsController objectAtIndexPath:indexPath];
			else showbag = (Showbag *)[self.filteredListContent objectAtIndex:[indexPath row]];
			[self configureCell:(ShowbagsTableCell *)[tableView cellForRowAtIndexPath:indexPath] withShowbag:showbag];
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


- (void)configureCell:(ShowbagsTableCell *)cell withShowbag:(Showbag *)showbag {
		
	cell.nameLabel.text = showbag.title;
	cell.dateLable.text = [NSString stringWithFormat:@"%.2f", [showbag.price floatValue]];
	
	[cell initImage:showbag.thumbURL];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShowbagsTableCell *cell = (ShowbagsTableCell *)[tableView dequeueReusableCellWithIdentifier:[ShowbagsTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"ShowbagsTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
    }
	
	Showbag *showbag;
	
	// Retrieve the Showbag object
	if (tableView == self.menuTable)
		showbag = (Showbag *)[fetchedResultsController objectAtIndexPath:indexPath];
	else
		showbag = (Showbag *)[self.filteredListContent objectAtIndex:[indexPath row]];
	
	// Retrieve Showbag object and set it's name to the cell
	[self configureCell:cell withShowbag:showbag];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	Showbag *showbag;
	
	// Retrieve the Showbag object
	if (tableView == self.menuTable)
		showbag = (Showbag *)[fetchedResultsController objectAtIndexPath:indexPath];
	else
		showbag = (Showbag *)[self.filteredListContent objectAtIndex:[indexPath row]];
		
	ShowbagVC *showbagVC = [[ShowbagVC alloc] initWithNibName:@"ShowbagVC" bundle:nil];
	[showbagVC setShowbag:showbag];
	[showbagVC setManagedObjectContext:self.managedObjectContext];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:showbagVC animated:YES];
	[showbagVC release];
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
	
	NSString *docName = @"showbags.xml";
	NSInteger lastShowbagID = 0;
	NSString *queryString = [NSString stringWithFormat:@"?id=%i", lastShowbagID];
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@", API_SERVER_ADDRESS, docName, queryString];
	NSLog(@"SHOWBAGS URL:%@", urlString);
	
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
	showbagsLoaded = YES;
	
	if ([theXMLFetcher.data length] > 0) {
        
        // loop through the XPathResultNode objects that the XMLFetcher fetched
        for (XPathResultNode *node in theXMLFetcher.results) { 
		
			if ([[node name] isEqualToString:@"add"]) {
				
				for (XPathResultNode *showbagNode in node.childNodes) { 
					
					NSMutableDictionary *showbagData = [NSMutableDictionary dictionary];
				
					// Store the showbag's ID
					[showbagData setObject:[[showbagNode attributes] objectForKey:@"id"] forKey:@"id"];
					
					// Store the rest of the showbag's attributes
					for (XPathResultNode *showbagChild in showbagNode.childNodes) {
						
						if ([[showbagChild contentString] length] > 0)
							[showbagData setObject:[showbagChild contentString] forKey:[showbagChild name]];
					}
					
					// Store Showbag data in Core Data persistent store
					[Showbag showbagWithShowbagData:showbagData inManagedObjectContext:self.managedObjectContext];
				}
			}
			else if ([[node name] isEqualToString:@"update"]) {
				
				for (XPathResultNode *showbagNode in node.childNodes) { 
					
					NSMutableDictionary *showbagData = [NSMutableDictionary dictionary];
					
					// Store the showbag's ID
					[showbagData setObject:[[showbagNode attributes] objectForKey:@"id"] forKey:@"id"];
					
					// Store the rest of the showbag's attributes
					for (XPathResultNode *showbagChild in showbagNode.childNodes) {
						
						if ([[showbagChild contentString] length] > 0)
							[showbagData setObject:[showbagChild contentString] forKey:[showbagChild name]];
					}
					
					// Store Showbag data in Core Data persistent store
					[Showbag updateShowbagWithShowbagData:showbagData inManagedObjectContext:self.managedObjectContext];
				}
			}
			else if ([[node name] isEqualToString:@"remove"]) {
				
				for (XPathResultNode *showbagNode in node.childNodes) {
				
					NSString *idString = [[showbagNode attributes] objectForKey:@"id"];
					NSNumber *showbagID = [NSNumber numberWithInt:[idString intValue]];
					
					// Delete Showbag from the persistent store
					Showbag *showbag = [Showbag showbagWithID:showbagID inManagedObjectContext:self.managedObjectContext];
					
					if (showbag) [self.managedObjectContext deleteObject:showbag];
				}
			}
		}		
	}
	
	// Save the object context
	[[self appDelegate] saveContext];
	
	// Fetch Showbag objets from Core Data
	[self fetchShowbagsFromCoreData];
	
	// Hide loading view
	[self hideLoading];
	
	[fetcher release];
	fetcher = nil;
}


- (void)fetchShowbagsFromCoreData {
	
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


- (void)initPriceRanges {

	NSMutableArray *range1 = [[NSMutableArray alloc] init];
	NSNumber *num1 = [[NSNumber alloc] initWithDouble:0.0];
	NSNumber *num2 = [[NSNumber alloc] initWithDouble:9.99];
	[range1 addObject:num1];
	[range1 addObject:num2];
	[num1 release];
	[num2 release];
	
	NSMutableArray *range2 = [[NSMutableArray alloc] init];
	NSNumber *num3 = [[NSNumber alloc] initWithDouble:10.0];
	NSNumber *num4 = [[NSNumber alloc] initWithDouble:17.50];
	[range2 addObject:num3];
	[range2 addObject:num4];
	[num3 release];
	[num4 release];
	
	NSMutableArray *range3 = [[NSMutableArray alloc] init];
	NSNumber *num5 = [[NSNumber alloc] initWithDouble:17.50];
	NSNumber *num6 = [[NSNumber alloc] initWithDouble:1000.0];
	[range3 addObject:num5];
	[range3 addObject:num6];
	[num5 release];
	[num6 release];
	
	NSArray *tempRanges = [[NSArray alloc] initWithObjects:range1, range2, range3, nil];
	[range1 release];
	[range2 release];
	[range3 release];


	self.priceRanges = tempRanges;
	[tempRanges release];
}


- (void)goBack:(id)sender { 
	
	[self.navigationController popViewControllerAnimated:YES];
	
}


- (void)filterShowbags:(id)sender {
	
	UIButton *btn = (UIButton *)sender;
	NSMutableArray *range;
	
	[btn setSelected:YES];
	
	[self.selectedFilterButton setSelected:NO];
	self.selectedFilterButton = btn;

	range = [self.priceRanges objectAtIndex:btn.tag];

	// min price is at 0, max at 1
	minPrice = [[range objectAtIndex:0] doubleValue];
	maxPrice = [[range objectAtIndex:1] doubleValue];
	
	[NSFetchedResultsController deleteCacheWithName:nil];
	self.fetchedResultsController.fetchRequest.predicate = [self getQueryForSelectedFilter];
	
	// Query the persistent store
	[self fetchShowbagsFromCoreData];
	
	[self.menuTable reloadData];
	[self.searchTable reloadData];
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
	
	// if already searching, then hide
	// the search table and search field
	if (searching) {
	
		search.text = @"";
		[self resetSearch];
		[self.searchTable reloadData];
		[self.search resignFirstResponder];
		
		CGFloat keyboardHeight = 166.0;
		CGRect newFrame = self.searchTable.frame;
		newFrame.size.height = (newFrame.size.height + keyboardHeight);
		[self.searchTable setFrame:newFrame];
		
		[self.searchTable setHidden:YES];
		[self.search setHidden:YES];
	}
	
	else {

		// MAKE THE SEARCH RESULTS TABLE VISIBLE
		// MAKE THE SEARCH BAR VISIBLE 
		[self.search setHidden:NO];
		[self.searchTable setHidden:NO];
		
		// Put the focus on the search bar field. 
		// Keyboard will now be visible
		[self.search becomeFirstResponder];
		
		CGFloat keyboardHeight = 166.0;
		CGRect newFrame = self.searchTable.frame;
		newFrame.size.height = (newFrame.size.height - keyboardHeight);
		[self.searchTable setFrame:newFrame];
	}
	
	searching = !searching;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
} 


- (NSPredicate *)getQueryForSelectedFilter {

	NSString *queryString = [NSString stringWithFormat:@"price >= %.2f AND price < %.2f", minPrice, maxPrice];
	
	NSPredicate *query = [NSPredicate predicateWithFormat:queryString];
	
	return query;
}


- (void)dealloc {
	
	[fetchedResultsController release];
	[managedObjectContext release];
		
	[menuTable release];
	[filteredListContent release];
	[searchTable release];
	[search release];
	[priceRanges release];
	
    [super dealloc];
}


@end
