//
//  ACUIDocSummary.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 10.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACUIPart.h"
@interface ACUICDocSummary : ACUIPart
@property (weak, nonatomic) IBOutlet UILabel *lNet;
@property (weak, nonatomic) IBOutlet UILabel *lGross;

-(void)setNet:(double)net andGross:(double)gross withCurrency:(NSString*)currency;
-(void)setNet:(double)net andGross:(double)gross;

@end
