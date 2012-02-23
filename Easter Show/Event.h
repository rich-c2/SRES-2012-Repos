//
//  Event.h
//  Easter Show
//
//  Created by Richard Lee on 6/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventDateTime;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSSet *occursOnDays;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addOccursOnDaysObject:(EventDateTime *)value;
- (void)removeOccursOnDaysObject:(EventDateTime *)value;
- (void)addOccursOnDays:(NSSet *)values;
- (void)removeOccursOnDays:(NSSet *)values;

+ (Event *)newEventWithData:(NSDictionary *)eventData 
	 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)getEventWithID:(NSNumber *)eventID inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)updateEventWithEventData:(NSDictionary *)eventData 
			 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)updateEvent:(Event *)event withData:(NSDictionary *)eventData 
			inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)insertEventWithData:(NSDictionary *)eventData 
		inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Event *)eventWithID:(NSNumber *)eventID 
		inManagedObjectContext:(NSManagedObjectContext *)context;

@end
