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
