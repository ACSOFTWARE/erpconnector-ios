//
//  InvoiceItem.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invoice;

@interface InvoiceItem : NSManagedObject

@property (nonatomic, retain) NSNumber * discount;
@property (nonatomic, retain) NSNumber * discountpercent;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * pricenet;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSNumber * totalgross;
@property (nonatomic, retain) NSNumber * totalnet;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSString * vatrate;
@property (nonatomic, retain) NSNumber * vatvalue;
@property (nonatomic, retain) Invoice *invoice;

@end
