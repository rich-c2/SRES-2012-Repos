//
//  CarnivalRide.h
//  Easter Show
//
//  Created by Richard Lee on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CarnivalRide : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * rideDescription;
@property (nonatomic, retain) NSNumber * rideID;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;

+ (CarnivalRide *)rideWithRideData:(NSDictionary *)rideData 
			inManagedObjectContext:(NSManagedObjectContext *)context;

@end