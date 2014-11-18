//
//  ACDEWaitingQueue.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 15.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACDEWaitingQueue.h"
#import "ERPCCommon.h"

@interface ACDEWaitingQueue ()

@end

@implementation ACDEWaitingQueue

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topPanel:(BOOL)topp
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil topPanel:NO];
    if (self) {
        [self setBackgroundImageWithName:@""];
        [self initTableWithNamedNib:@"ACDataExportTableViewCell"];
    }
    return self;
}

-(NSFetchedResultsController*)list_frc {
    
    return [Common.DB fetchedDataExportQueue];
}

-(void)doOpenRecord:(id)record {
    if ( record ) {
        [Common showDataExportItem:record];
    }
}

@end
