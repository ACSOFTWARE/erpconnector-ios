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

#import "ACActicleTableViewCell.h"
#import "Article.h"
#import "ERPCCommon.h"

@implementation ACActicleTableViewCell

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
    
    Article *article = (Article*)record;
    
    if ( article )  {
        
        self.lName.text = [article.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.lShortcut.text = [article.shortcut stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        NSString *unit = article.unit.length == 0 ? @"" : [NSString stringWithFormat:@"/%@", article.unit];
        
        self.lTotalQty.text = [NSString stringWithFormat:@"%.2f%@ / %.2f%@",[Common.DB articleQtyByUserWarehouse:article], article.unit, [article.qty doubleValue], article.unit];
        
        self.lNet.text =  [NSString stringWithFormat:@"%.2f %@%@", [article.unitlistpricenet doubleValue], article.unitpurchasecurr, unit];
        
        self.lGross.text = [NSString stringWithFormat:@"%.2f %@%@", [article.unitlistpricegross doubleValue], article.unitpurchasecurr, unit];
        
        /*
        if ( [self isSeleceted:article.shortcut] == NSNotFound  ) {
            article.accessoryType = UITableViewCellAccessoryNone;
        } else {
            srticle.accessoryType = UITableViewCellAccessoryCheckmark;
        }
         */
        
    } else {
        self.lName.text = @"";
        self.lShortcut.text = @"";
        self.lTotalQty.text = @"";
        self.lNet.text = @"";
        self.lGross.text = @"";
        self.accessoryType = UITableViewCellAccessoryNone;
    }

}

-(void)setSelectMode:(BOOL)selectMode {
    [super setSelectMode:selectMode];
    self.vDetail.hidden = selectMode;
}

@end
