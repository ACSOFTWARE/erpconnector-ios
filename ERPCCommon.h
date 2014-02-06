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
#define SERVERCAP_CUSTOMERS_SIMPLESEARCH       0x0000000000000010
#define SERVERCAP_INVOICES                     0x0000000000000020
#define SERVERCAP_INVOICE_ITEMS                0x0000000000000040
#define SERVERCAP_INVOICE_DOC                  0x0000000000000080
#define SERVERCAP_OUTSTANDINGPAYMENTS          0x0000000000000100

@class ACAppDelegate;
@class ACLoginVC;
@class ACSearchVC;
@class ACFavoritesVC;
@class ACHistoryVC;
@class ACContractorVC;
@class ACInfoVC;
@class ACInvoiceListVC;
@class ACInvoicePreviewVC;
@class ACPaymentListVC;
@class ACRemoteActionResultHello;

@interface ACERPCCommon : NSObject <UINavigationControllerDelegate> {
}

-(void) Logout;
- (void)defaultsChanged:(NSNotification *)notification;
- (NSURL *)applicationDocumentsDirectory;

- (void)showContractorVC:(Contractor*)c;
- (void)showContractorInvoiceListVC:(Contractor*)c;
- (void)showContractorPaymentListVC:(Contractor*)c;
- (void)showInvoicePreview:(NSString*)shortcut;
-(void)CheckTimeout;
-(BOOL)loginVC_Active;

@property (readwrite, atomic) NSString *UDID;
@property (copy, readwrite, atomic) NSString *Login;
@property (copy, readwrite, atomic) NSString *Password;
@property (readonly, atomic) NSString *Sign;
@property (copy, readwrite, atomic) NSString *ServerAddress;
@property (readwrite, atomic) int64_t ServerCap;
@property (readonly, atomic) NSOperationQueue *OpQueue;
@property (copy, readwrite, atomic) ACRemoteActionResultHello *HelloData;

@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) UINavigationController *navigationController;
@property (readonly, nonatomic) ACLoginVC *LoginVC;
@property (readonly, nonatomic) ACSearchVC *SearchVC;
@property (readonly, nonatomic) ACFavoritesVC *FavoritesVC;
@property (readonly, nonatomic) ACHistoryVC *HistoryVC;
@property (readonly, nonatomic) ACContractorVC *ContractorVC;
@property (readonly, nonatomic) ACInfoVC *InfoVC;
@property (readonly, nonatomic) ACInvoiceListVC *InvoiceListVC;
@property (readonly, nonatomic) ACInvoicePreviewVC *InvoicePreviewVC;
@property (readonly, nonatomic) ACPaymentListVC *PaymentListVC;
@property (readonly, nonatomic) ACDatabase *DB;
@property (readwrite, atomic) NSDate *LastLogin;
@end


@interface NSString (ERPC)
- (NSString*) HMACWithSecret:(NSString*) secret;
-(NSString*) Base64encode;
-(unsigned char*) Base64decode:(int*)OutLen;
-(NSData*) Base64decode;
-(NSString*) Base64encodeForUrl;
-(NSString*) firstChar;
-(NSString*) trim;
@end

@interface NSDictionary (ERPC)
-(NSString*) stringValueForKey:(NSString*)key;
-(int) intValueForKey:(NSString*)key;
-(double) doubleValueForKey:(NSString*)key;
-(double) floatValueForKey:(NSString*)key;
-(NSNumber*) numberValueForKey:(NSString*)key;
-(BOOL) boolValueForKey:(NSString*)key;

@end

extern ACERPCCommon *Common;
extern NSString *kConnectionErrorNotification;
extern NSString *kLoginOperationNotification;
extern NSString *kRegisterDeviceOperationNotification;
extern NSString *kCustomerSearchDoneNotification;
extern NSString *kCustomerDataNotification;
extern NSString *kGetInvoiceListDoneNotification;
extern NSString *kInvoiceDataNotification;
extern NSString *kGetOutstandingPaymentsListDoneNotification;
extern NSString *kRemoteResultUnsuccess;
extern NSString *kDocumentPartNotification;
extern NSString *kGetDocumentDoneNotification;
extern NSString *kVersionErrorNotification;
