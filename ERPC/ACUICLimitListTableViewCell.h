//
//  ACUICLimitListTableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 08.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACUICLimitListTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lLimit;
@property (weak, nonatomic) IBOutlet UILabel *lUsed;
@property (weak, nonatomic) IBOutlet UILabel *lRemain;
@property (weak, nonatomic) IBOutlet UILabel *lAllowedOverdue;
@property (weak, nonatomic) IBOutlet UILabel *lOverdue;
@property (weak, nonatomic) IBOutlet UILabel *lType;

@end
