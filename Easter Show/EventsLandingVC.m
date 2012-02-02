//
//  EventsLandingVC.m
//  Easter Show
//
//  Created by Richard Lee on 13/01/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "EventsLandingVC.h"
#import "SRESAppDelegate.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "Event.h"
#import "EventSelectionVC.h"
#import "EventTableCell.h"
#import "EventVC.h"
#import "EventsMainVC.h"
#import "JSONFetcher.h"
#import "SBJson.h"

@implementation EventsLandingVC

@synthesize managedObjectContext, loadCell;
@synthesize searchTable, events;
@synthesize search, todaysEventsButton, fullProgramButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		// Custom initialization
		self.title = @"Events";
		self.tabBarItem.title = @"Events";
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
}


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.managedObjectContext = nil;
	self.events = nil;
	self.searchTable = nil;
	self.search = nil; 
	self.todaysEventsButton = nil; 
	self.fullProgramButton = nil;
	self.loadCell = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated {
	
	// If this view has not already been loaded 
	//(i.e not coming back from an Offer detail view)
	if (!eventsLoaded && !loading) {
		
		[self showLoading];
		
		[self retrieveXML];
	}
}


- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {

	NSLog(@"touchesShouldBegin");
}


#pragma mark
#pragma mark Search Bar Delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	NSLog(@"searchBarSearchButtonClicked");
	
	// Make the search table visible
	[self.searchTable setHidden:NO];
	
	// Move the search bar to the top of the visible content area
	CGRect newFrame = self.search.frame;
	newFrame.origin.y = 0.0;
	[self.search setFrame:newFrame];
	
	NSString *searchTerm = [searchBar text];
	[self handleSearchForTerm:searchTerm];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {

	NSLog(@"searchBarShouldBeginEditing");
	
	// Reset the height of the Table's frame and hide it from view
	//CGFloat keyboardHeight = 166.0;
	CGRect newTableFrame = self.searchTable.frame;
	newTableFrame.size.height = 157.0; //(newTableFrame.size.height - (keyboardHeight));
	[self.searchTable setFrame:newTableFrame];
	
	// Make the search table visible
	[self.searchTable setHidden:NO];
	
	// Move the search bar to the top of the visible content area
	CGRect newFrame = self.search.frame;
	newFrame.origin.y = 0.0;
	[self.search setFrame:newFrame];
	
	return YES;
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
		
	if ([self.events count] > 0) self.events = [NSMutableArray array];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	
	NSLog(@"searchBarCancelButtonClicked");
	
	search.text = @"";
	[self resetSearch];
	[self.searchTable reloadData];
	[searchBar resignFirstResponder];
	
	// Reset the height of the Table's frame and hide it from view
	//CGFloat keyboardHeight = 166.0;
	CGRect newFrame = self.searchTable.frame;
	newFrame.size.height = 157.0; //(newFrame.size.height + keyboardHeight);
	[self.searchTable setFrame:newFrame];
	
	[self.searchTable setHidden:YES];
	
	// Move the search bar it's original position
	CGRect newSearchFrame = self.search.frame;
	newSearchFrame.origin.y = 130.0;
	[self.search setFrame:newSearchFrame];
}


- (void)handleSearchForTerm:(NSString *)searchTerm {
	
	NSLog(@"handleSearchForTerm");
	
	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title BEGINSWITH[c] %@", searchTerm]];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.events = (NSMutableArray *)[self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	// Reload the table
	[self.searchTable reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.events count];
}


- (void)configureCell:(EventTableCell *)cell withEvent:(Event *)event {
	
	cell.nameLabel.text = event.title;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"h:mm a"];
	
	cell.detailLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormat stringFromDate:event.startDate], [dateFormat stringFromDate:event.endDate]];
	[dateFormat release];
	
	[cell initImage];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:[EventTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"EventTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
    }
	
	// Retrieve Event object
	Event *event = [self.events objectAtIndex:[indexPath row]];
	
	// Configure the cell using the object's attributes
	[self configureCell:cell withEvent:event];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Go to particular Event
	Event *event = (Event *)[self.events objectAtIndex:[indexPath row]];
	
	EventVC *eventVC = [[EventVC alloc] initWithNibName:@"EventVC" bundle:nil];
	[eventVC setManagedObjectContext:self.managedObjectContext];
	[eventVC setEvent:event];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:eventVC animated:YES];
	[eventVC release];
}


- (void)retrieveXML {
	
	// TEST CODE
	//NSString *docName = @"events.xml";
	//NSString *docName = @"events-summaries.xml";
	NSString *docName = @"events-summaries2.json";
	
	//NSInteger eventCount = 0; 
	//NSInteger lastEventID = 5390;
	//NSString *queryString;
	
	//BOOL batchImport = NO;
	
	//if (batchImport) queryString = [NSString stringWithFormat:@"?first=true&start=%i&last=1000", eventCount]; 
	//else queryString = [NSString stringWithFormat:@"?id=%i", lastEventID];
	
	// TEST CODE
	//NSString *urlString = [NSString stringWithFormat:@"%@%@%@", API_SERVER_ADDRESS, docName, queryString];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", @"http://richardflee.me/test/", docName];
	
	
	NSURL *url = [urlString convertToURL];
	
	NSLog(@"EVENTS URL:%@", urlString);
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	[request setHTTPMethod:@"GET"];	
	
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
	
	loading = NO;
	eventsLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *addObjects = [results objectForKey:@"events"];
									// objectForKey:@"add"]
		
		NSDictionary *adds = [addObjects objectForKey:@"add"];
				
		NSMutableArray *eventsDict = [adds objectForKey:@"event"];
		
		NSLog(@"KEYS:%@", eventsDict);
		
		for (int i = 0; i < [eventsDict count]; i++) {
			
			NSDictionary *event = [eventsDict objectAtIndex:i];
		
			// Store Event data in Core Data persistent store
			[Event newEventWithData:event inManagedObjectContext:self.managedObjectContext];
		}
		
		NSDictionary *updates = [addObjects objectForKey:@"update"];
		
		NSMutableArray *updatesDict = [updates objectForKey:@"event"];
		
		for (int i = 0; i < [updatesDict count]; i++) {
			
			NSDictionary *event = [updatesDict objectAtIndex:i];
			
			// Store Event data in Core Data persistent store
			[Event updateEventWithEventData:event inManagedObjectContext:self.managedObjectContext];
		}	
		
		[jsonString release];
	}
	
	// Save the object context
	[[self appDelegate] saveContext];
	
	// Hide loading view
	[self hideLoading];
	
	[fetcher release];
	fetcher = nil;
}


- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url {
	
	NSArray *cells = [self.searchTable visibleCells];
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


- (IBAction)todaysEventsButtonClicked:(id)sender {

	NSDate *todaysDate = [NSDate date];
	//NSLog(@"TODAY'S DATE:%@", todaysDate);
	
	// Convert string to date object
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	
	// TODAY'S DATE:24/01/2012
	//[dateFormat setDateFormat:@"dd/MM/yyyy HH:MM:SS a"];
	
	// TODAY'S DATE:January 24
	[dateFormat setDateFormat:@"MMMM dd"];
	//NSLog(@"TODAY'S DATE:%@", [dateFormat stringFromDate:todaysDate]);

	
	EventSelectionVC *eventSelectionVC = [[EventSelectionVC alloc] initWithNibName:@"EventSelectionVC" bundle:nil];
	[eventSelectionVC setManagedObjectContext:self.managedObjectContext];
	[eventSelectionVC setSelectedDate:[dateFormat stringFromDate:todaysDate]];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:eventSelectionVC animated:YES];
	[eventSelectionVC release];
	
	[dateFormat release];
}


- (IBAction)fullProgramButtonClicked:(id)sender {
	
	EventsMainVC *eventsMainVC = [[EventsMainVC alloc] initWithNibName:@"EventsMainVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:eventsMainVC animated:YES];
	[eventsMainVC release];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
} 


-(void)dismissKeyboard {
	[self.search resignFirstResponder];
}



- (void)dealloc {
	
	[managedObjectContext release];
	[events release];
	[searchTable release];
	[search release];
	[todaysEventsButton release];
	[fullProgramButton release];
	[search release];
	[loadCell release];
	
    [super dealloc];
}


@end
