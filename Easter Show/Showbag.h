//
//  Showbag.h
//  Easter Show
//
//  Created by Richard Lee on 11/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Showbag : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * showbagDescription;
@property (nonatomic, retain) NSNumber * showbagID;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * rrPrice;

+ (Showbag *)showbagWithShowbagData:(NSDictionary *)showbagData 
			 inManagedObjectContext:(NSManagedObjectContext *)context;

@end
