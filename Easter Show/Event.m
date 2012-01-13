//
//  Event.m
//  Easter Show
//
//  Created by Richard Lee on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"


@implementation Event

+ (Event *)eventWithEventData:(NSDictionary *)eventData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", [eventData objectForKey:@"eventTitle"]];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !event) {
		
		// Create a new Artist
		event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
		event.eventID = [NSNumber numberWithInt:[[eventData objectForKey:@"id"] intValue]];
		event.title = [eventData objectForKey:@"eventTitle"];
		event.eventDescription = [eventData objectForKey:@"description"];
		event.imageURL = [eventData objectForKey:@"imageURL"];
		event.thumbURL = [eventData objectForKey:@"thumbURL"];
		event.latitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"latitude"] doubleValue]];
		event.longitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"longitude"] doubleValue]];
		event.eventDate = [eventData objectForKey:@"eventDate"];
		
		NSLog(@"Event CREATED:%@", event.title);
	}
	
	return event;
}


+ (Event *)updateEventWithEventData:(NSDictionary *)eventData 
				   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", [eventData objectForKey:@"eventTitle"]];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if ((!error && !event) || (!error && event)) {
		
		NSLog(@"Event UPDATED:%@", [eventData objectForKey:@"eventTitle"]);
		
		// Create a new Artist
		event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
		event.eventID = [NSNumber numberWithInt:[[eventData objectForKey:@"id"] intValue]];
		event.title = [eventData objectForKey:@"eventTitle"];
		event.eventDescription = [eventData objectForKey:@"description"];
		event.imageURL = [eventData objectForKey:@"imageURL"];
		event.thumbURL = [eventData objectForKey:@"thumbURL"];
		event.latitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"latitude"] doubleValue]];
		event.longitude = [NSNumber numberWithDouble:[[eventData objectForKey:@"longitude"] doubleValue]];
		event.eventDate = [eventData objectForKey:@"eventDate"];
	}
	
	return event;
}


+ (Event *)eventWithID:(NSNumber *)eventID 
	inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"eventID = %@", eventID];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !event) NSLog(@"NO event FOUND");
	
	return event;
}


@dynamic allDay;
@dynamic category;
@dynamic eventDescription;
@dynamic eventID;
@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic subCategory;
@dynamic thumbURL;
@dynamic title;
@dynamic eventDate;

@end
