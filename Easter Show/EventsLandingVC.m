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
#import "EventsSearchVC.h"
#import "EventTableCell.h"
#import "EventVC.h"
#import "EventsMainVC.h"
#import "JSONFetcher.h"
#import "SBJson.h"

@implementation EventsLandingVC

@synthesize managedObjectContext, searchButton;
@synthesize todaysEventsButton, fullProgramButton;

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
    
	// Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
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
	self.searchButton = nil;
	self.todaysEventsButton = nil; 
	self.fullProgramButton = nil;
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


- (void)retrieveXML {
	
	// TEST CODE
	//NSString *docName = @"events.xml";
	//NSString *docName = @"events-summaries.xml";
	NSString *docName = @"getEvents.json";
	
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


- (IBAction)searchButtonClicked:(id)sender {

	EventsSearchVC *eventsSearchVC = [[EventsSearchVC alloc] initWithNibName:@"EventsSearchVC" bundle:nil];
	[eventsSearchVC setManagedObjectContext:self.managedObjectContext];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:eventsSearchVC animated:YES];
	[eventsSearchVC release];
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


- (void)dealloc {
	
	[managedObjectContext release];
	[searchButton release];
	[todaysEventsButton release];
	[fullProgramButton release];
	
    [super dealloc];
}


@end
