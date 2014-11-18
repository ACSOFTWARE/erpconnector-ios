//
//  ACContractorTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 15.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACContractorTableViewCell.h"
#import "Contractor.h"
#import "ERPCCommon.h"

@implementation ACContractorTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setRecord:(id)record {
    
    [super setRecord:record];
    
    Contractor *c = (Contractor*)record;
    
    if ( c )  {
        
        self.lName.text = c.name;
        self.lName.textColor = [c.trnlocked boolValue] ? [UIColor redColor] : [UIColor blackColor] ;
        
        NSString *addr = @"";
        if ( c.street.length > 0) {
            addr = [[NSString stringWithFormat:@"ul. %@ %@", c.street, c.houseno] trim];
        }
        
        if ( c.postcode.length > 0 ) {
            if ( addr.length > 0 ) {
                addr = [NSString stringWithFormat:@"%@, %@", addr, c.postcode];
            } else {
                addr = c.postcode;
            }
        }
        
        self.lAddress.text = [[NSString stringWithFormat:@"%@ %@ %@", addr, c.city, c.country] trim];
        
    } else {
        self.lName.text = @"";
        self.lAddress.text = @"";
    }
    
}

- (IBAction)detailTouch:(id)sender {
    
    if ( self.delegate ) {
        [self.delegate detailSelected:0 record:self.record];
    }
}
@end
