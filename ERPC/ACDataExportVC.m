/*
 Copyright (C) 2012-2014 AC SOFTWARE SP. Z O.O.
 (p.zygmunt@acsoftware.pl)
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "ACDataExportVC.h"
#import "ERPCCommon.h"
#import "RemoteAction.h"
#import "DataExport.h"
#import "Order.h"
#import "Contractor.h"
#import "ACComDocVC.h"
#import "ACUIDataExportButtons.h"
#import "ACUIDeleteBtn.h"
#import "MFSideMenu/MFSideMenu.h"

@implementation ACDataExportVC {
    ACUIDataItem *di_object;
    ACUIDataItem *di_status;
    ACUIDataItem *di_date1;
    ACUIDataItem *di_date2;
    ACUITableView *tv;
    NSFetchedResultsController *_frc;
    ACUIDataExportButtons *btns;
    
    UIAlertView *awSend;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _frc = nil;
        self.form.Title = [NSString stringWithFormat:@"Export danych do %@", Common.HelloData.erp_name] ;
        di_object = [self.form CreateDataItem:@"dotyczy"];
        di_status = [self.form CreateDataItem:@"status"];
        di_date1 = [self.form CreateDataItem:@"utworzono"];
        di_date2 = [self.form CreateDataItem:@"uaktualniono"];
        tv = [self.form CreateTableViewWithMargin:20 headerNibName:nil cellNibName:@"ACDataExportMsgTableViewCell"];
        tv.rowHeight = 56;
        tv.dataSource = self;
    
        
        btns = [[ACUIDataExportButtons alloc] initWithNamedNib:@"ACUIDataExportButtons" form:self.form];
        
        [btns.btnEdit addTarget:self action:@selector(editTouch:) forControlEvents:UIControlEventTouchDown];
        [btns.btnSend addTarget:self action:@selector(sendTouch:) forControlEvents:UIControlEventTouchDown];
        [self.form AddUIPart:btns];

    }
    return self;
}


- (DataExport*)de {
    return [self.record isKindOfClass:[DataExport class]] ? self.record : nil;
}


-(id)fetchData {
    _frc = nil;    

    DataExport *de = [Common.DB fetchDataExport:self.record];
    if ( de ) {
        _frc = [Common.DB fetchedDataExportResultMessages:self.de];
        [Common.DB performFetch:_frc];
        [tv reloadData];
    }


    return de;
}


-(NSFetchedResultsController*)frc {
    return _frc;
}


-(void)onDataView {
    
    di_object.data = @"";
    [di_object removeDetailButton];
    di_status.data = @"";
    di_date1.data = @"";
    di_date2.data = @"";
    
    btns.btnEdit.enabled = false;
    btns.btnSend.enabled = false;
    
    if ( self.de ) {
        
        if ( self.de.order ) {
            di_object.data = [ACERPCCommon dateExportTitle:self.de];
            [btns.btnEdit setTitle:@"Edytuj dane zamówienia"];
        }
        
        if ( ![self objectVCisPrevious] ) {
            [di_object addDetailButtonWithImageName:@"detail.png" addTarget:self touchAction:@selector(detailTouch:)];
        };
        
        
        di_status.data = [ACERPCCommon statusStringWithDataExport:self.de];
        di_status.actInidicator = [Common exportInProgress:self.de];
        
        
        [di_date1 setDateTimeValue:self.de.added];
        [di_date2 setDateTimeValue:self.de.uptodate];
        
        btns.btnSend.enabled = [self.de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] || [self.de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ERROR]];
        
        if ( [self.de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] ) {
            [btns.btnSend setTitle:@"Akceptuj"];
        } else {
            [btns.btnSend setTitle:@"Wyślij ponownie"];
        };
        
        btns.btnEdit.enabled = btns.btnSend.enabled;
    }
};

- (void)onRecordAddDone:(NSNotification *)notif {
    
    [self onRecordData:nil];
}

-(void)onRecordAddError:(NSNotification *)notif {
    [self onRecordData:nil];
}

- (ACUIDataVC*)objectVCisPrevious {
    id v = nil;
    
    if ( Common.navigationController.viewControllers.count > 1 ) {
        v = [Common.navigationController.viewControllers objectAtIndex:Common.navigationController.viewControllers.count-2];
        if ( [v isKindOfClass:[ACComDocVC class]]) {
            return v;
        }
    }
    
    return nil;
}

- (IBAction)editTouch:(id)sender {
    
    [Common.DB updateDataExport:self.de withStatus:QSTATUS_EDITING];
    [self onRecordDetailData:nil];
    
    if ( [self objectVCisPrevious] ) {
        [self backButtonPressed:sender];
    } else {
        [Common showComDoc:self.de.order];
    }
};

- (IBAction)sendTouch:(id)sender {
    
    NSString *msg = [self.de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] ? @"Potwierdzasz akceptację ?" : @"Czy na pewno chcesz wysłać ponownie ?";
    
    awSend = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(msg, nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Tak", nil)  otherButtonTitles:NSLocalizedString(@"Nie", nil),nil];
    [awSend show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        
        if ( alertView == awSend ) {
            [Common.DB removeDataExportMessages:self.de];
            [Common.DB updateDataExport:self.de withStatus:[self.de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] ? QSTATUS_USERCONFIRMATION_WAITING : QSTATUS_WAITING];
            [self onRecordDetailData:nil];
            [tv reloadData];
        }

    }
    
    awSend = nil;
}

-(void)doDelete:(id)sender {
    ACComDocVC *cdoc = (ACComDocVC*)[self objectVCisPrevious];
    
    if ( cdoc ) {
        [cdoc showRecord:nil];
        [cdoc removeFromParentViewController];
        [Common.DB removeOrder:self.de.order];
    }
    
    [self backButtonPressed:self];
}

-(void)detailTouch:(id)sender {
    if ( self.de ) {
        if ( self.de.order ) {
            Order *order = self.de.order;
            if ( self.de.shortcut
                 && self.de.shortcut.length > 0 ) {
                order = [Common.DB fetchOrderByShortcut:self.de.shortcut];
            }
            
            [Common showComDoc:order];
        }
    };
}

@end
