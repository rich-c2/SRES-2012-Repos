//
//  EventsSearchVC.h
//  Easter Show
//
//  Created by Richard Lee on 8/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;
@class EventTableCell;
@class EventDateTime;

@interface EventsSearchVC : UIViewController<NSFetchedResultsControllerDelegate> {
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	JSONFetcher *fetcher;
	
	NSMutableArray *events;	
	UITableView *searchTable;
	NSDateFormatter *dateFormat;
	
	BOOL eventsLoaded;
	BOOL loading;
	
	UISearchBar *search;
	UITextField *searchField;
	
	EventTableCell *loadCell;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) NSDateFormatter *dateFormat;

@property (nonatomic, retain) IBOutlet UISearchBar *search;
@property (nonatomic, retain) IBOutlet UITextField *searchField;

@property (nonatomic, retain) IBOutlet EventTableCell *loadCell;

- (void)showLoading;
- (void)hideLoading;
- (void)retrieveXML;
//- (void)resetSearch;
//- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)fetchDateTimes;
- (void)configureCell:(UITableViewCell *)cell withEvent:(EventDateTime *)dateTime;
- (IBAction)goBack:(id)sender;
- (void)dismissKeyboard;
- (NSString *)compileRequestXML;

@end
