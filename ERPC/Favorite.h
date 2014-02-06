//
//  Favorite.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 02.11.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, Invoice;

@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * order;
@property (nonatomic, retain) Contractor *contractor;
@property (nonatomic, retain) Invoice *invoice;

@end
