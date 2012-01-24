//
//  Event.h
//  Easter Show
//
//  Created by Richard Lee on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * allDay;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * subCategory;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;


+ (Event *)eventWithEventData:(NSDictionary *)eventData 
	   inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)getEventWithID:(NSNumber *)eventID inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)updateEventWithEventData:(NSDictionary *)eventData 
			 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)insertEventWithData:(NSDictionary *)eventData 
		inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)eventWithID:(NSNumber *)eventID 
		inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSString *)categoryStringFromInt:(NSInteger)categoryInt;

@end
