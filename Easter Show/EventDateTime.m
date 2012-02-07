//
//  EventDateTime.m
//  Easter Show
//
//  Created by Richard Lee on 7/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventDateTime.h"
#import "Event.h"


@implementation EventDateTime

+ (EventDateTime *)dateTimeWithData:(NSDictionary *)dateData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	EventDateTime *dateTime = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"EventDateTime" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[dateData objectForKey:@"dateTimeID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"dateTimeID == %@", idNum];
	
	NSError *error = nil;
	dateTime = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !dateTime) {
		
		// Create a new EventDateTime
		dateTime = [NSEntityDescription insertNewObjectForEntityForName:@"EventDateTime" inManagedObjectContext:context];
		
		[dateTime setDateTimeID:[NSNumber numberWithInt:[[dateData objectForKey:@"dateTimeID"] intValue]]];
		
		// DAY
		/*NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
		[dayFormat setDateFormat:@"MMMM dd"];
		NSDate *dayDate = [dayFormat dateFromString:[dateData objectForKey:@"startDate"]];
		[dateTime setDay:[dayFormat stringFromDate:dayDate]];
		[dayFormat release];*/
		
		
		// EVENT DATE
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMMM dd h:mm a"];
		
		[dateTime setStartDate:[dateFormat dateFromString:[dateData objectForKey:@"startDate"]]];
		
		
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *weekdayComponents = [gregorian components:(NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dateTime.startDate];
		
		NSInteger day = [weekdayComponents day];
		NSInteger weekday = [weekdayComponents month];
		
		[dateTime setDay:[NSString stringWithFormat:@"April %i", day]];
		[gregorian release];
		
		[dateTime setEndDate:[dateFormat dateFromString:[dateData objectForKey:@"endDate"]]];
		
		NSLog(@"EventDateTime CREATED:%@", dateTime.day);
		
		[dateFormat release];
	}
	
	return dateTime;
	
}


+ (EventDateTime *)getDateTimeWithID:(NSNumber *)dateTimeID inManagedObjectContext:(NSManagedObjectContext *)context {
	
	EventDateTime *dateTime = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"EventDateTime" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"dateTimeID == %@", dateTimeID];
	
	NSError *error = nil;
	dateTime = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return dateTime;
}



@dynamic dateTimeID;
@dynamic endDate;
@dynamic startDate;
@dynamic day;
@dynamic forEvent;

@end
