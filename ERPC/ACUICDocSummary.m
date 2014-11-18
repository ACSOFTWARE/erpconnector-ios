//
//  ACUIDocSummary.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 10.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUICDocSummary.h"

@implementation ACUICDocSummary

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setNet:(double)net andGross:(double)gross withCurrency:(NSString*)currency {
    
    self.lNet.text = [NSString stringWithFormat:@"%.2f %@", net, currency];
    self.lGross.text = [NSString stringWithFormat:@"%.2f %@", gross, currency];
    
}

-(void)setNet:(double)net andGross:(double)gross {
    [self setNet:net andGross:gross withCurrency:@"zł"];
}

@end
