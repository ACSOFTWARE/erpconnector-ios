//
//  ACUIInvoiceListTableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 18.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACUIInvoiceListTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lNumber;
@property (weak, nonatomic) IBOutlet UILabel *lDateOfIssue;
@property (weak, nonatomic) IBOutlet UILabel *lTotalNet;
@property (weak, nonatomic) IBOutlet UILabel *lTotalGross;

@end
