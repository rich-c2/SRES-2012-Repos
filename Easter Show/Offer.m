//
//  Offer.m
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Offer.h"


@implementation Offer


+ (Offer *)offerWithOfferData:(NSDictionary *)offerData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Offer *offer = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"offerID = %@", [offerData objectForKey:@"id"]];
	
	NSError *error = nil;
	offer = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !offer) {
		
		NSLog(@"offer CREATED:%@", [offerData objectForKey:@"offerTitle"]);
		
		// Create a new Offer
		offer = [NSEntityDescription insertNewObjectForEntityForName:@"Offer" inManagedObjectContext:context];
		offer.offerID = [NSNumber numberWithInt:[[offerData objectForKey:@"id"] intValue]];
		offer.title = [offerData objectForKey:@"offerTitle"];
		offer.offerDescription = [offerData objectForKey:@"offerDescription"];
		offer.provider = [offerData objectForKey:@"offerProvider"];
		offer.offerType = [offerData objectForKey:@"type"];
		offer.imageURL = [offerData objectForKey:@"imageURL"];
		offer.thumbURL = [offerData objectForKey:@"thumbURL"];
		offer.latitude = [NSNumber numberWithDouble:-33.84476];
		offer.longitude = [NSNumber numberWithDouble:151.07062];
		offer.version = [NSNumber numberWithInt:[[offerData objectForKey:@"version"] intValue]];
	}
	
	return offer;
}


+ (Offer *)updateOfferWithOfferData:(NSDictionary *)offerData 
				   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Offer *offer = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"offerID = %@", [offerData objectForKey:@"id"]];
	
	NSError *error = nil;
	offer = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if ((!error && !offer) || (!error && offer)) {
		
		NSLog(@"offer UPDATED:%@", [offerData objectForKey:@"offerTitle"]);
		
		// Create a new Offer
		offer = [NSEntityDescription insertNewObjectForEntityForName:@"Offer" inManagedObjectContext:context];
		offer.offerID = [NSNumber numberWithInt:[[offerData objectForKey:@"id"] intValue]];
		offer.title = [offerData objectForKey:@"offerTitle"];
		offer.offerDescription = [offerData objectForKey:@"offerDescription"];
		offer.provider = [offerData objectForKey:@"offerProvider"];
		offer.offerType = [offerData objectForKey:@"type"];
		offer.imageURL = [offerData objectForKey:@"imageURL"];
		offer.thumbURL = [offerData objectForKey:@"thumbURL"];
		offer.latitude = [NSNumber numberWithDouble:-33.84476];
		offer.longitude = [NSNumber numberWithDouble:151.07062];
		offer.version = [NSNumber numberWithInt:[[offerData objectForKey:@"version"] intValue]];
	}
	
	return offer;
}


+ (Offer *)offerWithID:(NSNumber *)offerID 
	inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Offer *offer = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"offerID = %@", offerID];
	
	NSError *error = nil;
	offer = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !offer) NSLog(@"NO offer FOUND");
	
	return offer;
}


@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic offerDescription;
@dynamic offerID;
@dynamic offerType;
@dynamic thumbURL;
@dynamic title;
@dynamic provider;
@dynamic version;

@end
