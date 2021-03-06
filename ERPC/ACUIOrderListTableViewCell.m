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
