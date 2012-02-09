//
//  ShowbagsMenuVC.h
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Showbag;
@class ShowbagsTableCell;
@class JSONFetcher;

@interface ShowbagsMenuVC : UIViewController <NSFetchedResultsControllerDelegate> {
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	JSONFetcher *fetcher;
	
	BOOL viewLoaded;
	BOOL showbagsLoaded;
	BOOL loading;
	BOOL searching;
	
	UIButton *cokeOfferButton;
	
	UITableView *menuTable;
	UITableView *searchTable;
	
	NSMutableArray *filteredListContent;
	UISearchBar *search;
	
	ShowbagsTableCell *loadCell;
	
	UIButton *filterButton1;
	UIButton *filterButton2;
	UIButton *filterButton3;
	UIButton *selectedFilterButton;
	
	NSArray *priceRanges;
	
	CGFloat minPrice;
	CGFloat maxPrice;
	
	BOOL addingShowbag;
	BOOL updatingShowbag;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (assign) BOOL internetConnectionPresent;

@property (assign) BOOL viewLoaded;

@property (nonatomic, retain) IBOutlet UIButton *cokeOfferButton;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;
@property (nonatomic, retain) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) IBOutlet UISearchBar *search;

@property (nonatomic, retain) IBOutlet ShowbagsTableCell *loadCell;

@property (nonatomic, retain) NSArray *priceRanges;

@property (nonatomic, retain) IBOutlet UIButton *filterButton1;
@property (nonatomic, retain) IBOutlet UIButton *filterButton2;
@property (nonatomic, retain) IBOutlet UIButton *filterButton3;
@property (nonatomic, retain) UIButton *selectedFilterButton;


- (void)retrieveXML;
- (void)filterShowbags:(id)sender;
- (void)initPriceRanges;
- (void)setupNavBar;
- (void)showLoading;
- (void)hideLoading;
- (void)fetchShowbagsFromCoreData;
- (void)configureCell:(ShowbagsTableCell *)cell withShowbag:(Showbag *)showbag;
- (NSPredicate *)getQueryForSelectedFilter;
- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)resetSearch;

@end
