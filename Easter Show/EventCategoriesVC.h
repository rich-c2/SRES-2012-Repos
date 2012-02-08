//
//  EventCategoriesVC.h
//  Easter Show
//
//  Created by Richard Lee on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCategoriesVC : UIViewController {

	UITableView *menuTable;
	
	NSArray *categories;
	NSString *selectedDate;
	
	// Nav title
	UILabel *navigationTitle;
}

@property (nonatomic, retain) IBOutlet UITableView *menuTable;

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSString *selectedDate;

@property (nonatomic, retain) IBOutlet UILabel *navigationTitle;

- (IBAction)goBack:(id)sender;

@end
