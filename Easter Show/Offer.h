//
//  Offer.h
//  Easter Show
//
//  Created by Richard Lee on 10/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Offer : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * offerDescription;
@property (nonatomic, retain) NSNumber * offerID;
@property (nonatomic, retain) NSString * offerType;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSNumber * redeemed;

+ (Offer *)newOfferWithData:(NSDictionary *)offerData 
	 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Offer *)offerWithOfferData:(NSDictionary *)offerData 
	   inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Offer *)getOfferWithID:(NSNumber *)offerID inManagedObjectContext:(NSManagedObjectContext *)context;


+ (Offer *)updateOfferWithOfferData:(NSDictionary *)offerData 
			 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Offer *)insertOfferWithOfferData:(NSDictionary *)offerData 
			 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Offer *)offerWithID:(NSNumber *)offerID 
	inManagedObjectContext:(NSManagedObjectContext *)context;

@end
