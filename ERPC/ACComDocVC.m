//
//  ACComDocVCViewController.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 11.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACComDocVC.h"
#import "BackgroundOperations.h"
#import "Order.h"
#import "OrderItem.h"
#import "Invoice.h"
#import "InvoiceItem.h"
#import "Contractor.h"
#import "DataExport.h"
#import "ACUICDocSummary.h"
#import "ACComDocItemVC.h"
#import "ERPCCommon.h"
#import "RemoteAction.h"
#import "ACUICDocButtons.h"
#import "ACUICDocButtons2.h"
#import "ACUIDeleteBtn.h"
#import "ACDataExportVC.h"
#import "IndividualPrice.h"
#import "MFSideMenu/MFSideMenu.h"

@implementation ACComDocVC {
    ACUIDataItem *di_customer;
    ACUIDataItem *di_pm;
    ACUIDataItem *di_net;
    ACUIDataItem *di_gross;
    ACUIDataItem *di_state;
    ACUIDataItem *di_desc;
    ACUICDocSummary *summary;
    ACUITableView *itv;
    ACUICDocButtons *btns;
    ACUICDocButtons2 *btns2;
    ACUIDeleteBtn *btnDel;
    NSFetchedResultsController *_frc;
    BOOL _canCheckPrice;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.refreshPanelVisible = YES;
    
        self.form.delegate = self;
        di_customer = [self.form CreateDataItem:@"klient"];
        di_pm = [self.form CreateDataItem:@"forma płatności"];
        di_net = [self.form CreateDataItem:@"razem netto"];
        di_gross = [self.form CreateDataItem:@"razem brutto"];
        di_state = [self.form CreateDataItem:@"stan"];
        di_desc = [self.form CreateDataItem:@"opis/uwagi"];
        di_desc.numberOfLines = 10;
        itv = [self.form CreateTableViewWithMargin:20 headerNibName:@"ACUICDocTableHeader1" cellNibName:@"ACComDocTableViewCell"];
        itv.delegate = self;
        itv.dataSource = self;
        itv.rowHeight = 34;
        btns = nil;
        btns2 = nil;
        btnDel = nil;
        summary = [self.form CreateCDocSummary];
        
    }
    return self;
}

- (BOOL)exportVCisPrevious {
    id v = nil;
    
    if ( Common.navigationController.viewControllers.count > 1 ) {
        v = [Common.navigationController.viewControllers objectAtIndex:Common.navigationController.viewControllers.count-2];
        if ( [v isKindOfClass:[ACDataExportVC class]]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _canCheckPrice = YES;
}

- (Order*)order {
    return [self.record isKindOfClass:[Order class]] ? self.record : nil;
}

- (Invoice*)invoice {
    return [self.record isKindOfClass:[Invoice class]] ? self.record : nil;
}

-(DataExport*)dataexport {
    if ( self.order ) {
        return self.order.dataexport;
    } else if ( self.invoice ) {
        return self.invoice.dataexport;
    }
    
    return nil;
}

-(BOOL)isOrder {
    return [self order] != nil;
}

-(void)fetchRemoteDetailDataWithRefreshTouch:(BOOL)rtouch {
    
    if ( self.isOrder ) {
        
        [ACRemoteOperation itemsForOrderByShortcut:self.order.shortcut mtu:3];
        
    } else {
        [ACRemoteOperation itemsForInvoiceByShortcut:self.invoice.shortcut mtu:3];
    }
    
}

-(void)fetchRemoteDataByShortcut:(NSString*)shortcut RefreshTouch:(BOOL)rtouch {
    
    if ( self.isOrder ) {
        [ACRemoteOperation orderByShortcut:shortcut];
        
    } else {
        [ACRemoteOperation invoiceByShortcut:shortcut];
    }
}

-(void)fetchRemoteDataWithRefreshTouch:(BOOL)rtouch {
    [self fetchRemoteDataByShortcut:self.isOrder ? self.order.shortcut : self.invoice.shortcut RefreshTouch:rtouch];
}

-(id)fetchRecordByShortcut:(NSString*)shortcut {
    return self.isOrder ? [Common.DB fetchOrderByShortcut:shortcut] : [Common.DB fetchInvoiceByShortcut:shortcut];
}

-(id)fetchData {
    _frc = nil;
    
    if ( self.isOrder ) {
        
        Order *order = [Common.DB fetchOrder:self.order];
        if ( order ) {
            
            _frc = [Common.DB fetchedItemsOfOrder:order];
            [Common.DB performFetch:_frc];
            [itv reloadData];
        }
        
        return order;
        
    } else {
        
        Invoice *invoice = [Common.DB fetchInvoice:self.invoice];
        if ( invoice ) {
            
            _frc = [Common.DB fetchedItemsOfInvoice:invoice];
            [Common.DB performFetch:_frc];
            [itv reloadData];
        }
        
        return invoice;
    }

}

-(NSFetchedResultsController*)frc {
    return _frc;
}

-(void)onDataView {
  
    self.form.Title = @"";
    
    di_customer.data = @"";
    di_pm.data = @"";
    di_net.data = @"";
    di_gross.data = @"";
    di_state.data = @"";
    di_state.selection = nil;
    di_desc.data = @"";
    [summary setNet:0 andGross:0];
    
    if ( btns ) {
        [self.form RemoveUIPart:btns];
        btns = nil;
    }
    
    if ( btns2 ) {
        [self.form RemoveUIPart:btns2];
        btns2 = nil;
    }
    
    if ( btnDel ) {
        [self.form RemoveUIPart:btnDel];
        btnDel = nil;
    }

    if ( self.order ) {
        
        [di_state removeDetailButton];
        di_state.hidden = NO;
        [self removeRightNavBtn];
        
        if ( self.order.dataexport ) {
            
            [di_pm setDictionaryOfType:DICTTYPE_CONTRACTOR_PAYMENTMETHODS forContractor:self.order.customer];
            [ACRemoteOperation dictinaryOfType:DICTTYPE_CONTRACTOR_PAYMENTMETHODS forContractor:self.order.customer.shortcut];
     
            self.refreshPanelVisible = NO;
            self.form.Title = NSLocalizedString(@"Nowe zamówienie", nil);
            
            di_pm.readonly = ![self.order.dataexport.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_EDITING]];
            di_desc.readonly = di_pm.readonly;
            
            di_state.actInidicator = [Common exportInProgress:self.order.dataexport];
            di_state.readonly = di_pm.readonly;
            
            di_state.data = [ACERPCCommon statusStringWithDataExport:self.order.dataexport andStatusString:self.order.state];
            di_state.selection = self.order.state;
            
            if ( !di_state.readonly ) {
                [di_state setDictionaryOfType:DICTTYPE_NEWORDER_STATE forContractor:nil];
            }

            if ( [self.order.dataexport.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ERROR]] ) {
                [di_state addErrorButtonWithTarget:self touchAction:@selector(showDataExportDetails:)];
            } else if ( [self.order.dataexport.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] ) {
                [di_state addWarningButtonWithTarget:self touchAction:@selector(showDataExportDetails:)];
            }
            
            if ( (Common.HelloData.cap & SERVERCAP_INDIVIDUALPRICES) > 0 ) {
                [self checkIndividualPrices];
            }
            
        } else {
            
            
            self.refreshPanelVisible = YES;
            self.form.Title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Zamówienie nr:", nil), self.order.number];
            
            di_pm.readonly = YES;
            di_desc.readonly = YES;
            di_state.actInidicator = NO;
            
            di_state.data = self.order.state;
            di_state.selection = nil;
            self.form.refreshPanel.refreshBtnHidden = NO;
            [self showFavBtn];
            
        }
        
        if ( !di_pm.readonly ) {
            
            if ( btns == nil ) {
                btns = [[ACUICDocButtons alloc] initWithNamedNib:@"ACUICDocButtons" form:self.form];
                btns.topMargin = 20;
                [btns.btnSend addTarget:self action:@selector(sendTouch:) forControlEvents:UIControlEventTouchDown];
                [self.form AddUIPart:btns];
            }

            [self addAddButtonWithSelector:@selector(addTouch:)];
        }

        if ( self.order.dataexport
             && ![Common exportInProgress:self.order.dataexport] ) {
            if ( btnDel == nil ) {
                btnDel =  [ACUIDeleteBtn btnWithForm:self.form];
                btnDel.topMargin = 20;
                btnDel.btnDel.enabled = YES;
                [btnDel addTargetForDeleteEvent:self action:@selector(doDelete:)];
                [self.form AddUIPart:btnDel];
            }
        }

        
        di_customer.data = self.order.customer.name;
        di_pm.data = self.order.paymentmethod;
        di_desc.data = self.order.desc;
        [di_net setMoneyValue:[self.order.totalnet doubleValue]];
        [di_gross setMoneyValue:[self.order.totalgross doubleValue]];
        
        [summary setNet:[self.order.totalnet doubleValue] andGross:[self.order.totalgross doubleValue]];
        
    } else {
        
        di_state.hidden = YES;
        di_desc.hidden = YES;
        
        [self removeRightNavBtn];
        
        self.refreshPanelVisible = YES;
        self.form.Title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Faktura VAT nr:", nil), self.invoice.number];
        
        di_pm.readonly = YES;
        
        
        self.form.refreshPanel.refreshBtnHidden = NO;
        [self showFavBtn];
        
        di_customer.data = self.invoice.customer.name;
        di_pm.data = self.invoice.paymentmethod;
        [di_net setMoneyValue:[self.invoice.totalnet doubleValue]];
        [di_gross setMoneyValue:[self.invoice.totalgross doubleValue]];
        
        [summary setNet:[self.invoice.totalnet doubleValue] andGross:[self.invoice.totalgross doubleValue]];
        
        if ( btns2 == nil ) {
            btns2 = [[ACUICDocButtons2 alloc] initWithNamedNib:@"ACUICDocButtons2" form:self.form];
            btns2.topMargin = 20;
            [btns2.btnPreview addTarget:self action:@selector(previewTouch:) forControlEvents:UIControlEventTouchDown];
            [self.form AddUIPart:btns2];
        }
    }
    

}

-(void)showDataExportDetails:(id)sender {
    if ( [self exportVCisPrevious] ) {
        [self backButtonPressed:sender];
    } else {
        if ( self.dataexport ) {
            [Common showDataExportItem:self.dataexport];
        }
    }

}

-(void)fieldChanged:(id)field {
    if ( self.order ) {
        if ( field == di_pm ) {
            self.order.paymentmethod = [NSString stringWithString:di_pm.data];
            [Common.DB save];
        } else if ( field == di_desc ) {
            self.order.desc = [NSString stringWithString:di_desc.data];
            [Common.DB save];
        } else if ( field == di_state ) {
            self.order.state = [NSString stringWithString:di_state.data];
            [Common.DB save];
            di_state.data = [ACERPCCommon statusStringWithDataExport:self.order.dataexport andStatusString:self.order.state];
            di_state.selection = self.order.state;
        }
    };

}

- (IBAction)addTouch:(id)sender {
    if ( btns.btnSend.hidden == NO ) {
        [Common selectArticlesForDocument:self.order];
    }
}

- (IBAction)doDelete:(id)sender {
    if ( btnDel ) {
        [Common.DB removeOrder:self.order];
        [self backButtonPressed:sender];
    }
}

- (IBAction)sendTouch:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Czy na pewno chcesz wysłać zamówienie ?", nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Tak", nil)  otherButtonTitles:NSLocalizedString(@"Nie", nil),nil];
    [alertView show];
    
    
}

- (IBAction)previewTouch:(id)sender {
    [Common showComDocPreview:self.record];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        
        btns.btnSend.enabled = NO;
        btns.btnSend.hidden = YES;
        [Common.DB updateDataExport:self.order.dataexport withStatus:QSTATUS_WAITING];
        [self onRecordDetailData:nil];
    }
}

-(NSDate*)getDate {
    return self.order ? self.order.uptodate : self.invoice.uptodate;
}

-(void)recordSelected:(id)record cellSelected:(ACUITableViewCell*)cell {

    [Common showComDocItem:record];
}


-(void)checkIndividualPrices {
  
    if ( _canCheckPrice
         && di_pm.readonly == NO ) {
        
        _canCheckPrice = NO;
        BOOL _caclulateAndRefresh = NO;
        
        NSArray *items = [Common.DB orderItemsWithoutIndividualPrices:self.order];
        
        if ( items )
            for(int a=0;a<items.count;a++) {
                OrderItem *i = [items objectAtIndex:a];
                IndividualPrice *price = [Common.DB individualPriceForContractor:self.order.customer.shortcut articleShortcut:i.shortcut currency:self.order.currency];
                if ( price ) {
                    
                    double totalnet = 0;
                    
                    i.individualprice = [NSNumber numberWithBool:YES];
                    if ( [price.pricenet doubleValue] > 0 ) {
                        totalnet = [i.totalnet doubleValue];
                        i.pricenet = [NSNumber numberWithDouble:[price.pricenet doubleValue]];
                    }
                    
                    [ACComDocItemVC calculateOrderItem:i];
                    
                    if ( [i.discountpercent doubleValue] > 0
                        && totalnet > [i.totalnet doubleValue] ) {
                        i.discountpercent = [NSNumber numberWithDouble:0.00];
                        [ACComDocItemVC calculateOrderItem:i];
                    };
                    
                    [Common.DB save];
                    _caclulateAndRefresh = YES;
                } else {
                    [ACRemoteOperation priceForContractor:self.order.customer.shortcut withArticleShortcut:i.shortcut currency:self.order.currency];
                }
            }
 
        if ( _caclulateAndRefresh  ) {
            [Common.DB updateOrderSummary:self.order];
            [self showRecord:self.record];
        }
    }
}

-(void)onPriceData:(NSNotification *)notif {
    _canCheckPrice = YES;
    [self checkIndividualPrices];
}

@end
