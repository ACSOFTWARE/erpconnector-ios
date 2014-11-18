//
//  WareHouse.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article, User;

@interface WareHouse : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSDate * uptodate;
@property (nonatomic, retain) NSString * whid;
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) User *user;

@end
