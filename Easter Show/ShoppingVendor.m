//
//  ShoppingVendor.m
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShoppingVendor.h"


@implementation ShoppingVendor


+ (ShoppingVendor *)vendorWithVendorData:(NSDictionary *)vendorData 
			inManagedObjectContext:(NSManagedObjectContext *)context {
	
	ShoppingVendor *shoppingVendor = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"ShoppingVendor" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[vendorData objectForKey:@"id"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"shopID == %@", idNum];
	
	NSError *error = nil;
	shoppingVendor = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !shoppingVendor) {
		
		NSLog(@"ShoppingVendor CREATED:%@", [vendorData objectForKey:@"title"]);
		
		// Create a new Artist
		shoppingVendor = [NSEntityDescription insertNewObjectForEntityForName:@"ShoppingVendor" inManagedObjectContext:context];
		shoppingVendor.shopID = idNum;
		shoppingVendor.title = [vendorData objectForKey:@"title"];
		shoppingVendor.vendorDescription = [vendorData objectForKey:@"description"];
		shoppingVendor.imageURL = [vendorData objectForKey:@"imageURL"];
		shoppingVendor.thumbURL = [vendorData objectForKey:@"thumbURL"];
		shoppingVendor.latitude = [NSNumber numberWithDouble:[[vendorData objectForKey:@"latitude"] doubleValue]];
		shoppingVendor.longitude = [NSNumber numberWithDouble:[[vendorData objectForKey:@"longitude"] doubleValue]];
	}
	
	return shoppingVendor;
}


+ (ShoppingVendor *)getShoppingVendorWithID:(NSNumber *)shopID inManagedObjectContext:(NSManagedObjectContext *)context {
	
	ShoppingVendor *vendor = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"ShoppingVendor" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"shopID == %@", shopID];
	
	NSError *error = nil;
	vendor = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return vendor;
}


@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic vendorDescription;
@dynamic shopID;
@dynamic thumbURL;
@dynamic title;

@end
