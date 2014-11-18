//
//  Article.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Article : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pkwiu;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSString * unitlistpricecurr;
@property (nonatomic, retain) NSNumber * unitlistpricegross;
@property (nonatomic, retain) NSNumber * unitlistpricenet;
@property (nonatomic, retain) NSString * unitpurchasecurr;
@property (nonatomic, retain) NSNumber * unitpurchaseprice;
@property (nonatomic, retain) NSString * unitretailcurr;
@property (nonatomic, retain) NSNumber * unitretailprice;
@property (nonatomic, retain) NSString * unitspecialcurr;
@property (nonatomic, retain) NSNumber * unitspecialprice;
@property (nonatomic, retain) NSString * unitwholesalecurr;
@property (nonatomic, retain) NSNumber * unitwholesaleprice;
@property (nonatomic, retain) NSDate * uptodate;
@property (nonatomic, retain) NSNumber * vatpercent;
@property (nonatomic, retain) NSString * vatrate;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) User *user;

@end
