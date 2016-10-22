//
//  ArticleSHItem+CoreDataProperties.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.01.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ArticleSHItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ArticleSHItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cname;
@property (nullable, nonatomic, retain) NSString *cshortcut;
@property (nullable, nonatomic, retain) NSDate *dateofsale;
@property (nullable, nonatomic, retain) NSString *invoice;
@property (nullable, nonatomic, retain) NSNumber *pricenet;
@property (nullable, nonatomic, retain) NSNumber *qty;
@property (nullable, nonatomic, retain) NSNumber *totalgross;
@property (nullable, nonatomic, retain) NSNumber *totalnet;
@property (nullable, nonatomic, retain) NSString *unit;
@property (nullable, nonatomic, retain) NSString *whdoc;
@property (nullable, nonatomic, retain) Article *article;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
