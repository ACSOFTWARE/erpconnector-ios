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

#import "ACUIExportBtn.h"
#import "ERPCCommon.h"
#import "RemoteAction.h"

@implementation ACUIExportBtn


- (id)initWithNamedNib:(NSString *)nib form:(ACUIForm*)_form {
    self = [super initWithNamedNib:nib form:_form];
    if ( self ) {
         [self.btnSend setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Prześlij do", nil), Common.HelloData.erp_name] forState:UIControlStateNormal];
    }
    
    return self;
}

@end
