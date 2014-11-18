//
//  ACDataExportTableViewCell.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 25.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableViewCell.h"

@interface ACDataExportTableViewCell : ACUITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *vImg;
@property (weak, nonatomic) IBOutlet UILabel *lInfo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInd;
@property (weak, nonatomic) IBOutlet UIImageView *vDetail;

@end
