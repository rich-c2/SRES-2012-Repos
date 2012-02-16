//
//  CarnivalMenuVC.h
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarnivalTableCell;

@interface CarnivalMenuVC : UIViewController <NSFetchedResultsControllerDelegate> {
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	BOOL viewLoaded;
	
	UITableView *menuTable;

	CarnivalTableCell *loadCell;
	
	UIButton *cokeFilterButton;
	UIButton *kidsFilterButton;
	
	BOOL viewingCoke;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;

@property (nonatomic, retain) IBOutlet CarnivalTableCell *loadCell;

@property (nonatomic, retain) IBOutlet UIButton *cokeFilterButton;
@property (nonatomic, retain) IBOutlet UIButton *kidsFilterButton;


- (void)showLoading;
- (void)hideLoading;
- (void)fetchRidesFromCoreData;
- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url;
- (void)configureCell:(CarnivalTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)setupNavBar;
- (void)addCarnivaRidesToCoreData:(NSArray *)rideNodes;
- (IBAction)goBack:(id)sender;
- (NSPredicate *)getPredicateForSelectedFilter;

- (IBAction)cocaColaCarnivalButtonClicked:(id)sender;
- (IBAction)kidsCarnivalButtonClicked:(id)sender;

@end
