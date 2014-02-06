//
//  Payment.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 24.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor;

@interface Payment : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSDate * dateofissue;
@property (nonatomic, retain) NSDate * dateofsale;
@property (nonatomic, retain) NSString * paymentform;
@property (nonatomic, retain) NSDate * termdate;
@property (nonatomic, retain) NSNumber * remaining;
@property (nonatomic, retain) NSNumber * totalnet;
@property (nonatomic, retain) NSNumber * totalgross;
@property (nonatomic, retain) Contractor *contractor;

@end
