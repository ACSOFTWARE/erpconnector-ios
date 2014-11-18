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

#import "ACDataExportTableViewCell.h"
#import "DataExport.h"
#import "ERPCCommon.h"

@implementation ACDataExportTableViewCell

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
    
    DataExport *de = (DataExport*)record;
    if ( de ) {
        
        if ( [Common exportInProgress:de] ) {
            self.vImg.hidden = YES;
            self.actInd.hidden = NO;
            [self.actInd startAnimating];
        } else {
            self.vImg.hidden = ![de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] && ![de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ERROR]];
            
            self.actInd.hidden = YES;
            if ( self.vImg.hidden == NO ) {
              [self.vImg setImage:[UIImage imageNamed:[de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ERROR]]? @"error.png" : @"warning.png"]];
            }
            
        }
        
        self.lInfo.text = [ACERPCCommon dateExportTitle:de];
        self.vDetail.hidden = NO;
        
    } else {
        self.vImg.hidden = YES;
        self.lInfo.text = @"";
        self.actInd.hidden = YES;
        self.vDetail.hidden = YES;
    }
    
}
@end
