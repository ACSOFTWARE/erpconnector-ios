//
//  ACArtSalesHistoryTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 26.01.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACArtSalesHistoryTableViewCell.h"
#import "ArticleSHItem+CoreDataProperties.h"

@implementation ACArtSalesHistoryTableViewCell

-(void)setRecord:(id)record {
    [super setRecord:record];
    
    ArticleSHItem *i= (ArticleSHItem*)record;
    
    if ( i )  {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.lDate.text = [dateFormatter stringFromDate:i.dateofsale];
        self.lQty.text = [NSString stringWithFormat:@"%@ %@", i.qty, i.unit];
        self.lPriceNet.text = [NSString stringWithFormat:@"%.2f zł", [i.pricenet doubleValue]];
        self.lTotalNet.text = [NSString stringWithFormat:@"%.2f zł", [i.totalnet doubleValue]];
        self.lContractor.text = i.cname;
        self.lInvoice.text = i.invoice;
        self.lWhDoc.text = i.whdoc;
        

    } else {

        self.lDate.text = @"";
        self.lQty.text = @"";
        self.lPriceNet.text = @"";
        self.lTotalNet.text = @"";
        self.lContractor.text = @"";
        self.lInvoice.text = @"";
        self.lWhDoc.text = @"";
        
    }
}

@end
