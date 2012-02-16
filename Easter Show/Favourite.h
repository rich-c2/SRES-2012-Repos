//
//  Favourite.h
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favourite : NSManagedObject

@property (nonatomic, retain) NSNumber * favouriteID;
@property (nonatomic, retain) NSString * favouriteType;
@property (nonatomic, retain) NSNumber * itemID;
@property (nonatomic, retain) NSString * title;

+ (Favourite *)favouriteWithFavouriteData:(NSDictionary *)favouriteData 
				   inManagedObjectContext:(NSManagedObjectContext *)context;

+ (BOOL)isItemFavourite:(NSNumber *)itemID favouriteType:(NSString *)type 
 inManagedObjectContext:(NSManagedObjectContext *)context;

@end
