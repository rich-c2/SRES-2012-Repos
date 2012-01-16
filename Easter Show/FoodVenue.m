//
//  FoodVenue.m
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodVenue.h"


@implementation FoodVenue


+ (FoodVenue *)venueWithVenueData:(NSDictionary *)venueData 
		   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID = %@", [venueData objectForKey:@"id"]];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !foodVenue) {
		
		NSLog(@"FoodVenue CREATED:%@", [venueData objectForKey:@"venueTitle"]);
		
		// Create a new Artist
		foodVenue = [NSEntityDescription insertNewObjectForEntityForName:@"FoodVenue" inManagedObjectContext:context];
		foodVenue.venueID = [NSNumber numberWithInt:[[venueData objectForKey:@"id"] intValue]];
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


+ (FoodVenue *)updateVenueWithVenueData:(NSDictionary *)venueData 
				 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	FoodVenue *foodVenue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"FoodVenue" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID = %@", [venueData objectForKey:@"id"]];
	
	NSError *error = nil;
	foodVenue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if ((!error && !foodVenue) || (!error && foodVenue)) {
		
		NSLog(@"FoodVenue UPDATED:%@", [venueData objectForKey:@"title"]);
		
		// Create a new Artist
		foodVenue = [NSEntityDescription insertNewObjectForEntityForName:@"FoodVenue" inManagedObjectContext:context];
		foodVenue.venueID = [NSNumber numberWithInt:[[venueData objectForKey:@"id"] intValue]];
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
