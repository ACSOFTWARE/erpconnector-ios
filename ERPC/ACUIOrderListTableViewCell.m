//
//  ACUIComDocListTableCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 07.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIOrderListTableViewCell.h"
#import "Order.h"
#import "ERPCCommon.h"

@implementation ACUIOrderListTableViewCell

-(void)setRecord:(id)record {
    [super setRecord:record];
    
    Order *o = (Order*)record;
    
    if ( o )  {
        
        self.lNumber.text = o.number;
        
        if ( o.dataexport ) {
            self.lState.text = [ACERPCCommon statusStringWithDataExport:o.dataexport];
        } else if ( o.state ) {
            self.lState.text = o.state;
        }
        
        if ( [self.lState.text isEqualToString:@""] ) {
            self.lState.text = @"---";
        }
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.lDateOfIssue.text = [dateFormatter stringFromDate:o.dateofissue];
        self.lDateOfComplete.text = [o.dateofcomplete timeIntervalSince1970] == 0 ? @"---" : [dateFormatter stringFromDate:o.dateofcomplete];

        self.lNet.text = [NSString stringWithFormat:@"%.2f zł", [o.totalnet doubleValue]];
        self.lGross.text = [NSString stringWithFormat:@"%.2f zł", [o.totalgross doubleValue]];
        
    } else {
        self.lNumber.text = @"";
        self.lState.text = @"";
        self.lDateOfIssue.text = @"";
        self.lDateOfComplete.text = @"";
        self.lNet.text = @"";
        self.lGross.text = @"";
    }
    

}

@end
