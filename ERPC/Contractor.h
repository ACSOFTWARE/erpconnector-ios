//
//  Contractor.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 24.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contractor : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * email1;
@property (nonatomic, retain) NSString * email2;
@property (nonatomic, retain) NSString * email3;
@property (nonatomic, retain) NSString * houseno;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nip;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * regon;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * tel1;
@property (nonatomic, retain) NSString * tel2;
@property (nonatomic, retain) NSString * tel3;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * www1;
@property (nonatomic, retain) NSString * www2;
@property (nonatomic, retain) NSString * www3;
@property (nonatomic, retain) NSDate * invoices_last_resp_date;
@property (nonatomic, retain) NSDate * payments_last_resp_date;

@end
