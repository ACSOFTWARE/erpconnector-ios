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

#import "ACUIForm.h"
#import "ACUIPart.h"

@implementation ACUIPart {
    int _topMargin;
}

@synthesize topMargin = _topMargin;

- (id)initWithNamedNib:(NSString *)nib form:(ACUIForm*)_form
{
    CGRect frame = [_form getBaseFrame];
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _topMargin = 0;
        UIView *v = [ACUIPart viewByNamedNib:nib owner:self frame:self.frame];
        if ( v ) {
            CGRect frame = self.frame;
            frame.size.height = v.frame.size.height;
            self.frame = frame;
            [self addSubview:v];
        }
    }
    
    return self;
}

+ (UIView*)viewByNamedNib:(NSString*)nib owner:(id)_owner {
    
    UIView *result = nil;
    
    if ( nib ) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:nib owner:_owner options:nil];
        if ( arr
            && arr.count > 0 ) {
            id obj1 = [arr objectAtIndex:0];
            if ( [obj1 isKindOfClass:[UIView class]] ) {
                result = obj1;
            }
        }
    }
    
    return result;
};

+ (UIView*)viewByNamedNib:(NSString*)nib owner:(id)_owner frame:(CGRect)_frame {
    
    UIView *result = [ACUIPart viewByNamedNib:nib owner:_owner];
    
    if ( result ) {
        CGRect frame = result.frame;
        frame.size.width = _frame.size.width;
        frame.origin.x = _frame.origin.x;
        result.frame = frame;
    }
    
    return result;
}


@end
