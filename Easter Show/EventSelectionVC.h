//
//  EventSelectionVC.h
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRESAppDelegate.h"

typedef enum  {
	SelectionModeAll = -1,
	SelectionModeEntertainment = 1,
	SelectionModeAnimals = 2,
	SelectionModeCompetitions = 3 
} SelectionMode;

@class EventTableCell;
@class Event;

@interface EventSelectionVC : UIViewController {

	NSManagedObjectContext *managedObjectContext;	
	
	UIButton *selectedFilterButton;
	UITableView *menuTable;
	NSMutableArray *events;
	NSString *selectedDate;
	NSString *selectedCategory;
	
	NSMutableArray *filteredListContent;
	UITableView *searchTable;
	UISearchBar *search;
	
	BOOL alphabeticallySorted;
		
	EventTableCell *loadCell;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIButton *selectedFilterButton;
@property (nonatomic, retain) IBOutlet UITableView *menuTable;
@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSString *selectedDate;
@property (nonatomic, retain) NSString *selectedCategory;

@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) IBOutlet UISearchBar *search;

@property (nonatomic, retain) IBOutlet EventTableCell *loadCell;

- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url;
- (void)setupSubNav;
- (void)goBack:(id)sender;
- (void)setupNavBar;
- (void)configureCell:(EventTableCell *)cell withEvent:(Event *)event;
- (void)fetchEventsFromCoreData;
- (IBAction)alphabeticalSortButtonClicked:(id)sender;
- (IBAction)timeSortButtonClicked:(id)sender;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)resetSearch;


@end