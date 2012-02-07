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


static NSString* kTableCellFont = @"HelveticaNeue-Bold";
static NSString *kThumbPlaceholderAnimals = @"placeholder-events-animals-thumb.jpg";
static NSString *kThumbPlaceholderCompetitions = @"placeholder-events-competitions-thumb.jpg";
static NSString *kThumbPlaceholderEntertainment = @"placeholder-events-entertainment-thumb.jpg";

@implementation EventSelectionVC

@synthesize selectedFilterButton, dateTimes;
@synthesize menuTable, events, selectedDate, selectedCategory;
@synthesize loadCell, managedObjectContext, dateFormat;
@synthesize search, searchTable, filteredListContent;


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
	
	self.filteredListContent = [NSMutableArray array];
	
	// Initialise the date form that we are using
	// across all dates/times
	NSDateFormatter *tempDateFormat = [[NSDateFormatter alloc] init];
	[tempDateFormat setDateFormat:@"MMMM dd h:mm a"];
	self.dateFormat = tempDateFormat;
	[tempDateFormat release];
	
	// Navigation bar elements
	[self setupNavBar];
	
	alphabeticallySorted = YES;
	
	// Get the Event objects
	// By default, get them in alphabetical order
	//[self fetchEventsFromCoreData];
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
}


- (void)viewWillDisappear:(BOOL)animated {
	
    [super viewWillDisappear:animated];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[self.menuTable reloadData];
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
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:[EventTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"EventTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
    }
	
	// Retrieve Event object
	Event *event;
	EventDateTime *dateTime;
	
	// Retrieve the Showbag object
	if (tableView == self.menuTable) {
		
		//if (alphabeticallySorted)
			//event = [self.events objectAtIndex:[indexPath row]];
		//else {
			
			dateTime = [self.dateTimes objectAtIndex:[indexPath row]];
			
		//}
	}
		
	else 
		dateTime = [self.filteredListContent objectAtIndex:[indexPath row]];
		
	event = [dateTime forEvent];
	
	// Configure the cell using the object's attributes
	[self configureCell:cell withDateTime:dateTime];
    
    return cell;
}


- (void)configureCell:(EventTableCell *)cell withDateTime:(EventDateTime *)dateTime {
	
	cell.nameLabel.text = [[dateTime forEvent] title];
	cell.detailLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.dateFormat stringFromDate:dateTime.startDate], [self.dateFormat stringFromDate:dateTime.endDate]];
	
	[cell initImage];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *sectionTitle = @"All";
	
	return sectionTitle;
	
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	CGFloat footerHeight = 4.0;
	
	UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, footerHeight)];
	[returnView setBackgroundColor:[UIColor clearColor]];
	
	return [returnView autorelease];
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	CGFloat footerHeight = 4.0;
	
	return footerHeight;
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


- (void)goBack:(id)sender { 

	[self.navigationController popViewControllerAnimated:YES];

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
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"EventDateTime" inManagedObjectContext:self.managedObjectContext]];
	
	// April 17 9:00 AM - 6:30 PM
	NSDateFormatter *tempDateFormat = [[NSDateFormatter alloc] init];
	[tempDateFormat setDateFormat:@"MMMM dd"];
	
	NSDate *date = [tempDateFormat dateFromString:[NSString stringWithFormat:@"%@", self.selectedDate]];
	NSDate *endDate = [date dateByAddingTimeInterval:86400];
	
	// FETCH PREDICATE
	NSPredicate *fetchPredicate;
	
	if ([self.selectedCategory length] > 0) {
		
		NSLog(@"DATE:%@", [tempDateFormat stringFromDate:date]);
		
		NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(forEvent.category like[cd] %@)", self.selectedCategory];
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(day = %@)", self.selectedDate];
		
		//NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(startDate >= %@)", date];
		//NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"(endDate < %@)", endDate];
		
		NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil]; //, predicate3, nil];
		
		fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
	}
	else 
		fetchPredicate = [NSPredicate predicateWithFormat:@"(occursOnDays.startDate >= %@) AND (occursOnDays.endDate < %@)", date, endDate];
	
	[fetchRequest setPredicate:fetchPredicate];
	
	if (alphabeticallySorted)
		fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"forEvent.title" ascending:YES]];
	else
		fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
	
	[tempDateFormat release];
	
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
		
		// make a fetch request to get an alphabetically sorted list of data
		//[self fetchEventsFromCoreData];
		
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
		
		// make a fetch request to get a time sorted list of data
		//[self fetchEventsFromCoreData];
		
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


- (void)dealloc {
	
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
	
    [super dealloc];
}


@end
