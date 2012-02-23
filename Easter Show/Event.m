//
//  Event.m
//  Easter Show
//
//  Created by Richard Lee on 6/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "EventDateTime.h"


@implementation NSManagedObject (safeSetValuesKeysWithDictionary)


- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues 
							 dateFormatter:(NSDateFormatter *)dateFormatter {
	
    NSDictionary *attributes = [[self entity] attributesByName];
	
    for (NSString *attribute in attributes) {
		
        id value = [keyedValues objectForKey:attribute];
		
        if (value == nil || value == (id)[NSNull null]) {
            continue;
        }
		
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
		
		NSLog(@"KEY:%@", attribute);
		
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
			
            value = [value stringValue];
        }
		
		else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) 
				  || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) 
				 && ([value isKindOfClass:[NSString class]])) {
			
            value = [NSNumber numberWithInteger:[value integerValue]];
        } 
		
		else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } 
		
		else if ((attributeType == NSDoubleAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } 
		
		else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) 
				 && (dateFormatter != nil)) {
			
            value = [dateFormatter dateFromString:value];
        }
		
		else if ((attributeType == NSFloatAttributeType) && ([value isKindOfClass:[NSArray class]])) {
			
			continue;
		}
		
		NSLog(@"KEY:%@|VALUE:%@", attribute, value);
        [self setValue:value forKey:attribute];
    }
}
@end


@implementation Event


+ (Event *)newEventWithData:(NSDictionary *)eventData 
	 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Event *event = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[eventData objectForKey:@"eventID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", idNum];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !event) {
		
		// Create a new Event
		event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
		
		// EVENT DATE
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMMM dd h:mm a"];
		
		// Assign the dictionary values to the corresponding object properties
		[event safeSetValuesForKeysWithDictionary:eventData dateFormatter:dateFormat];
		
		// Create EventDateTime objects for each of the dates 
		// and then assign the NSSet of them to the occursOnDay property
		NSMutableArray *datesArray = [NSMutableArray array];
		
		for (NSDictionary *dateDictionary in [eventData objectForKey:@"dates"]) {
			
			NSLog(@"dateDictionary:%@", dateDictionary);
			
			// By default, all EventDateTime sessions are not a Favourite
			[dateDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isFavourite"];
			
			[datesArray addObject:[EventDateTime dateTimeWithData:dateDictionary inManagedObjectContext:context]];
		}
		
		NSSet *dates = [[NSSet alloc] initWithArray:(NSArray *)datesArray];
		[event setOccursOnDays:dates];
		[dates release];
		
		////////////////////////////////////////////////////////////////////////////////////
		
		NSLog(@"Event CREATED:%@", event.title);
		
		[dateFormat release];
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
	
	NSNumber *idNum = [NSNumber numberWithInt:[[eventData objectForKey:@"eventID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", idNum];
	
	NSError *error = nil;
	event = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && event) {
		
		// EVENT DATE
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"MMMM dd h:mm a"];
		
		// Assign the dictionary values to the corresponding object properties
		[event safeSetValuesForKeysWithDictionary:eventData dateFormatter:dateFormat];
		
		// Create EventDateTime objects for each of the dates 
		// and then assign the NSSet of them to the occursOnDay property
		NSMutableArray *datesArray = [NSMutableArray array];
		
		for (NSDictionary *dateDictionary in [eventData objectForKey:@"dates"]) {
			
			[datesArray addObject:[EventDateTime dateTimeWithData:dateDictionary inManagedObjectContext:context]];
		}
		
		NSSet *dates = [[NSSet alloc] initWithArray:(NSArray *)datesArray];
		[event setOccursOnDays:dates];
		[dates release];
		
		////////////////////////////////////////////////////////////////////////////////////
		
		[dateFormat release];
	}
	
	else if (!error && !event) event = [self newEventWithData:eventData inManagedObjectContext:context];
	
	return event;
}


+ (void)updateEvent:(Event *)event withData:(NSDictionary *)eventData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
		
	// EVENT DATE
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM dd h:mm a"];
	
	// Assign the dictionary values to the corresponding object properties
	[event safeSetValuesForKeysWithDictionary:eventData dateFormatter:dateFormat];
	
	// Create EventDateTime objects for each of the dates 
	// and then assign the NSSet of them to the occursOnDay property
	NSMutableArray *datesArray = [NSMutableArray array];
	
	for (NSDictionary *dateDictionary in [eventData objectForKey:@"dates"]) {
		
		[datesArray addObject:[EventDateTime dateTimeWithData:dateDictionary inManagedObjectContext:context]];
	}
	
	NSSet *dates = [[NSSet alloc] initWithArray:(NSArray *)datesArray];
	[event setOccursOnDays:dates];
	[dates release];
	
	////////////////////////////////////////////////////////////////////////////////////
	
	[dateFormat release];
}


+ (Event *)insertEventWithData:(NSDictionary *)eventData 
		inManagedObjectContext:(NSManagedObjectContext *)context {
	
	// Create a new Event
	Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
	
	// EVENT DATE
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM dd h:mm a"];
	
	[event safeSetValuesForKeysWithDictionary:eventData dateFormatter:dateFormat];
	
	[dateFormat release];
	
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


@dynamic category;
@dynamic eventDescription;
@dynamic eventID;
@dynamic latitude;
@dynamic longitude;
@dynamic title;
@dynamic version;
@dynamic occursOnDays;

@end
