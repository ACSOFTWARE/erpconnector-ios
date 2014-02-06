//
//  Server.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 24.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Server : NSManagedObject

@property (nonatomic, retain) NSString * drv_mfr;
@property (nonatomic, retain) NSString * drv_ver;
@property (nonatomic, retain) NSString * erp_mfr;
@property (nonatomic, retain) NSString * erp_name;
@property (nonatomic, retain) NSDecimalNumber * svr_vmajor;
@property (nonatomic, retain) NSDecimalNumber * svr_vminor;

@end
