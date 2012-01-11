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


static NSString* kTableCellFont = @"Arial-BoldMT";
static NSString *kCellThumbPlaceholder = @"placeholder-showbags-thumb.jpg";

@implementation ShowbagsMenuVC

@synthesize loadingSpinner, internetConnectionPresent, cokeOfferButton, showbags, menuTable;
@synthesize priceRanges, loadingView, viewLoaded;
@synthesize rssParser, currentAttribute, cancelThread, tempShowbag;
@synthesize filterButton1, filterButton2, filterButton3, selectedFilterButton;
@synthesize loadCell;
@synthesize downloads;

@synthesize idString, titleString, descriptionString;
@synthesize imageURLString, thumbURLString, rrpString;
@synthesize priceString, versionString;


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
	
	appDelegate = (SRESAppDelegate *)[[UIApplication sharedApplication] delegate];

	[self setupNavBar];
	
	[self.filterButton1 setBackgroundImage:[UIImage imageNamed:@"showbagFilter-under10-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[self.filterButton2 setBackgroundImage:[UIImage imageNamed:@"showbagFilter-10-17-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[self.filterButton3 setBackgroundImage:[UIImage imageNamed:@"showbagFilter-over17-on.png"] forState:UIControlStateHighlighted|UIControlStateSelected];
	
	[self.filterButton1 setSelected:YES];
	
	[self.selectedFilterButton setSelected:NO];
	self.selectedFilterButton = self.filterButton1;
	
	// Clear coloured cell separators
	[self.menuTable setSeparatorColor:[UIColor clearColor]];
	
	[self initPriceRanges];
	
	minPrice = 0.0;
	maxPrice = 9.99;
	
	[self.loadingView setHidden:NO];
	[self.loadingSpinner startAnimating];
	
	// Init downloads array
	self.downloads = [[NSMutableArray alloc] init];
	
	// Determine network/internet availability
	reach = [[Reachability reachabilityForInternetConnection] retain];
	NetworkStatus status = [reach currentReachabilityStatus];
    self.internetConnectionPresent = [appDelegate boolFromNetworkStatus:status];
	
	if ([self.showbags count] == 0) {
		
		self.filterButton1.enabled = NO;
		self.filterButton2.enabled = NO;
		self.filterButton3.enabled = NO;
	}
	
	// Sort events alphabetically
	NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"showbagTitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.showbags sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
	[alphaDesc release];
	
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
	
	self.loadingView = nil;
	self.idString = nil; 
	self.titleString = nil; 
	self.descriptionString = nil;
	self.imageURLString, 
	self.thumbURLString = nil; 
	self.rrpString = nil;
	self.priceString = nil; 
	self.versionString = nil;
	self.currentAttribute = nil;
	
	self.loadingSpinner = nil;
	self.menuTable = nil;
	self.showbags = nil;
	self.priceRanges = nil;
	self.rssParser = nil;
	self.downloads = nil;
}


- (void)viewWillAppear:(BOOL)animated {
	
	//[self.menuTable reloadData];
}


- (void)viewDidAppear:(BOOL)animated {
	
	// If this view has not already been loaded 
	//(i.e not coming back from an Offer detail view)
	if (!self.viewLoaded) {

		BOOL loaded = [appDelegate isShowbagsXMLLoaded];
		if ((self.internetConnectionPresent) && (!loaded)) {
			
			[self retrieveXML];
			
			//[NSThread detachNewThreadSelector:@selector(retrieveXML)toTarget:self withObject:nil];
		}
		else {
			
			self.showbags = [appDelegate getShowbags:minPrice maxPrice:maxPrice startIndex:0];
			
			// Stop loading animation
			[self.loadingSpinner stopAnimating];
			[self.loadingView setHidden:YES];
			
			self.filterButton1.enabled = YES;
			self.filterButton2.enabled = YES;
			self.filterButton3.enabled = YES;
			
			// This view has been loaded now
			self.viewLoaded = YES;
			
			[self.menuTable reloadData];
		}
	}
}


#pragma mark ImageDownloadDelegate Methods
- (void)downloadDidFinishDownloading:(ImageDownload *)download {
	
	// Get the index of where this image is in the table
    NSUInteger index = [self getIndexOfItemWithID:download.downloadID]; 
	
	// Get the associated Offer object
	Showbag *showbag = [self getShowbagWithID:download.downloadID];
	
	// Save the image to the Offer object
	[showbag setShowbagThumb:download.image];
	
	// Create a user friendly filename from the URL path
	NSString *filename = [appDelegate extractImageNameFromURLString:download.urlString];
	
	// Save image to the relevant sub directory of Documents/
	[appDelegate saveShowbagsImageToDocumentsWithID:[[showbag showbagID] intValue] imageName:filename obj:download.image];
	
	NSLog(@"SHOWBAG DOWNLOAD FINISHED:%i|%i", index, [[showbag showbagID] intValue]);
    NSUInteger indices[] = {0, index};
    NSIndexPath *path = [[NSIndexPath alloc] initWithIndexes:indices length:2];
    [self.menuTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    [path release];
    download.delegate = nil;
	
	[self.downloads removeObject:download];
}


- (void)download:(ImageDownload *)download didFailWithError:(NSError *)error {
	
    NSLog(@"Error: %@", [error localizedDescription]);
	
	// Get the index of where this image is in the table
    NSUInteger index = [self getIndexOfItemWithID:download.downloadID]; 
	
	// Get the associated Offer object
	Showbag *showbag = [self getShowbagWithID:download.downloadID];
	
	UIImage *placeholder = [UIImage imageNamed:kCellThumbPlaceholder];
	
	// Save the image to the Offer object
	[showbag setShowbagThumb:placeholder];
	
	NSLog(@"PLACEHOLDER INSERTED FOR SHOWBAG:%i|%i", index, [[showbag showbagID] intValue]);
    NSUInteger indices[] = {0, index};
    NSIndexPath *path = [[NSIndexPath alloc] initWithIndexes:indices length:2];
    [self.menuTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    [path release];
    download.delegate = nil;
	
	[self.downloads removeObject:download];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	NSInteger showbagsCount = [appDelegate getShowbagsCountForRange:minPrice maxPrice:maxPrice];
	
	if ([self.showbags count] == 0) return 0;
    else if ([self.showbags count] < showbagsCount) return ([self.showbags count] + 1);
	else return [self.showbags count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShowbagsTableCell *cell = (ShowbagsTableCell *)[tableView dequeueReusableCellWithIdentifier:[ShowbagsTableCell reuseIdentifier]];
	
    if (cell == nil) {
		
        [[NSBundle mainBundle] loadNibNamed:@"ShowbagsTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
    }
	
	NSString *cellDescription;
	
	if ([self.showbags count] == 0){
		return cell;
	}
	else if (indexPath.row == [self.showbags count]){
		
		NSInteger showbagsCount = [appDelegate getShowbagsCountForRange:minPrice maxPrice:maxPrice];
		
		if ([self.showbags count] < showbagsCount) {
		
			cellDescription = @"";
			cell.nameLabel.font = [UIFont fontWithName:kTableCellFont size:15.0];
			cell.nameLabel.text = @"LOAD MORE...";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell.cellSpinner stopAnimating];
			[cell.cellSpinner setHidden:YES];
			cell.dateLable.text = cellDescription;
			cell.thumbView.image = [UIImage imageNamed:kCellThumbPlaceholder];
		}
	}
	else {
		
		// Configure the cell...
		Showbag *showbag = [self.showbags objectAtIndex:[indexPath row]];
		cellDescription = [showbag showbagDescription];
		if ([cellDescription length] == 0) cellDescription = @"";
		
		UIImage *thumb;
		
		thumb = [showbag showbagThumb];
		
		if (thumb == nil) {
			
			// Get thumbURL
			NSString *thumbURL = [showbag thumbURL];
			
			// get user friendly name for image e.g. 'product1.jpg'
			NSString *filename = [appDelegate extractImageNameFromURLString:thumbURL];
			
			thumb = [UIImage imageNamed:filename];
			
			if (thumb == nil) {
				
				// Check Documents/
				thumb = [appDelegate getImageForShowbagWithID:[[showbag showbagID] intValue] image:filename];
				
				if (thumb == nil) {
					
					if (self.internetConnectionPresent && ([thumbURL length] != 0)) {
						
						// Download Image from URL
						ImageDownload *download = [[ImageDownload alloc] init];
						download.urlString = thumbURL;
						download.downloadID = [[showbag showbagID] intValue];
						thumb = download.image;
						
						[cell.cellSpinner startAnimating];
						download.delegate = self;
						
						[self.downloads addObject:download];
						[download release];
					}
					else thumb = [UIImage imageNamed:kCellThumbPlaceholder];
				}
				else [showbag setShowbagThumb:thumb];
			}
			else [showbag setShowbagThumb:thumb];
		}
		else [cell.cellSpinner stopAnimating];
		
		
		cell.nameLabel.text = [showbag showbagTitle];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.nameLabel.font = [UIFont fontWithName:kTableCellFont size:15.0];
		cell.thumbView.image = thumb;
		cell.dateLable.text = cellDescription;
	}
	
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 303.0, 32.0)];
	[returnView setBackgroundColor:[UIColor clearColor]];
	
	return [returnView autorelease];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 32.0;
	
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
	
	if ([self.showbags count] == 0){
		return;
	} else if (indexPath.row == [self.showbags count]) {
		
		NSInteger startIndex = ([self.showbags count]);
		NSMutableArray *moreShowbags = [appDelegate getShowbags:minPrice maxPrice:maxPrice startIndex:startIndex];
		NSArray *more = [NSArray arrayWithArray:moreShowbags];
		[self.showbags addObjectsFromArray:more];
		
		// Sort events alphabetically
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"showbagTitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[self.showbags sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
		[alphaDesc release];
		
		[self.menuTable reloadData];
	}
	else {
		
		Showbag *showbag = [self.showbags objectAtIndex:[indexPath row]];
		
		ShowbagVC *showbagVC = [[ShowbagVC alloc] initWithNibName:@"ShowbagVC" bundle:nil];
		[showbagVC setShowbag:showbag];
		//[showbagVC setMinPrice:[NSNumber numberWithFloat:minPrice]];
		//[showbagVC setMaxPrice:[NSNumber numberWithFloat:maxPrice]];
		//[showbagVC setEnableQuickSelection:YES];
		
		// Pass the selected object to the new view controller.
		[self.navigationController pushViewController:showbagVC animated:YES];
		[showbagVC release];
	}
}


/* XML PARSING FUNCTIONS *****************************************************************************************/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	//NSLog(@"STARTED:%@", elementName);
	
	NSMutableString *tmpCurElement = [[NSMutableString alloc] initWithString:elementName];
	[self setCurrentAttribute:tmpCurElement];
	[tmpCurElement release];
	tmpCurElement = nil;
	
	if (cancelThread) {
		[pool release];
		return;
	}
	else {
				
		if ([elementName isEqualToString:@"add"]) {
			
			addingShowbag = YES;
			updatingShowbag = NO;
		}
		
		if ([elementName isEqualToString:@"update"]) {
			
			updatingShowbag = YES;
			addingShowbag = NO;
		}
		
		if ([elementName isEqualToString:@"remove"]) {
			
			updatingShowbag = NO;
			addingShowbag = NO;
		}
		
		if ([elementName isEqualToString:@"showbag"]) {
			
			NSString *tmpIDString = [[NSString alloc] initWithString:[attributeDict objectForKey:@"id"]];
			[self setIdString:tmpIDString];
			[tmpIDString release];
			tmpIDString = nil;
			
			NSInteger idInt = [idString intValue];
			currentID = idInt;
			
			NSMutableString *tmpTitle = [[NSMutableString alloc] init];
			[self setTitleString:tmpTitle];
			[tmpTitle release];
			tmpTitle = nil;
			
			NSMutableString *tmpDesc = [[NSMutableString alloc] init];
			[self setDescriptionString:tmpDesc];
			[tmpDesc release];
			tmpDesc = nil;
			
			NSMutableString *tmpImage = [[NSMutableString alloc] init];
			[self setImageURLString:tmpImage];
			[tmpImage release];
			tmpImage = nil;
			
			NSMutableString *tmpThumb = [[NSMutableString alloc] init];
			[self setThumbURLString:tmpThumb];
			[tmpThumb release];
			tmpThumb = nil;
			
			NSMutableString *tmpRrp = [[NSMutableString alloc] init];
			[self setRrpString:tmpRrp];
			[tmpRrp release];
			tmpRrp = nil;
			
			NSMutableString *tmpPrice = [[NSMutableString alloc] init];
			[self setPriceString:tmpPrice];
			[tmpPrice release];
			tmpPrice = nil;
			
			NSMutableString *tmpVersion = [[NSMutableString alloc] init];
			[self setVersionString:tmpVersion];
			[tmpVersion release];
			tmpVersion = nil;
		}
	}
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	if (cancelThread) {
		[pool release];
		return;
	}
	else {
		
		//NSLog(@"FOUND:%@", string);
		if (self.currentAttribute) {
			
			NSString *decodedString = [NSString stringWithFormat:@"%i", currentID];
			
			@try {
				
				decodedString = [appDelegate replaceHtmlEntities:string];
				
				NSLog(@"decodedString:%@", decodedString);
			}
			@catch (NSException* ex) {
				
				NSLog(@"decodedString failed:%i", currentID);
			}
			
			//[self.currentAttribute appendString:decodedString];
			
			if ([self.currentAttribute isEqualToString:@"title"])
				[self.titleString appendString:decodedString];			
			else if ([self.currentAttribute isEqualToString:@"description"]) 
				[self.descriptionString appendString:decodedString];
			else if ([self.currentAttribute isEqualToString:@"price"]) 
				[self.priceString appendString:decodedString];
			else if ( [self.currentAttribute isEqualToString:@"rrp"]) 
				[self.rrpString appendString:decodedString];
			else if ( [self.currentAttribute isEqualToString:@"imageURL"]) 
				[self.imageURLString appendString:decodedString];
			else if ( [self.currentAttribute isEqualToString:@"thumbURL"]) 
				[self.thumbURLString appendString:decodedString];
			else if ([self.currentAttribute isEqualToString:@"version"]) 
				[self.versionString appendString:decodedString];
		}
	}
}


- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	
	
	if (cancelThread) {
		[pool release];
		return;
	}
	else {
		
		if (self.currentAttribute) {
			
			NSString *decodedString = [NSString stringWithFormat:@"%i", currentID];
			
			@try {
				
				NSString *cDataString = [[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease];
				NSLog(@"FOUND cDataString:%@", cDataString);
				
				decodedString = [appDelegate replaceHtmlEntities:cDataString];
				
				NSLog(@"decodedString:%@", decodedString);
			}
			@catch (NSException* ex) {
				
				NSLog(@"decodedString failed:%i", currentID);
			}
			
			//[self.currentAttribute appendString:decodedString];
			
			if ([self.currentAttribute isEqualToString:@"title"])
				[self.titleString appendString:decodedString];			
			else if ([self.currentAttribute isEqualToString:@"description"]) 
				[self.descriptionString appendString:decodedString];
			else if ([self.currentAttribute isEqualToString:@"price"]) 
				[self.priceString appendString:decodedString];
			else if ( [self.currentAttribute isEqualToString:@"rrp"]) 
				[self.rrpString appendString:decodedString];
			else if ( [self.currentAttribute isEqualToString:@"imageURL"]) 
				[self.imageURLString appendString:decodedString];
			else if ( [self.currentAttribute isEqualToString:@"thumbURL"]) 
				[self.thumbURLString appendString:decodedString];
			else if ([self.currentAttribute isEqualToString:@"version"]) 
				[self.versionString appendString:decodedString];
		}
	}
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if (cancelThread) {
		[pool release];
		return;
	}
	else {
		
		if ([elementName isEqualToString:@"showbag"]) {
			
			NSInteger idInt = [self.idString intValue];
			
			NSString *tmpTitle = [self.titleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *tmpDescription = [self.descriptionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *tmpImage = [self.imageURLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *tmpThumb = [self.thumbURLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			double tmpRRPrice = [[self.rrpString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] doubleValue];
			double tmpPrice = [[self.priceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] doubleValue];
			
			NSInteger vInt = [self.versionString intValue];
			
			Showbag *_showbag = [[[Showbag alloc] initWithID:idInt] autorelease];
			[_showbag setShowbagTitle:tmpTitle];
			[_showbag setShowbagDescription:tmpDescription];
			[_showbag setImageURL:tmpImage];
			[_showbag setThumbURL:tmpThumb];
			[_showbag setShowbagRRPrice:tmpRRPrice];
			[_showbag setShowbagPrice:tmpPrice];
			
			[_showbag setVersion:vInt];
			
			if (addingShowbag) [appDelegate addShowbag:_showbag];
			else {	
				
				if (updatingShowbag) [appDelegate updateShowbag:_showbag];
				else if (!updatingShowbag) [appDelegate deleteShowbag:[[_showbag showbagID] intValue]];
			}
		}
	}
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	[self performSelectorOnMainThread:@selector(loadingFinished) withObject:nil waitUntilDone:false];
	
	if (cancelThread) {
		[pool release];
		return;
	}
	else {
		[parser abortParsing];
		
	}
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // If the number of earthquake records received is greater than kMaximumNumberOfEarthquakesToParse, we abort parsing.
    // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
    // how we distinguish real errors encountered by the parser.
	
	NSLog(@"PARSER ERROR:%@", parseError);
	[parser abortParsing];
}


/* ======================================================================================================*/


- (void)retrieveXML {
	
	pool = [[NSAutoreleasePool alloc] init];
	
	NSString *docName = @"showbags.xml";
	NSInteger lastShowbagID = [appDelegate getLastShowbagID];
	NSString *queryString = [NSString stringWithFormat:@"?id=%i", lastShowbagID];
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@", appDelegate.xmlDomainName, docName, queryString];
	NSLog(@"SHOWBAGS URL:%@", urlString);
	
	[self loadXMLAtURL:urlString];
	
	[self performSelectorOnMainThread:@selector(loadingFinished) withObject:nil waitUntilDone:false];
	
	[pool release];
	
}


- (void)loadXMLAtURL:(NSString *)_urlString {
	
	NSString *formattedURL = [_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"FORMATTED URL:%@", formattedURL);
	
	self.rssParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:formattedURL]];
	[self.rssParser setDelegate:self];
	
	BOOL success = [self.rssParser parse];
	
	if(success) NSLog(@"No Errors - SHOWBAGS LOADED");
	else NSLog(@"Error parsing xml - SHOWBAGS"); 
	
}


- (void)loadingFinished {
	
	NSLog(@"LOADING FINISHED");
	
	// Stop loading animation
	[self.loadingSpinner stopAnimating];
	[self.loadingView setHidden:YES];
	
	if ([self.showbags count] > 0) [self.showbags removeAllObjects];
	
	minPrice = 0.0;
	maxPrice = 9.99;
	
	self.showbags = [appDelegate getShowbags:minPrice maxPrice:maxPrice startIndex:0];
	
	if ([self.showbags count] > 0) {
		
		self.filterButton1.enabled = YES;
		self.filterButton2.enabled = YES;
		self.filterButton3.enabled = YES;
	}
	
	// Sort events alphabetically
	NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"showbagTitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.showbags sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
	[alphaDesc release];
	
	// This view has been loaded now
	self.viewLoaded = YES;
	
	[self.menuTable reloadData];
	
	// Set 'global var' that we've loaded Showbags
	[appDelegate showbagsXMLLoaded];
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

	self.priceRanges = [[NSArray alloc] initWithObjects:range1, range2, range3, nil];
	[range1 release];
	[range2 release];
	[range3 release];
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
	
	// Stop any current image downloads
	[self disableDownloads];
	
	if ([self.showbags count] > 0) [self.showbags removeAllObjects];
	
	self.showbags = [appDelegate getShowbags:minPrice maxPrice:maxPrice startIndex:0];
	
	// Sort events alphabetically
	NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"showbagTitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.showbags sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
	[alphaDesc release];
	
	[self.menuTable reloadData];
}


- (NSInteger)getIndexOfItemWithID:(NSInteger)_showbagID {
	
	for (NSInteger i = 0; i < [self.showbags count]; i++) {
		
		Showbag *showbag = [self.showbags objectAtIndex:i];
		NSInteger showbagID = [[showbag showbagID] intValue];
		
		if (showbagID == _showbagID) return i;
	}
	
	return -1;
}


- (Showbag *)getShowbagWithID:(NSInteger)_showbagID {
	
	Showbag *showbag;
	
	for (NSInteger i = 0; i < [self.showbags count]; i++) {
		
		showbag = [self.showbags objectAtIndex:i];
		NSInteger showbagID = [[showbag showbagID] intValue];
		
		if (showbagID == _showbagID) return showbag;
	}
	
	showbag = nil;
	return showbag;
	
}


- (void)setupNavBar {
	
	// Add button to Navigation Title 
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 118.0, 22.0)];
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
	self.navigationItem.leftBarButtonItem = backItem;
	
	self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(132, 22, 37, 37)];
	[self.loadingSpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.loadingView addSubview:self.loadingSpinner];
	[self.loadingSpinner release];
}


// Stop any ImageDownloads that are still downloading
- (void)disableDownloads {
	
	for (NSInteger i = 0; i < [self.downloads count]; i++) {
		
		ImageDownload *imageDownload = [self.downloads objectAtIndex:i];
		imageDownload.delegate = nil;
	}
}


- (void)dealloc {
	
	[loadingView release];
	[idString release]; 
	[titleString release]; 
	[descriptionString release];
	[imageURLString release]; 
	[thumbURLString release];
	[rrpString release];
	[priceString release]; 
	[versionString release];
	[currentAttribute release];
	
	[loadingSpinner release];
	[menuTable release];
	[showbags release];
	[priceRanges release];
	[rssParser release];
	[downloads release];
    [super dealloc];
}


@end
