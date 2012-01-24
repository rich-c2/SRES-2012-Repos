//
//  EventsMainVC.h
//  SRES
//
//  Created by Richard Lee on 11/01/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@class Event;
@class XMLFetcher;

@interface EventsMainVC : UIViewController <NSXMLParserDelegate> {
	
	XMLFetcher *fetcher;
	
	UIButton *bigButton;
	
	NSManagedObjectContext *managedObjectContext;
	
	BOOL eventsLoaded;
	BOOL loading;
	
	NSMutableArray *days;
	UIView *calendarContainer;
	
	// Progress
	UIView *progressContainer;
	NSTimer *progressTimer;
	
	BOOL addingEvent;
	BOOL updatingEvent;
}

@property (nonatomic, retain) IBOutlet UIButton *bigButton;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableArray *days;

@property (nonatomic, retain) IBOutlet UIView *calendarContainer;


- (void)initCalendarData;
- (void)createCalendar;
- (void)goToDaysEvents:(id)sender;
- (NSString *)getDayStringUsingInt:(NSInteger)dayInt;
- (void)setupNavBar;
- (void)showLoading;
- (void)hideLoading;


@end
