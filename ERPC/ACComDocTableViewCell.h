//
//  ACComDocTableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 13.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACComDocTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lShortcut;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lQty;
@property (weak, nonatomic) IBOutlet UILabel *lValue;
@property (weak, nonatomic) IBOutlet UILabel *lPrice;

@end
