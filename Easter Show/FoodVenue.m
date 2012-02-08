//
//  FoodVenue.m
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
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
		
		NSLog(@"foodVenue CREATED:%@", foodVenue.title);
	}
	
	return foodVenue;
}


+ (FoodVenue *)venueWithVenueData:(NSDictionary *)venueData 
		   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[venueData objectForKey:@"id"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID == %@", idNum];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !foodVenue) {
		
		NSLog(@"FoodVenue CREATED:%@", [venueData objectForKey:@"venueTitle"]);
		
		// Create a new Artist
		foodVenue = [NSEntityDescription insertNewObjectForEntityForName:@"FoodVenue" inManagedObjectContext:context];
		foodVenue.venueID = idNum;
		foodVenue.title = [venueData objectForKey:@"venueTitle"];
		foodVenue.subtitle = [venueData objectForKey:@"subTitle"];
		foodVenue.venueDescription = [venueData objectForKey:@"venueDescription"];
		foodVenue.imageURL = [venueData objectForKey:@"imageURL"];
		foodVenue.thumbURL = [venueData objectForKey:@"thumbURL"];
		foodVenue.latitude = [NSNumber numberWithDouble:-33.84476];
		foodVenue.longitude = [NSNumber numberWithDouble:151.07062];
		foodVenue.version = [NSNumber numberWithInt:[[venueData objectForKey:@"version"] intValue]];
	}
	
	return foodVenue;
}


/*
+ (FoodVenue *)updateVenueWithVenueData:(NSDictionary *)venueData 
				 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[venueData objectForKey:@"id"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID == %@", idNum];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && foodVenue) {
		
		NSLog(@"FoodVenue UPDATED:%@", [venueData objectForKey:@"title"]);
		
		// Create a new Artist
		foodVenue.venueID = idNum;
		foodVenue.title = [venueData objectForKey:@"venueTitle"];
		foodVenue.subtitle = [venueData objectForKey:@"subTitle"];
		foodVenue.venueDescription = [venueData objectForKey:@"venueDescription"];
		foodVenue.imageURL = [venueData objectForKey:@"imageURL"];
		foodVenue.thumbURL = [venueData objectForKey:@"thumbURL"];
		foodVenue.latitude = [NSNumber numberWithDouble:-33.84476];
		foodVenue.longitude = [NSNumber numberWithDouble:151.07062];
		foodVenue.version = [NSNumber numberWithInt:[[venueData objectForKey:@"version"] intValue]];
	}
	
	else if (!error && !foodVenue) foodVenue = [self insertFoodVenueWithData:venueData inManagedObjectContext:context];
	
	return foodVenue;
}
*/

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


+ (FoodVenue *)insertFoodVenueWithData:(NSDictionary *)venueData 
				inManagedObjectContext:(NSManagedObjectContext *)context {

	// Create a new Artist
	FoodVenue *foodVenue = [NSEntityDescription insertNewObjectForEntityForName:@"FoodVenue" inManagedObjectContext:context];
	foodVenue.venueID = [NSNumber numberWithInt:[[venueData objectForKey:@"id"] intValue]];
	foodVenue.title = [venueData objectForKey:@"venueTitle"];
	foodVenue.subtitle = [venueData objectForKey:@"subTitle"];
	foodVenue.venueDescription = [venueData objectForKey:@"venueDescription"];
	foodVenue.imageURL = [venueData objectForKey:@"imageURL"];
	foodVenue.thumbURL = [venueData objectForKey:@"thumbURL"];
	foodVenue.latitude = [NSNumber numberWithDouble:-33.84476];
	foodVenue.longitude = [NSNumber numberWithDouble:151.07062];
	foodVenue.version = [NSNumber numberWithInt:[[venueData objectForKey:@"version"] intValue]];
						 
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


@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic thumbURL;
@dynamic title;
@dynamic venueDescription;
@dynamic venueID;
@dynamic version;
@dynamic subtitle;

@end
