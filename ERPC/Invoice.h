//
//  Invoice.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, DataExport, User;

@interface Invoice : NSManagedObject

@property (nonatomic, retain) NSDate * dateofissue;
@property (nonatomic, retain) NSData * doc;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * paid;
@property (nonatomic, retain) NSString * paymentmethod;
@property (nonatomic, retain) NSNumber * remaining;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSDate * termdate;
@property (nonatomic, retain) NSNumber * totalgross;
@property (nonatomic, retain) NSNumber * totalnet;
@property (nonatomic, retain) NSDate * uptodate;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) Contractor *customer;
@property (nonatomic, retain) DataExport *dataexport;
@property (nonatomic, retain) User *user;

@end
