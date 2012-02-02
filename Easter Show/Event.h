//
//  Event.h
//  Easter Show
//
//  Created by Richard Lee on 2/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * version;


+ (Event *)newEventWithData:(NSDictionary *)eventData 
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
