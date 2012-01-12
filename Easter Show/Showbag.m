//
//  Showbag.m
//  Easter Show
//
//  Created by Richard Lee on 11/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Showbag.h"


@implementation Showbag

+ (Showbag *)showbagWithShowbagData:(NSDictionary *)showbagData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", [showbagData objectForKey:@"title"]];
	
	NSError *error = nil;
	showbag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !showbag) {
		
		NSLog(@"Showbag CREATED:%@", [showbagData objectForKey:@"title"]);
		
		// Create a new Artist
		showbag = [NSEntityDescription insertNewObjectForEntityForName:@"Showbag" inManagedObjectContext:context];
		showbag.showbagID = [NSNumber numberWithInt:[[showbagData objectForKey:@"id"] intValue]];
		showbag.title = [showbagData objectForKey:@"title"];
		showbag.showbagDescription = [showbagData objectForKey:@"description"];
		showbag.imageURL = [showbagData objectForKey:@"imageURL"];
		showbag.thumbURL = [showbagData objectForKey:@"thumbURL"];
		showbag.latitude = [NSNumber numberWithDouble:-33.84476];
		showbag.longitude = [NSNumber numberWithDouble:151.07062];
		showbag.price = [NSNumber numberWithFloat:[[showbagData objectForKey:@"price"] floatValue]];
		showbag.rrPrice = [NSNumber numberWithFloat:[[showbagData objectForKey:@"rrp"] floatValue]];
	}
	
	return showbag;
}


@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic price;
@dynamic showbagDescription;
@dynamic showbagID;
@dynamic thumbURL;
@dynamic title;
@dynamic rrPrice;

@end
