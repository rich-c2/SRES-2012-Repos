//
//  MoreVC.h
//  Easter Show
//
//  Created by Richard Lee on 10/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreVC : UIViewController {
	
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (IBAction)showbagsButtonClicked:(id)sender;
- (IBAction)carnivalButtonClicked:(id)sender;
- (IBAction)foodButtonClicked:(id)sender;
- (IBAction)shoppingButtonClicked:(id)sender;
- (IBAction)aboutButtonClicked:(id)sender;

@end
