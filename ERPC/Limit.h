//
//  Limit.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, User;

@interface Limit : NSManagedObject

@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSNumber * limit;
@property (nonatomic, retain) NSNumber * overdue;
@property (nonatomic, retain) NSNumber * overdueallowed;
@property (nonatomic, retain) NSNumber * remain;
@property (nonatomic, retain) NSNumber * unlimited;
@property (nonatomic, retain) NSNumber * used;
@property (nonatomic, retain) Contractor *contractor;
@property (nonatomic, retain) User *user;

@end
