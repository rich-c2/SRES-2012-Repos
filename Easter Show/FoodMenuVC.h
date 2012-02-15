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
	UITextField *search;
	
	UIButton *cancelButton;
	UIButton *searchButton;

	FoodTableCell *loadCell;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;
@property (nonatomic, retain) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) IBOutlet UITextField *search;


@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *searchButton;

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
- (IBAction)startSearch:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
-(void)dismissKeyboard;


@end
