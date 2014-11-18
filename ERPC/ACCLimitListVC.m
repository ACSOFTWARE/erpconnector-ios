//
//  ACCLimitListVC.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 08.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACCLimitListVC.h"
#import "ERPCCommon.h"

@interface ACCLimitListVC ()

@end

@implementation ACCLimitListVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil topPanel:NO];
    if (self) {
        [self initTableWithNamedNib:@"ACUICLimitListTableViewCell"];
        self.refreshPanelVisible = NO;
        self.rowHeight = 185;
    }
    return self;
}

-(NSFetchedResultsController*)list_frc {
    
    return [Common.DB fetchedLimitsForContractor:self.record];
}

@end
