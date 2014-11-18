//
//  ACUIContractorButtons.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 07.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIPart.h"

@interface ACUIContractorButtons : ACUIPart
@property (weak, nonatomic) IBOutlet UIButton *btnInvoices;
@property (weak, nonatomic) IBOutlet UIButton *btnPayments;
@property (weak, nonatomic) IBOutlet UIButton *btnOrders;

@end
