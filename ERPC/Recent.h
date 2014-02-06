//
//  Recent.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 24.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, Invoice;

@interface Recent : NSManagedObject

@property (nonatomic, retain) NSDate * last_access;
@property (nonatomic, retain) Contractor *contractor;
@property (nonatomic, retain) Invoice *invoice;

@end
