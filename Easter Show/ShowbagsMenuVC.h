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
	NSMutableArray *filteredListContent;
	NSArray *priceRanges;
	
	JSONFetcher *fetcher;
	
	BOOL showbagsLoaded;
	BOOL loading;
	BOOL searching;
		
	UITableView *menuTable;
	UITableView *searchTable;
	
	UITextField *search;
	
	ShowbagsTableCell *loadCell;
	
	UIButton *filterButton1;
	UIButton *filterButton2;
	UIButton *filterButton3;
	UIButton *cancelButton;
	UIButton *searchButton;
	
	CGFloat minPrice;
	CGFloat maxPrice;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) NSArray *priceRanges;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;
@property (nonatomic, retain) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) IBOutlet UITextField *search;

@property (nonatomic, retain) IBOutlet ShowbagsTableCell *loadCell;

@property (nonatomic, retain) IBOutlet UIButton *filterButton1;
@property (nonatomic, retain) IBOutlet UIButton *filterButton2;
@property (nonatomic, retain) IBOutlet UIButton *filterButton3;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *searchButton;


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
- (IBAction)goBack:(id)sender;
- (IBAction)startSearch:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
-(void)dismissKeyboard;

@end
