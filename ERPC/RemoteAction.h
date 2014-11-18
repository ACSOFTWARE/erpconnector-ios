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
#define ACTION_CUSTOMER_SIMPLESEARCH      4
#define ACTION_FETCHDOCUMENTFROMRESULT    5
#define ACTION_FETCHRECORDSFROMRESULT     6
#define ACTION_INVOICES                   7
#define ACTION_INVOICE_ITEMS              8
#define ACTION_INVOICE_DOC                9
#define ACTION_OUTSTANDINGPAYMENTS        10
#define ACTION_ORDERS                     11
#define ACTION_ORDER_ITEMS                12
#define ACTION_ORDER_DOC                  13
#define ACTION_ARTICLE_SIMPLESEARCH       14
#define ACTION_NEW_ORDER                  15
#define ACTION_NEW_ORDER_CONFIRM          16
#define ACTION_ASYNC_POST                 17
#define ACTION_ASYNC_NEWORDER_FETCHRESULT 18
#define ACTION_ASYNC_DELETERESULT         19
#define ACTION_GETDICTIONARY              20
#define ACTION_GETINDIVIDUALPRICE         21
#define ACTION_GETLIMITS                  22

#define DICTTYPE_CONTRACTOR_COUNTRY           1
#define DICTTYPE_CONTRACTOR_REGION            2
#define DICTTYPE_CONTRACTOR_PAYMENTMETHODS    3
#define DICTTYPE_NEWORDER_STATE               4

#define IPRESULT_ERROR                0
#define IPRESULT_ITEMNOTEXISTS        1
#define IPRESULT_CONTRACTORERROR      2
#define IPRESULT_UNKNOWNPRICE         3
#define IPRESULT_OK                   4


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
@property int offline_valitidytime;
@property int online_validitytime;
@property int64_t cap;
@property NSString *dev_regstate;
@property BOOL dev_accessgranted;
@property NSString *srv_instanceid;
@end

@interface ACRemoteActionResultUserDetails : ACRemoteActionResult
@property NSString *name;
@property NSString *default_warehouse;
@end

@interface ACRemoteActionResultLogin : ACRemoteActionResult
@property ACRemoteActionResultUserDetails *userdetails;
@end

@interface ACRemoteActionResultDocument : ACRemoteActionResult
@property int totalSize;
@property NSString *resultID;
@property NSData *doc;

@end

@interface ACRemoteActionVerificationResultItem :NSObject
@property (readonly) NSString *msg;
@property (readonly) BOOL err;
-(id) initWithMessage:(NSString*)msg isError:(BOOL)err;
@end

@interface ACRemoteActionResultNewObject : ACRemoteActionResult
@property NSString *confirmrefid;
@property NSString *shortcut;
@property NSString *number;
@property NSArray *vresult;
@end

@interface ACRemoteActionResultPrice : ACRemoteActionResult

@property NSNumber *code;    //IPRESULT_
@property NSString *message;
@property NSNumber *pricenet;

@end

@interface ACRemoteActionResultAsync : ACRemoteActionResult
@property NSString *requestID;
@property (readonly) ACRemoteActionResultNewObject *newobject_result;
-(id) initWithNewObjectResult;
@end


@interface ACRemoteDictionaryItem : NSObject
@property NSString *shortcut;
@property NSString *name;
@property int pri;
@end

@interface ACRemoteActionResultDict: ACRemoteActionResult
@property BOOL Exists;
@property int Type;
@property NSArray *items;
-(ACRemoteDictionaryItem*)ItemAtIndex:(int)idx;
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
- (BOOL) invoiceByShortcut:(NSString *)shortcut;
- (BOOL) invoiceItems:(NSString*)fvID maxCount:(int)maxcount;
- (BOOL) invoiceDOC:(NSString*)fvID maxBytesCount:(int)maxbytescount;
- (BOOL) ordersFromDate:(NSDate*)date forCustomerID:(NSString*)cID maxCount:(int)maxcount;
- (BOOL) orderByShortcut:(NSString *)shortcut;
- (BOOL) orderItems:(NSString*)oID maxCount:(int)maxcount;
- (BOOL) orderDOC:(NSString*)oID maxBytesCount:(int)maxbytescount;
- (BOOL) outstandingPayments:(NSString*)cID maxCount:(int)maxcount;
- (BOOL) articleSearch:(NSString*)text maxCount:(int)maxcount;
- (BOOL) newOrder:(NSString*)jsonData;
- (BOOL) confirmOrderByRefID:(NSString*)refID;
- (BOOL) async_confirm:(NSString*)requestID;
- (BOOL) async_fetchresult:(NSString*)requestID;
- (BOOL) async_deleteresult:(NSString*)requestID;
- (BOOL) dictionaryOfType:(int)type forContractor:(NSString*)contractor;
- (BOOL) priceForContractor:(NSString*)contractor withArticleShortcut:(NSString*)article currency:(NSString*)currency;
- (BOOL) outstandingPayments:(NSString*)cID maxCount:(int)maxcount;
- (BOOL) contractorLimits:(NSString*)cID maxCount:(int)maxcount;

- (ACRemoteActionResultData*) getDataByName:(NSString*)name;
- (ACRemoteActionResultData*) getDataByResultID:(NSString*)resultID;
- (NSString*) resultIdByName:(NSString*)name;
+ (NSString*) messageByResultCode:(int)code;

@property (readwrite) id delegate;
@property (readonly) ACRemoteActionResult *result;
@property (readonly) ACRemoteActionResultDocument *doc_result;
@property (readonly) ACRemoteActionResultHello *hello_result;
@property (readonly) ACRemoteActionResultLogin *login_result;
@property (readonly) ACRemoteActionResultAsync *async_result;
@property (readonly) ACRemoteActionResultDict *dict_result;
@property (readonly) ACRemoteActionResultPrice *price_result;
@end
