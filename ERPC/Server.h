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


@interface Server : NSManagedObject

@property (nonatomic, retain) NSNumber * cap;
@property (nonatomic, retain) NSString * drv_mfr;
@property (nonatomic, retain) NSString * drv_ver;
@property (nonatomic, retain) NSString * erp_mfr;
@property (nonatomic, retain) NSString * erp_name;
@property (nonatomic, retain) NSString * instanceid;
@property (nonatomic, retain) NSNumber * offline_validitytime;
@property (nonatomic, retain) NSNumber * online_validitytime;
@property (nonatomic, retain) NSNumber * svr_vmajor;
@property (nonatomic, retain) NSNumber * svr_vminor;

@end
