//
//  Contractor+CoreDataProperties.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.03.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contractor.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contractor (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSString *email1;
@property (nullable, nonatomic, retain) NSString *email2;
@property (nullable, nonatomic, retain) NSString *email3;
@property (nullable, nonatomic, retain) NSString *houseno;
@property (nullable, nonatomic, retain) NSDate *invoices_last_resp_date;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *nip;
@property (nullable, nonatomic, retain) NSDate *orders_last_resp_date;
@property (nullable, nonatomic, retain) NSDate *payments_last_resp_date;
@property (nullable, nonatomic, retain) NSString *postcode;
@property (nullable, nonatomic, retain) NSString *region;
@property (nullable, nonatomic, retain) NSString *regon;
@property (nullable, nonatomic, retain) NSString *section;
@property (nullable, nonatomic, retain) NSString *shortcut;
@property (nullable, nonatomic, retain) NSString *street;
@property (nullable, nonatomic, retain) NSString *tel1;
@property (nullable, nonatomic, retain) NSString *tel2;
@property (nullable, nonatomic, retain) NSString *tel3;
@property (nullable, nonatomic, retain) NSNumber *trnlocked;
@property (nullable, nonatomic, retain) NSDate *uptodate;
@property (nullable, nonatomic, retain) NSNumber *visible;
@property (nullable, nonatomic, retain) NSString *www1;
@property (nullable, nonatomic, retain) NSString *www2;
@property (nullable, nonatomic, retain) NSString *www3;
@property (nullable, nonatomic, retain) NSNumber *limit;
@property (nullable, nonatomic, retain) DataExport *dataexport;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
