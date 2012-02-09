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
#import "XMLFetcher.h"

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
	/*if (!eventsLoaded && !loading) {
		
		[self showLoading];
		
		[self retrieveXML];
	}*/
}


- (void)retrieveXML {
	
	NSString *docName = @"get_init.json";
	//http://sres2012.supergloo.net.au/api/get_foodvenues.json
	
	//NSString *mutableXML = [self compileRequestXML];
	
	//NSLog(@"XML:%@", mutableXML);
	
	// Change the string to NSData for transmission
	//NSData *requestBody = [mutableXML dataUsingEncoding:NSASCIIStringEncoding];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", @"http://sres2012.supergloo.net.au/api/", docName];
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	//[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];
	//[request setHTTPBody:requestBody];
	
	// JSONFetcher
	/*fetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedFeedResponse:)];
	[fetcher start];*/
	
	// XML Fetcher
	fetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//versions" receiver:self action:@selector(receivedResponse:)];
	[fetcher start];
}


// Example fetcher response handling
- (void)receivedFeedResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
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
	
	// Hide loading view
	[self hideLoading];
	
	[fetcher release];
	fetcher = nil;
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
			
			if ([[node name] isEqualToString:@"init"]) {
				
				for (XPathResultNode *initNode in node.childNodes) { 
					
					NSMutableDictionary *initData = [NSMutableDictionary dictionary];
					
					// Store the showbag's ID
					/*[initData setObject:[[offerNode attributes] objectForKey:@"id"] forKey:@"id"];
					
					// Store the rest of the showbag's attributes
					for (XPathResultNode *offerChild in offerNode.childNodes) {
						
						if ([[offerChild contentString] length] > 0)
							[offerData setObject:[offerChild contentString] forKey:[offerChild name]];
					}
					
					// Store Offer data in Core Data persistent store
					[Offer offerWithOfferData:offerData inManagedObjectContext:self.managedObjectContext];*/
				}
			}
		}		
	}
	
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
