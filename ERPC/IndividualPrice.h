//
//  IndividualPrice.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article, Contractor, User;

@interface IndividualPrice : NSManagedObject

@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSNumber * pricenet;
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) Contractor *contractor;
@property (nonatomic, retain) User *user;

@end
