//
//  ACUIComDocList.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 07.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACComDocListVC.h"
#import "ERPCCommon.h"
#import "Contractor.h"
#import "BackgroundOperations.h"
#import "MFSideMenu/MFSideMenu.h"
#import "RemoteAction.h"

@interface ACComDocListVC ()

@end

@implementation ACComDocListVC {
    BOOL _OrderList;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topPanel:(BOOL)topp
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil topPanel:NO];
    if (self) {
        
        if ( _OrderList ) {
            [self initTableWithNamedNib:@"ACUIOrderListTableViewCell" andHeaderNib:@"ACUIOrderListTableHeader"];
            [self addAddButtonWithSelector:@selector(addTouch:)];
        } else {
            [self initTableWithNamedNib:@"ACUIInvoiceListTableViewCell" andHeaderNib:@"ACUIInvoiceListTableHeader"];
        }

        
        self.refreshPanelVisible = YES;
    }
    return self;
}

-(id)initAsOrderList:(BOOL)orderList {
    _OrderList = orderList;
    return [super init];
}

-(Contractor*)contractor {
        return (Contractor*)self.record;
}

-(NSFetchedResultsController*)list_frc {
    
    return _OrderList ? [Common.DB fetchedOrdersForContractor:self.record] : [Common.DB fetchedInvoicesForContractor:self.record];
}

-(void)doOpenRecord:(id)record {
    if ( record ) {
        [Common showComDoc:record];
    }
}

-(NSDate*)getDate {
    return _OrderList ? self.contractor.orders_last_resp_date : self.contractor.invoices_last_resp_date;
}

-(void)fetchRemoteDetailDataWithRefreshTouch:(BOOL)rtouch {
    
    if ( _OrderList ) {

        [ACRemoteOperation ordersForCustomerWithShortcut:self.contractor.shortcut mtu:3 fromDate:nil ];
    } else {
        
        [ACRemoteOperation invoicesForCustomerWithShortcut:self.contractor.shortcut mtu:3 fromDate:nil ];
    }
    
}

-(void)onDetailDataLoadDone:(NSNotification *)notif {
    if ( _OrderList ) {
        self.contractor.orders_last_resp_date = [NSDate date];
    } else {
        self.contractor.invoices_last_resp_date = [NSDate date];
    }
    
    [Common.DB updateContractor:self.contractor];
    
    [super onDetailDataLoadDone:notif];
}

-(IBAction)addTouch:(id)sender {
    
    if ( Common.HelloData.cap & SERVERCAP_NEWORDER
         && Common.HelloData.cap & SERVERCAP_ARTICLE_SIMPLESEARCH ) {
        
        [Common newOrderForCustomer:self.contractor];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Ten serwer nie pozwala na dodawanie zamówień. Skontaktuj się z Administratorem serwera.", nil) delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }

}


@end
