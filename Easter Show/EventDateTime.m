//
//  EventDateTime.m
//  Easter Show
//
//  Created by Richard Lee on 22/02/12.
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
		
		// Start Date
		[dateTime setStartDate:[dateFormat dateFromString:[dateData objectForKey:@"startDate"]]];
		
		// Day
		[dateTime setDay:[dateData objectForKey:@"day"]];
		
		// End date
		[dateTime setEndDate:[dateFormat dateFromString:[dateData objectForKey:@"endDate"]]];
		
		// Is Favourite
		[dateTime setIsFavourite:[dateData objectForKey:@"isFavourite"]];
		
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


+ (EventDateTime *)updateDateTimeWithID:(NSNumber *)dateTimeID isFavourite:(BOOL)favourite 
					inManagedObjectContext:(NSManagedObjectContext *)context {
	
	EventDateTime *dateTime = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"EventDateTime" inManagedObjectContext:context];
	
	request.predicate = [NSPredicate predicateWithFormat:@"dateTimeID == %@", dateTimeID];
	
	NSError *error = nil;
	dateTime = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && dateTime) {
		
		// Assign the dictionary values to the corresponding object properties
		[dateTime setIsFavourite:[NSNumber numberWithBool:favourite]];
	}
	
	return dateTime;
}


@dynamic dateTimeID;
@dynamic day;
@dynamic endDate;
@dynamic startDate;
@dynamic isFavourite;
@dynamic forEvent;

@end
