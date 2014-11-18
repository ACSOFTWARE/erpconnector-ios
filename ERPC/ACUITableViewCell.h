//
//  ACUITableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 12.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACUIForm.h"

@interface ACUITableViewCell : UITableViewCell

@property (nonatomic)id record;
@property (nonatomic, assign)   id <ACUITableViewDelegate> delegate;
@property (nonatomic)BOOL record_selected;
@property (nonatomic)BOOL selectMode;

@end
