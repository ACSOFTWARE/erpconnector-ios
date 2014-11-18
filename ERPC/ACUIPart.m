//
//  ACUIPart.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 10.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

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
