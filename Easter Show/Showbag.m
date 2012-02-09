//
//  Showbag.m
//  Easter Show
//
//  Created by Richard Lee on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Showbag.h"


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
		
		NSLog(@"KEY:%@", attribute);
		
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
		
		else if ((attributeType == NSDoubleAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        }
		
		else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) 
				 && (dateFormatter != nil)) {
			
            value = [dateFormatter dateFromString:value];
        }
		
		else if ((attributeType == NSFloatAttributeType) && ([value isKindOfClass:[NSArray class]])) {
			
			continue;
		}
		
		NSLog(@"KEY:%@|VALUE:%@", attribute, value);
        [self setValue:value forKey:attribute];
    }
}
@end


@implementation Showbag

+ (Showbag *)newShowbagWithData:(NSDictionary *)showbagData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[showbagData objectForKey:@"showbagID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"showbagID == %@", idNum];
	
	NSError *error = nil;
	showbag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !showbag) {
		
		// Create a new Event
		showbag = [NSEntityDescription insertNewObjectForEntityForName:@"Showbag" inManagedObjectContext:context];
		
		// Assign the dictionary values to the corresponding object properties
		[showbag safeSetValuesForKeysWithDictionary:showbagData dateFormatter:nil];
		
		NSLog(@"showbag CREATED:%@", showbag.title);
	}
	
	return showbag;
}


+ (Showbag *)showbagWithShowbagData:(NSDictionary *)showbagData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"showbagID = %@", [showbagData objectForKey:@"id"]];
	
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
		showbag.version = [NSNumber numberWithInt:[[showbagData objectForKey:@"version"] intValue]];
	}
	
	return showbag;
}


+ (Showbag *)getShowbagWithID:(NSNumber *)showbagID inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"showbagID == %@", showbagID];
	
	NSError *error = nil;
	showbag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return showbag;
}


/*+ (Showbag *)updateShowbagWithShowbagData:(NSDictionary *)showbagData 
				   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"showbagID = %@", [showbagData objectForKey:@"id"]];
	
	NSError *error = nil;
	showbag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if ((!error && !showbag) || (!error && showbag)) {
		
		NSLog(@"Showbag UPDATED:%@", [showbagData objectForKey:@"title"]);
		
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
		showbag.version = [NSNumber numberWithInt:[[showbagData objectForKey:@"version"] intValue]];
	}
	
	return showbag;
}*/


+ (Showbag *)updateShowbagWithShowbagData:(NSDictionary *)showbagData 
				 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[showbagData objectForKey:@"venueID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"venueID == %@", idNum];
	
	NSError *error = nil;
	showbag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && showbag) {
		
		// Assign the dictionary values to the corresponding object properties
		[showbag safeSetValuesForKeysWithDictionary:showbagData dateFormatter:nil];
	}
	
	else if (!error && !showbag) showbag = [self newShowbagWithData:showbagData inManagedObjectContext:context];
	
	return showbag;
}


+ (Showbag *)showbagWithID:(NSNumber *)showbagID 
	inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"showbagID = %@", showbagID];
	
	NSError *error = nil;
	showbag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !showbag) NSLog(@"NO SHOWBAG FOUND");
	
	return showbag;
}

@dynamic imageURL;
@dynamic latitude;
@dynamic longitude;
@dynamic price;
@dynamic rrPrice;
@dynamic showbagDescription;
@dynamic showbagID;
@dynamic thumbURL;
@dynamic title;
@dynamic version;

@end
