//
//  ACArtSalesHistoryTableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 26.01.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACArtSalesHistoryTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lDate;
@property (weak, nonatomic) IBOutlet UILabel *lQty;
@property (weak, nonatomic) IBOutlet UILabel *lPriceNet;
@property (weak, nonatomic) IBOutlet UILabel *lTotalNet;
@property (weak, nonatomic) IBOutlet UILabel *lContractor;
@property (weak, nonatomic) IBOutlet UILabel *lInvoice;
@property (weak, nonatomic) IBOutlet UILabel *lWhDoc;

@end
