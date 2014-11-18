//
//  ACUIComDocListTableCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 07.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACUIOrderListTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lNumber;
@property (weak, nonatomic) IBOutlet UILabel *lState;
@property (weak, nonatomic) IBOutlet UILabel *lDateOfIssue;
@property (weak, nonatomic) IBOutlet UILabel *lDateOfComplete;
@property (weak, nonatomic) IBOutlet UILabel *lNet;
@property (weak, nonatomic) IBOutlet UILabel *lGross;

@end
