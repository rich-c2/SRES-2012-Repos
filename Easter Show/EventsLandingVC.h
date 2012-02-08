//
//  EventsLandingVC.h
//  Easter Show
//
//  Created by Richard Lee on 13/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;
@class EventTableCell;

@interface EventsLandingVC : UIViewController {

	JSONFetcher *fetcher;
	
	NSManagedObjectContext *managedObjectContext;
	
	BOOL eventsLoaded;
	BOOL loading;
	
	UIButton *searchButton;
	UIButton *todaysEventsButton;
	UIButton *fullProgramButton;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UIButton *searchButton;
@property (nonatomic, retain) IBOutlet UIButton *todaysEventsButton;
@property (nonatomic, retain) IBOutlet UIButton *fullProgramButton;


- (IBAction)searchButtonClicked:(id)sender;
- (IBAction)todaysEventsButtonClicked:(id)sender;
- (IBAction)fullProgramButtonClicked:(id)sender;
- (void)showLoading;
- (void)hideLoading;
- (void)retrieveXML;


@end
