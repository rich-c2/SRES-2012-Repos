//
//  EventDateTime.m
//  Easter Show
//
//  Created by Richard Lee on 6/02/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
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
		
		// EVENT DATE
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMMM dd h:mm a"];
		
		[dateTime setStartDate:[dateFormat dateFromString:[dateData objectForKey:@"startDate"]]];
		[dateTime setEndDate:[dateFormat dateFromString:[dateData objectForKey:@"endDate"]]];
		
		NSLog(@"EventDateTime CREATED:%@ | %@", [dateFormat stringFromDate:dateTime.startDate], [dateFormat stringFromDate:dateTime.endDate]);
		
		[dateFormat release];
	}
	
	return dateTime;

}


@dynamic dateTimeID;
@dynamic endDate;
@dynamic startDate;
@dynamic forEvent;

@end
