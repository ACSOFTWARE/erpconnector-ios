//
//  ACActicleTableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACActicleTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lShortcut;
@property (weak, nonatomic) IBOutlet UILabel *lTotalQty;
@property (weak, nonatomic) IBOutlet UILabel *lNet;
@property (weak, nonatomic) IBOutlet UILabel *lGross;
@property (weak, nonatomic) IBOutlet UIImageView *vDetail;

@end
