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

#define ACREMOTEOPERATIONTYPE_REGISTERDEVICE         1
#define ACREMOTEOPERATIONTYPE_LOGIN                  2
#define ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH        3
#define ACREMOTEOPERATIONTYPE_INVOICE_LIST           4
#define ACREMOTEOPERATIONTYPE_OUTSTANDING_PAYMENTS   5
#define ACREMOTEOPERATIONTYPE_INVOICE_GETDOCUMENT    6

#define DOC_MAX_DATA_PACKET 32768

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

+(void)customerSearch:(NSString*)text mtu:(int)MTU onlyShortCut:(BOOL)osc {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_CUSTOMER_SEARCH];
    [Op setStr1:text];
    [Op setInt1:MTU];
    [Op setBool1:osc];
    [Common.OpQueue addOperation:Op];
};

+(void)customerSearch:(NSString*)text mtu:(int)MTU {
    [ACRemoteOperation customerSearch:text mtu:MTU onlyShortCut:NO];
}

+(void)customerSearchOnlyByShortcut:(NSString*)shortcut {
    [ACRemoteOperation customerSearch:shortcut mtu:1 onlyShortCut:YES];
}

+(void)invoicesForCustomerWithShortcut:(NSString*)shortcut mtu:(int)MTU fromDate:(NSDate*)date {
    ACRemoteOperation *Op = [[ACRemoteOperation alloc] init];
    [Op setOptype:ACREMOTEOPERATIONTYPE_INVOICE_LIST];
    [Op setStr1:shortcut];
    [Op setDate1:date];
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
    _str1 = [NSString stringWithString:str1];
}

-(void)setStr2:(NSString*)str2 {
    _str2 = [NSString stringWithString:str2];
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
            case ACREMOTEOPERATIONTYPE_OUTSTANDING_PAYMENTS:
                notifyName = kGetOutstandingPaymentsListDoneNotification;
                break;
            case ACREMOTEOPERATIONTYPE_INVOICE_GETDOCUMENT:
                notifyName = kGetDocumentDoneNotification;
                
                keys = [NSArray arrayWithObjects:@"Shortcut", nil];
                values = [NSArray arrayWithObjects:_str1, nil];
                dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
                
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

- (void) onCustomerData:(ACRemoteActionResultData*)data {
    if ( [self isCancelled] ) return;
    
    for(int a=0;a<data.items.count;a++) {
        [self.DB updateContractor:[self.DB jsonToContractor:[data.items objectAtIndex:a]]];
    }
    
    NSArray *keys = [NSArray arrayWithObjects:@"NN", nil];
    NSArray *values = [NSArray arrayWithObjects:kCustomerDataNotification, nil];
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];
}

- (void)customerSearch {
    if ( [_RA customerSearch:_str1 maxCount:_int1 onlyByShortcut:_bool1] ) {
        ACRemoteActionResultData *data = [_RA getDataByName:@"Customers"];
        if ( data ) {
            
            [self onCustomerData: data];
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
                    
                    [self onCustomerData: data];
                    
                    offset+=data.rowCount;
                };
            }
            
        }
    };
    
    [self onOperationDone];
}

- (void) onInvoiceData:(ACRemoteActionResultData*)data {
    if ( [self isCancelled] ) return;
    
    for(int a=0;a<data.items.count;a++) {
            [self.DB updateInvoice:[self.DB jsonToInvoice:[data.items objectAtIndex:a]] customer:_id1];
    }
    
    NSArray *keys = [NSArray arrayWithObjects:@"NN", nil];
    NSArray *values = [NSArray arrayWithObjects:kInvoiceDataNotification, nil];
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];
}

- (void)invoiceList {
    
    _id1 = [self.DB fetchContractorByShortcut:_str1];
    
    if ( [_RA invoicesFromDate:_date1 forCustomerID:_str1 maxCount:_int1] ) {

        ACRemoteActionResultData *data = [_RA getDataByName:@"Invoices"];
        if ( data ) {
            
            [self onInvoiceData: data];
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

                    [self onInvoiceData: data];
                    
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
            int Offset = doc_result.doc.length;
            
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
                [self customerSearch];
                break;
            case ACREMOTEOPERATIONTYPE_INVOICE_LIST:
                [self invoiceList];
                break;
            case ACREMOTEOPERATIONTYPE_OUTSTANDING_PAYMENTS:
                [self outstandingPaymentsList];
                break;
                
            case ACREMOTEOPERATIONTYPE_INVOICE_GETDOCUMENT:
                [self getInvoiceDocument];
                break;
        }
	}
}

@end
