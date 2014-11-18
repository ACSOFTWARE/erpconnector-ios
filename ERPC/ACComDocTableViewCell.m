/*
 Copyright (C) 2012-2014 AC SOFTWARE SP. Z O.O.
 (p.zygmunt@acsoftware.pl)
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

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
