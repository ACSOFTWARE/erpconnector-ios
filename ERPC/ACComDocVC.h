//
//  ACComDocVCViewController.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 11.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACUIDataVC.h"
#import "ACUIForm.h"

@interface ACComDocVC : ACUIDataVC <ACUIFormDataSource, ACUITableViewDataSource, ACUITableViewDelegate, ACUIFormDelegate>
-(BOOL)isOrder;
-(void)onPriceData:(NSNotification *)notif;
@end
