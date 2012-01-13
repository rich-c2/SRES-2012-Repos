//
//  EventsLandingVC.h
//  Easter Show
//
//  Created by Richard Lee on 13/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMLFetcher;
@class EventTableCell;

@interface EventsLandingVC : UIViewController {

	XMLFetcher *fetcher;
	
	NSManagedObjectContext *managedObjectContext;
	
	NSMutableArray *events;
	UITableView *searchTable;
	
	BOOL eventsLoaded;
	BOOL loading;
	
	UISearchBar *search;
	UIButton *todaysEventsButton;
	UIButton *fullProgramButton;
	
	EventTableCell *loadCell;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) IBOutlet UITableView *searchTable;

@property (nonatomic, retain) IBOutlet UISearchBar *search;
@property (nonatomic, retain) IBOutlet UIButton *todaysEventsButton;
@property (nonatomic, retain) IBOutlet UIButton *fullProgramButton;

@property (nonatomic, retain) IBOutlet EventTableCell *loadCell;


- (IBAction)todaysEventsButtonClicked:(id)sender;
- (IBAction)fullProgramButtonClicked:(id)sender;
- (void)showLoading;
- (void)hideLoading;
- (void)retrieveXML;
- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;


@end
