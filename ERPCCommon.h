/*
 ERPCCommon.h
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
#import "Database.h"

#define SERVERCAP_REGISTERDEVICE               0x0000000000000001
#define SERVERCAP_LOGIN                        0x0000000000000002
#define SERVERCAP_FETCHRECORDSFROMRESULT       0x0000000000000004
#define SERVERCAP_FETCHDOCUMENTFROMRESULT      0x0000000000000008
#define SERVERCAP_CUSTOMER_SIMPLESEARCH        0x0000000000000010
#define SERVERCAP_INVOICES                     0x0000000000000020
#define SERVERCAP_INVOICE_ITEMS                0x0000000000000040
#define SERVERCAP_INVOICE_DOC                  0x0000000000000080
#define SERVERCAP_OUTSTANDINGPAYMENTS          0x0000000000000100
#define SERVERCAP_ORDERS                       0x0000000000000200
#define SERVERCAP_ORDER_ITEMS                  0x0000000000000400
#define SERVERCAP_ARTICLE_SIMPLESEARCH         0x0000000000000800
#define SERVERCAP_INDIVIDUALPRICES             0x0000000000001000
#define SERVERCAP_DICTRIONARIES                0x0000000000002000
#define SERVERCAP_LIMITKH                      0x0000000000004000
#define SERVERCAP_NEWINVOICE                   0x0000000000008000
#define SERVERCAP_NEWORDER                     0x0000000000010000
#define SERVERCAP_ADDCONTRACTOR                0x0000000000020000
#define SERVERCAP_ARTICLE_SALESHISTORY         0x0000000000040000

#define QSTATUS_EDITING                        0
#define QSTATUS_WAITING                        1
#define QSTATUS_SENT                           2
#define QSTATUS_ASYNCREQUEST_CONFIRMED         3
#define QSTATUS_WARNING                        4
#define QSTATUS_USERCONFIRMATION_WAITING       5
#define QSTATUS_ERROR                          6
#define QSTATUS_DONE                           7
#define QSTATUS_DELETED                        8

@class ACAppDelegate;
@class ACLoginVC;
@class ACContractorListVC;
@class ACFavoritesVC;
@class ACHistoryVC;
@class ACContractorVC;
@class ACInfoVC;
@class ACInvoiceListVC;
@class ACPaymentListVC;
@class ACRemoteActionResultHello;
@class ACArticleVC;
@class ACArticleSalesHistoryVC;
@class ACComDocVC;
@class ACComDocItemVC;
@class ACComDocPreviewVC;
@class ACArticleListVC;
@class ACDEWaitingQueue;
@class ACDataExportVC;
@class ACComDocListVC;
@class ACCLimitListVC;
@class ACRemoteActionResultLogin;

@interface ACERPCCommon : NSObject <UINavigationControllerDelegate> {
}

-(void) Logout;
-(void) BeforeLogin;
-(void) onLogin:(ACRemoteActionResultLogin*)login_result;
-(BOOL) loginVC_Active;
- (void)defaultsChanged:(NSNotification *)notification;
- (NSURL *)applicationDocumentsDirectory;


- (void)showContractorVC:(Contractor*)c;
- (void)showContractorInvoiceListVC:(Contractor*)c;
- (void)showContractorPaymentListVC:(Contractor*)c;
- (void)showContractorOrderListVC:(Contractor*)c;
- (void)showComDoc:(id)record;
- (void)showComDocItem:(id)record;
- (void)showComDocPreview:(id)record;
- (void)selectArticlesForDocument:(id)record;
- (void)showArticle:(Article*)article;
- (void)showArticleSalesHistory:(Article*)article;
- (void)showArticleList;
- (void)showDataExportItem:(DataExport*)de;
- (void)showLimitsForContractor:(Contractor*)c;
- (void)newOrderForCustomer:(Contractor*)c;
- (void)newContractor;
-(void)CheckTimeout;
-(BOOL)exportInProgress:(DataExport*)de;
+(NSString*)statusStringWithDataExport:(DataExport*)de;
+(NSString*)statusStringWithDataExport:(DataExport*)de andStatusString:(NSString*)status;
+(NSString*)dateExportTitle:(DataExport*)de;
+(void)postNotification:(NSString*)n target:(id)target;

@property (readwrite, atomic) NSString *UDID;
@property (copy, readwrite, atomic) NSString *Login;
@property (copy, readwrite, atomic) NSString *Password;
@property (readonly, atomic) NSString *Sign;
@property (copy, readwrite, atomic) NSString *ServerAddress;
@property (readonly, atomic) NSOperationQueue *OpQueue;
@property (readonly, atomic) NSOperationQueue *OpExportQueue;
@property (copy, readwrite, atomic) ACRemoteActionResultHello *HelloData;
@property (nonatomic) BOOL Connected;


@property (readonly, nonatomic)BOOL keyboardVisible;
@property (readonly, nonatomic)CGSize keyboardSize;
@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) UINavigationController *navigationController;
@property (readonly, nonatomic) ACLoginVC *LoginVC;
@property (readonly, nonatomic) ACContractorListVC *ContractorListVC;
@property (readonly, nonatomic) ACFavoritesVC *FavoritesVC;
@property (readonly, nonatomic) ACHistoryVC *HistoryVC;
@property (readonly, nonatomic) ACContractorVC *ContractorVC;
@property (readonly, nonatomic) ACInfoVC *InfoVC;
@property (readonly, nonatomic) ACComDocListVC *InvoiceListVC;
@property (readonly, nonatomic) ACComDocPreviewVC *ComDocPreviewVC;
@property (readonly, nonatomic) ACPaymentListVC *PaymentListVC;
@property (readonly, nonatomic) ACArticleVC *ArticleVC;
@property (readonly, nonatomic) ACArticleSalesHistoryVC *ArticleSalesHistoryVC;
@property (readonly, nonatomic) ACComDocVC *ComDocVC;
@property (readonly, nonatomic) ACComDocItemVC *ComDocItemVC;
@property (readonly, nonatomic) ACArticleListVC *ArticleGlobalListVC;
@property (readonly, nonatomic) ACArticleListVC *ArticleListVC;
@property (readonly, nonatomic) ACDEWaitingQueue *DataExportWaitingQueue;
@property (readonly, nonatomic) ACDataExportVC *DataExportVC;
@property (readonly, nonatomic) ACDatabase *DB;
@property (readwrite, atomic) NSDate *LastLogin;
@end


@interface NSString (ERPC)
- (NSString*) HMACWithSecret:(NSString*) secret;
-(NSString*) Base64encode;
+(NSString*) Base64encodeWithCString:(const char*)bytes_to_encode length:(unsigned long)in_len;
+(NSString*) Base64encodeForUrlWithCString:(const char*)bytes_to_encode length:(int)in_len;
-(unsigned char*) Base64decode:(int*)OutLen;
-(NSData*) Base64decode;
-(NSString*) Base64encodeForUrl;
-(NSString*) firstChar;
-(NSString*) trim;
-(double)doubleValueWithLocalization;
@end

@interface NSNumber (ERPC)
-(double)addVatByRate:(NSString*)rate;
-(NSString*)moneyToString;
@end

@interface NSDictionary (ERPC)
-(NSString*) stringValueForKey:(NSString*)key;
-(int) intValueForKey:(NSString*)key;
-(double) doubleValueForKey:(NSString*)key;
-(double) floatValueForKey:(NSString*)key;
-(NSNumber*) numberValueForKey:(NSString*)key;
-(BOOL) boolValueForKey:(NSString*)key;

@end

@interface UIButton (ERPC)
-(void)setTitle:(NSString*)title;
@end

extern ACERPCCommon *Common;
extern NSString *kConnectionErrorNotification;
extern NSString *kRemoteDataNotification;
extern NSString *kLoginOperationNotification;
extern NSString *kRegisterDeviceOperationNotification;
extern NSString *kCustomerSearchDoneNotification;
extern NSString *kCustomerDataNotification;
extern NSString *kGetInvoiceListDoneNotification;
extern NSString *kGetInvoiceItemsDoneNotification;
extern NSString *kInvoiceDataNotification;
extern NSString *kGetOutstandingPaymentsListDoneNotification;
extern NSString *kRemoteResultUnsuccess;
extern NSString *kDocumentPartNotification;
extern NSString *kGetDocumentDoneNotification;
extern NSString *kVersionErrorNotification;
extern NSString *kOrderDataNotification;
extern NSString *kGetOrderListDoneNotification;
extern NSString *kGetOrderItemsDoneNotification;
extern NSString *kArticleSearchDoneNotification;
extern NSString *kArticleDataNotification;
extern NSString *kRemoteAddDoneNotification;
extern NSString *kRemoteAddErrorNotification;
extern NSString *kDictionaryNotification;
extern NSString *kPriceNotification;
extern NSString *kGetLimitsDoneNotification;
extern NSString *kArticleSalesHistoryListDoneNotification;
extern NSString *kArticleSalesHistoryItemDataNotification;
