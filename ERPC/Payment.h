//
//  Payment.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, User;

@interface Payment : NSManagedObject

@property (nonatomic, retain) NSDate * dateofissue;
@property (nonatomic, retain) NSDate * dateofsale;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * paymentform;
@property (nonatomic, retain) NSNumber * remaining;
@property (nonatomic, retain) NSDate * termdate;
@property (nonatomic, retain) NSNumber * totalgross;
@property (nonatomic, retain) NSNumber * totalnet;
@property (nonatomic, retain) Contractor *contractor;
@property (nonatomic, retain) User *user;

@end
