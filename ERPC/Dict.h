//
//  Dict.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, User;

@interface Dict : NSManagedObject

@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * uptodate;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) Contractor *contractor;
@property (nonatomic, retain) User *user;

@end
