/*
 RemoteConnection.m
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

#import "RemoteAction.h"
#import "ERPCCommon.h"
#import "JSONKit.h"
#include "zlib.h"


@implementation ACRemoteActionResultStatus

@synthesize success;
@synthesize code;
@synthesize message;

-(id)init {
    self = [super init];
    success = NO;
    code = RESULTCODE_NONE;
    return self;
}

@end

@implementation ACRemoteActionResult : NSObject
@synthesize status = _status;

-(id)init {
    self = [super init];
    _status = [[ACRemoteActionResultStatus alloc] init];
    return self;
}
@end

@implementation ACRemoteActionResultHello : ACRemoteActionResult

@synthesize erp_name;
@synthesize erp_mfr;
@synthesize drv_mfr;
@synthesize drv_ver;
@synthesize cap;
@synthesize ver_major;
@synthesize ver_minor;
@synthesize dev_regstate;
@synthesize dev_accessgranted;

-(id)init {
    self = [super init];
    erp_name = nil;
    erp_mfr = nil;
    cap = 0;
    drv_mfr = nil;
    drv_ver = nil;
    ver_major = 0;
    ver_minor = 0;
    dev_regstate = nil;
    dev_accessgranted = NO;
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    
    ACRemoteActionResultHello *copy = [[ACRemoteActionResultHello alloc] init];

    
    copy.erp_name = [NSString stringWithString:self.erp_name];
    copy.erp_mfr = [NSString stringWithString:self.erp_mfr];
    copy.drv_mfr = [NSString stringWithString:self.drv_mfr];
    copy.drv_ver = [NSString stringWithString:self.drv_ver];   
    copy.ver_major = self.ver_major;
    copy.ver_minor = self.ver_minor;
    copy.cap = self.cap;
    copy.dev_regstate = [NSString stringWithString:self.dev_regstate];   
    copy.dev_accessgranted = self.dev_accessgranted;
    
    
    return copy;
}

@end

@implementation ACRemoteActionResultData
@synthesize name;
@synthesize resultID;
@synthesize rowCount;
@synthesize colCount;
@synthesize totalRowCount;
@synthesize items;

-(id)init {
    self = [super init];
    name = nil;
    resultID = nil;
    rowCount = 0;
    colCount = 0;
    totalRowCount = 0;
    items = nil;
    
    return self;
}
@end

@implementation ACRemoteActionResultDocument
@synthesize doc;
@synthesize totalSize;
@synthesize resultID;

-(id)init {
    self = [super init];
    if ( self ) {
        doc = nil;
        totalSize = 0;
        resultID = nil;
    }

    return self;
}
@end

@implementation ACRemoteAction {
    NSURLConnection *_connection;
    NSMutableData *received_data;
    NSString *content_type;
    NSOperation *_op;
    int _Action;
}



- (id)init {
    
    self = [super init];
    
    received_data = nil;
    content_type = nil;
    
    _connection = nil;
    _result = nil;
    _Action = ACTION_NONE;
    _op = nil;
    return self;
}

- (id) initWithOperationPtr:(NSOperation*)op {
    self = [self init];
    _op = op;
    return self;
}


-(char*) inflate:(unsigned char*)Source sourceLen:(int)SourceLen destLen:(int *)DestLen {
    
    #define ZLIB_BUFFER_SIZE 16384
    
    if ( Source == NULL
        || SourceLen == 0 ) return NULL;
    
    char *dest = NULL;
    *DestLen = 0;
    int ret;
    unsigned have;
    z_stream strm;
    unsigned char out[ZLIB_BUFFER_SIZE];
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK)
        return NULL;
    
    strm.avail_in = SourceLen;
    strm.next_in = Source;
    
    do {
        strm.avail_out = ZLIB_BUFFER_SIZE;
        strm.next_out = out;
        ret = inflate(&strm, Z_NO_FLUSH);
        
        switch (ret) {
            case Z_NEED_DICT:
                ret = Z_DATA_ERROR;
            case Z_DATA_ERROR:
            case Z_MEM_ERROR:
            case Z_STREAM_ERROR:
                (void)inflateEnd(&strm);
                if ( dest )
                {
                    free(dest);
                    *DestLen = 0;
                };
                break;
                
        }
        
        if ( ret == Z_OK || ret == Z_STREAM_END )
        {
            have = ZLIB_BUFFER_SIZE - strm.avail_out;
            if ( have > 0 )
            {
                dest = (char*)realloc(dest, (*DestLen)+have);
                memcpy(&dest[*DestLen], out, have);
                (*DestLen)+=have;
            };
        };
        
    } while (strm.avail_out == 0);
    
    
    (void)inflateEnd(&strm);
    if ( ret == Z_STREAM_END )
        return dest;
    
    free(dest);
    dest = NULL;
    *DestLen = 0;
    
    #undef ZLIB_BUFFER_SIZE
    
    return dest;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    content_type = [response MIMEType];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if ( received_data == nil ) {
        received_data = [[NSMutableData alloc] init];
    };
    
    [received_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if ( error )
        NSLog(@"%@", error.description);
    
    _connection = nil;
    _result = [[ACRemoteActionResult alloc] init];
    
    
    [self performSelectorOnMainThread:@selector(postConnectionErrorNotification:) withObject:error waitUntilDone:YES];
}

- (void)postConnectionErrorNotification:(NSError *)error {
    
    NSArray *keys = [NSArray arrayWithObjects:@"error", @"action", nil];
    NSArray *values = [NSArray arrayWithObjects:error, [NSNumber numberWithInt:_Action], nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionErrorNotification object:self userInfo:dict];
}

- (void)postResultUnsuccessNotification:(NSDictionary *)dict {
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteResultUnsuccess object:self userInfo:dict];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    _connection = nil;
    
    
    if ( received_data != nil
        && received_data.length > 0 ) {
        
        int data_size = received_data.length;
        char *buffer = (char *)malloc(data_size+1);
        buffer[data_size] = 0;
        [received_data getBytes:buffer];
        received_data = nil;
        
        
        if ( content_type && [content_type isEqualToString:@"application/x-compress"] ) {
            int un_size;
            char *uncompressed = [self inflate:(unsigned char*)buffer sourceLen:data_size destLen:&un_size];
            free(buffer);
            uncompressed = realloc(uncompressed, un_size+1);
            uncompressed[un_size] = 0;
            buffer = uncompressed;
        };
        
        NSString *data_str = [[NSString alloc] initWithString:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]];
        free(buffer);
        #ifdef DEBUG
        if ( _Action == ACTION_FETCHDOCUMENTFROMRESULT
             || _Action == ACTION_INVOICE_DOC ) {
            NSLog(@"Result for ---> ACTION_FETCHDOCUMENTFROMRESULT || ACTION_INVOICE_DOC");
        } else {
            NSLog(@"%@", data_str);
        }

        #endif
        _result.status.code = 10;
        
        NSDictionary *Dict = [data_str objectFromJSONString];
        data_str = nil;
        
        
        switch (_Action) {
            case ACTION_HELLO:
                _result = [[ACRemoteActionResultHello alloc] init];
                break;
                
            case ACTION_FETCHDOCUMENTFROMRESULT:
            case ACTION_INVOICE_DOC:
                _result = [[ACRemoteActionResultDocument alloc] init];
                break;
                
            default:
                _result = [[ACRemoteActionResult alloc] init];
                break;
        }
        

        [self assignResult:_result withStatusData:Dict];
        
        if ( _result.status.success == YES ) {
            
            switch (_Action) {
                case ACTION_HELLO:
                    [self assignResult:(ACRemoteActionResultHello*)_result withHelloData:Dict];
                    break;
                case ACTION_FETCHDOCUMENTFROMRESULT:
                case ACTION_INVOICE_DOC:
                    [self assignResult:(ACRemoteActionResultDocument*)_result withDocumentData:Dict];
                    break;
                default:
                    [self assignResult:_result withData:Dict];
                    break;
            }
            
        } else {

            ACRemoteActionResult *r = [[ACRemoteActionResult alloc] init];
            r.status.success = false;
            r.status.code = _result.status.code;
            r.status.message = _result.status.message;
            
            NSArray *keys = [NSArray arrayWithObjects:@"action", @"result", nil];
            NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithInt:_Action], r, nil];
            
            [self performSelectorOnMainThread:@selector(postResultUnsuccessNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];

        }
        
    } else {
        received_data = nil;
    }
    
    
    if ( _result == nil )
       _result = [[ACRemoteActionResult alloc] init];
}

-(void)assignResult:(ACRemoteActionResult*)result withStatusData:(NSDictionary *)data {
    
    if ( data ) {
        data = [data valueForKey:@"status"];
        if ( data && data.count > 0 ) {
            
            NSNumber *_n = [data valueForKey:@"success"];
            
            result.status.success = _n && [_n boolValue] == YES;
            result.status.message = [data stringValueForKey:@"message"];
            result.status.code = [data intValueForKey:@"code"];;
        }
    }
    
}

-(void)assignResult:(ACRemoteActionResultHello*)result withHelloData:(NSDictionary*)data {
    
    NSDictionary *D = [data valueForKey:@"erp"];
    if ( D && D.count > 0 ) {
        result.erp_name = [D stringValueForKey:@"name"];
        result.erp_mfr = [D stringValueForKey:@"mfr"];
    }

    D = [data valueForKey:@"drv"];
    if ( D && D.count > 0 ) {
        result.drv_mfr = [D stringValueForKey:@"mfr"];
        result.drv_ver = [D stringValueForKey:@"ver"];
    };
    
    D = [data valueForKey:@"cap"];
    if ( D && D.count > 0 ) {
        if ([D boolValueForKey:@"RegisterDevice"] == YES )
            result.cap |= SERVERCAP_REGISTERDEVICE;
        
        if ([D boolValueForKey:@"Login"] == YES )
            result.cap |= SERVERCAP_LOGIN;
        
        if ([D boolValueForKey:@"FetchRecordsFromResult"] == YES )
            result.cap |= SERVERCAP_FETCHRECORDSFROMRESULT;
        
        if ([D boolValueForKey:@"FetchDocumentFromResult"] == YES )
            result.cap |= SERVERCAP_FETCHDOCUMENTFROMRESULT;
        
        if ([D boolValueForKey:@"Customers_SimpleSearch"] == YES )
            result.cap |= SERVERCAP_CUSTOMERS_SIMPLESEARCH;
        
        if ([D boolValueForKey:@"Invoices"] == YES )
            result.cap |= SERVERCAP_INVOICES;
        
        if ([D boolValueForKey:@"Invoice_Items"] == YES )
            result.cap |= SERVERCAP_INVOICE_ITEMS;
        
        if ([D boolValueForKey:@"Invoice_DOC"] == YES )
            result.cap |= SERVERCAP_INVOICE_DOC;
        
        if ([D boolValueForKey:@"OutstandingPayments"] == YES )
            result.cap |= SERVERCAP_OUTSTANDINGPAYMENTS;
        
    };
    
    D = [data valueForKey:@"version"];
    if ( D && D.count > 0 ) {
        result.ver_minor = [D intValueForKey:@"minor"];
        result.ver_major = [D intValueForKey:@"major"];
    };
    
    D = [data valueForKey:@"device"];
    if ( D && D.count > 0 ) {
        result.dev_regstate = [D stringValueForKey:@"regstate"];
        result.dev_accessgranted = [D boolValueForKey:@"accessgranted"];
    };
    
}

-(void)assignResult:(ACRemoteActionResult*)result withData:(NSDictionary*)data {
    
    
    if ( data ) {
        NSArray *arr1 = [data valueForKey:@"results"];
        if ( arr1 && arr1.count > 0 ) {
            for(int a=0;a<arr1.count;a++) {
                NSDictionary *item = [arr1 objectAtIndex:a];
                if ( item ) {
                    ACRemoteActionResultData *Data = [[ACRemoteActionResultData alloc] init];
                    Data.name = [item stringValueForKey:@"name"];
                    Data.rowCount = [item intValueForKey:@"rowcount"];
                    Data.colCount = [item intValueForKey:@"colcount"];
                    Data.totalRowCount = [item intValueForKey:@"totalrowcount"];
                    Data.resultID = [item stringValueForKey:@"resultid"];
                    Data.items = [item valueForKey:@"content"];
                    
                    if ( result.data == nil )
                        result.data = [[NSMutableArray alloc] init];
                    
                    [result.data addObject:Data];
                };
            }
        }
    }
    
};

-(void)assignResult:(ACRemoteActionResultDocument*)result withDocumentData:(NSDictionary*)data {
    
    
    if ( data ) {
        NSString *doc = [data stringValueForKey:@"DOC"];
        
        result.totalSize = [data intValueForKey:@"totalsize"];
        result.resultID = [data stringValueForKey:@"resultid"];
        
        if ( doc.length > 0 ) {
            result.doc = [doc Base64decode];
        }
    }
    
};

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    } else {
        [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
    }
    
}

-(void)requestWithAction:(NSString *)action andParams:(NSString*)params {
    
    if ( _connection ) {
        @throw [NSException exceptionWithName:@"ConnInUseException" reason:@"Connection in use" userInfo:nil];
    }
    
    _result = nil;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"https://%@/pzWebservice.dll/json", Common.ServerAddress]]];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    NSMutableString *body = [NSMutableString stringWithFormat:@"Compress=true&Namespace=erpConnector&UDID=%@&Sign=%@&Login=%@&Password=%@&Action=%@", Common.UDID, Common.Sign, [Common.Login Base64encodeForUrl], [Common.Password Base64encodeForUrl], action];
    
    if (params && params.length > 0 ) {
        [body appendString:[NSString stringWithFormat:@"&%@", params]];
    }
    
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self waitForResult];
}

-(void)waitForResult {

    while(_result == nil 
          && [[NSThread currentThread] isCancelled] == NO
          && (_op == nil
              || [_op isCancelled] == NO)) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        usleep(10000);
    };
    
    
    if ( _connection
        && ( [[NSThread currentThread] isCancelled] || (_op && [_op isCancelled]) ) ) {
        [_connection cancel];
        _connection = nil;
    }
}

- (ACRemoteActionResultData*) getDataByName:(NSString*)name {
    
    ACRemoteActionResultData *Data = NULL;
    
    if ( _result && _result.data )
        for(int a=0;a<_result.data.count;a++) {
            
            ACRemoteActionResultData *D = (ACRemoteActionResultData*)[_result.data objectAtIndex:a];
            
            if ( [D.name isEqualToString:name] ) {
                Data = D;
                break;
            }
        };
    
    return Data;
}

- (ACRemoteActionResultData*) getDataByResultID:(NSString*)resultID {
    
    ACRemoteActionResultData *Data = NULL;
    
    if ( _result && _result.data )
        for(int a=0;a<_result.data.count;a++) {
            
            ACRemoteActionResultData *D = (ACRemoteActionResultData*)[_result.data objectAtIndex:a];
            
            if ( [D.resultID isEqualToString:resultID] ) {
                Data = D;
                break;
            }
        };
    
    return Data;
}

- (NSString*) resultIdByName:(NSString*)name {
    ACRemoteActionResultData *Data = [self getDataByName:name];
    if ( Data
         && Data.resultID
         && Data.resultID.length > 0 ) {
        return [NSString stringWithString:Data.resultID];
    }
    return nil;
}

-(short)hello {
    _Action = ACTION_HELLO;
    [self requestWithAction:@"Hello" andParams:nil];
    
    if ( _result.status.success ) {
        
        ACRemoteActionResultHello *h = (ACRemoteActionResultHello*)_result;
        
        if ( h.ver_major == 1
            && h.ver_minor == 0 ) {
            
            if ( [h.dev_regstate isEqualToString:@"unregistered"] ) {
                return HELLO_UNREGISTERED;
            } else if ( [h.dev_regstate isEqualToString:@"waiting"] ) {
                return HELLO_WAITING;
            } else if ( [h.dev_regstate isEqualToString:@"registered"] ) {
                return HELLO_REGISTERED;
            };
            
        } else {
            return HELLO_VERSIONERROR;
        }
        

    };
    
    return 0;
}

-(ACRemoteActionResultDocument*)doc_result {
    if ( _result
        && [_result isKindOfClass:[ACRemoteActionResultDocument class]] ) {
        return (ACRemoteActionResultDocument*)_result;
    }
    
    return nil;
}

-(ACRemoteActionResultHello*)hello_result {
    if ( _result
        && [_result isKindOfClass:[ACRemoteActionResultHello class]] ) {
        return (ACRemoteActionResultHello*)_result;
    }
    
    return nil;
}

-(short)registerDevice {
    
    short result = [self hello];
    
    if ( result == HELLO_UNREGISTERED ) {
        _Action = ACTION_REGISTERDEVICE;
        [self requestWithAction:@"RegisterDevice" andParams:[NSString stringWithFormat:@"DeviceCaption=%@", [[UIDevice currentDevice].name Base64encodeForUrl]]];
        
        return [self hello];
    }

    
    return result;
}

- (BOOL) login:(NSString*)Login withPassword:(NSString*)password {
    _Action = ACTION_LOGIN;
    Common.Login = Login;
    Common.Password = password;
    [self requestWithAction:@"Login" andParams:nil];
    
    return _result.status.success;
}

- (BOOL) customerSearch:(NSString*)text maxCount:(int)maxcount onlyByShortcut:(BOOL)osc{
    _Action = ACTION_CUSTOMERS_SIMPLESEARCH;
    [self requestWithAction:@"Customers_SimpleSearch" andParams:[NSString stringWithFormat:@"Text=%@&MaxCount=%i&OnlyID=%i", [text Base64encodeForUrl], maxcount, osc ? 1 : 0]];
    
    return _result.status.success;
}

- (BOOL) fetchRecordsFromResult:(NSString*)resultID from:(int)From maxCount:(int)maxcount {
    _Action = ACTION_FETCHRECORDSFROMRESULT;
    [self requestWithAction:@"FetchRecordsFromResult" andParams:[NSString stringWithFormat:@"ResultID=%@&From=%i&MaxCount=%i", resultID, From, maxcount]];
    
    return _result.status.success;
}

- (BOOL) fetchDocumentFromResult:(NSString*)resultID fromByte:(int)FromByte maxBytesCount:(int)maxbytescount {
    _Action = ACTION_FETCHDOCUMENTFROMRESULT;
    [self requestWithAction:@"FetchDocumentFromResult" andParams:[NSString stringWithFormat:@"ResultID=%@&FromByte=%i&MaxBytesCount=%i", resultID, FromByte, maxbytescount]];
    
    return _result.status.success;
}

- (BOOL) invoicesFromDate:(NSDate*)date forCustomerID:(NSString*)cID maxCount:(int)maxcount {
    _Action = ACTION_INVOICES;
    time_t unixTime = (time_t) [date timeIntervalSince1970];
    [self requestWithAction:@"Invoices" andParams:[NSString stringWithFormat:@"KHID=%@&FromDate=%lu&MaxCount=%i", [cID Base64encodeForUrl], unixTime, maxcount]];
    
    return _result.status.success;
}

- (BOOL) invoiceItems:(NSString*)fvID maxCount:(int)maxcount {
    _Action = ACTION_INVOICE_ITEMS;
    [self requestWithAction:@"Invoice_Items" andParams:[NSString stringWithFormat:@"FVID=%@&MaxCount=%i", [fvID Base64encodeForUrl], maxcount]];
    
    return _result.status.success;
}

- (BOOL) invoiceDOC:(NSString*)fvID maxBytesCount:(int)maxbytescount {
    _Action = ACTION_INVOICE_DOC;
    [self requestWithAction:@"Invoice_DOC" andParams:[NSString stringWithFormat:@"DocType=pdf&FVID=%@&MaxBytesCount=%i", [fvID Base64encodeForUrl], maxbytescount]];
    
    return _result.status.success;
}

- (BOOL) outstandingPayments:(NSString*)cID maxCount:(int)maxcount {
    _Action = ACTION_OUTSTANDINGPAYMENTS;
    [self requestWithAction:@"OutstandingPayments" andParams:[NSString stringWithFormat:@"KHID=%@&MaxCount=%i", [cID Base64encodeForUrl], maxcount]];
    
    return _result.status.success;
}


@end
