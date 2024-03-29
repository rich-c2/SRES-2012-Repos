//
//  Showbag.m
//  Easter Show
//
//  Created by Richard Lee on 24/02/12.
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
		
		showbag.latitude = [NSNumber numberWithDouble:-33.84476];
		showbag.longitude = [NSNumber numberWithDouble:151.07062];
		
		// By default this is not a favourite
		[showbag setIsFavourite:[NSNumber numberWithBool:NO]];
		
		NSLog(@"showbag CREATED:%@", showbag.title);
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


+ (Showbag *)updateShowbagWithShowbagData:(NSDictionary *)showbagData 
				   inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[showbagData objectForKey:@"showbagID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"showbagID == %@", idNum];
	
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


+ (Showbag *)updateShowbagWithID:(NSNumber *)showbagID isFavourite:(BOOL)favourite 
	  inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Showbag *showbag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Showbag" inManagedObjectContext:context];
	
	request.predicate = [NSPredicate predicateWithFormat:@"showbagID == %@", showbagID];
	
	NSError *error = nil;
	showbag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && showbag) {
		
		// Assign the dictionary values to the corresponding object properties
		[showbag setIsFavourite:[NSNumber numberWithBool:favourite]];
	}
	
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
@dynamic isFavourite;

@end
