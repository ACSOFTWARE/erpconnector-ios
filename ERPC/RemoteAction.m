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


@implementation ACRemoteDictionaryItem
@synthesize shortcut;
@synthesize name;
@synthesize pri;
@end

@implementation ACRemoteActionResultDict
@synthesize Exists;
@synthesize Type;
@synthesize items;

-(ACRemoteDictionaryItem*)ItemAtIndex:(int)idx {
    if ( items && idx < items.count) {
        return [items objectAtIndex:idx];
    }
    
    return nil;
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
@synthesize online_validitytime;
@synthesize offline_valitidytime;
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
    online_validitytime = 0;
    offline_valitidytime = 0;
    dev_regstate = nil;
    dev_accessgranted = NO;
    
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    
    ACRemoteActionResultHello *copy = [[ACRemoteActionResultHello alloc] init];

    copy.erp_name = self.erp_name ? [NSString stringWithString:self.erp_name] : nil;
    copy.erp_mfr = self.erp_mfr ? [NSString stringWithString:self.erp_mfr] : nil;
    copy.drv_mfr = self.drv_mfr ? [NSString stringWithString:self.drv_mfr] : nil;
    copy.drv_ver = self.drv_ver ? [NSString stringWithString:self.drv_ver] : nil;
    copy.ver_major = self.ver_major;
    copy.ver_minor = self.ver_minor;
    copy.online_validitytime = self.online_validitytime;
    copy.offline_valitidytime = self.offline_valitidytime;
    copy.cap = self.cap;
    copy.dev_regstate = self.dev_regstate ? [NSString stringWithString:self.dev_regstate] : nil;
    copy.dev_accessgranted = self.dev_accessgranted;
    
    
    return copy;
}

@end

@implementation ACRemoteActionResultUserDetails
@synthesize name;
@synthesize default_warehouse;
@end

@implementation ACRemoteActionResultLogin
@synthesize userdetails;
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

@implementation ACRemoteActionResultAsync

@synthesize requestID = _requestID;
@synthesize newobject_result = _newobject_result;

-(id)init {
    self = [super init];
    if ( self ) {
        _requestID = nil;
        _newobject_result = nil;
    }
    
    return self;
}

-(id)initWithNewObjectResult {
    self = [self init];
    if ( self ) {
        _newobject_result = [[ACRemoteActionResultNewObject alloc] init];
    }
    
    return self;
}
@end

@implementation ACRemoteActionVerificationResultItem

@synthesize msg = _msg;
@synthesize err = _err;

-(id)initWithMessage:(NSString *)msg isError:(BOOL)err {
    self = [super init];
    if ( self ) {
        _msg = msg;
        _err = err;
    }
    
    return self;
}
@end

@implementation ACRemoteActionResultNewObject

@synthesize shortcut;
@synthesize number;
@synthesize vresult = _vresult;
@synthesize confirmrefid;

-(id)init {
    self = [super init];
    if ( self ) {
        shortcut = nil;
        number = nil;
        _vresult = nil;
    }
    
    return self;
}
@end

@implementation ACRemoteActionResultPrice

@synthesize code;
@synthesize message;
@synthesize pricenet;

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

#define ZLIB_BUFFER_SIZE 16384

-(char*) inflate:(unsigned char*)Source sourceLen:(int)SourceLen destLen:(int *)DestLen {
    
  
    
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
    

    
    return dest;
    
}

-(char*) deflate:(unsigned char*)Source sourceLen:(int)SourceLen destLen:(int *)DestLen {
    
    
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
    ret = deflateInit(&strm, Z_BEST_COMPRESSION);
    if (ret != Z_OK)
        return NULL;
    
    strm.avail_in = SourceLen;
    strm.next_in = Source;
    
    do {
        strm.avail_out = ZLIB_BUFFER_SIZE;
        strm.next_out = out;
        ret = deflate(&strm, Z_FINISH);
        assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
        have = ZLIB_BUFFER_SIZE - strm.avail_out;
        if ( have > 0 ) {
            dest = (char*)realloc(dest, (*DestLen)+have);
            memcpy(&dest[*DestLen], out, have);
            (*DestLen)+=have;
        };
    } while (strm.avail_out == 0);
    
    
    (void)deflateEnd(&strm);
    if ( ret == Z_STREAM_END )
        return dest;
    
    free(dest);
    dest = NULL;
    *DestLen = 0;
    

    
    return dest;
    
}
#undef ZLIB_BUFFER_SIZE
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

- (void)postRemoteDataNotification:(NSError *)error {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoteDataNotification object:self userInfo:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    _connection = nil;
    
    
    if ( received_data != nil
        && received_data.length > 0 ) {
        
        [self performSelectorOnMainThread:@selector(postRemoteDataNotification:) withObject:nil waitUntilDone:NO];
        
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
        
        bool postErrorNotification = YES;
        
        
        switch (_Action) {
            case ACTION_HELLO:
                _result = [[ACRemoteActionResultHello alloc] init];
                break;
                
            case ACTION_LOGIN:
                _result = [[ACRemoteActionResultLogin alloc] init];
                break;
                
            case ACTION_FETCHDOCUMENTFROMRESULT:
            case ACTION_INVOICE_DOC:
                _result = [[ACRemoteActionResultDocument alloc] init];
                break;
                
            case ACTION_NEW_ORDER:
            case ACTION_NEW_ORDER_CONFIRM:
                _result = [[ACRemoteActionResultAsync alloc] init];
                postErrorNotification = NO;
                break;
                
            case ACTION_ASYNC_NEWORDER_FETCHRESULT:
                _result = [[ACRemoteActionResultAsync alloc] initWithNewObjectResult];
                postErrorNotification = NO;
                break;
                
            case ACTION_GETDICTIONARY:
                _result = [[ACRemoteActionResultDict alloc] init];
                postErrorNotification = NO;
                break;
                
            case ACTION_GETINDIVIDUALPRICE:
                _result = [[ACRemoteActionResultPrice alloc] init];
                postErrorNotification = NO;
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
                case ACTION_LOGIN:
                    [self assignResult:(ACRemoteActionResultLogin*)_result withLoginData:Dict];
                    break;
                case ACTION_FETCHDOCUMENTFROMRESULT:
                case ACTION_INVOICE_DOC:
                    [self assignResult:(ACRemoteActionResultDocument*)_result withDocumentData:Dict];
                    break;
                case ACTION_NEW_ORDER:
                case ACTION_ASYNC_NEWORDER_FETCHRESULT:
                case ACTION_NEW_ORDER_CONFIRM:
                    [self assignResult:(ACRemoteActionResultAsync*)_result withAsyncData:Dict];
                    break;
                case ACTION_GETDICTIONARY:
                    [self assignResult:(ACRemoteActionResultDict*)_result withDictData:Dict];
                    break;
                case ACTION_GETINDIVIDUALPRICE:
                    [self assignResult:(ACRemoteActionResultPrice*)_result withPriceData:Dict];
                    break;
                default:
                    [self assignResult:_result withData:Dict];
                    break;
            }
            
        } else if ( postErrorNotification == YES ) {

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

-(void)assignResult:(ACRemoteActionResultDict*)result withDictData:(NSDictionary *)data {
    
    result.Exists = NO;
    
    if ( data ) {
        data = [data valueForKey:@"dictionary"];
        if ( data && data.count > 0 ) {
            
            NSNumber *_n = [data valueForKey:@"exists"];
            
            result.Exists = _n && [_n boolValue] == YES;
            
            if ( result.Exists ) {
                _n = [data valueForKey:@"count"];
                
                if ( _n && [_n intValue] > 0 ) {
                    NSArray *i = [data valueForKey:@"items"];
                    if ( i && i.count > 0) {
                        NSMutableArray *arr = [[NSMutableArray alloc] init];
                        for(int a=0;a<i.count;a++) {
                            NSDictionary *dict = [i objectAtIndex:a];
                            if ( dict ) {
                                ACRemoteDictionaryItem *item = [[ACRemoteDictionaryItem alloc] init];
                                item.name = [dict valueForKey:@"name"];
                                item.shortcut = [dict valueForKey:@"shortcut"];
                                item.pri = [[dict valueForKey:@"pri"] intValue];
                                
                                [arr addObject:item];
                            }
                        }
                        
                        result.items = [NSArray arrayWithArray:arr];
                    }
                }
            }
            
        }
    }
    
};

-(void)assignResult:(ACRemoteActionResultUserDetails*)result withUserDetailsData:(NSDictionary *)data {
    
    if ( data ) {
        data = [data valueForKey:@"userdetails"];
        if ( data && data.count > 0 ) {
            result.name = [data stringValueForKey:@"name"];
            result.default_warehouse = [data stringValueForKey:@"defaultwarehouse"];
        };
    };
    
};


-(void)assignResult:(ACRemoteActionResultLogin*)result withLoginData:(NSDictionary *)data {
    result.userdetails = [[ACRemoteActionResultUserDetails alloc] init];
    [self assignResult:result.userdetails withUserDetailsData:data];
};


-(void)assignResult:(ACRemoteActionResultPrice*)result withPriceData:(NSDictionary *)data {
    if ( data ) {
        data = [data valueForKey:@"price"];
        if ( data && data.count > 0 ) {
            result.code = [data numberValueForKey:@"code"];
            result.pricenet = [data numberValueForKey:@"price"];
            result.message = [data stringValueForKey:@"message"];
        };
    };
};

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
        
        if ([D boolValueForKey:@"Customer_SimpleSearch"] == YES )
            result.cap |= SERVERCAP_CUSTOMER_SIMPLESEARCH;
        
        if ([D boolValueForKey:@"Invoices"] == YES )
            result.cap |= SERVERCAP_INVOICES;
        
        if ([D boolValueForKey:@"Invoice_Items"] == YES )
            result.cap |= SERVERCAP_INVOICE_ITEMS;
        
        if ([D boolValueForKey:@"Invoice_DOC"] == YES )
            result.cap |= SERVERCAP_INVOICE_DOC;
        
        if ([D boolValueForKey:@"OutstandingPayments"] == YES )
            result.cap |= SERVERCAP_OUTSTANDINGPAYMENTS;
        
        if ([D boolValueForKey:@"Orders"] == YES )
            result.cap |= SERVERCAP_ORDERS;
        
        if ([D boolValueForKey:@"Order_Items"] == YES )
            result.cap |= SERVERCAP_ORDER_ITEMS;
        
        if ([D boolValueForKey:@"Article_SimpleSearch"] == YES )
            result.cap |= SERVERCAP_ARTICLE_SIMPLESEARCH;
        
        if ([D boolValueForKey:@"IndividualPrices"] == YES )
            result.cap |= SERVERCAP_INDIVIDUALPRICES;
        
        if ([D boolValueForKey:@"GetDictionary"] == YES )
            result.cap |= SERVERCAP_DICTRIONARIES;
        
        if ([D boolValueForKey:@"GetLimit"] == YES )
            result.cap |= SERVERCAP_LIMITKH;
        
        if ([D boolValueForKey:@"AddContractor"] == YES )
            result.cap |= SERVERCAP_ADDCONTRACTOR;
        
        if ([D boolValueForKey:@"NewInvoice"] == YES )
            result.cap |= SERVERCAP_NEWINVOICE;
        
        if ([D boolValueForKey:@"NewOrder"] == YES )
            result.cap |= SERVERCAP_NEWORDER;
        
        
    };
    
    D = [data valueForKey:@"version"];
    if ( D && D.count > 0 ) {
        result.ver_minor = [D intValueForKey:@"minor"];
        result.ver_major = [D intValueForKey:@"major"];
    };
    
    D = [data valueForKey:@"datavaliditytime"];
    if ( D && D.count > 0 ) {
        result.online_validitytime = [D intValueForKey:@"online"];
        result.offline_valitidytime = [D intValueForKey:@"offline"];
    };
    
    D = [data valueForKey:@"device"];
    if ( D && D.count > 0 ) {
        result.dev_regstate = [D stringValueForKey:@"regstate"];
        result.dev_accessgranted = [D boolValueForKey:@"accessgranted"];
    };
    
    result.srv_instanceid = @"";
    
    D = [data valueForKey:@"server"];
    if ( D && D.count > 0 ) {
        result.srv_instanceid = [D stringValueForKey:@"InstanceId"];
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

-(NSArray*)getVerificationResult:(NSDictionary*)data {
    
    NSArray *result = nil;
    
    data = [data valueForKey:@"status"];
    if ( !data || data.count <= 0 ) return nil;
    
    data = [data valueForKey:@"extension"];
    if ( !data || data.count <= 0 ) return nil;
    
    NSArray *vr = [data valueForKey:@"verification_result"];
    if ( vr && vr.count > 0) {
        NSMutableArray *r = [[NSMutableArray alloc] init];
        for(int a=0;a<vr.count;a++) {
            data = [vr objectAtIndex:a];
            if ( data && data.count > 0 ) {
                [r addObject:[[ACRemoteActionVerificationResultItem alloc] initWithMessage:[data stringValueForKey:@"msg"] isError:[data boolValueForKey:@"err"]]];
            }
        }
        
        result = r;
    }

    
    return result;
}

-(void)assignResult:(ACRemoteActionResultAsync*)result withAsyncData:(NSDictionary*)data {
    
    
    if ( data ) {
        result.requestID = [data stringValueForKey:@"requestid"];
        
        if ( [data valueForKey:@"asyncresult"] != nil ) {
            if ( result.newobject_result != nil ) {
                data = [data valueForKey:@"asyncresult"];
                if ( [data isKindOfClass:[NSDictionary class]] ) {
                    
                    [self assignResult:result.newobject_result withStatusData:data];
                    result.newobject_result.shortcut = [data stringValueForKey:@"ID"];
                    result.newobject_result.number = [data stringValueForKey:@"DocNum"];
                    result.newobject_result.confirmrefid = [data stringValueForKey:@"ConfirmRefID"];
                    result.newobject_result.vresult = [self getVerificationResult:data];

                }
            }
        }
    }
    
};

-(void)assignResult:(ACRemoteActionResultNewObject*)result withAddResult:(NSDictionary*)data {
    
    
    if ( data ) {
        result.shortcut = [data stringValueForKey:@"ID"];
        result.number= [data stringValueForKey:@"DocNum"];
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
    
    //NSLog(@"Login=%@, Password=%@", [Common.Login Base64encodeForUrl], [Common.Password Base64encodeForUrl]);
    
    if (params && params.length > 0 ) {
        [body appendString:[NSString stringWithFormat:@"&%@", params]];
    }
    
   // NSLog(@"RequestBody:%@", body);

    
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self waitForResult];
}

-(NSString*)jsonParams:(NSString *)jsonString {
    
    NSString *result = nil;
    
    if ( jsonString.length < 100 ) {
        return [NSString stringWithFormat:@"JSONDATA=%@", [jsonString Base64encodeForUrl]];
    }
    
    const char *str = [jsonString cStringUsingEncoding:NSUTF8StringEncoding];
    if (str) {
        
        int data_size = 0;
        char *data = [self deflate:(unsigned char*)str sourceLen:strlen(str) destLen:&data_size];
        
        if ( data ) {
            if (data_size) {
                result = [NSString stringWithFormat:@"JSONDATA_UncompressedSize=%lu&JSONDATA=%@", strlen(str), [NSString Base64encodeForUrlWithCString:data length:data_size]];
            }
            free(data);
        }
        
    }
    
    return result;

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

+ (NSString*) messageByResultCode:(int)code {
    switch(code) {
        case RESULTCODE_INTERNAL_SERVER_ERROR:
            return NSLocalizedString(@"Wystąpił wewnętrzny błąd serwera. Skontaktuj się z administratorem!", nil);
        case RESULTCODE_PARAM_ERROR:
            return NSLocalizedString(@"Błąd kompatybilności. Skontaktuj się z administratorem!", nil);
        case RESULTCODE_INVALID_ACCESSKEY:
            return NSLocalizedString(@"Błędny klucz autoryzacji. Skontaktuj się z administratorem!", nil);
        case RESULTCODE_LOGIN_INCORRECT:
            return NSLocalizedString(@"Błędny login lub hasło", nil);
        case RESULTCODE_INSUFF_ACCESS_RIGHTS:
            return NSLocalizedString(@"Brak uprawnień", nil);
        case RESULTCODE_INVALID_PASSWD_RETYPE:
            return NSLocalizedString(@"Błędne powtórzenie hasła!", nil);
        case RESULTCODE_EMAIL_SEND_ERROR:
            return NSLocalizedString(@"Próba wysłania wiadomości e-mail zakończona niepowodzeniem!", nil);
        case RESULTCODE_INVALID_ADDRESS_OR_ID:
            return NSLocalizedString(@"Błędny adres lub identyfikator!", nil);
        case RESULTCODE_INVALID_KEY:
            return NSLocalizedString(@"Błędny klucz!", nil);
        case RESULTCODE_TEMPORARILY_UNAVAILABLE:
            return NSLocalizedString(@"Tymczasowo niedostępne.", nil);
        case RESULTCODE_NOTEXISTS_OR_INSUFF_ACCESS_RIGHTS:
            return NSLocalizedString(@"Nie istnieje lub brak wystarczających uprawnień.", nil);
        case RESULTCODE_NOTEXISTS:
            return NSLocalizedString(@"Nie istnieje.", nil);
        case RESULTCODE_OPERATION_NOT_ALLOWED:
            return NSLocalizedString(@"Niedozwolona operacja!", nil);
        case RESULTCODE_ERROR:
            return NSLocalizedString(@"Błąd ogólny!", nil);
        case RESULTCODE_SERVICEUNAVAILABLE:
            return NSLocalizedString(@"Usługa niedostępna. Skontaktuj się z administratorem!", nil);
        case RESULTCODE_ACCESSDENIED:
            return NSLocalizedString(@"Brak dostępu! Skontaktuj się z administratorem.", nil);
        case RESULTCODE_UNKNOWN_ACTION:
            return NSLocalizedString(@"Błądna akcja.", nil);
        case RESULTCODE_WAIT_FOR_REGISTER:
            return NSLocalizedString(@"Urządzenie oczekuje na rejestrację. Skontaktuj się z administratorem serwera.", nil);
        case RESULTCODE_ACTION_NOT_AVAILABLE:
            return NSLocalizedString(@"Żądana akcja nie istnieje.", nil);
        case RESULTCODE_CONFIRMATION_NEEDED:
            return NSLocalizedString(@"Wymagane potwierdzenie.", nil);
        case RESULTCODE_RESULT_NOT_READY:
            return NSLocalizedString(@"Brak gotowości.", nil);
    }
    
    return nil;
}



-(short)hello {
    
    _Action = ACTION_HELLO;
    [self requestWithAction:@"Hello" andParams:nil];
    
    if ( _result.status.success ) {
        
        ACRemoteActionResultHello *h = (ACRemoteActionResultHello*)_result;
        
        if ( h.ver_major == 3
            && h.ver_minor == 7 ) {
            
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

-(ACRemoteActionResultLogin*)login_result {
    if ( _result
        && [_result isKindOfClass:[ACRemoteActionResultLogin class]] ) {
        return (ACRemoteActionResultLogin*)_result;
    }
    
    return nil;
}

-(ACRemoteActionResultAsync*)async_result {
    if ( _result
        && [_result isKindOfClass:[ACRemoteActionResultAsync class]] ) {
        return (ACRemoteActionResultAsync*)_result;
    }
    
    return nil;
}

-(ACRemoteActionResultDict*)dict_result {
    if ( _result
        && [_result isKindOfClass:[ACRemoteActionResultDict class]] ) {
        return (ACRemoteActionResultDict*)_result;
    }

    return nil;
}

-(ACRemoteActionResultPrice*)price_result {
    if ( _result
        && [_result isKindOfClass:[ACRemoteActionResultPrice class]] ) {
        return (ACRemoteActionResultPrice*)_result;
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
    [self requestWithAction:@"Login" andParams:nil];
    
    return _result.status.success;
}

- (BOOL) customerSearch:(NSString*)text maxCount:(int)maxcount onlyByShortcut:(BOOL)osc{
    _Action = ACTION_CUSTOMER_SIMPLESEARCH;
    [self requestWithAction:@"Customer_SimpleSearch" andParams:[NSString stringWithFormat:@"Text=%@&MaxCount=%i&OnlyID=%i", [text Base64encodeForUrl], maxcount, osc ? 1 : 0]];
    
    return _result.status.success;
}

- (BOOL) articleSearch:(NSString*)text maxCount:(int)maxcount {
    _Action = ACTION_ARTICLE_SIMPLESEARCH;
    [self requestWithAction:@"Article_SimpleSearch" andParams:[NSString stringWithFormat:@"CodeOrName=%@&MaxCount=%i", [text Base64encodeForUrl], maxcount]];
    
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

- (BOOL) commercialDocFromDate:(NSDate*)date WithAction:(NSInteger)action CustomerID:(NSString*)cID maxCount:(int)maxcount {
    _Action = action;
    NSString *ActionStr = nil;
    
    switch(action) {
        case ACTION_INVOICES:
            ActionStr = @"Invoices";
            break;
        case ACTION_ORDERS:
            ActionStr = @"Orders";
            break;
    }
    
    time_t unixTime = (time_t) [date timeIntervalSince1970];
    [self requestWithAction:ActionStr andParams:[NSString stringWithFormat:@"CID=%@&FromDate=%lu&MaxCount=%i", [cID Base64encodeForUrl], unixTime, maxcount]];
    
    return _result.status.success;
}

- (BOOL) commercialDocByShortcut:(NSString*)shortcut withAction:(NSInteger)action {
    
    _Action = action;
    NSString *ActionStr = nil;
    
    switch(action) {
        case ACTION_INVOICES:
            ActionStr = @"InvoiceById";
            break;
        case ACTION_ORDERS:
            ActionStr = @"OrderById";
            break;
    }
    
    [self requestWithAction:ActionStr andParams:[NSString stringWithFormat:@"DocID=%@", [shortcut Base64encodeForUrl]]];
    
    return _result.status.success;
}

- (BOOL) commercialDocItemsWithAction:(NSInteger)action DocID:(NSString*)docID maxCount:(int)maxcount {

    _Action = action;
    NSString *ActionStr = nil;
    
    switch(action) {
        case ACTION_INVOICE_ITEMS:
            ActionStr = @"Invoice_Items";
            break;
        case ACTION_ORDER_ITEMS:
            ActionStr = @"Order_Items";
            break;
    }
    
    [self requestWithAction:ActionStr andParams:[NSString stringWithFormat:@"DocID=%@&MaxCount=%i", [docID Base64encodeForUrl], maxcount]];
    
    return _result.status.success;
}

- (BOOL) commercialDocPDFWithAction:(NSInteger)action DocID:(NSString*)docID maxBytesCount:(int)maxbytescount {
    _Action = action;
    NSString *ActionStr = nil;
    
    switch(action) {
        case ACTION_INVOICE_DOC:
            ActionStr = @"Invoice_DOC";
            break;
        case ACTION_ORDER_DOC:
            ActionStr = @"Order_DOC";
            break;
    }
    
    [self requestWithAction:ActionStr andParams:[NSString stringWithFormat:@"DocType=pdf&DocID=%@&MaxBytesCount=%i", [docID Base64encodeForUrl], maxbytescount]];
    
    return _result.status.success;
}

- (BOOL) invoicesFromDate:(NSDate*)date forCustomerID:(NSString*)cID maxCount:(int)maxcount {
    
    return [self commercialDocFromDate:date WithAction:ACTION_INVOICES CustomerID:cID maxCount:maxcount];
}

- (BOOL) invoiceByShortcut:(NSString *)shortcut {
    return [self commercialDocByShortcut:shortcut withAction:ACTION_INVOICES];
}

- (BOOL) invoiceItems:(NSString*)fvID maxCount:(int)maxcount {
    
    return [self commercialDocItemsWithAction:ACTION_INVOICE_ITEMS DocID:fvID maxCount:maxcount];
    
}

- (BOOL) invoiceDOC:(NSString*)fvID maxBytesCount:(int)maxbytescount {
    
    return [self commercialDocPDFWithAction:ACTION_INVOICE_DOC DocID:fvID maxBytesCount:maxbytescount];
}

- (BOOL) ordersFromDate:(NSDate*)date forCustomerID:(NSString*)cID maxCount:(int)maxcount {
    
    return [self commercialDocFromDate:date WithAction:ACTION_ORDERS CustomerID:cID maxCount:maxcount];
}

- (BOOL) orderByShortcut:(NSString *)shortcut {
    return [self commercialDocByShortcut:shortcut withAction:ACTION_ORDERS];
}

- (BOOL) orderItems:(NSString*)oID maxCount:(int)maxcount {
    
    return [self commercialDocItemsWithAction:ACTION_ORDER_ITEMS DocID:oID maxCount:maxcount];
    
}

- (BOOL) orderDOC:(NSString*)oID maxBytesCount:(int)maxbytescount {
    
    return [self commercialDocPDFWithAction:ACTION_ORDER_DOC DocID:oID maxBytesCount:maxbytescount];
}


- (BOOL) outstandingPayments:(NSString*)cID maxCount:(int)maxcount {
    _Action = ACTION_OUTSTANDINGPAYMENTS;
    [self requestWithAction:@"OutstandingPayments" andParams:[NSString stringWithFormat:@"CID=%@&MaxCount=%i", [cID Base64encodeForUrl], maxcount]];
    
    return _result.status.success;
}

- (BOOL) newOrder:(NSString*)jsonData {
    _Action = ACTION_NEW_ORDER;
    [self requestWithAction:@"NewOrder" andParams:[NSString stringWithFormat:@"Async=1&%@", [self jsonParams:jsonData]]];
    return _result.status.success;
}


- (BOOL) confirmOrderByRefID:(NSString*)refID {
    _Action = ACTION_NEW_ORDER_CONFIRM;
    [self requestWithAction:@"NewOrder_Confirm" andParams:[NSString stringWithFormat:@"Async=1&RefID=%@", refID]];
    return _result.status.success;
}

- (BOOL) async_confirm:(NSString*)requestID {
    _Action = ACTION_ASYNC_POST;
    [self requestWithAction:@"Async_Confirm" andParams:[NSString stringWithFormat:@"RequestID=%@", requestID]];
    return _result.status.success;
}

- (BOOL) async_fetchresult:(NSString*)requestID {
    _Action = ACTION_ASYNC_NEWORDER_FETCHRESULT;
    [self requestWithAction:@"Async_FetchResult" andParams:[NSString stringWithFormat:@"RequestID=%@", requestID]];
    return _result.status.success;
}

- (BOOL) async_deleteresult:(NSString*)requestID {
    _Action = ACTION_ASYNC_DELETERESULT;
    [self requestWithAction:@"Async_DeleteResult" andParams:[NSString stringWithFormat:@"RequestID=%@", requestID]];
    return _result.status.success;
}

- (BOOL) dictionaryOfType:(int)type forContractor:(NSString*)contractor {
    _Action = ACTION_GETDICTIONARY;
    [self requestWithAction:@"GetDictionary" andParams:[NSString stringWithFormat:@"DictType=%i&CID=%@", type, [contractor Base64encodeForUrl]]];
    return _result.status.success;
}

- (BOOL) priceForContractor:(NSString*)contractor withArticleShortcut:(NSString*)article currency:(NSString*)currency {
    _Action = ACTION_GETINDIVIDUALPRICE;
    [self requestWithAction:@"IndividualPrice" andParams:[NSString stringWithFormat:@"CID=%@&Code=%@&Currency=%@", [contractor Base64encodeForUrl], [article Base64encodeForUrl], [currency Base64encodeForUrl]]];
    return _result.status.success;
}

- (BOOL) contractorLimits:(NSString*)cID maxCount:(int)maxcount {
    _Action = ACTION_GETLIMITS;
    [self requestWithAction:@"GetLimits" andParams:[NSString stringWithFormat:@"CID=%@&MaxCount=%i", [cID Base64encodeForUrl], maxcount]];
    
    return _result.status.success;
}

@end
