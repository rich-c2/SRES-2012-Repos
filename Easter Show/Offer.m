//
//  Offer.m
//  Easter Show
//
//  Created by Richard Lee on 23/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Offer.h"

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
		
        [self setValue:value forKey:attribute];
    }
}
@end


@implementation Offer

+ (Offer *)newOfferWithData:(NSDictionary *)offerData 
	 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Offer *offer = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[offerData objectForKey:@"offerID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"offerID == %@", idNum];
	
	NSError *error = nil;
	offer = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !offer) {
		
		// Create a new Event
		offer = [NSEntityDescription insertNewObjectForEntityForName:@"Offer" inManagedObjectContext:context];
		
		// Assign the dictionary values to the corresponding object properties
		[offer safeSetValuesForKeysWithDictionary:offerData dateFormatter:nil];
		
		// By default an offer is not a favourite
		[offer setIsFavourite:[NSNumber numberWithBool:NO]];
		
		NSLog(@"OFFER CREATED:%@", offer.title);
	}
	
	return offer;
}


+ (Offer *)getOfferWithID:(NSNumber *)offerID inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Offer *offer = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"offerID == %@", offerID];
	
	NSError *error = nil;
	offer = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return offer;
}


+ (Offer *)updateOfferWithOfferData:(NSDictionary *)offerData 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Offer *offer = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:context];
	
	NSNumber *idNum = [NSNumber numberWithInt:[[offerData objectForKey:@"offerID"] intValue]];
	request.predicate = [NSPredicate predicateWithFormat:@"offerID == %@", idNum];
	
	NSError *error = nil;
	offer = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && offer) {
		
		// Assign the dictionary values to the corresponding object properties
		[offer safeSetValuesForKeysWithDictionary:offerData dateFormatter:nil];
	}
	
	else if (!error && !offer) offer = [self newOfferWithData:offerData inManagedObjectContext:context];
	
	return offer;
}


+ (Offer *)updateOfferWithID:(NSNumber *)offerID isFavourite:(BOOL)favourite 
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Offer *offer = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Offer" inManagedObjectContext:context];
	
	request.predicate = [NSPredicate predicateWithFormat:@"offerID == %@", offerID];
	
	NSError *error = nil;
	offer = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && offer) {
		
		// Assign the dictionary values to the corresponding object properties
		[offer setIsFavourite:[NSNumber numberWithBool:favourite]];
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
@dynamic provider;
@dynamic redeemed;
@dynamic thumbURL;
@dynamic title;
@dynamic version;
@dynamic isFavourite;

@end
