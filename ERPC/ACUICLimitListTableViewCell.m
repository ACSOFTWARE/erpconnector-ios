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
