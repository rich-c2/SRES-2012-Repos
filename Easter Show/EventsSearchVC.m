//
//  EventsSearchVC.m
//  Easter Show
//
//  Created by Richard Lee on 8/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsSearchVC.h"
#import "SRESAppDelegate.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "Event.h"
#import "EventDateTime.h"
#import "EventSelectionVC.h"
#import "EventTableCell.h"
#import "EventVC.h"
#import "EventsMainVC.h"
#import "JSONFetcher.h"
#import "SBJson.h"

@implementation EventsSearchVC

@synthesize managedObjectContext, events, fetchedResultsController;
@synthesize searchTable, search, loadCell, searchField;

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


#pragma mark - Private Methods
- (SRESAppDelegate *)appDelegate {
	
    return (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
    // Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
	
	//[self fetchDateTimes];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.managedObjectContext = nil; 
	self.events = nil;
	self.fetchedResultsController = nil;
	
	self.searchTable = nil; 
	self.search = nil;
	self.searchField = nil;
	self.loadCell = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[self dismissKeyboard];
	
	// Request JSON
	[self retrieveXML];
	
	return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	/*NSInteger numberOfRows = 0;
	
	if ([[fetchedResultsController sections] count] > 0) {
		
		id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
		numberOfRows = [sectionInfo numberOfObjects];
    }*/
    
    return [self.events count];
}


- (void)configureCell:(UITableViewCell *)cell withEvent:(EventDateTime *)dateTime {
	
	UIImage *bgViewImage = [UIImage imageNamed:@"table-cell-background.png"];
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bgViewImage];
	cell.backgroundView = bgView;
	[bgView release];
	
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
	cell.textLabel.textColor = [UIColor colorWithRed:63.0/255.0 green:23.0/255.0 blue:56.0/255.0 alpha:1.0];
	cell.textLabel.text = dateTime.forEvent.title;
	
	/*NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	 [dateFormat setDateFormat:@"h:mm a"];
	 
	 cell.detailLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormat stringFromDate:event.startDate], [dateFormat stringFromDate:event.endDate]];
	 [dateFormat release];*/
	
	//[cell initImage];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:[EventTableCell reuseIdentifier]];
	
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
        /*[[NSBundle mainBundle] loadNibNamed:@"EventTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;*/
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	// Retrieve Event object
	EventDateTime *dateTime = [self.events objectAtIndex:[indexPath row]];//[fetchedResultsController objectAtIndexPath:indexPath];
	
	// Configure the cell using the object's attributes
	[self configureCell:cell withEvent:dateTime];
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Go to particular Event
	EventDateTime *dateTime = [self.events objectAtIndex:[indexPath row]];
	
	EventVC *eventVC = [[EventVC alloc] initWithNibName:@"EventVC" bundle:nil];
	[eventVC setManagedObjectContext:self.managedObjectContext];
	[eventVC setEventDateTime:dateTime];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:eventVC animated:YES];
	[eventVC release];
}


- (void)retrieveXML {
	
	NSString *docName = @"get_events.json";
	//http://sres2012.supergloo.net.au/api/get_foodvenues.json
	
	NSString *mutableXML = [self compileRequestXML];
	
	NSLog(@"XML:%@", mutableXML);
	
	// Change the string to NSData for transmission
	NSData *requestBody = [mutableXML dataUsingEncoding:NSASCIIStringEncoding];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", @"http://sres2012.supergloo.net.au/api/", docName];
	
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
	
	loading = NO;
	eventsLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *addObjects = [results objectForKey:@"events"];
		
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
	
	[self fetchDateTimes];
	
	[self.searchTable reloadData];
	
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


- (void)fetchDateTimes {
	
	NSString *searchTerm = self.searchField.text;

	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"EventDateTime" inManagedObjectContext:self.managedObjectContext]];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"((forEvent.title BEGINSWITH[c] %@) OR (forEvent.eventDescription CONTAINS[cd] %@))", searchTerm, searchTerm]];	
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"forEvent.title" ascending:YES]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.events = (NSMutableArray *)[self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	// Reload the table
	[self.searchTable reloadData];
}


-(void)dismissKeyboard {
	[self.searchField resignFirstResponder];
}


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSString *)compileRequestXML {
	
	NSString *searchTerm = self.searchField.text;
	
	// CREATE FETCH REQUEST
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"EventDateTime" inManagedObjectContext:self.managedObjectContext]];
	
	// FETCH PREDICATE
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"((forEvent.title BEGINSWITH[c] %@) OR (forEvent.eventDescription CONTAINS[cd] %@))", searchTerm, searchTerm]];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"forEvent.title" ascending:YES]];
	
	// Execute the fetch request
	NSError *error = nil;
	NSArray *storedEvents = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	NSMutableString *mutableXML = [NSMutableString string];
	[mutableXML appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><request><day /><category />"];
	
	[mutableXML appendFormat:@"<searchTerm>%@</searchTerm>", searchTerm];
	
	if ([storedEvents count] > 0) {
		
		[mutableXML appendString:@"<events>"];
		
		for (EventDateTime *dateTime in storedEvents) {
			
			Event *event = dateTime.forEvent;
			
			[mutableXML appendFormat:@"<e id=\"%i\" v=\"%i\" />", [event.eventID intValue], [event.version intValue]];
		}
		
		[mutableXML appendString:@"</events>"];
	}
	
	else [mutableXML appendString:@"<events />"];
	
	[mutableXML appendString:@"</request>"];
	
	NSString *returnString = [NSString stringWithString:mutableXML];
	
	return returnString;
}



- (void)dealloc {
	
	[managedObjectContext release]; 
	[events release];
	[fetchedResultsController release];

	[searchTable release];
	
	[search release];
	[searchField release];
	[loadCell release];
	
	[super dealloc];
}


@end