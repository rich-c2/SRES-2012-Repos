//
//  OffersMenuVC.h
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;
@class OfferTableCell;
@class Offer;

@interface OffersMenuVC : UIViewController <NSFetchedResultsControllerDelegate> {

	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;

	JSONFetcher *fetcher;

	BOOL offersLoaded;
	BOOL loading;

	UITableView *menuTable;

	OfferTableCell *loadCell;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;

@property (nonatomic, retain) IBOutlet OfferTableCell *loadCell;


- (void)retrieveXML;
- (void)showLoading;
- (void)hideLoading;
- (void)fetchOffersFromCoreData;
- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url;
- (void)configureCell:(OfferTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
