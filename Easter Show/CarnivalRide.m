//
//  CarnivalRide.m
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CarnivalRide.h"


@implementation CarnivalRide


+ (CarnivalRide *)rideWithRideData:(NSDictionary *)rideData 
			inManagedObjectContext:(NSManagedObjectContext *)context {
	
	CarnivalRide *carnivalRide = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"CarnivalRide" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[rideData objectForKey:@"id"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"rideID == %@", idNum];
	
	NSError *error = nil;
	carnivalRide = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !carnivalRide) {
		
		NSLog(@"CarnivalRide CREATED:%@", [rideData objectForKey:@"title"]);
		
		// Create a new Artist
		carnivalRide = [NSEntityDescription insertNewObjectForEntityForName:@"CarnivalRide" inManagedObjectContext:context];
		carnivalRide.rideID = idNum;
		carnivalRide.title = [rideData objectForKey:@"title"];
		carnivalRide.rideDescription = [rideData objectForKey:@"description"];
		carnivalRide.imageURL = [rideData objectForKey:@"imageURL"];
		carnivalRide.thumbURL = [rideData objectForKey:@"thumbURL"];
		carnivalRide.latitude = [NSNumber numberWithDouble:-33.84476];
		carnivalRide.longitude = [NSNumber numberWithDouble:151.07062];
	}
	
	return carnivalRide;
}

@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic rideDescription;
@dynamic rideID;
@dynamic thumbURL;
@dynamic title;

@end
