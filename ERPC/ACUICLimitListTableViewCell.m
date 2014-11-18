//
//  ACUICLimitListTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 08.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUICLimitListTableViewCell.h"
#import "Limit.h"
#import "ERPCCommon.h"

@implementation ACUICLimitListTableViewCell

-(void)setRecord:(id)record {
    [super setRecord:record];
    
    Limit *l = (Limit*)record;
    
    if ( l )  {
        self.lType.text = [l.unlimited boolValue] ? NSLocalizedString(@"Nieograniczony", nil) : NSLocalizedString(@"Określony", nil);
        self.lLimit.text = [NSString stringWithFormat:@"%@ %@", [l.limit moneyToString], l.currency];
        self.lUsed.text = [NSString stringWithFormat:@"%@ %@", [l.used moneyToString], l.currency];
        self.lRemain.text = [NSString stringWithFormat:@"%@ %@", [l.remain moneyToString], l.currency];
        self.lAllowedOverdue.text = [NSString stringWithFormat:@"%@ %@", [l.overdueallowed moneyToString], l.currency];
        self.lOverdue.text = [NSString stringWithFormat:@"%@ %@", [l.overdue moneyToString], l.currency];
    } else {
       self.lType.text = @"";
       self.lLimit.text = @"";
       self.lUsed.text = @"";
       self.lRemain.text = @"";
       self.lAllowedOverdue.text = @"";
       self.lOverdue.text = @"";
    }
    
    
}

@end
