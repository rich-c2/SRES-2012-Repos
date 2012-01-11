//
//  MoreVC.h
//  Easter Show
//
//  Created by Richard Lee on 10/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreVC : UIViewController {
	
	NSArray *menuArray;
	UITableView *menuTable;
	//NSArray *cellLabelImageNames;
	
	//MoreTableCell *loadCell;
	
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSArray *menuArray;
@property (nonatomic, retain) IBOutlet UITableView *menuTable;
//@property (nonatomic, retain) NSArray *cellLabelImageNames;

//@property (nonatomic, retain) IBOutlet MoreTableCell *loadCell;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
