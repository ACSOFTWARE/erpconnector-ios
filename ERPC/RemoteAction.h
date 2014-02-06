/*
 RemoteConnection.h
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

#import <Foundation/Foundation.h>
#import "pzWSCommon_RC.h"

#define HELLO_UNREGISTERED   1
#define HELLO_WAITING        2
#define HELLO_REGISTERED     3
#define HELLO_VERSIONERROR   4

#define ACTION_NONE                       0
#define ACTION_HELLO                      1
#define ACTION_REGISTERDEVICE             2
#define ACTION_LOGIN                      3
#define ACTION_CUSTOMERS_SIMPLESEARCH     4
#define ACTION_FETCHDOCUMENTFROMRESULT    5
#define ACTION_FETCHRECORDSFROMRESULT     6
#define ACTION_INVOICES                   7
#define ACTION_INVOICE_ITEMS              8
#define ACTION_INVOICE_DOC                9
#define ACTION_OUTSTANDINGPAYMENTS        10

@interface ACRemoteActionResultStatus : NSObject
@property (atomic) BOOL success;
@property int code;
@property NSString *message;
@end

@interface ACRemoteActionResultData : NSObject
@property NSString *name;
@property NSString *resultID;
@property int rowCount;
@property int colCount;
@property int totalRowCount;
@property NSArray *items;
@end

@interface ACRemoteActionResult : NSObject
@property ACRemoteActionResultStatus *status;
@property NSMutableArray *data;
@end


@interface ACRemoteActionResultHello : ACRemoteActionResult <NSCopying>
@property NSString *erp_name;
@property NSString *erp_mfr;
@property NSString *drv_mfr;
@property NSString *drv_ver;
@property int ver_major;
@property int ver_minor;
@property int64_t cap;
@property NSString *dev_regstate;
@property BOOL dev_accessgranted;
@end

@interface ACRemoteActionResultDocument : ACRemoteActionResult
@property int totalSize;
@property NSString *resultID;
@property NSData *doc;

@end

@interface ACRemoteAction : NSObject <NSURLConnectionDataDelegate>

- (id) initWithOperationPtr:(NSOperation*)op;
- (short) hello;
- (short) registerDevice;
- (BOOL) login:(NSString*)Login withPassword:(NSString*)password;
- (BOOL) customerSearch:(NSString*)text maxCount:(int)maxcount onlyByShortcut:(BOOL)osc;
- (BOOL) fetchRecordsFromResult:(NSString*)resultID from:(int)From maxCount:(int)maxcount;
- (BOOL) fetchDocumentFromResult:(NSString*)resultID fromByte:(int)FromByte maxBytesCount:(int)maxbytescount;
- (BOOL) invoicesFromDate:(NSDate*)date forCustomerID:(NSString*)cID maxCount:(int)maxcount;
- (BOOL) invoiceItems:(NSString*)fvID maxCount:(int)maxcount;
- (BOOL) invoiceDOC:(NSString*)fvID maxBytesCount:(int)maxbytescount;
- (BOOL) outstandingPayments:(NSString*)cID maxCount:(int)maxcount;

- (ACRemoteActionResultData*) getDataByName:(NSString*)name;
- (ACRemoteActionResultData*) getDataByResultID:(NSString*)resultID;
- (NSString*) resultIdByName:(NSString*)name;

@property (readwrite) id delegate;
@property (readonly) ACRemoteActionResult *result;
@property (readonly) ACRemoteActionResultDocument *doc_result;
@property (readonly) ACRemoteActionResultHello *hello_result;
@end
