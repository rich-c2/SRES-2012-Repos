//
//  FoodVenue.m
//  Easter Show
//
//  Created by Richard Lee on 24/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodVenue.h"


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
		
		else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) 
				 && (dateFormatter != nil)) {
			
            value = [dateFormatter dateFromString:value];
        }
		
		else if ((attributeType == NSFloatAttributeType) && ([value isKindOfClass:[NSArray class]])) {
			
			continue;
		}
		
        [self setValue:value forKey:attribute];
    }
}
@end


@implementation FoodVenue

+ (FoodVenue *)newFoodVenueWithData:(NSDictionary *)venueData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[venueData objectForKey:@"venueID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID == %@", idNum];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !foodVenue) {
		
		// Create a new Event
		foodVenue = [NSEntityDescription insertNewObjectForEntityForName:@"FoodVenue" inManagedObjectContext:context];
		
		// Assign the dictionary values to the corresponding object properties
		[foodVenue safeSetValuesForKeysWithDictionary:venueData dateFormatter:nil];
		
		// By default this is not a favourite
		[foodVenue setIsFavourite:[NSNumber numberWithBool:NO]];
		
		NSLog(@"foodVenue CREATED:%@", foodVenue.title);
	}
	
	return foodVenue;
}


+ (FoodVenue *)getFoodVenueWithID:(NSNumber *)venueID inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID == %@", venueID];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return foodVenue;
}


+ (FoodVenue *)venueWithID:(NSNumber *)venueID 
			inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID = %@", venueID];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !foodVenue) NSLog(@"NO FoodVenue FOUND");
	
	return foodVenue;
}


+ (FoodVenue *)updateFoodVenueWithID:(NSNumber *)venueID isFavourite:(BOOL)favourite 
	  inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *venue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	
	request.predicate = [NSPredicate predicateWithFormat:@"venueID == %@", venueID];
	
	NSError *error = nil;
	venue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && venue) {
		
		// Assign the dictionary values to the corresponding object properties
		[venue setIsFavourite:[NSNumber numberWithBool:favourite]];
	}
	
	return venue;
}


+ (FoodVenue *)updateVenueWithVenueData:(NSDictionary *)venueData 
				 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[venueData objectForKey:@"venueID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID == %@", idNum];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && foodVenue) {
		
		// Assign the dictionary values to the corresponding object properties
		[foodVenue safeSetValuesForKeysWithDictionary:venueData dateFormatter:nil];
	}
	
	else if (!error && !foodVenue) foodVenue = [self newFoodVenueWithData:venueData inManagedObjectContext:context];
	
	return foodVenue;
}


@dynamic latitude;
@dynamic longitude;
@dynamic subtitle;
@dynamic title;
@dynamic venueDescription;
@dynamic venueID;
@dynamic version;
@dynamic isFavourite;

@end
