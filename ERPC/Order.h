//
//  Order.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, DataExport, User;

@interface Order : NSManagedObject

@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSDate * dateofcomplete;
@property (nonatomic, retain) NSDate * dateofissue;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * paymentmethod;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * termofcontract;
@property (nonatomic, retain) NSNumber * totalgross;
@property (nonatomic, retain) NSNumber * totalnet;
@property (nonatomic, retain) NSDate * uptodate;
@property (nonatomic, retain) NSNumber * valuerealized;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) Contractor *customer;
@property (nonatomic, retain) DataExport *dataexport;
@property (nonatomic, retain) User *user;

@end
