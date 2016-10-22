//
//  Article+CoreDataProperties.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.01.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Article.h"

NS_ASSUME_NONNULL_BEGIN

@interface Article (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *codeex;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *group;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *pkwiu;
@property (nullable, nonatomic, retain) NSNumber *qty;
@property (nullable, nonatomic, retain) NSDate *sh_uptodate;
@property (nullable, nonatomic, retain) NSString *shortcut;
@property (nullable, nonatomic, retain) NSString *unit;
@property (nullable, nonatomic, retain) NSString *unitlistpricecurr;
@property (nullable, nonatomic, retain) NSNumber *unitlistpricegross;
@property (nullable, nonatomic, retain) NSNumber *unitlistpricenet;
@property (nullable, nonatomic, retain) NSString *unitpurchasecurr;
@property (nullable, nonatomic, retain) NSNumber *unitpurchaseprice;
@property (nullable, nonatomic, retain) NSString *unitretailcurr;
@property (nullable, nonatomic, retain) NSNumber *unitretailprice;
@property (nullable, nonatomic, retain) NSString *unitspecialcurr;
@property (nullable, nonatomic, retain) NSNumber *unitspecialprice;
@property (nullable, nonatomic, retain) NSString *unitwholesalecurr;
@property (nullable, nonatomic, retain) NSNumber *unitwholesaleprice;
@property (nullable, nonatomic, retain) NSDate *uptodate;
@property (nullable, nonatomic, retain) NSNumber *vatpercent;
@property (nullable, nonatomic, retain) NSString *vatrate;
@property (nullable, nonatomic, retain) NSNumber *visible;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
