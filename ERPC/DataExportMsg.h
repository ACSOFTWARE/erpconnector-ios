//
//  DataExportMsg.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DataExport;

@interface DataExportMsg : NSManagedObject

@property (nonatomic, retain) NSNumber * error;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) DataExport *dataexport;

@end
