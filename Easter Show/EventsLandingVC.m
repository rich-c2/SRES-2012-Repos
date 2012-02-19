//
//  EventsLandingVC.m
//  Easter Show
//
//  Created by Richard Lee on 13/01/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "EventsLandingVC.h"
#import "CustomTabBarItem.h"
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
#import "AnnouncementVC.h"

@implementation EventsLandingVC

@synthesize managedObjectContext, searchButton;
@synthesize todaysEventsButton, fullProgramButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"events-tab-button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"events-tab-button.png"];
        self.tabBarItem = tabItem;
        [tabItem release];
        tabItem = nil;
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


#pragma AnnouncementDelegate methods

- (void)announcementCloseButtonClicked {

	[self dismissModalViewControllerAnimated:YES];
}


- (void)retrieveXML {
	
	NSString *docName = @"get_init.json";
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_SERVER_ADDRESS, docName];
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	//[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];

	
	// XML Fetcher
	fetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//init" receiver:self action:@selector(receiveResponse:)];
	[fetcher start];
}


// The API Request has finished being processed. Deal with the return data.
- (void)receiveResponse:(HTTPFetcher *)aFetcher {
    
    XMLFetcher *theXMLFetcher = (XMLFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	eventsLoaded = YES;
	
	NSMutableDictionary *initData = [NSMutableDictionary dictionary];
	
	if ([theXMLFetcher.data length] > 0) {
        
        // loop through the XPathResultNode objects that the XMLFetcher fetched
        for (XPathResultNode *node in theXMLFetcher.results) { 
			
			if ([[node name] isEqualToString:@"init"]) {
				
				for (XPathResultNode *initNode in node.childNodes) { 
					
					if ([[initNode name] isEqualToString:@"latestVersion"]) {
					
						if ([[initNode contentString] length] > 0)
							[initData setObject:[initNode contentString] forKey:[initNode name]];
					}
						
					else if ([[initNode name] isEqualToString:@"minVersion"]) {
						
						NSMutableDictionary *minVersionDict = [NSMutableDictionary dictionary];
						
						[minVersionDict setObject:[[initNode attributes] objectForKey:@"version"] forKey:@"version"];
						
						for (XPathResultNode *versionChild in initNode.childNodes) {
						
							if ([[versionChild name] isEqualToString:@"message"]) {
							
								for (XPathResultNode *messageChild in versionChild.childNodes) {
								
									if ([[messageChild name] isEqualToString:@"text"])
										[minVersionDict setObject:[messageChild contentString] forKey:[messageChild name]];
								}
							}
						}
						
						[initData setObject:minVersionDict forKey:@"minVersion"];
					}
						
					else if ([[initNode name] isEqualToString:@"offlineMode"]) {
					
						if ([[initNode contentString] length] > 0)
							[initData setObject:[initNode contentString] forKey:[initNode name]];
					}
						
					else if ([[initNode name] isEqualToString:@"lockDown"]) {
					
						[initData setObject:[[initNode attributes] objectForKey:@"enabled"] forKey:[initNode name]];
					}
					
					else if ([[initNode name] isEqualToString:@"announcement"]) {
						
						NSMutableDictionary *announcementDict = [NSMutableDictionary dictionary];
						
						[announcementDict setObject:[[initNode attributes] objectForKey:@"enabled"] forKey:@"enabled"];
						
						for (XPathResultNode *announcementChild in initNode.childNodes) {
							
							if ([[announcementChild name] isEqualToString:@"message"]) {
								
								for (XPathResultNode *messageChild in announcementChild.childNodes) {
									
									if ([[messageChild name] isEqualToString:@"text"])
										[announcementDict setObject:[messageChild contentString] forKey:[messageChild name]];
								}
							}
						}
						
						[initData setObject:announcementDict forKey:@"announcement"];
					}
				}
			}
		}	
	}
	
	// Hide loading view
	[self hideLoading];
	
	// Process the results of the get_init API response
	[self processInitData:initData];
	
	[fetcher release];
	fetcher = nil;
}


- (void)processInitData:(NSMutableDictionary *)initData {

	if ([[initData objectForKey:@"lockDown"] isEqualToString:@"True"]) {
		
		NSString *message = @"The app is currently undergoing maintenance and is out of action for the time being. Please visit the app again soon and it should be running as expected!";
	
		AnnouncementVC *announcementVC = [[AnnouncementVC alloc] initWithNibName:@"AnnouncementVC" bundle:nil];
		[announcementVC setDelegate:self];
		[announcementVC setLockDown:YES];
		[announcementVC setAnnouncementText:message];
		[self presentModalViewController:announcementVC animated:YES];
		[announcementVC release];
		
		return;
	}
	
	
	// OFFLINE MODE
	if ([[initData objectForKey:@"offlineMode"] isEqualToString:@"True"]) {
		
		[[self appDelegate] setOfflineMode:YES];
		
		return;
	}
	
	else [[self appDelegate] setOfflineMode:NO];
	
	NSArray *keys = [initData allKeys];
	
	if ([keys containsObject:@"minVersion"]) {
	
		NSMutableDictionary *minVersionDict = [initData objectForKey:@"minVersion"];
		
		// Compare the version number parsed in the dictionary to the one that this app
		CGFloat minVersion = [[minVersionDict objectForKey:@"version"] floatValue];
		CGFloat appVersion = [[self appDelegate] getAppVersion];
		
		if (minVersion > appVersion) {
			
			NSString *message = [minVersionDict objectForKey:@"text"];
		
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please upgrade" message:message 
													delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
			[alert show];    
			[alert release];
		}
	}
	
	if ([keys containsObject:@"announcement"]) {
		
		NSMutableDictionary *announcementDict = [initData objectForKey:@"announcement"];
	
		if ([[announcementDict objectForKey:@"enabled"] isEqualToString:@"True"]) {
		
			AnnouncementVC *announcementVC = [[AnnouncementVC alloc] initWithNibName:@"AnnouncementVC" bundle:nil];
			[announcementVC setDelegate:self];
			[announcementVC setAnnouncementText:[announcementDict objectForKey:@"text"]];
			[self presentModalViewController:announcementVC animated:YES];
			[announcementVC release];
			
			return;
		}
	}
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
