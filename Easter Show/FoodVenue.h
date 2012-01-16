//
//  FoodVenue.h
//  Easter Show
//
//  Created by Richard Lee on 16/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FoodVenue : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * venueDescription;
@property (nonatomic, retain) NSNumber * venueID;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSString * subtitle;


+ (FoodVenue *)venueWithVenueData:(NSDictionary *)venueData 
		   inManagedObjectContext:(NSManagedObjectContext *)context;

+ (FoodVenue *)updateVenueWithVenueData:(NSDictionary *)venueData 
				 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (FoodVenue *)venueWithID:(NSNumber *)venueID 
	inManagedObjectContext:(NSManagedObjectContext *)context;


@end
