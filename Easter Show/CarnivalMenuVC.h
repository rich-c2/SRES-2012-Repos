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
	
	UITableView *menuTable;

	CarnivalTableCell *loadCell;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;

@property (nonatomic, retain) IBOutlet CarnivalTableCell *loadCell;


- (void)showLoading;
- (void)hideLoading;
- (void)fetchRidesFromCoreData;
- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url;
- (void)configureCell:(CarnivalTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)setupNavBar;
- (void)addCarnivaRidesToCoreData:(NSArray *)rideNodes;


@end
