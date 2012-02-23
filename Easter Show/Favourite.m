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
	
	NSNumber *idNum = [NSNumber numberWithInt:[[favouriteData objectForKey:@"itemID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"itemID == %@ AND title = %@", idNum, [favouriteData objectForKey:@"title"]];
	
	NSError *error = nil;
	favourite = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !favourite) {
		
		// Create a new Artist
		favourite = [NSEntityDescription insertNewObjectForEntityForName:@"Favourite" inManagedObjectContext:context];
		favourite.favouriteID = [NSNumber numberWithInt:[[favouriteData objectForKey:@"id"] intValue]];
		favourite.title = [favouriteData objectForKey:@"title"];
		favourite.itemID = idNum;
		favourite.favouriteType = [favouriteData objectForKey:@"favouriteType"];
	}
	
	return favourite;
}


+ (BOOL)isItemFavourite:(NSNumber *)itemID favouriteType:(NSString *)type 
			inManagedObjectContext:(NSManagedObjectContext *)context {

	Favourite *favourite = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Favourite" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"itemID == %@ AND favouriteType = %@", itemID, type];
	
	NSError *error = nil;
	favourite = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && favourite) return YES;
	
	return NO;
}


+ (Favourite *)favouriteWithItemID:(NSNumber *)itemID favouriteType:(NSString *)type
				   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Favourite *favourite = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Favourite" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"itemID == %@ AND favouriteType = %@", itemID, type];
	
	NSError *error = nil;
	favourite = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return favourite;
}


+ (Favourite *)updateFavouriteItemID:(NSNumber *)itemID withNewID:(NSInteger)newID
							   title:(NSString *)newTitle
			  inManagedObjectContext:(NSManagedObjectContext *)context {

	Favourite *fav = nil;
	
	NSNumber *newIDNum = [NSNumber numberWithInt:newID];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Favourite" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"itemID == %@", itemID];
	
	NSError *error = nil;
	fav = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && fav) {
		
		NSLog(@"UPDATING FAV:%@ - %i", newTitle, [newIDNum intValue]);
		
		// Update the Favourite's itemID with the new one
		fav.itemID = newIDNum;
		
		fav.title = newTitle;
	}
	
	return fav;
}


@dynamic favouriteID;
@dynamic favouriteType;
@dynamic itemID;
@dynamic title;

@end
