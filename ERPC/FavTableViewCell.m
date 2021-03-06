/*
 FavTableViewCell.m
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

#import "FavTableViewCell.h"
#import "Favorite.h"
#import "ERPCCommon.h"
#import "Invoice.h"

@implementation ACFavTableViewCell

@synthesize f = _f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)detailTouch:(id)sender {
    if ( _f ) {
        if ( _f.contractor ) {
            [Common showContractorVC:_f.contractor];
        } else if ( _f.invoice ) {
            [Common showComDoc:_f.invoice];
        } else if ( _f.order ) {
            [Common showComDoc:_f.order];
        }
    }
}
@end
