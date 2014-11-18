//
//  ACComDocTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 13.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACComDocTableViewCell.h"
#import "OrderItem.h"
#import "InvoiceItem.h"
#import "Order.h"
#import "ERPCCommon.h"
#import "RemoteAction.h"

@implementation ACComDocTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setRecord:(id)record {
    [super setRecord:record];
    
    if ( !record ) {
        self.lName.text = @"";
        self.lShortcut.text = @"";
        self.lPrice.text = @"";
        self.lQty.text = @"";
        self.lValue.text = @"";
        return;
    }
    
    if (  [record isKindOfClass:[OrderItem class]] ) {
        
        OrderItem *item = (OrderItem*)record;
        
        self.lName.text = item.name;
        self.lShortcut.text = item.shortcut;
        self.lPrice.text = [NSString stringWithFormat:@"%.2f zł", [item.pricenet doubleValue]];
        self.lQty.text = [NSString stringWithFormat:@"%@ %@", item.qty, item.unit];
        self.lValue.text = [NSString stringWithFormat:@"%.2f zł | %.2f zł", [item.totalnet doubleValue], [item.totalgross doubleValue]];
        
        if ( item.order.dataexport
            && (Common.HelloData.cap & SERVERCAP_INDIVIDUALPRICES) > 0
            && [item.pricenet doubleValue] > 0
            && [item.individualprice boolValue] == NO ) {
            self.lPrice.textColor = [UIColor redColor];
            
        } else {
            self.lPrice.textColor = [UIColor blackColor];
        }
        
    } else {
        
       InvoiceItem *item = (InvoiceItem*)record;
        
        if ( item )  {
            self.lName.text = item.name;
            self.lShortcut.text = item.shortcut;
            self.lPrice.text = [NSString stringWithFormat:@"%.2f zł", [item.pricenet doubleValue]];
            self.lQty.text = [NSString stringWithFormat:@"%@ %@", item.qty, item.unit];
            self.lValue.text = [NSString stringWithFormat:@"%.2f zł | %.2f zł", [item.totalnet doubleValue], [item.totalgross doubleValue]];
            self.lPrice.textColor = [UIColor blackColor];
        };
    
    }

}



@end
