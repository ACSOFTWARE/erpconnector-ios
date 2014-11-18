//
//  Server.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

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
