//
//  EventDateTime.h
//  Easter Show
//
//  Created by Richard Lee on 6/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface EventDateTime : NSManagedObject

@property (nonatomic, retain) NSNumber * dateTimeID;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) Event *forEvent;

+ (EventDateTime *)dateTimeWithData:(NSDictionary *)dateData 
			 inManagedObjectContext:(NSManagedObjectContext *)context;

@end
