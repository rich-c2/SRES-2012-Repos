//
//  Event.m
//  Easter Show
//
//  Created by Richard Lee on 2/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"


@implementation NSManagedObject (safeSetValuesKeysWithDictionary)


- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues 
							 dateFormatter:(NSDateFormatter *)dateFormatter {
	
    NSDictionary *attributes = [[self entity] attributesByName];
	
    for (NSString *attribute in attributes) {
		
        id value = [keyedValues objectForKey:attribute];
		
		NSLog(@"STARTING:%@", attribute);
		
        if (value == nil || value == (id)[NSNull null]) {
            continue;
        }
		
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
		
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithInteger:[value integerValue]];
        } else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) && (dateFormatter != nil)) {
			
            value = [dateFormatter dateFromString:value];
        }
		
		NSLog(@"VALUE:%@|ATT:%@", value, attribute);
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
		
		[event safeSetValuesForKeysWithDictionary:eventData dateFormatter:dateFormat];
		
		NSLog(@"Event CREATED:%@ | %@", event.title, [dateFormat stringFromDate:event.startDate]);
		
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
		
		[event safeSetValuesForKeysWithDictionary:eventData dateFormatter:dateFormat];
		
		NSLog(@"Event UPDATED:%@ | %@", event.title, [dateFormat stringFromDate:event.startDate]);
		
		[dateFormat release];
	}
	
	else if (!error && !event) event = [self insertEventWithData:eventData inManagedObjectContext:context];
	
	return event;
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

@dynamic category;
@dynamic startDate;
@dynamic eventDescription;
@dynamic eventID;
@dynamic latitude;
@dynamic longitude;
@dynamic title;
@dynamic endDate;
@dynamic version;

@end
