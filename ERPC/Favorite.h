//
//  Favorite.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, Invoice, Order, User;

@interface Favorite : NSManagedObject

@property (nonatomic, retain) Contractor *contractor;
@property (nonatomic, retain) Invoice *invoice;
@property (nonatomic, retain) Order *order;
@property (nonatomic, retain) User *user;

@end
