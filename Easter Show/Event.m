//
//  Event.m
//  Easter Show
//
//  Created by Richard Lee on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"


@implementation Event

+ (Event *)eventWithEventData:(NSDictionary *)eventData 
	   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[eventData objectForKey:@"id"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", idNum];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !event) {
		
		// Create a new Event
		event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
		event.eventID = idNum;
		event.title = [eventData objectForKey:@"eventTitle"];
		event.eventDescription = [eventData objectForKey:@"eventDescription"];
		event.imageURL = [eventData objectForKey:@"imageURL"];
		event.thumbURL = [eventData objectForKey:@"thumbURL"];
		event.latitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"latitude"] doubleValue]];
		event.longitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"longitude"] doubleValue]];
		event.category = [self categoryStringFromInt:[[eventData objectForKey:@"eventType"] intValue]];
		
		// EVENT DATE
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMMM dd"];
		NSDate *date = [dateFormat dateFromString:[eventData objectForKey:@"eventDate"]];
		event.eventDate = date;
		
		NSLog(@"Event CREATED:%@", event.title);
	}
	
	return event;
}


+ (Event *)getEventWithID:(NSNumber *)eventID inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventID];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return event;
}


+ (Event *)updateEventWithEventData:(NSDictionary *)eventData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[eventData objectForKey:@"id"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", idNum];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && event) {
		
		NSLog(@"Event UPDATED:%@", [eventData objectForKey:@"eventTitle"]);
		
		// Create a new Artist
		event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
		event.eventID = idNum;
		event.title = [eventData objectForKey:@"eventTitle"];
		event.eventDescription = [eventData objectForKey:@"eventDescription"];
		event.imageURL = [eventData objectForKey:@"imageURL"];
		event.thumbURL = [eventData objectForKey:@"thumbURL"];
		event.latitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"latitude"] doubleValue]];
		event.longitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"longitude"] doubleValue]];
		event.category = [self categoryStringFromInt:[[eventData objectForKey:@"eventType"] intValue]];
		
		// EVENT DATE
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMMM dd"];
		NSDate *date = [dateFormat dateFromString:[eventData objectForKey:@"eventDate"]];
		event.eventDate = date;
	}
	
	else if (!error && !event) event = [self insertEventWithData:eventData inManagedObjectContext:context];
	
	return event;
}


+ (Event *)insertEventWithData:(NSDictionary *)eventData 
				inManagedObjectContext:(NSManagedObjectContext *)context {
	
	// Create a new Event
	Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
	event.eventID = [NSNumber numberWithInt:[[eventData objectForKey:@"id"] intValue]];;
	event.title = [eventData objectForKey:@"eventTitle"];
	event.eventDescription = [eventData objectForKey:@"eventDescription"];
	event.imageURL = [eventData objectForKey:@"imageURL"];
	event.thumbURL = [eventData objectForKey:@"thumbURL"];
	event.latitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"latitude"] doubleValue]];
	event.longitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"longitude"] doubleValue]];
	event.category = [self categoryStringFromInt:[[eventData objectForKey:@"eventType"] intValue]];
	
	// EVENT DATE
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM dd"];
	NSDate *date = [dateFormat dateFromString:[eventData objectForKey:@"eventDate"]];
	event.eventDate = date;
	
	return event;
}


+ (Event *)eventWithID:(NSNumber *)eventID 
		inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventID];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !event) NSLog(@"NO event FOUND");
	
	return event;
}


+ (NSString *)categoryStringFromInt:(NSInteger)categoryInt {

	NSString *category;
	
	switch (categoryInt) {
		case 1:
			category = @"Entertainment";
			break;
			
		case 2:
			category = @"Animals";
			break;
			
		case 3:
			category = @"Competitions";
			break;
			
		default:
			category = @"Entertainment";
			break;
	}
	
	return category;
}


@dynamic allDay;
@dynamic category;
@dynamic eventDate;
@dynamic eventDescription;
@dynamic eventID;
@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic subCategory;
@dynamic thumbURL;
@dynamic title;

@end
