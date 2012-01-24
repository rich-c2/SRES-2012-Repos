//
//  ShoppingMenuVC.h
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShoppingTableCell;

@interface ShoppingMenuVC : UIViewController <NSFetchedResultsControllerDelegate> {
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	UITableView *menuTable;
	
	ShoppingTableCell *loadCell;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;

@property (nonatomic, retain) IBOutlet ShoppingTableCell *loadCell;


- (void)showLoading;
- (void)hideLoading;
- (void)fetchVendorsFromCoreData;
- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url;
- (void)configureCell:(ShoppingTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)setupNavBar;
- (void)addShoppingVendorsToCoreData:(NSArray *)vendorNodes;

@end
