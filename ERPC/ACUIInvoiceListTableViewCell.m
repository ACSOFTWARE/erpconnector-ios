//
//  ACUIInvoiceListTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 18.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIInvoiceListTableViewCell.h"
#import "Invoice.h"

@implementation ACUIInvoiceListTableViewCell

-(void)setRecord:(id)record {
    [super setRecord:record];
    
    Invoice *i = (Invoice*)record;
    
    if ( i )  {
        
        self.lNumber.text = i.number;
        
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.lDateOfIssue.text = [dateFormatter stringFromDate:i.dateofissue];
        
        self.lTotalNet.text = [NSString stringWithFormat:@"%.2f zł", [i.totalnet doubleValue]];
        self.lTotalGross.text = [NSString stringWithFormat:@"%.2f zł", [i.totalgross doubleValue]];
        
    } else {
        self.lNumber.text = @"";
        self.lDateOfIssue.text = @"";
        self.lTotalNet.text = @"";
        self.lTotalGross.text = @"";
    }
    
    
}

@end
