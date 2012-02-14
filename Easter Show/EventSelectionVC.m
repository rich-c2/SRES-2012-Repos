//
//  EventSelectionVC.m
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "EventSelectionVC.h"
#import "Event.h"
#import "EventTableCell.h"
#import "SRESAppDelegate.h"
#import "EventVC.h"
#import "EventDateTime.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "StringHelper.h"


static NSString* kTableCellFont = @"HelveticaNeue-Bold";
static NSString *kThumbPlaceholderAnimals = @"placeholder-events-animals-thumb.jpg";
static NSString *kThumbPlaceholderCompetitions = @"placeholder-events-competitions-thumb.jpg";
static NSString *kThumbPlaceholderEntertainment = @"placeholder-events-entertainment-thumb.jpg";

@implementation EventSelectionVC

@synthesize selectedFilterButton, dateTimes, navigationTitle;
@synthesize menuTable, events, selectedDate, selectedCategory;
@synthesize loadCell, managedObjectContext, dateFormat;
@synthesize search, searchTable, filteredListContent;
@synthesize alphabeticalSortButton, timeSortButton;


// The designated initializer.  Override if you create the controller programmatically 
// and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set the title
	self.title = self.selectedDate;
	
	// Init search array
	self.filteredListContent = [NSMutableArray array];
	
	// Initialise the date form that we are using
	// across all dates/times
	NSDateFormatter *tempDateFormat = [[NSDateFormatter alloc] init];
	[tempDateFormat setDateFormat:@"MMMM dd h:mm a"];
	self.dateFormat = tempDateFormat;
	[tempDateFormat release];
	
	
	// Set the image for when the button's are selected
	[self.alphabeticalSortButton setImage:[UIImage imageNamed:@"alphabetical-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	[self.timeSortButton setImage:[UIImage imageNamed:@"time-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
	
	[self.alphabeticalSortButton setSelected:YES];
    [self.alphabeticalSortButton setHighlighted:NO];
    [self.alphabeticalSortButton setUserInteractionEnabled:NO];
	
	
	// Navigation bar elements
	[self setupNavBar];
	
	// Get the EventDateTime objects
	// By default, get them in alphabetical order
	alphabeticallySorted = YES;
	[self fetchEventDateTimesFromCoreData];

	// Populate sub nav
	[self setupSubNav];
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
	
	self.alphabeticalSortButton = nil; 
	self.timeSortButton = nil;
	self.dateTimes = nil;
	self.dateFormat = nil;
	self.managedObjectContext = nil;
	self.events = nil;
	self.menuTable = nil;
	self.selectedDate = nil;
	self.selectedCategory = nil;
	self.loadCell = nil;
	self.search = nil; 
	self.searchTable = nil; 
	self.filteredListContent = nil;
	self.navigationTitle = nil;
}


- (void)viewWillDisappear:(BOOL)animated {
	
    [super viewWillDisappear:animated];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[self.menuTable reloadData];
}


- (void)viewDidAppear:(BOOL)animated {
	
	// If this view has not already been loaded 
	//(i.e not coming back from an Offer detail view)
	if (!eventsLoaded && !loading) {
		
		[self showLoading];
		
		[self retrieveJSON];
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
	
	self.filteredListContent = (NSMutableArray *)[self.dateTimes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"forEvent.title BEGINSWITH[c] %@", searchTerm]];
	
	[self.searchTable reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	// Return the number of rows in the section.
	if (tableView == self.menuTable) return [self.dateTimes count];
	else return [self.filteredListContent count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	// Retrieve Event object
	Event *event;
	EventDateTime *dateTime;
	
	// Retrieve the Showbag object
	if (tableView == self.menuTable) dateTime = [self.dateTimes objectAtIndex:[indexPath row]];
	else dateTime = [self.filteredListContent objectAtIndex:[indexPath row]];
		
	event = [dateTime forEvent];
	
	// Configure the cell using the object's attributes
	[self configureCell:cell withDateTime:dateTime];
    
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell withDateTime:(EventDateTime *)dateTime {
	
	[cell setBackgroundColor:[UIColor clearColor]];
	
	UIImage *bgViewImage = [UIImage imageNamed:@"table-cell-background.png"];
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bgViewImage];
	cell.backgroundView = bgView;
	[bgView release];
	
	UIImage *selBGViewImage = [UIImage imageNamed:@"table-cell-background-on.png"];
	UIImageView *selBGView = [[UIImageView alloc] initWithImage:selBGViewImage];
	cell.selectedBackgroundView = selBGView;
	[selBGView release];
	
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
	cell.textLabel.text = [[[dateTime forEvent] title] uppercaseString];
	
	cell.detailTextLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.dateFormat stringFromDate:dateTime.startDate], [self.dateFormat stringFromDate:dateTime.endDate]];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	EventDateTime *dateTime;
	
	// Retrieve the FoodVenue object
	if (tableView == self.menuTable) dateTime = [self.dateTimes objectAtIndex:[indexPath row]];
	else dateTime = [self.filteredListContent objectAtIndex:[indexPath row]];
					
	EventVC *eventVC = [[EventVC alloc] initWithNibName:@"EventVC" bundle:nil];
	[eventVC setEventDateTime:dateTime];
	[eventVC setManagedObjectContext:self.managedObjectContext];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:eventVC animated:YES];
	[eventVC release];
}


#pragma mark MY-FUNCTIONS

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


- (void)setupSubNav {
	
	/*NSMutableArray *filterTypes = [appDelegate getEventTypes];

	CGFloat btnWidth = 30.0;
	CGFloat btnHeight = 31.0;
	
	CGFloat xPos = 80.0;
	CGFloat xPadding = 10.0;
	CGFloat yPos = 4.0;
	
	
	// Create button for 'ALL'
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn setFrame:CGRectMake(xPos, yPos, btnWidth, btnHeight)];
	[btn addTarget:self action:@selector(filterEvents:) forControlEvents:UIControlEventTouchUpInside];
	[btn setBackgroundColor:[UIColor clearColor]];
	[btn setTag:-1];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all.png"] forState:UIControlStateNormal];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all-on.png"] forState:UIControlStateHighlighted];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all-on.png"] forState:UIControlStateSelected];
	[btn setBackgroundImage:[UIImage imageNamed:@"subNavButton-all-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[btn setSelected:YES];
	
	[self.selectedFilterButton setSelected:NO];
	self.selectedFilterButton = btn;
	
	// Add button to sub nav scroll view
	[self.subNavScrollView addSubview:btn];
	
	// Update xPos for next button
	xPos += (btnWidth + xPadding);
	
	NSString *imageFilename;
	NSString *selectedImageFilename;
	NSArray *stringParts;
	
	for (NSInteger i = 0; i < [filterTypes count]; i++) {
		
		NSArray *filterType = [filterTypes objectAtIndex:i];
	
		// Create the sub nav button
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(xPos, yPos, btnWidth, btnHeight)];
		[btn addTarget:self action:@selector(filterEvents:) forControlEvents:UIControlEventTouchUpInside];
		[btn setBackgroundColor:[UIColor clearColor]];
		
		[btn setTag:[[filterType objectAtIndex:0] intValue]];
		
		imageFilename = [filterType objectAtIndex:2];
		stringParts = [imageFilename componentsSeparatedByString:@"."];
		selectedImageFilename = [NSString stringWithFormat:@"%@-on.%@", [stringParts objectAtIndex:0], [stringParts objectAtIndex:1]];
								 
		[btn setBackgroundImage:[UIImage imageNamed:imageFilename] forState:UIControlStateNormal];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateHighlighted];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateSelected];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateHighlighted|UIControlStateSelected];
		
		// Add button to sub nav scroll view
		[self.subNavScrollView addSubview:btn];
	
		// Update xPos for next button
		xPos += (btnWidth + xPadding);
		
		// Update sub nav scroll view content size - using the updated xPos
		[self.subNavScrollView setContentSize:CGSizeMake(xPos, self.subNavScrollView.frame.size.height)];
	}
	*/
}


- (void)setupNavBar {

	// Add back button to nav bar
	/*CGRect btnFrame = CGRectMake(0.0, 0.0, 60.0, 30.0);
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton-Events.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	backButton.frame = btnFrame;
	
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	backItem.target = self;
	self.navigationItem.leftBarButtonItem = backItem;
	
	NSArray *stringParts = [self.selectedDate componentsSeparatedByString:@" "];
	NSString *titleImageName = [NSString stringWithFormat:@"screenTitle-%@%@.png", [stringParts objectAtIndex:0], [stringParts objectAtIndex:1]];
	UIImage *titleImage = [UIImage imageNamed:titleImageName];
	
	// Add button to Navigation Title 
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, titleImage.size.width, titleImage.size.height)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:titleImage];
	
	self.navigationItem.titleView = image;
	[image release];*/
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
	
	// Set the navigation bar's title label
	[self.navigationTitle setText:[self.selectedDate uppercaseString]];
	
	UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[searchButton addTarget:self action:@selector(startSearch:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
	searchItem.target = self;
	self.navigationItem.rightBarButtonItem = searchItem;

}


- (void)fetchEventsFromCoreData {
	
	if (!self.managedObjectContext) self.managedObjectContext = [[self appDelegate] managedObjectContext];

	// CREATE FETCH REQUEST
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
	
	// April 17 9:00 AM - 6:30 PM
	NSDate *date = [self.dateFormat dateFromString:[NSString stringWithFormat:@"%@ 12:00 AM", self.selectedDate]];
	NSDate *endDate = [date dateByAddingTimeInterval:86400];
		
	// FETCH PREDICATE
	NSPredicate *fetchPredicate;
	
	if ([self.selectedCategory length] > 0) {
		
		NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(category like[cd] %@)", self.selectedCategory];
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(ANY occursOnDays.startDate >= %@)", date];
		NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"(ANY occursOnDays.endDate < %@)", endDate];

		NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, predicate3, nil];
		
		fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
	}
	else 
		fetchPredicate = [NSPredicate predicateWithFormat:@"(ANY occursOnDays.startDate >= %@) AND (ANY occursOnDays.endDate < %@)", date, endDate];
	
	[fetchRequest setPredicate:fetchPredicate];
	
	
	// FETCH SORT DESCRIPTORS
	//if (!alphabeticallySorted)
		fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
	//else
		//fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"occursOnDays.startDate" ascending:YES]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.events = (NSMutableArray *)[self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	// Reload the table
	//[self.menuTable reloadData];
}


- (void)fetchEventDateTimesFromCoreData {
	
	if (!self.managedObjectContext) self.managedObjectContext = [[self appDelegate] managedObjectContext];
	
	// CREATE FETCH REQUEST
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"EventDateTime" 
										inManagedObjectContext:self.managedObjectContext]];
	
	/* ///////////////////////////////////////////////////////////////////////////
	 
		FETCH PREDICATE
	 
		If a Event category has been selected, then results
		must match the category as well as the day that was selected.
	 
		Otherwise, just match EventDateTimes that start on the selected day
	 */
	 NSPredicate *fetchPredicate;
	
	if ([self.selectedCategory length] > 0) {
				
		NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(forEvent.category like[cd] %@)", self.selectedCategory];
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(day = %@)", self.selectedDate];
		NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
		
		fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
	}
	
	else fetchPredicate = [NSPredicate predicateWithFormat:@"(day = %@)", self.selectedDate];
	
	[fetchRequest setPredicate:fetchPredicate];
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	
	// SORT BY: Event title or by start time
	if (alphabeticallySorted)
		fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"forEvent.title" ascending:YES]];
	else
		fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
	
	// Execute the fetch request
	NSError *error = nil;
	NSArray *tempDateTimes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	self.dateTimes = [NSMutableArray arrayWithArray:tempDateTimes];
	
	// Reload the table
	[self.menuTable reloadData];
}


- (IBAction)alphabeticalSortButtonClicked:(id)sender {

	if (!alphabeticallySorted) {
		
		UIButton *selectedButton = (UIButton *)sender;
		[selectedButton setSelected:YES];
		[selectedButton setHighlighted:NO];
		[selectedButton setUserInteractionEnabled:NO];
		
		[self.timeSortButton setSelected:NO];
		[self.timeSortButton setHighlighted:NO];
		[self.timeSortButton setUserInteractionEnabled:YES];
		
		// Sort alphabetically by venue title
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"forEvent.title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[self.dateTimes sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
		[alphaDesc release];
	
		alphabeticallySorted = !alphabeticallySorted;
		
		[self.menuTable reloadData];
	}
}


- (IBAction)timeSortButtonClicked:(id)sender {

	if (alphabeticallySorted) {
		
		UIButton *selectedButton = (UIButton *)sender;
		[selectedButton setSelected:YES];
		[selectedButton setHighlighted:NO];
		[selectedButton setUserInteractionEnabled:NO];
		
		[self.alphabeticalSortButton setSelected:NO];
		[self.alphabeticalSortButton setHighlighted:NO];
		[self.alphabeticalSortButton setUserInteractionEnabled:YES];
		
		// Sort the events by their start time
		NSSortDescriptor *timeDesc = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES selector:@selector(compare:)];
		[self.dateTimes sortUsingDescriptors:[NSArray arrayWithObject:timeDesc]];	
		[timeDesc release];
		
		alphabeticallySorted = !alphabeticallySorted;
		
		[self.menuTable reloadData];
	}
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


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
} 


- (void)retrieveJSON {
	
	NSString *docName = @"get_events.json";
	NSString *mutableXML = [self compileRequestXML];
	
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
	
	[self fetchEventDateTimesFromCoreData];
	
	[self checkEventsCount];
	
	// Hide loading view
	[self hideLoading];
	
	[fetcher release];
	fetcher = nil;
}


- (NSString *)compileRequestXML {

	// CREATE FETCH REQUEST
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"EventDateTime" inManagedObjectContext:self.managedObjectContext]];
	
	// FETCH PREDICATE
	NSPredicate *fetchPredicate;
	
	if ([self.selectedCategory length] > 0) {
		
		NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(forEvent.category like[cd] %@)", self.selectedCategory];
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(day = %@)", self.selectedDate];
		NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
		
		fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
	}
	
	else fetchPredicate = [NSPredicate predicateWithFormat:@"(day = %@)", self.selectedDate];
	
	[fetchRequest setPredicate:fetchPredicate];
	
	
	// FETCH SORT DESCRIPTORS
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"forEvent.eventID" ascending:YES]];
	
	// Execute the fetch request
	NSError *error = nil;
	NSArray *storedEvents = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	NSMutableString *mutableXML = [NSMutableString string];
	[mutableXML appendFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><request><day>%@</day>", self.selectedDate];
	
	NSString *categoryElement;
	if ([self.selectedCategory length] > 0) categoryElement = [NSString stringWithFormat:@"<category>%@</category>", self.selectedCategory];
	else categoryElement = [NSString stringWithString:@"<category />"];
	[mutableXML appendString:categoryElement];
	
	[mutableXML appendString:@"<searchTerm />"];
	
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


- (void)checkEventsCount {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
													message:@"There are no Events on today." delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
	[alert show];    
	[alert release];
}


- (void)dealloc {
	
	[alphabeticalSortButton release];
	[timeSortButton release];
	[dateTimes release];
	[dateFormat release];
	[search release]; 
	[searchTable release]; 
	[filteredListContent release];
	[managedObjectContext release];
	[loadCell release];
	[menuTable release];
	[selectedCategory release];
	[selectedDate release];
	[events release];
	[navigationTitle release];
	
    [super dealloc];
}


@end
