//
//  User.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Server;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * lastaccess;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * warehouse;
@property (nonatomic, retain) Server *server;

@end
