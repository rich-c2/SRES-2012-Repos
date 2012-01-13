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
#import "XMLFetcher.h"
#import "SVProgressHUD.h"
#import "Event.h"
#import "EventSelectionVC.h"
#import "EventTableCell.h"

@implementation EventsLandingVC

@synthesize managedObjectContext, loadCell;
@synthesize searchTable, events;
@synthesize search, todaysEventsButton, fullProgramButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
	
	// Make the search table visible
	[self.searchTable setHidden:NO];
	
	// Move the search bar to the top of the visible content area
	CGRect newFrame = self.search.frame;
	newFrame.origin.y = 0.0;
	[self.search setFrame:newFrame];
	
	//NSString *searchTerm = [searchBar text];
	//[self handleSearchForTerm:searchTerm];
	
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
	
	//self.filteredListContent = [[self.fetchedResultsController fetchedObjects] mutableCopy];
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
	cell.dateLable.text = event.eventDate;
	
	[cell initImage:event.thumbURL];
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
}


- (void)retrieveXML {
	
	NSString *docName = @"events.xml";
	NSInteger eventCount = 0; 
	NSInteger lastEventID = 0;
	NSString *queryString;
	
	BOOL batchImport = NO;
	
	if (batchImport) queryString = [NSString stringWithFormat:@"?first=true&start=%i&last=1000", eventCount]; 
	else queryString = [NSString stringWithFormat:@"?id=%i", lastEventID];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@", API_SERVER_ADDRESS, docName, queryString];
	NSURL *url = [urlString convertToURL];
	
	NSLog(@"EVENTS URL:%@", urlString);
	
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
	eventsLoaded = YES;
	
	if ([theXMLFetcher.data length] > 0) {
        
        // loop through the XPathResultNode objects that the XMLFetcher fetched
        for (XPathResultNode *node in theXMLFetcher.results) { 
			
			if ([[node name] isEqualToString:@"add"]) {
				
				for (XPathResultNode *eventNode in node.childNodes) { 
					
					NSMutableDictionary *eventData = [NSMutableDictionary dictionary];
					
					// Store the Event's ID
					[eventData setObject:[[eventNode attributes] objectForKey:@"id"] forKey:@"id"];
					
					// Store the rest of the showbag's attributes
					for (XPathResultNode *eventChild in eventNode.childNodes) {
						
						if ([[eventChild contentString] length] > 0)
							[eventData setObject:[eventChild contentString] forKey:[eventChild name]];
					}
					
					// Store Event data in Core Data persistent store
					[Event eventWithEventData:eventData inManagedObjectContext:self.managedObjectContext];
				}
			}
			else if ([[node name] isEqualToString:@"update"]) {
				
				for (XPathResultNode *eventNode in node.childNodes) { 
					
					NSMutableDictionary *eventData = [NSMutableDictionary dictionary];
					
					// Store the Event's ID
					[eventData setObject:[[eventNode attributes] objectForKey:@"id"] forKey:@"id"];
					
					// Store the rest of the Event's attributes
					for (XPathResultNode *eventChild in eventNode.childNodes) {
						
						if ([[eventChild contentString] length] > 0)
							[eventData setObject:[eventChild contentString] forKey:[eventChild name]];
					}
					
					// Store Event data in Core Data persistent store
					[Event updateEventWithEventData:eventData inManagedObjectContext:self.managedObjectContext];
				}
			}
			else if ([[node name] isEqualToString:@"remove"]) {
				
				for (XPathResultNode *showbagNode in node.childNodes) {
					
					NSString *idString = [[showbagNode attributes] objectForKey:@"id"];
					NSNumber *eventID = [NSNumber numberWithInt:[idString intValue]];
					
					// Delete Event from the persistent store
					Event *event = [Event eventWithID:eventID inManagedObjectContext:self.managedObjectContext];
					
					if (event) [self.managedObjectContext deleteObject:event];
				}
			}
		}		
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

	
}


- (IBAction)fullProgramButtonClicked:(id)sender {
	
	
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
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
