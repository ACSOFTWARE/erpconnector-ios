//
//  ACUIDeleteBtn.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 25.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

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
