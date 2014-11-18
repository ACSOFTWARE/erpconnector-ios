//
//  ACDataExportVC.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 25.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIDataVC.h"
#import "ACUIForm.h"

@interface ACDataExportVC : ACUIDataVC <ACUITableViewDataSource>
-(void)onRecordAddError:(NSNotification *)notif;
@end
