//
//  ACUICDocButtons.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 24.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUICDocButtons.h"
#import "ERPCCommon.h"
#import "RemoteAction.h"

@implementation ACUICDocButtons


- (id)initWithNamedNib:(NSString *)nib form:(ACUIForm*)_form {
    self = [super initWithNamedNib:nib form:_form];
    if ( self ) {
         [self.btnSend setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Prześlij do", nil), Common.HelloData.erp_name] forState:UIControlStateNormal];
    }
    
    return self;
}

@end
