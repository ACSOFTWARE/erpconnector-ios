/*
 ACRemoteOperation.m
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

#import "BackgroundOperations.h"
#import "ERPCCommon.h"
#import "RemoteAction.h"
#import "Database.h"
#import "Invoice.h"
#import "DataExport.h"

#define ACREMOTEOPERATIONTYPE_REGISTERDEVICE         1
#define ACREMOTEOPERATIONTYPE_LOGIN                  2
#define ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH        3
#define ACREMOTEOPERATIONTYPE_INVOICE_LIST           4
#define ACREMOTEOPERATIONTYPE_INVOICE_ITEMS          5
#define ACREMOTEOPERATIONTYPE_ORDER_LIST             6
#define ACREMOTEOPERATIONTYPE_ORDER_ITEMS            7
#define ACREMOTEOPERATIONTYPE_OUTSTANDING_PAYMENTS   8
#define ACREMOTEOPERATIONTYPE_INVOICE_GETDOCUMENT    9
#define ACREMOTEOPERATIONTYPE_ARTICLE_SEARCH         10
#define ACREMOTEOPERATIONTYPE_EXPORT                 11
#define ACREMOTEOPERATIONTYPE_GETDICTIONARY          12
#define ACREMOTEOPERATIONTYPE_GETPRICE               13
#define ACREMOTEOPERATIONTYPE_LIMITS                 14
#define ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY   15

#define DOC_MAX_DATA_PACKET 32768

@interface ACROPriceCheckQueueItem : NSObject
@property NSString *contractor;
@property NSString *article;
@property NSString *currency;
@end

@implementation ACROPriceCheckQueueItem
@synthesize contractor;
@synthesize article;
@synthesize currency;
@end

NSMutableArray *priceCheckQueue;

@implementation ACRemoteOperation {
    int _optype;
    ACRemoteAction *_RA;
    NSString *_str1;
    NSString *_str2;
    int _int1;
    BOOL _bool1;
    NSDate *_date1;
    id _id1;
    ACDatabase *_DB;
    DataExport *_de;
    BOOL _deleted;
}

+(void)registerDevice {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_REGISTERDEVICE];
    [Common.OpQueue addOperation:Op];
}

+(void)login:(NSString*)Login withPassword:(NSString*)password {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_LOGIN];
    [Op setStr1:Login];
    [Op setStr2:password];
    [Common.OpQueue addOperation:Op];
}

+(void)search:(NSString*)text mtu:(int)MTU onlyByShortcut:(BOOL)osc opType:(int)type{
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:type];
    [Op setStr1:text];
    [Op setInt1:MTU];
    [Op setBool1:osc];
    [Common.OpQueue addOperation:Op];
};

+(void)customerSearch:(NSString*)text mtu:(int)MTU {
    [ACRemoteOperation search:text mtu:MTU onlyByShortcut:NO opType:ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH];
}

+(void)customerSearchOnlyByShortcut:(NSString*)shortcut {
    [ACRemoteOperation search:shortcut mtu:1 onlyByShortcut:YES opType:ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH];
}

+(void)articleSearch:(NSString*)text mtu:(int)MTU {
    [ACRemoteOperation search:text mtu:MTU onlyByShortcut:NO opType:ACREMOTEOPERATIONTYPE_ARTICLE_SEARCH];
}

+(void)articleSalesHistory:(NSString*)shortcut mtu:(int)MTU {
    
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY];
    [Op setStr1:shortcut];
    [Op setInt1:MTU];
    [Common.OpQueue addOperation:Op];
}

+(void)commercialDocByShortcut:(NSString*)shortcut Optype:(int)optype CustomerShortcut:(NSString*)cshortcut mtu:(int)MTU fromDate:(NSDate*)date {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:optype];
    [Op setStr1:cshortcut];
    [Op setStr2:shortcut];
    [Op setDate1:date];
    [Op setInt1:MTU];
    [Common.OpQueue addOperation:Op];
}

+(void)invoicesForCustomerWithShortcut:(NSString*)shortcut mtu:(int)MTU fromDate:(NSDate*)date {
    [self commercialDocByShortcut:nil Optype:ACREMOTEOPERATIONTYPE_INVOICE_LIST CustomerShortcut:shortcut mtu:MTU fromDate:date];
}

+(void)invoiceByShortcut:(NSString*)shortcut {
    [self commercialDocByShortcut:shortcut Optype:ACREMOTEOPERATIONTYPE_INVOICE_LIST CustomerShortcut:nil mtu:1 fromDate:nil];
}

+(void)itemsForInvoiceByShortcut:(NSString*)ishortcut mtu:(int)MTU {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_INVOICE_ITEMS];
    [Op setStr1:ishortcut];
    [Op setInt1:MTU];
    [Common.OpQueue addOperation:Op];
}

+(void)outstandingPaymentsForCustomerWithShortcut:(NSString*)shortcut {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_OUTSTANDING_PAYMENTS];
    [Op setStr1:shortcut];
    [Common.OpQueue addOperation:Op];
}

+(void)getInvoiceDocumentWithShortcut:(NSString*)shortcut {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_INVOICE_GETDOCUMENT];
    [Op setStr1:shortcut];
    [Common.OpQueue addOperation:Op];
}

+(void)ordersForCustomerWithShortcut:(NSString*)shortcut mtu:(int)MTU fromDate:(NSDate*)date {
    
    [self commercialDocByShortcut:nil Optype:ACREMOTEOPERATIONTYPE_ORDER_LIST CustomerShortcut:shortcut mtu:MTU fromDate:date];
}

+(void)orderByShortcut:(NSString*)shortcut {
    [self commercialDocByShortcut:shortcut Optype:ACREMOTEOPERATIONTYPE_ORDER_LIST CustomerShortcut:nil mtu:1 fromDate:nil];
}


+(void)itemsForOrderByShortcut:(NSString*)oshortcut mtu:(int)MTU {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_ORDER_ITEMS];
    [Op setStr1:oshortcut];
    [Op setInt1:MTU];
    [Common.OpQueue addOperation:Op];
}

+(void)doExport {
    if ( Common.OpExportQueue.operationCount == 0 ) {
        
        ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
        [Op setOptype:ACREMOTEOPERATIONTYPE_EXPORT];
        [Common.OpExportQueue addOperation:Op];
    }
}

+(void)dictinaryOfType:(int)type forContractor:(NSString*)contractor {
    
    if ( Common.HelloData.cap & SERVERCAP_DICTRIONARIES )  {
        
        ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
        [Op setOptype:ACREMOTEOPERATIONTYPE_GETDICTIONARY];
        [Op setStr1:contractor];
        [Op setInt1:type];
        [Common.OpQueue addOperation:Op];
        
    }
}

+(void)priceForContractor:(NSString*)contractor withArticleShortcut:(NSString*)article currency:(NSString*)currency {

    if ( !(Common.HelloData.cap & SERVERCAP_INDIVIDUALPRICES ) )  return;
    
    if ( currency == nil )
        currency = @"";
        
    BOOL add = NO;
    
    @synchronized(priceCheckQueue) {
        if ( priceCheckQueue == nil ) {
            priceCheckQueue = [[NSMutableArray alloc] init];
            add = YES;
        }

        ACROPriceCheckQueueItem *item = nil;
        
        for(int a=0;a<priceCheckQueue.count;a++) {
            item = [priceCheckQueue objectAtIndex:a];
            if ( [item.contractor isEqualToString:contractor]
                 && [item.article isEqualToString:article]
                && [item.currency isEqualToString:currency] ) {
                break;
            } else {
                item = nil;
            }
        }
        
        if ( item == nil ) {
            item = [[ACROPriceCheckQueueItem alloc] init];
            item.contractor = [NSString stringWithString:contractor];
            item.article = [NSString stringWithString:article];
            item.currency = [NSString stringWithString:currency];
            [priceCheckQueue addObject:item];
        }
    }
    
    if ( add ) {
        ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
        [Op setOptype:ACREMOTEOPERATIONTYPE_GETPRICE];
        [Common.OpQueue addOperation:Op];
    }

}

+(void)limitForContractor:(NSString*)contractor {
    
    if ( Common.HelloData.cap & SERVERCAP_LIMITKH ) {
        
        ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
        [Op setOptype:ACREMOTEOPERATIONTYPE_LIMITS];
        [Op setStr1:contractor];
        [Common.OpQueue addOperation:Op];
        
    }
    

}

-(id)init {
    self = [super init];
    if ( self ) {
        _optype = 0;
        _str1 = nil;
        _str2 = nil;
        _date1 = nil;
        _id1 = nil;
        _RA = [[ACRemoteAction alloc] initWithOperationPtr:self];
        _DB = nil;
    }
    
    return self;
}

-(void)setOptype:(int)optype {
    _optype = optype;
}

-(void)setStr1:(NSString*)str1 {
    _str1 = str1 ? [NSString stringWithString:str1] : nil;
}

-(void)setStr2:(NSString*)str2 {
    _str2 = str2 ? [NSString stringWithString:str2] : nil;
}

-(void)setInt1:(int)int1 {
    _int1 = int1;
}

-(void)setBool1:(int)bool1 {
    _bool1 = bool1;
}

-(void)setDate1:(NSDate*)date1 {
    _date1 = date1 ? [[NSDate alloc] initWithTimeInterval:0 sinceDate:date1] : [[NSDate alloc] initWithTimeIntervalSince1970:0];
}

-(ACDatabase*)DB {
    if ( !_DB ) {
        _DB = [[ACDatabase alloc] init];
    }
    
    return _DB;
}

- (void) onOperationDone {
    
    if ( ![self isCancelled] ) {
        
        
        NSArray *keys = [NSArray arrayWithObjects:@"RA", nil];
        NSArray *values = [NSArray arrayWithObjects:_RA, nil];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
        NSString *notifyName = nil;
        
        switch(_optype) {
            case ACREMOTEOPERATIONTYPE_REGISTERDEVICE:
                notifyName = kRegisterDeviceOperationNotification;
                break;
            case ACREMOTEOPERATIONTYPE_LOGIN:
                notifyName = kLoginOperationNotification;
                break;
            case ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH:
                notifyName = kCustomerSearchDoneNotification;
                break;
            case ACREMOTEOPERATIONTYPE_INVOICE_LIST:
                notifyName = kGetInvoiceListDoneNotification;
                break;
            case ACREMOTEOPERATIONTYPE_INVOICE_ITEMS:
                notifyName = kGetInvoiceItemsDoneNotification;
                break;
            case ACREMOTEOPERATIONTYPE_ORDER_LIST:
                notifyName = kGetOrderListDoneNotification;
                break;
            case ACREMOTEOPERATIONTYPE_ORDER_ITEMS:
                notifyName = kGetOrderItemsDoneNotification;
                break;
            case ACREMOTEOPERATIONTYPE_OUTSTANDING_PAYMENTS:
                notifyName = kGetOutstandingPaymentsListDoneNotification;
                break;
            case ACREMOTEOPERATIONTYPE_INVOICE_GETDOCUMENT:
                notifyName = kGetDocumentDoneNotification;
                
                keys = [NSArray arrayWithObjects:@"Shortcut", nil];
                values = [NSArray arrayWithObjects:_str1, nil];
                dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                
                break;
                
            case ACREMOTEOPERATIONTYPE_ARTICLE_SEARCH:
                notifyName = kArticleSearchDoneNotification;
                break;
                
            case ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY:
                notifyName = kArticleSalesHistoryListDoneNotification;
                break;
                
            case ACREMOTEOPERATIONTYPE_GETDICTIONARY:
                notifyName = kDictionaryNotification;
                break;
                
            case ACREMOTEOPERATIONTYPE_GETPRICE:
                notifyName = kPriceNotification;
                break;

            case ACREMOTEOPERATIONTYPE_LIMITS:
                notifyName = kGetLimitsDoneNotification;
                break;
                
        }
        
        keys = [NSArray arrayWithObjects:@"NN", @"UI", nil];
        values = [NSArray arrayWithObjects:notifyName, dict, nil];
    
        dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
        [self performSelectorOnMainThread:@selector(postNotification:) withObject:dict waitUntilDone:YES];
    }
}

- (void) postNotification:(NSDictionary*)dict {
        [[NSNotificationCenter defaultCenter] postNotificationName:[dict valueForKey:@"NN"] object:self userInfo:[dict valueForKey:@"UI"]];
}


- (short)registerDevice {
    short result = 0;
    _optype = ACREMOTEOPERATIONTYPE_REGISTERDEVICE;
    result = [_RA registerDevice];
    [self onOperationDone];
    
    return result;
}


- (void)login {
    
    if ( [self registerDevice] == HELLO_VERSIONERROR ) {
        
        NSArray *keys = [NSArray arrayWithObjects:@"NN", nil];
        NSArray *values = [NSArray arrayWithObjects:kVersionErrorNotification, nil];
        [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];
        
    } else {
        _optype = ACREMOTEOPERATIONTYPE_LOGIN;
        
        if ( ![self isCancelled] ) {
            [_RA login:_str1 withPassword:_str2];
            [self onOperationDone];
        }
    }

}

- (void) onData:(ACRemoteActionResultData*)data {
    if ( [self isCancelled] ) return;
    
    NSString *nt = nil;
    
    switch(_optype) {
        case ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH:
            nt = kCustomerDataNotification;
            break;
        case ACREMOTEOPERATIONTYPE_INVOICE_LIST:
            nt = kInvoiceDataNotification;
            break;
            
        case ACREMOTEOPERATIONTYPE_ORDER_LIST:
            nt = kOrderDataNotification;
            break;
            
        case ACREMOTEOPERATIONTYPE_ARTICLE_SEARCH:
            nt = kArticleDataNotification;
            break;
            
        case ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY:
            nt = kArticleSalesHistoryItemDataNotification;
            break;
    }
    
    for(int a=0;a<data.items.count;a++) {
        switch(_optype) {
            case ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH:
                [self.DB updateContractor:[self.DB jsonToContractor:[data.items objectAtIndex:a]]];
                break;
            case ACREMOTEOPERATIONTYPE_INVOICE_LIST:
                [self.DB updateInvoice:[self.DB jsonToInvoice:[data.items objectAtIndex:a]] customer:_id1];
                break;
                
            case ACREMOTEOPERATIONTYPE_ORDER_LIST:
            {
                NSString *cshortcut = nil;
                Order *order = [self.DB jsonToOrder:[data.items objectAtIndex:a] customerShortcut:&cshortcut];
                if ( _id1 == nil && cshortcut != nil ) {
                    _id1 = [self.DB fetchContractorByShortcut:cshortcut];
                }
                [self.DB updateOrder:order customer:_id1];
            }

                break;
                
            case ACREMOTEOPERATIONTYPE_ARTICLE_SEARCH:
            {
                NSNumber *Qty;
                NSString *WareHouseId;
                NSString *WareHouseName;
                Article *artice = [self.DB jsonToArticle:[data.items objectAtIndex:a] qty:&Qty warehouseid:&WareHouseId warehousename:&WareHouseName];
                [self.DB updateArticle:artice qty:Qty warehouseid:WareHouseId warehousename:WareHouseName];
                break;
            }
                
            case ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY:
            {
                if ( _deleted == NO ) {
                    [self.DB removeArticleSHItems:_id1];
                    _deleted = YES;
                }
                
                ArticleSHItem *item = [self.DB jsonToArticleSHItem:[data.items objectAtIndex:a]];
                [self.DB addArticleSHItem:item article:_id1];
                break;
            }
                
        }
    }
    
    NSArray *keys = [NSArray arrayWithObjects:@"NN", nil];
    NSArray *values = [NSArray arrayWithObjects:nt, nil];
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];
}

- (void)doSearch {
    
    bool Result = NO;
    NSString *n = nil;
    
    switch(_optype) {
        case ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH:
            Result = [_RA customerSearch:_str1 maxCount:_int1 onlyByShortcut:_bool1];
            n = @"Customers";
            break;
            
        case ACREMOTEOPERATIONTYPE_ARTICLE_SEARCH:
            Result = [_RA articleSearch:_str1 maxCount:_int1];
            n = @"Articles";
            break;
            
        case ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY:
            
            _id1 = [self.DB fetchArticleByShortcut:_str1];
            _deleted = NO;
            
            if ( _id1 != nil ) {
                Result = [_RA articleSalesHistory:_str1 maxCount:_int1];
                n = @"ArticleSalesHistory";
            }
            
            break;
    }
    
    if ( Result ) {
        ACRemoteActionResultData *data = [_RA getDataByName:n];
        if ( data ) {
            
            [self onData: data];
            NSString *resultID = data.resultID;
            
            if ( _int1 > 0
                && resultID
                && data.rowCount < data.totalRowCount ) {
                
                int offset = data.rowCount;
                
                while (![self isCancelled]
                       && offset < data.totalRowCount )  {
                    
                    if ( ![_RA fetchRecordsFromResult:resultID from:offset maxCount:_int1] )
                        break;
                    
                    data = [_RA getDataByResultID:resultID];
                    
                    if ( !data || data.rowCount < 1 )
                        break;
                    
                    [self onData: data];
                    
                    offset+=data.rowCount;
                };
            }
            
        }
        
        if ( _optype == ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY
             && _deleted == NO ) {
            
            [self.DB removeArticleSHItems:_id1];
        }
    };
    
    
    [self onOperationDone];
}


- (void)commercialDocList {
    
    _id1 = _str1 == nil ? nil : [self.DB fetchContractorByShortcut:_str1];
    
    BOOL result = NO;
    NSString *name = nil;
    
    switch(_optype) {
        case ACREMOTEOPERATIONTYPE_INVOICE_LIST:
            name = @"Invoices";
            if ( _str1 ) {
                result = [_RA invoicesFromDate:_date1 forCustomerID:_str1 maxCount:_int1];
            } else if ( _str2 ) {
                result = [_RA invoiceByShortcut:_str2];
            }
            
            break;
            
        case ACREMOTEOPERATIONTYPE_ORDER_LIST:
            name = @"Orders";
            if ( _str1 ) {
                result = [_RA ordersFromDate:_date1 forCustomerID:_str1 maxCount:_int1];
            } else if ( _str2 ) {
                result = [_RA orderByShortcut:_str2];
            }
            
            break;
    }
    
    if ( result ) {

        ACRemoteActionResultData *data = [_RA getDataByName:name];
        
        if ( data ) {
            
            [self onData: data];
            NSString *resultID = data.resultID;
            
            if ( _int1 > 0
                && resultID
                && data.rowCount < data.totalRowCount ) {
                
                int offset = data.rowCount;
                
                while (![self isCancelled]
                       && offset < data.totalRowCount )  {
                    
                    if ( ![_RA fetchRecordsFromResult:resultID from:offset maxCount:_int1] )
                        break;
                    
                    data = [_RA getDataByResultID:resultID];
                    
                    if ( !data || data.rowCount < 1 )
                        break;

                    [self onData: data];
                    
                    offset+=data.rowCount;
                };
            }
            
        }
    };
    
    [self onOperationDone];
}

- (void) onCommercialDocumentItemData:(ACRemoteActionResultData*)data {
    if ( [self isCancelled] ) return;
    
    for(int a=0;a<data.items.count;a++) {
        switch(_optype) {
            case ACREMOTEOPERATIONTYPE_INVOICE_ITEMS:
                [self.DB insertInvoiceItem:[self.DB jsonToInvoiceItem:[data.items objectAtIndex:a]] order:_id1];
                break;
                
            case ACREMOTEOPERATIONTYPE_ORDER_ITEMS:
                [self.DB insertOrderItem:[self.DB jsonToOrderItem:[data.items objectAtIndex:a]] order:_id1];
                break;
        }
    }

}

- (void)commercialDocItems {
    
    
    BOOL result = NO;
    NSString *name = nil;
    _id1 = nil;
    
    switch(_optype) {
        case ACREMOTEOPERATIONTYPE_INVOICE_ITEMS:
            name = @"InvoiceItems";
            _id1 = [self.DB fetchInvoiceByShortcut:_str1];
            
            if ( _id1 ) {
              result = [_RA invoiceItems:_str1 maxCount:_int1];
            }

            break;
            
        case ACREMOTEOPERATIONTYPE_ORDER_ITEMS:
            name = @"OrderItems";
            _id1 = [self.DB fetchOrderByShortcut:_str1];
            if ( _id1 ) {
               result = [_RA orderItems:_str1 maxCount:_int1];
            }
            
            break;
    }
    
    if ( result ) {
        
        ACRemoteActionResultData *data = [_RA getDataByName:name];
        
        if ( data ) {
            
            switch(_optype) {
                case ACREMOTEOPERATIONTYPE_INVOICE_ITEMS:
                    [self.DB removeAllInvoiceItems: _id1];
                    break;
                    
                case ACREMOTEOPERATIONTYPE_ORDER_ITEMS:
                    [self.DB removeAllOrderItems: _id1];
                    break;
            }
            
            [self onCommercialDocumentItemData: data];
            NSString *resultID = data.resultID;
            
            if ( _int1 > 0
                && resultID
                && data.rowCount < data.totalRowCount ) {
                
                int offset = data.rowCount;
                
                while (![self isCancelled]
                       && offset < data.totalRowCount )  {
                    
                    if ( ![_RA fetchRecordsFromResult:resultID from:offset maxCount:_int1] )
                        break;
                    
                    data = [_RA getDataByResultID:resultID];
                    
                    if ( !data || data.rowCount < 1 )
                        break;
                    
                    [self onCommercialDocumentItemData: data];
                    
                    offset+=data.rowCount;
                };
            }
            
        }
    };
    
    [self onOperationDone];
}


- (void) onPaymentData:(ACRemoteActionResultData*)data {
    if ( [self isCancelled] ) return;
    
    [self.DB removeAllContractorPayments:_id1];
    
    for(int a=0;a<data.items.count;a++) {
        [self.DB insertPaymentItem:[self.DB jsonToPaymentItem:[data.items objectAtIndex:a]] contractor:_id1];
    }
    
}

- (void)outstandingPaymentsList {
    
    _id1 = [self.DB fetchContractorByShortcut:_str1];
    
    if ( [_RA outstandingPayments:_str1 maxCount:-1] ) {

        ACRemoteActionResultData *data = [_RA getDataByName:@"Payments"];
        if ( data ) {
            [self onPaymentData: data];
        }
    }
    
    [self onOperationDone];
}

- (void)onDocumentPart:(NSString*)shortcut posistion:(int)pos size:(int)Size {
    if ( pos > Size ) {
       pos = Size; 
    }
    
    NSArray *keys = [NSArray arrayWithObjects:@"Shortcut", @"Position", @"Size", nil];
    NSArray *values = [NSArray arrayWithObjects:shortcut, [NSNumber numberWithInt:pos], [NSNumber numberWithInt:Size], nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    keys = [NSArray arrayWithObjects:@"NN", @"UI", nil];
    values = [NSArray arrayWithObjects:kDocumentPartNotification, dict, nil];
    
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];
    usleep(100000);
}

- (void)getInvoiceDocument {

    if ( [_RA invoiceDOC:_str1 maxBytesCount:DOC_MAX_DATA_PACKET] ) {
        
        NSMutableData *md = [[NSMutableData alloc] init];
        
        ACRemoteActionResultDocument *doc_result = _RA.doc_result;
        if ( doc_result
            && doc_result.doc ) {
            
            [md appendData:doc_result.doc];
            int Offset = (int)doc_result.doc.length;
            
            while(Offset < doc_result.totalSize) {
                if ( [self isCancelled]
                    || ![_RA fetchDocumentFromResult:doc_result.resultID fromByte:Offset maxBytesCount:DOC_MAX_DATA_PACKET] ) {
                    break;
                } else {
                    doc_result = _RA.doc_result;
                    if ( doc_result
                        && doc_result.doc ) {
                        Offset += doc_result.doc.length;
                        [md appendData:doc_result.doc];
                        [self onDocumentPart:_str1 posistion:Offset size:doc_result.totalSize];
                    }

                }
                
            }
            
            if ( Offset > 0
                && Offset == doc_result.totalSize ) {
                Invoice *i = [self.DB fetchInvoiceByShortcut:_str1];
                if ( i ) {
                    i.doc = md;
                    [self.DB updateInvoice:i customer:i.customer];
                }
            }
        }
    }
    
    [self onOperationDone];
}

- (void)async_export {
    
    int status = [_de.status intValue];
    
    if ( status == QSTATUS_WAITING
         || status ==  QSTATUS_USERCONFIRMATION_WAITING ) {
        
        BOOL result = NO;
        if ( _de.order !=  nil ) {
            result = status == QSTATUS_WAITING ? [_RA newOrder:[self.DB orderTojsonString:_de.order]] : [_RA confirmOrderByRefID:_de.confirmrefid];
        } else if ( _de.contractor != nil ) {
            result = status == QSTATUS_WAITING ? [_RA addContractor:[self.DB contractorTojsonString:_de.contractor autoShortcut:YES]] : [_RA confirmContractorByRefID:_de.confirmrefid];
        }
        
        if ( result ) {
            _de.requestid = _RA.async_result.requestID;
            status = QSTATUS_SENT;
            [self.DB updateDataExport:_de withStatus:status];

        } else {
            [self.DB updateDataExport:_de withResult:_RA.async_result];
            
            [ACERPCCommon postNotification:kRemoteAddErrorNotification target:self];
        }
    };
    
    NSString *ne_error = NSLocalizedString(@"Dane o wskazanym identyfikatorze nie zostały odnalezione. Skontaktuj się z administratorem serwera.", nil);
    
    if ( status == QSTATUS_SENT ) {
        
        if ( [_RA async_confirm:_de.requestid] ) {
            status = QSTATUS_ASYNCREQUEST_CONFIRMED;
            [self.DB updateDataExport:_de withStatus:status];
        } else {
            if ( _RA.async_result.status.code == RESULTCODE_NOTEXISTS ) {
                [self.DB updateDataExport:_de withErrorMessage:ne_error];
            } else {
               [self.DB updateDataExport:_de withResult:_RA.async_result];
            }
            
            [ACERPCCommon postNotification:kRemoteAddErrorNotification target:self];
        }
    }
    

    if ( status == QSTATUS_ASYNCREQUEST_CONFIRMED ) {
        
        BOOL sendNotification = NO;
        
        if ( [_RA async_fetchresult:_de.requestid] ) {
            
            [self.DB updateDataExport:_de withResult:_RA.async_result];
            sendNotification = YES;
            
            if (_RA.async_result.status.success == YES) {
                [_RA async_deleteresult:_de.requestid];
            }
            
        } else {
            if ( _RA.async_result.status.code == RESULTCODE_NOTEXISTS ) {
                [self.DB updateDataExport:_de withErrorMessage:ne_error];
                sendNotification = YES;
            };
        }
        
        if ( sendNotification ) {
            NSArray *keys = [NSArray arrayWithObjects:@"Shortcut", nil];
            NSArray *values = [NSArray arrayWithObjects:_de.shortcut == nil ? @"" : _de.shortcut, nil];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            
            keys = [NSArray arrayWithObjects:@"NN", @"UI", nil];
            values = [NSArray arrayWithObjects:kRemoteAddDoneNotification, dict, nil];
            [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];
        }
        

    }
    
}

- (void)getDictionary {
    
    if ( [_RA dictionaryOfType:_int1 forContractor:_str1] ) {
        [self.DB updateDictionaryOfType:_int1 forContractor:_str1 withData:_RA.dict_result];
    }
    
    [self onOperationDone];
}

- (void)getPrice {
    
    ACROPriceCheckQueueItem *item;
    
    do {
     
        item = nil;
        
        @synchronized(priceCheckQueue) {
            if ( priceCheckQueue != nil
                && priceCheckQueue.count > 0 ) {
                
                item = [priceCheckQueue objectAtIndex:0];
                [priceCheckQueue removeObjectAtIndex:0];
            }
        }
        
        if ( item ) {
            if ( [_RA priceForContractor:item.contractor withArticleShortcut:item.article currency:item.currency] ) {
                
                NSNumber *price = _RA.price_result.pricenet != nil
                && [_RA.price_result.code isEqualToNumber:[NSNumber numberWithInt:IPRESULT_OK]] ? _RA.price_result.pricenet : [NSNumber numberWithDouble:0.00];
                
                [self.DB updateIndividualPriceForContractor:item.contractor withPrice:price articleShortcut:item.article currency:item.currency];
            }
        }
        
    }while (item != nil && ![self isCancelled]);
    
    @synchronized(priceCheckQueue) {
        if ( priceCheckQueue ) {
            [priceCheckQueue removeAllObjects];
            priceCheckQueue = nil;
        }
    }
    
    [self onOperationDone];
}

- (void)getLimits {
    
    if ( [_RA contractorLimits:_str1 maxCount:-1] ) {
        
        ACRemoteActionResultData *data = [_RA getDataByName:@"Limits"];
        if ( data ) {
            [self onLimitData: data];
        }
    }
    
    [self onOperationDone];
}

- (void) onLimitData:(ACRemoteActionResultData*)data {
    if ( [self isCancelled] ) return;
    
    _id1 = [self.DB fetchContractorByShortcut:_str1];
    
    [self.DB removeAllContractorLimits:_id1];
    
    for(int a=0;a<data.items.count;a++) {
        [self.DB insertLimitItem:[self.DB jsonToLimitItem:[data.items objectAtIndex:a]] contractor:_id1];
    }
    
}

- (void)main
{
	if (![self isCancelled])
	{
        switch(_optype) {
            case ACREMOTEOPERATIONTYPE_REGISTERDEVICE:
                [self registerDevice];
                break;
            case ACREMOTEOPERATIONTYPE_LOGIN:
                [self login];
                break;
            case ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH:
                [self doSearch];
                break;
            case ACREMOTEOPERATIONTYPE_INVOICE_LIST:
            case ACREMOTEOPERATIONTYPE_ORDER_LIST:
                [self commercialDocList];
                break;
            case ACREMOTEOPERATIONTYPE_ORDER_ITEMS:
            case ACREMOTEOPERATIONTYPE_INVOICE_ITEMS:
                 [self commercialDocItems];
                break;
            case ACREMOTEOPERATIONTYPE_OUTSTANDING_PAYMENTS:
                [self outstandingPaymentsList];
                break;
                
            case ACREMOTEOPERATIONTYPE_INVOICE_GETDOCUMENT:
                [self getInvoiceDocument];
                break;
                
            case ACREMOTEOPERATIONTYPE_ARTICLE_SEARCH:
                [self doSearch];
                break;
                
            case ACREMOTEOPERATIONTYPE_ARTICLE_SALESHISTORY:
                [self doSearch];
                break;
                
            case ACREMOTEOPERATIONTYPE_GETDICTIONARY:
                [self getDictionary];
                break;
                
            case ACREMOTEOPERATIONTYPE_GETPRICE:
                [self getPrice];
                break;
                
            case ACREMOTEOPERATIONTYPE_EXPORT:
                
                _de = nil;
                do {
                    _de = [self.DB getDataToExport];
                    if (_de) {
                        
                        [self async_export];
                        sleep(1);
                    }
                } while (_de && !self.isCancelled);
                    
                break;
                
            case ACREMOTEOPERATIONTYPE_LIMITS:
                [self getLimits];
                break;
        }
	}
}

@end
