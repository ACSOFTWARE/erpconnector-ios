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
