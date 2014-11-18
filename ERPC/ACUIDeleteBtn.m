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

#import "ACUIDeleteBtn.h"
#import "ERPCCommon.h"

@implementation ACUIDeleteBtn {
    SEL _action;
    id _target;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

+ (ACUIDeleteBtn*)btnWithForm:(ACUIForm*)form {
   return [[ACUIDeleteBtn alloc] initWithNamedNib:@"ACUIDeleteBtn" form:form];
}


- (IBAction)deleteTouch:(id)sender {
    
    UIAlertView *aw = [[UIAlertView alloc] initWithTitle:@"" message: NSLocalizedString(@"Czy na pewno chcesz usunąć ?", nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Tak", nil)  otherButtonTitles:NSLocalizedString(@"Nie", nil),nil];
    [aw show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        if ( _target && _action ) {
            [_target performSelectorOnMainThread:_action withObject:self waitUntilDone:NO];
        }
    }
}

- (void)addTargetForDeleteEvent:(id)target action:(SEL)action {
    _action = action;
    _target = target;
}

@end
