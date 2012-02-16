//
//  ShoppingVendor.h
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShoppingVendor : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * vendorDescription;
@property (nonatomic, retain) NSNumber * shopID;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;

+ (ShoppingVendor *)vendorWithVendorData:(NSDictionary *)vendorData 
				  inManagedObjectContext:(NSManagedObjectContext *)context;

+ (ShoppingVendor *)getShoppingVendorWithID:(NSNumber *)shopID 
					 inManagedObjectContext:(NSManagedObjectContext *)context;

@end
