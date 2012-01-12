//
//  EventsMainVC.m
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "EventsMainVC.h"
#import "SRESAppDelegate.h"
#import "StringHelper.h"
#import "XMLFetcher.h"
#import "SVProgressHUD.h"
#import "Event.h"

@implementation EventsMainVC

@synthesize days;
@synthesize calendarContainer, managedObjectContext;

// The designated initializer.  Override if you create the controller programmatically 
//and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 
	self.title = @"What's On";
	self.tabBarItem.image = [UIImage imageNamed:@"eventsIcon.png"];
 
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupNavBar];

	[self initCalendarData];
	[self createCalendar];
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
	
	self.days = nil;
	self.calendarContainer = nil;
	self.managedObjectContext = nil;
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


- (void)initCalendarData {

	self.days = [[NSMutableArray alloc] init];
	
	NSString *month = @"April";
	
	NSString *day1 = [[NSString alloc] initWithFormat:@"%@ 14", month];
	NSString *day2 = [[NSString alloc] initWithFormat:@"%@ 15", month];
	NSString *day3 = [[NSString alloc] initWithFormat:@"%@ 16", month];
	NSString *day4 = [[NSString alloc] initWithFormat:@"%@ 17", month];
	NSString *day5 = [[NSString alloc] initWithFormat:@"%@ 18", month];
	NSString *day6 = [[NSString alloc] initWithFormat:@"%@ 19", month];
	NSString *day7 = [[NSString alloc] initWithFormat:@"%@ 20", month];
	NSString *day8 = [[NSString alloc] initWithFormat:@"%@ 21", month];
	NSString *day9 = [[NSString alloc] initWithFormat:@"%@ 22", month];
	NSString *day10 = [[NSString alloc] initWithFormat:@"%@ 23", month];
	NSString *day11 = [[NSString alloc] initWithFormat:@"%@ 24", month];
	NSString *day12 = [[NSString alloc] initWithFormat:@"%@ 25", month];
	NSString *day13 = [[NSString alloc] initWithFormat:@"%@ 26", month];
	NSString *day14 = [[NSString alloc] initWithFormat:@"%@ 27", month];
	
	NSArray *dayStrings = [NSArray arrayWithObjects:day1, day2, day3, day4, 
						   day5, day6, day7, day8, day9, day10,
						   day11, day12, day13, day14, nil];
	
	[day1 release]; 
	[day2 release]; 
	[day3 release]; 
	[day4 release]; 
	[day5 release]; 
	[day6 release]; 
	[day7 release]; 
	[day8 release]; 
	[day9 release]; 
	[day10 release];
	[day11 release]; 
	[day12 release]; 
	[day13 release]; 
	[day14 release];
	
	NSInteger startDay = 14;
	NSInteger dayInt = startDay;
	NSNumber *dayNum;
	
	for (NSInteger i = 0; i < [dayStrings count]; i++) {
		
		dayNum = [[NSNumber alloc] initWithInt:dayInt];
		
		NSArray *dayArray = [[NSArray alloc] initWithObjects:[dayStrings objectAtIndex:i], dayNum, nil];
		[dayNum release];
		
		[self.days addObject:dayArray];
		[dayArray release];
		
		dayInt++;
	}

}


- (void)createCalendar {

	CGFloat btnWidth = 40.0;
	CGFloat btnHeight = 40.0;
	CGFloat startXPos = 14.0;
	CGFloat xPos = startXPos;
	CGFloat xPadding = 2.5;
	CGFloat yPos = 43.0;
	CGFloat yPadding = 3.0;
	
	NSInteger startDay = 10;
	NSInteger calendarLength = 21;
	
	NSInteger showStart = 14;
	NSInteger showEnd = 27;
	NSInteger rowCount = 1;
	NSInteger counter = 0;
	
	BOOL enableButton;
	
	
	NSArray *imageNames = [NSArray arrayWithObjects:@"calendarButton-april10th.png", @"calendarButton-april11th.png", @"calendarButton-april12th.png",
						   @"calendarButton-april13th.png", @"calendarButton-april14th.png", @"calendarButton-april15th.png", @"calendarButton-april16th.png", 
						   @"calendarButton-april17th.png", @"calendarButton-april18th.png", @"calendarButton-april19th.png", 
						   @"calendarButton-april20th.png", @"calendarButton-april21st.png", @"calendarButton-april22nd.png", 
						   @"calendarButton-april23rd.png", @"calendarButton-april24th.png", @"calendarButton-april25th.png", 
						   @"calendarButton-april26th.png", @"calendarButton-april27th.png", @"calendarButton-april28th.png",
						   @"calendarButton-april29th.png", @"calendarButton-april30th.png", nil];
	
	
	NSString *selectedImageFilename;
	NSArray *stringParts;
	
	for (NSInteger i = startDay; i < (startDay	+ calendarLength); i++) {
		
		if ((i >= showStart) && (i <= showEnd)) {
			
			enableButton = YES;
		}
		else {
			
			enableButton = NO;
		}
		
		NSString *imageName = [imageNames objectAtIndex:counter];
		stringParts = [imageName componentsSeparatedByString:@"."];
		selectedImageFilename = [NSString stringWithFormat:@"%@-on.%@", [stringParts objectAtIndex:0], [stringParts objectAtIndex:1]];

		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(xPos, yPos, btnWidth, btnHeight)];
		[btn addTarget:self action:@selector(goToDaysEvents:) forControlEvents:UIControlEventTouchUpInside];
		
		[btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateHighlighted];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateSelected];
		[btn setBackgroundImage:[UIImage imageNamed:selectedImageFilename] forState:UIControlStateHighlighted|UIControlStateSelected];
		
		[btn setTag:i];
		[btn setEnabled:enableButton];
		[btn setAdjustsImageWhenDisabled:NO];
	
		[self.calendarContainer addSubview:btn];
		
		xPos += (btnWidth + xPadding);
		
		if (rowCount == 7) {
			
			rowCount = 1;
			xPos = startXPos;
			yPos += (btnHeight + yPadding);
		}
		else rowCount++;
		
		counter++;
	}
}


- (void)goToDaysEvents:(id)sender {
	
	//UIButton *selectedBtn = (UIButton *)sender;

	/*EventSelectionVC *eventSelectionVC = [[EventSelectionVC alloc] initWithNibName:@"EventSelectionVC" bundle:nil];
	[eventSelectionVC setSelectedDate:[self getDayStringUsingInt:selectedBtn.tag]];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:eventSelectionVC animated:YES];
	[eventSelectionVC release];*/

}


- (void)setupNavBar {
	
	// Add button to Navigation Title 
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 123.0, 22.0)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:[UIImage imageNamed:@"screenTitle-whatsOn.png"]];
	
	self.navigationItem.titleView = image;
	[image release];

}
	 

- (NSString *)getDayStringUsingInt:(NSInteger)dayInt {

	for (NSInteger i = 0; i < [self.days count]; i++) {
	
		NSArray *dayArray = [self.days objectAtIndex:i];
		
		NSInteger dayArrayInt = [[dayArray objectAtIndex:1] intValue];
		
		if (dayArrayInt == dayInt) return [dayArray objectAtIndex:0];
	
	}
	
	return nil;
}


- (NSString *)replaceHtmlEntities:(NSString *)htmlCode {
	
    NSMutableString *temp = [NSMutableString stringWithString:htmlCode];
	
    [temp replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
    [temp replaceOccurrencesOfString:@"&Agrave;" withString:@"À" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Aacute;" withString:@"Á" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Acirc;" withString:@"Â" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Atilde;" withString:@"Ã" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Auml;" withString:@"Ä" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Aring;" withString:@"Å" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&AElig;" withString:@"Æ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ccedil;" withString:@"Ç" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Egrave;" withString:@"È" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Eacute;" withString:@"É" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ecirc;" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Euml;" withString:@"Ë" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Igrave;" withString:@"Ì" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Iacute;" withString:@"Í" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Icirc;" withString:@"Î" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Iuml;" withString:@"Ï" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ETH;" withString:@"Ð" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ntilde;" withString:@"Ñ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ograve;" withString:@"Ò" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Oacute;" withString:@"Ó" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ocirc;" withString:@"Ô" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Otilde;" withString:@"Õ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ouml;" withString:@"Ö" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Oslash;" withString:@"Ø" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ugrave;" withString:@"Ù" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Uacute;" withString:@"Ú" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ucirc;" withString:@"Û" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Uuml;" withString:@"Ü" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Yacute;" withString:@"Ý" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&THORN;" withString:@"Þ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&szlig;" withString:@"ß" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&agrave;" withString:@"à" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&aacute;" withString:@"á" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&acirc;" withString:@"â" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&atilde;" withString:@"ã" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&auml;" withString:@"ä" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&aring;" withString:@"å" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&aelig;" withString:@"æ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ccedil;" withString:@"ç" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&egrave;" withString:@"è" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&eacute;" withString:@"é" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ecirc;" withString:@"ê" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&euml;" withString:@"ë" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&igrave;" withString:@"ì" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&iacute;" withString:@"í" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&icirc;" withString:@"î" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&iuml;" withString:@"ï" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&eth;" withString:@"ð" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ntilde;" withString:@"ñ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ograve;" withString:@"ò" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&oacute;" withString:@"ó" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ocirc;" withString:@"ô" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&otilde;" withString:@"õ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ouml;" withString:@"ö" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&oslash;" withString:@"ø" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ugrave;" withString:@"ù" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&uacute;" withString:@"ú" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ucirc;" withString:@"û" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&uuml;" withString:@"ü" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&yacute;" withString:@"ý" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&thorn;" withString:@"þ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&yuml;" withString:@"ÿ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
	
	
    return [NSString stringWithString:temp];
	
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
} 

- (void)dealloc {
	
	[days release];
	[calendarContainer release];
	[progressContainer release];
	[managedObjectContext release];
	
    [super dealloc];
}


@end
