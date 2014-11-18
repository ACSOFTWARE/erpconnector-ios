//
//  ACContractorTableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 15.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACContractorTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lAddress;
- (IBAction)detailTouch:(id)sender;


@end
