//
//  ACUIDeleteBtn.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 25.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIPart.h"

@interface ACUIDeleteBtn : ACUIPart
@property (weak, nonatomic) IBOutlet UIButton *btnDel;

- (IBAction)deleteTouch:(id)sender;
- (void)addTargetForDeleteEvent:(id)target action:(SEL)action;
+ (ACUIDeleteBtn*)btnWithForm:(ACUIForm*)form;

@end
