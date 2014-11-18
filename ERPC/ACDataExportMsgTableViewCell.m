//
//  ACDataExportMsgTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 25.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACDataExportMsgTableViewCell.h"
#import "DataExportMsg.h"

@implementation ACDataExportMsgTableViewCell {
    UIImage *warningImg;
    UIImage *errorImg;
}



-(void)setRecord:(id)record {
    [super setRecord:record];
    
    DataExportMsg *msg = (DataExportMsg*)record;
    if ( msg ) {
        self.lMsg.text = msg.message;
        [self.vImg setImage:[UIImage imageNamed:[msg.error boolValue]? @"error.png" : @"warning.png"]];
    } else {
        self.lMsg.text = @"";
    }
    
}


@end
