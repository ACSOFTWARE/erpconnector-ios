/*
 Copyright (C) 2012-2014 AC SOFTWARE SP. Z O.O.
 (p.zygmunt@acsoftware.pl)
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DataExport, User;

@interface Contractor : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * email1;
@property (nonatomic, retain) NSString * email2;
@property (nonatomic, retain) NSString * email3;
@property (nonatomic, retain) NSString * houseno;
@property (nonatomic, retain) NSDate * invoices_last_resp_date;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nip;
@property (nonatomic, retain) NSDate * orders_last_resp_date;
@property (nonatomic, retain) NSDate * payments_last_resp_date;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * regon;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSString * shortcut;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * tel1;
@property (nonatomic, retain) NSString * tel2;
@property (nonatomic, retain) NSString * tel3;
@property (nonatomic, retain) NSNumber * trnlocked;
@property (nonatomic, retain) NSDate * uptodate;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSString * www1;
@property (nonatomic, retain) NSString * www2;
@property (nonatomic, retain) NSString * www3;
@property (nonatomic, retain) DataExport *dataexport;
@property (nonatomic, retain) User *user;

@end
