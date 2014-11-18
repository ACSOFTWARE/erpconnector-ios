//
//  ACDataExportTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 25.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACDataExportTableViewCell.h"
#import "DataExport.h"
#import "ERPCCommon.h"

@implementation ACDataExportTableViewCell

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
    
    DataExport *de = (DataExport*)record;
    if ( de ) {
        
        if ( [Common exportInProgress:de] ) {
            self.vImg.hidden = YES;
            self.actInd.hidden = NO;
            [self.actInd startAnimating];
        } else {
            self.vImg.hidden = ![de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] && ![de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ERROR]];
            
            self.actInd.hidden = YES;
            if ( self.vImg.hidden == NO ) {
              [self.vImg setImage:[UIImage imageNamed:[de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ERROR]]? @"error.png" : @"warning.png"]];
            }
            
        }
        
        self.lInfo.text = [ACERPCCommon dateExportTitle:de];
        self.vDetail.hidden = NO;
        
    } else {
        self.vImg.hidden = YES;
        self.lInfo.text = @"";
        self.actInd.hidden = YES;
        self.vDetail.hidden = YES;
    }
    
}
@end
