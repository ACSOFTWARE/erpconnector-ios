//
//  Invoice.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 26.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor;

@interface Invoice : NSManagedObject

@property (nonatomic, retain) NSDate * dateofissue;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * paid;
@property (nonatomic, retain) NSString * paymentform;
@property (nonatomic, retain) NSNumber * remaining;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSDate * termdate;
@property (nonatomic, retain) NSNumber * totalgross;
@property (nonatomic, retain) NSNumber * totalnet;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSData * doc;
@property (nonatomic, retain) Contractor *customer;

@end
