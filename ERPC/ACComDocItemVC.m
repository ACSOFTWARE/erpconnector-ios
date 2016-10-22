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

#import "ACComDocItemVC.h"
#import "OrderItem.h"
#import "Order.h"
#import "Invoice.h"
#import "InvoiceItem.h"
#import "Contractor.h"
#import "DataExport.h"
#import "ERPCCommon.h"
#import "ACUIDeleteBtn.h"
#import "MFSideMenu/MFSideMenu.h"
#import "RemoteAction.h"
#import "BackgroundOperations.h"
#import "ACUIArticleButton1.h"

@implementation ACComDocItemVC {
    
    ACUIDataItem *di_shortcut;
    ACUIDataItem *di_name;
    ACUIDataItem *di_vatrate;
    ACUIDataItem *di_vatvalue;
    ACUIDataItem *di_price;
    ACUIDataItem *di_pricegross;
    ACUIDataItem *di_discount;
    ACUIDataItem *di_qty;
    ACUIDataItem *di_totalnet;
    ACUIDataItem *di_totalgross;
    ACUIDeleteBtn *btnDel;
    ACUIArticleButton1 *btnSH;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.form.delegate = self;
        self.form.Title = @"";
        di_shortcut = [self.form CreateDataItem:@"symbol"];
        di_name = [self.form CreateDataItem:@"nazwa"];
        di_vatrate = [self.form CreateDataItem:@"stawka vat"];
        di_vatvalue = [self.form CreateDataItem:@"wartość vat"];
        di_price = [self.form CreateDataItem:@"cena netto"];
        di_pricegross = [self.form CreateDataItem:@"cena brutto"];
        di_discount = [self.form CreateDataItem:@"rabat"];
        di_discount.maxValue = 100;
        di_qty = [self.form CreateDataItem:@"ilość"];
        di_totalnet = [self.form CreateDataItem:@"razem netto"];
        di_totalgross = [self.form CreateDataItem:@"razem brutto"];
        
        btnSH = [[ACUIArticleButton1 alloc] initWithNamedNib:@"ACUIArticleButton1" form:self.form];
        btnSH.topMargin = 20;
        btnSH.btnHistory.enabled = NO;
        [btnSH.btnHistory addTarget:self action:@selector(salesHistoryTouch:) forControlEvents:UIControlEventTouchDown];
        [self.form AddUIPart:btnSH];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (OrderItem*)orderItem {
    return [self.record isKindOfClass:[OrderItem class]] ? self.record : nil;
}

- (InvoiceItem*)invoiceItem {
    return [self.record isKindOfClass:[InvoiceItem class]] ? self.record : nil;
}


-(id)fetchData {

    return self.record;
}


-(void)onDataView {
    
    self.form.Title = @"";
    di_shortcut.data = @"";
    di_name.data = @"";
    di_vatrate.data = @"";
    di_vatvalue.data = @"";
    di_price.data = @"";
    di_price.readonly = YES;
    di_pricegross.data = @"";
    di_pricegross.readonly = YES;
    di_discount.data = @"";
    di_discount.readonly = YES;
    di_qty.data = @"";
    di_qty.readonly = YES;
    di_totalnet.data = @"";
    di_totalgross.data = @"";
    
    
    if ([self orderItem]) {
        
        NSNumber *price = [self.orderItem.pricenet doubleValue] > 0 ? self.orderItem.pricenet : self.orderItem.price;
        
        self.form.Title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Pozycja zamówienia", nil), self.orderItem.order.number];
        di_shortcut.data = self.orderItem.shortcut;
        di_name.data = self.orderItem.name;
        [di_vatrate setDoubleValue:[self.orderItem.vatrate doubleValue] withSuffix:@"%"];
        [di_vatvalue setMoneyValue:[self.orderItem.vatvalue doubleValue]];
        [di_price setMoneyValue:[price doubleValue]];
        [di_pricegross setMoneyValue:[price addVatByRate:self.orderItem.vatrate]];
        [di_discount setDoubleValue:[self.orderItem.discountpercent doubleValue] withSuffix:@"%"];
        di_discount.readonly = ![[self orderItem].order.dataexport.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_EDITING]];
        [di_qty setDoubleValue:[self.orderItem.qty doubleValue] withSuffix:self.orderItem.unit];
        di_price.readonly = di_discount.readonly;
        di_pricegross.readonly = di_discount.readonly;
        di_qty.readonly = di_discount.readonly;
        di_qty.editing = YES;
        [di_totalnet setMoneyValue:[self.orderItem.totalnet doubleValue]];
        [di_totalgross setMoneyValue:[self.orderItem.totalgross doubleValue]];
        
        [di_price removeDetailButton];
        
        if ( self.orderItem.order.dataexport != nil
             && (Common.HelloData.cap & SERVERCAP_INDIVIDUALPRICES) > 0
             && [price doubleValue] > 0
             && [self.orderItem.individualprice boolValue] == NO ) {
            [di_price addDetailButtonWithImageName:@"warning.png" addTarget:self touchAction:@selector(pricewarning:)];
        }
        
    } else {
        
        self.form.Title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Pozycja faktury", nil), self.invoiceItem.invoice.number];
        di_shortcut.data = self.invoiceItem.shortcut;
        di_name.data = self.invoiceItem.name;
        [di_vatrate setDoubleValue:[self.invoiceItem.vatrate doubleValue] withSuffix:@"%"];
        [di_vatvalue setMoneyValue:[self.invoiceItem.vatvalue doubleValue]];
        [di_price setMoneyValue:[self.invoiceItem.price doubleValue]];
        [di_pricegross setMoneyValue:[self.invoiceItem.price addVatByRate:self.invoiceItem.vatrate]];
        [di_discount setDoubleValue:[self.invoiceItem.discountpercent doubleValue] withSuffix:@"%"];
        di_discount.readonly = YES;
        [di_qty setDoubleValue:[self.invoiceItem.qty doubleValue] withSuffix:self.invoiceItem.unit];
        di_price.readonly = YES;
        di_pricegross.readonly = YES;
        di_qty.readonly = YES;
        di_qty.editing = NO;
        [di_totalnet setMoneyValue:[self.invoiceItem.totalnet doubleValue]];
        [di_totalgross setMoneyValue:[self.invoiceItem.totalgross doubleValue]];
        [di_price removeDetailButton];
        
    }
    
    if ( di_qty.readonly ) {
        if ( btnDel ) {
            [self.form RemoveUIPart:btnDel];
            btnDel = nil;
        }
    } else {
        if ( btnDel == nil ) {
            btnDel = [ACUIDeleteBtn btnWithForm:self.form];
            btnDel.topMargin = 20;
            btnDel.btnDel.enabled = YES;
            [btnDel addTargetForDeleteEvent:self action:@selector(doDelete:)];
            [self.form AddUIPart:btnDel];
        }
    }
    
    if ( [Common.DB fetchArticleByShortcut:di_shortcut.data] == nil ) {
        btnSH.btnHistory.enabled = NO;
        btnSH.btnHistory.alpha = 0.5;
        
        [ACRemoteOperation articleSearch:di_shortcut.data mtu:3];
        
    } else {
        btnSH.btnHistory.enabled = YES;
        btnSH.btnHistory.alpha = 1;
    }
    

    
}

-(BOOL)setSalesHistoryButtonState {
    
    if ( [Common.DB fetchArticleByShortcut:di_shortcut.data] == nil ) {
        btnSH.btnHistory.enabled = NO;
        btnSH.btnHistory.alpha = 0.5;
        
        return NO;
        
    };
    
    
    btnSH.btnHistory.enabled = YES;
    btnSH.btnHistory.alpha = 1;
    
    return YES;

}

+(void)calculateOrderItem:(OrderItem*)oi priceNet:(double)net discount:(double)discount qty:(double)qty vatRate:(double)vat {
    
    if ( oi == nil ) return;
    
    double totalnet = net - (net * discount / 100);
    totalnet*=qty;
    double vatvalue = totalnet * vat / 100;
   
    
    oi.totalnet = [NSNumber numberWithDouble:totalnet];
    oi.totalgross = [NSNumber numberWithDouble:totalnet+vatvalue];
    oi.vatvalue = [NSNumber numberWithDouble:vatvalue];
    oi.discountpercent = [NSNumber numberWithDouble:discount];
    oi.discount = [NSNumber numberWithDouble:(net * discount / 100.00)];
}

+(void)calculateOrderItem:(OrderItem*)oi {
    [ACComDocItemVC calculateOrderItem:oi priceNet:[oi.pricenet doubleValue] discount:[oi.discount doubleValue] qty:[oi.qty doubleValue] vatRate:[oi.vatrate doubleValue]];
};

-(void)calculatePrice {
    
    [ACComDocItemVC calculateOrderItem:self.orderItem priceNet:di_price.doubleValue discount:di_discount.doubleValue qty:di_qty.doubleValue vatRate:di_vatrate.doubleValue];

    [di_totalnet setMoneyValue:[self.orderItem.totalnet doubleValue]];
    [di_totalgross setMoneyValue:[self.orderItem.totalgross doubleValue]];
    [di_vatvalue setMoneyValue:[self.orderItem.vatvalue doubleValue]];

}

-(void)fieldChanged:(id)field {
    if ([self orderItem]) {
        
        if ( di_pricegross == field ) {
            
            double v = di_vatrate.doubleValue / 100 + 1;
            [di_price setMoneyValue:di_pricegross.doubleValue / v];
            field = di_price;
        };
        
        if ( di_price == field ) {
            /*TODO Poprawić pricenet to cena po rabacie, a price to cena wyjściowa*/
            [self orderItem].pricenet = [NSNumber numberWithDouble:di_price.doubleValue];
            [self orderItem].price = [self orderItem].pricenet;
            [di_pricegross setMoneyValue:[self.orderItem.price addVatByRate:self.orderItem.vatrate]];
        }
        
        if ( di_qty == field
             || di_discount == field
             || di_price == field ) {
            [self calculatePrice];
            [self orderItem].qty = [NSNumber numberWithDouble:di_qty.doubleValue];
            [Common.DB save];
            [Common.DB updateOrderSummary:[self orderItem].order];
        }
        
    } else {
        
    }
}

- (IBAction)doDelete:(id)sender {
    if ( btnDel ) {
        [Common.DB removeOrderItem:[self orderItem]];
        [self backButtonPressed:sender];
    }
}

- (void)pricewarning:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Cena wyjściowa dla tego towaru nie została pobrana z serwera dla tego Klienta.", nil) delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)salesHistoryTouch:(id)sender {
    
    Article *article = [Common.DB fetchArticleByShortcut:di_shortcut.data];
    
    if ( article != nil )
      [Common showArticleSalesHistory:article];
    
}

-(void)fetchRemoteDataWithRefreshTouch:(BOOL)rtouch {
    
    if ( [self setSalesHistoryButtonState] == NO ) {
        [ACRemoteOperation articleSearch:di_shortcut.data mtu:3];
    }
}


@end
