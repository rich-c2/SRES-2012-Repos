//
//  FavouritesMenuVC.h
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouritesMenuVC : UIViewController <NSFetchedResultsControllerDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	NSMutableArray *favourites;
	NSMutableArray *deletePaths;

	UITableView *menuTable;
	UIView *actionsView;
	
	BOOL editing;
}

@property (nonatomic, retain) NSMutableArray *favourites;
@property (nonatomic, retain) NSMutableArray *deletePaths;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITableView *menuTable;
@property (nonatomic, retain) IBOutlet UIView *actionsView;

//- (void)fetchFavouritesFromCoreData;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)fetchFavouritesFromCoreData;
- (void)setupNavBar;
- (IBAction)deleteSelectedFavourites:(id)sender;


@end
