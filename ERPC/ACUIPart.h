//
//  ACUIPart.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 10.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACUIForm;
@interface ACUIPart : UIView
- (id)initWithNamedNib:(NSString *)nib form:(ACUIForm*)_form;
+ (UIView*)viewByNamedNib:(NSString*)nib owner:(id)_owner;
+ (UIView*)viewByNamedNib:(NSString*)nib owner:(id)_owner frame:(CGRect)_frame;
@property (nonatomic) int topMargin;
@end
