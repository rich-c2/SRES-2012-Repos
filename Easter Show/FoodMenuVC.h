//
//  FoodMenuVC.h
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;
@class FoodTableCell;
@class FoodVenue;

@interface FoodMenuVC : UIViewController <NSFetchedResultsControllerDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	JSONFetcher *fetcher;

	BOOL venuesLoaded;
	BOOL loading;
	BOOL searching;

	UITableView *menuTable;
	UITableView *searchTable;

	NSMutableArray *filteredListContent;
	UISearchBar *search;

	FoodTableCell *loadCell;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;
@property (nonatomic, retain) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) IBOutlet UISearchBar *search;

@property (nonatomic, retain) IBOutlet FoodTableCell *loadCell;


- (void)retrieveXML;
- (void)showLoading;
- (void)hideLoading;
- (void)fetchVenuesFromCoreData;
- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)resetSearch;
- (void)configureCell:(FoodTableCell *)cell withFoodVenue:(FoodVenue *)foodVenue;
- (void)setupNavBar;
- (IBAction)goBack:(id)sender;



@end
