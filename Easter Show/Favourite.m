//
//  Favourite.m
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Favourite.h"


@implementation Favourite


+ (Favourite *)favouriteWithFavouriteData:(NSDictionary *)favouriteData 
	   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Favourite *favourite = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Favourite" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"favouriteID = %@", [favouriteData objectForKey:@"id"]];
	
	NSError *error = nil;
	favourite = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !favourite) {
		
		// Create a new Artist
		favourite = [NSEntityDescription insertNewObjectForEntityForName:@"Favourite" inManagedObjectContext:context];
		favourite.favouriteID = [NSNumber numberWithInt:[[favouriteData objectForKey:@"id"] intValue]];
		favourite.title = [favouriteData objectForKey:@"title"];
		favourite.itemID = [NSNumber numberWithInt:[[favouriteData objectForKey:@"itemID"] intValue]];
		favourite.favouriteType = [favouriteData objectForKey:@"type"];	
		
		NSLog(@"favourite CREATED:%@", favourite.title);
	}
	
	return favourite;
}


@dynamic favouriteID;
@dynamic favouriteType;
@dynamic itemID;
@dynamic title;

@end
