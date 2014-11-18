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
