/*
 ERPCCommon.m
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

#import "ERPCCommon.h"
#import "SideMenuVC.h"
#import "MFSideMenu.h"
#import "RemoteAction.h"
#import "BackgroundOperations.h"
#import "LoginVC.h"
#import "ACContractorListVC.h"
#import "FavoritesVC.h"
#import "HistoryVC.h"
#import "ACContractorVC.h"
#import "InfoVC.h"
#import "PaymentListVC.h"
#import "Invoice.h"
#import "ACArticleVC.h"
#import "ACArticleSalesHistoryVC.h"
#import "ACComDocListVC.h"
#import "ACComDocVC.h"
#import "ACComDocItemVC.h"
#import "ACComDocPreviewVC.h"
#import "ACArticleListVC.h"
#import "ACDEWaitingQueue.h"
#import "DataExport.h"
#import "ACDataExportVC.h"
#import "Contractor.h"
#import "Order.h"
#import "ACCLimitListVC.h"

#include <CommonCrypto/CommonHMAC.h>
#include <Foundation/Foundation.h>

ACERPCCommon *Common = nil;

NSString *kConnectionErrorNotification = @"n01";
NSString *kLoginOperationNotification = @"n02";
NSString *kRegisterDeviceOperationNotification = @"n03";
NSString *kCustomerSearchDoneNotification = @"n04";
NSString *kCustomerDataNotification = @"n05";
NSString *kGetInvoiceListDoneNotification = @"n06";
NSString *kGetInvoiceItemsDoneNotification = @"n7";
NSString *kInvoiceDataNotification = @"n08";
NSString *kGetOutstandingPaymentsListDoneNotification = @"n09";
NSString *kRemoteResultUnsuccess = @"n10";
NSString *kDocumentPartNotification = @"n11";
NSString *kGetDocumentDoneNotification = @"n12";
NSString *kVersionErrorNotification = @"n13";
NSString *kOrderDataNotification = @"n14";
NSString *kGetOrderListDoneNotification = @"n15";
NSString *kGetOrderItemsDoneNotification = @"n16";
NSString *kArticleSearchDoneNotification = @"n17";
NSString *kArticleDataNotification = @"n18";
NSString *kRemoteAddDoneNotification = @"n19";
NSString *kRemoteAddErrorNotification = @"n20";
NSString *kRemoteDataNotification = @"n21";
NSString *kDictionaryNotification = @"n22";
NSString *kPriceNotification = @"n23";
NSString *kGetLimitsDoneNotification = @"n24";
NSString *kArticleSalesHistoryListDoneNotification = @"n25";
NSString *kArticleSalesHistoryItemDataNotification = @"n26";

@implementation ACERPCCommon {
    BOOL _Connected;
    NSString *_UDID;
    ACSideMenuVC *_sideMenuVC;
    UINavigationController *_navigationController;
    ACLoginVC *_LoginVC;
    ACContractorListVC *_ContractorListVC;
    ACFavoritesVC *_FavoritesVC;
    ACHistoryVC *_HistoryVC;
    ACContractorVC *_ContractorVC;
    ACInfoVC *_InfoVC;
    ACComDocListVC *_InvoiceListVC;
    ACComDocPreviewVC *_ComDocPreviewVC;
    ACPaymentListVC *_PaymentListVC;
    ACDatabase *_DB;
    ACComDocVC *_ComDocVC;
    ACComDocItemVC *_ComDocItemVC;
    ACComDocListVC *_OrderListVC;
    ACArticleVC *_ArticleVC;
    ACArticleSalesHistoryVC *_ArticleSalesHistoryVC;
    ACArticleListVC *_ArticleListVC;
    ACArticleListVC *_ArticleGlobalListVC;
    ACDEWaitingQueue *_ACDEWaitingQueue;
    ACDataExportVC *_DataExportVC;
    ACCLimitListVC *_CLimitListVC;
    NSTimer *_exportTimer;
    UIImageView *_connectionStatus;
    UIImage *_imgConnected;
    UIImage *_imgDisconnected;
    
    Contractor *_new_order_customer;
}

@synthesize window = _window;
@synthesize Sign = _Sign;
@synthesize Login = _Login;
@synthesize Password = _Password;
@synthesize ServerAddress = _ServerAddress;
@synthesize OpQueue = _OpQueue;
@synthesize OpExportQueue = _OpExportQueue;
@synthesize HelloData = _HelloData;
@synthesize LastLogin = _LastLogin;
@synthesize keyboardVisible = _keyboardVisible;
@synthesize keyboardSize = _keyboardSize;

-(id) init {
    self = [super init];
    if ( self ) {
        _keyboardVisible = NO;
        _window = nil;
        _sideMenuVC = nil;
        _navigationController = nil;
        _navigationController = nil;
        _OpQueue = [[NSOperationQueue alloc] init];
        _OpExportQueue = [[NSOperationQueue alloc] init];
        _InfoVC = nil;
        _ContractorListVC = nil;
        _HistoryVC = nil;
        _InvoiceListVC = nil;
        _ComDocPreviewVC = nil;
        _DB = nil;
        _HelloData = nil;
        _LastLogin = nil;
        _ComDocVC = nil;
        _ComDocItemVC = nil;
        _OrderListVC = nil;
        _ArticleVC = nil;
        _ArticleSalesHistoryVC = nil;
        _exportTimer = nil;
        _connectionStatus = nil;
        _CLimitListVC = nil;
        _Connected = NO;
        
        
        _connectionStatus = [[UIImageView alloc] init];
        _imgConnected = [UIImage imageNamed:@"greenpoint.png"];
        _imgDisconnected = [UIImage imageNamed:@"redpoint.png"];
        
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(defaultsChanged:)
                       name:NSUserDefaultsDidChangeNotification
                     object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionError:) name:kConnectionErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteData:) name:kRemoteDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVersionError:) name:kVersionErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegisterResult:) name:kRegisterDeviceOperationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomerData:) name:kCustomerDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteSearchDone:) name:kCustomerSearchDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteLoginResult:) name:kLoginOperationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteResultUnsuccess:) name:kRemoteResultUnsuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetInvoiceListDone:) name:kGetInvoiceListDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetInvoiceItemsDone:) name:kGetInvoiceItemsDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInvoiceData:) name:kInvoiceDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetPaymentListDone:) name:kGetOutstandingPaymentsListDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDocumentPart:) name:kDocumentPartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetDocumentDone:) name:kGetDocumentDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetOrderListDone:) name:kGetOrderListDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrderData:) name:kOrderDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetOrderItemsDone:) name:kGetOrderItemsDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticleData:) name:kArticleDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticleSearchDone:) name:kArticleSearchDoneNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticleSHItemData:) name:kArticleSalesHistoryItemDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onArticleSHItemDone:) name: kArticleSalesHistoryListDoneNotification object:nil];
        
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteAddDone:) name:kRemoteAddDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteAddError:) name:kRemoteAddErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPriceData:) name:kPriceNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLimitData:) name:kGetLimitsDoneNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];

    }
    return self;
}

- (void)managedObjectContextDidSaveNotification:(NSNotification *)n {
    
    if ( _DB
        && _DB.managedObjectContext
        && _DB.managedObjectContext != n.object ) {
        [_DB.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:n waitUntilDone:NO];
    };

    /*
    NSManagedObjectContext *moc = self.mainManagedObjectContext;
    if (note.object != moc)
        [moc performBlock:^(){
            [moc mergeChangesFromContextDidSaveNotification:note];
        }];
*/
}

-(void)setUDID:(NSString *)UDID {
    _UDID = [NSString stringWithString:UDID];
    _Sign = [UDID HMACWithSecret:@"{649EC9FEE0B9}"];
}

-(NSString*)UDID {
    return _UDID;
}


- (void)defaultsChanged:(NSNotification *)notification {
    
    self.UDID = [[[NSUserDefaults standardUserDefaults] stringForKey:@"udid_preference"] trim];
    self.ServerAddress = [[[NSUserDefaults standardUserDefaults] stringForKey:@"server_preference"] trim];
}

-(UINavigationController *)navigationController {

    if ( _navigationController == nil ) {
        
        _navigationController = [[UINavigationController alloc] init];

        [_navigationController.navigationBar setBackgroundImage:[UIImage  imageNamed : (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ? @"nav_bg1" : @"ios6_nav_bg1" ) ] forBarMetrics:UIBarMetricsDefault];
        [_navigationController.navigationBar setTranslucent:NO];
        
        [_navigationController pushViewController:self.ContractorListVC animated:NO];
        
        CGRect frame;
        frame.size.height = 8;
        frame.size.width = 8;
        frame.origin.y = 2;
        frame.origin.x = _navigationController.navigationBar.frame.size.width - frame.size.width - 2;
        _connectionStatus.frame = frame;
        
        [_navigationController.navigationBar addSubview:_connectionStatus];
        
        [_navigationController setDelegate:self];
    };
    return _navigationController;
    
};

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (  _ComDocPreviewVC
        && viewController != _ComDocPreviewVC ) {
        _ComDocPreviewVC = nil;
    } else if ( viewController == _ContractorListVC ) {
        [_ContractorListVC onRemoteSearchDone:nil];
    };
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( viewController == _HistoryVC ) {
        [_HistoryVC refresh];
    } else if ( viewController == _FavoritesVC ) {
        [_FavoritesVC refresh];
    }
}

-(void)setConnected:(BOOL)Connected {
    _Connected = Connected;
    UIImage *i = Connected ? _imgConnected : _imgDisconnected;
    
    if ( _connectionStatus.image != i ) {
        [_connectionStatus setImage:i];
    }
}

-(BOOL)Connected {
    return _Connected;
}

-(ACLoginVC*)LoginVC {
    if ( _LoginVC == nil ) {
         _LoginVC = [[ACLoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    }
    return _LoginVC;
}

-(ACContractorListVC*)ContractorListVC {
    if ( _ContractorListVC == nil ) {
        _ContractorListVC = [[ACContractorListVC alloc] init];
    }
    
    return  _ContractorListVC;
}

-(ACFavoritesVC*)FavoritesVC {
    if ( _FavoritesVC == nil ) {
        _FavoritesVC = [[ACFavoritesVC alloc] initWithNibName:@"FavoritesVC" bundle:nil];
    }
    return _FavoritesVC;
}

-(ACHistoryVC*)HistoryVC {
    if ( _HistoryVC == nil ) {
        _HistoryVC = [[ACHistoryVC alloc] initWithNibName:@"HistoryVC" bundle:nil];
    }
    return _HistoryVC;
}

-(ACContractorVC*)ContractorVC {
    if ( _ContractorVC == nil ) {
        _ContractorVC = [[ACContractorVC alloc] init];
    }
    
    return _ContractorVC;
}

-(ACInfoVC*)InfoVC {
    if ( _InfoVC == nil ) {
        _InfoVC = [[ACInfoVC alloc] initWithNibName:@"InfoVC" bundle:nil];
    }

    return _InfoVC;
}

-(ACComDocListVC*)InvoiceListVC {
    if ( _InvoiceListVC == nil ) {
        _InvoiceListVC = [[ACComDocListVC alloc] initAsOrderList:NO];
    }
    
    return _InvoiceListVC;
}

-(ACComDocPreviewVC*)ComDocPreviewVC {
    if ( _ComDocPreviewVC == nil ) {
        _ComDocPreviewVC = [[ACComDocPreviewVC alloc] initWithNibName:@"ACComDocPreviewVC" bundle:nil];
    }
    
    return _ComDocPreviewVC;
}

-(ACPaymentListVC*)PaymentListVC {
    if ( _PaymentListVC == nil ) {
        _PaymentListVC = [[ACPaymentListVC alloc] initWithNibName:@"PaymentListVC" bundle:nil];
    }
    
    return _PaymentListVC;
}

-(ACDEWaitingQueue*)DataExportWaitingQueue {
    if ( _ACDEWaitingQueue == nil ) {
        _ACDEWaitingQueue = [[ACDEWaitingQueue alloc] init];
    }
    
    return _ACDEWaitingQueue;
}

-(ACComDocListVC*)OrderListVC {
    if ( _OrderListVC == nil ) {
        _OrderListVC = [[ACComDocListVC alloc] initAsOrderList:YES];
    }
    
    return _OrderListVC;
}

-(ACComDocVC*)ComDocVC {
    if ( _ComDocVC == nil ) {
        _ComDocVC = [[ACComDocVC alloc] init];
    }
    
    return _ComDocVC;
}

-(ACComDocItemVC*)ComDocItemVC {
    if ( _ComDocItemVC == nil ) {
        _ComDocItemVC = [[ACComDocItemVC alloc] init];
    }
    
    return _ComDocItemVC;
}


-(ACArticleListVC*)ArticleListVC {
    if ( _ArticleListVC == nil ) {
        _ArticleListVC = [[ACArticleListVC alloc] init];
    }
    
    return _ArticleListVC;
}

-(ACArticleListVC*)ArticleGlobalListVC {
    if ( _ArticleGlobalListVC == nil ) {
        _ArticleGlobalListVC = [[ACArticleListVC alloc] init];
    }
    
    return _ArticleGlobalListVC;
}

-(ACArticleVC*)ArticleVC {
    if ( _ArticleVC == nil ) {
        _ArticleVC = [[ACArticleVC alloc] init];
    }
    
    return _ArticleVC;
}

-(ACArticleSalesHistoryVC*)ArticleSalesHistoryVC {
    if ( _ArticleSalesHistoryVC == nil ) {
        _ArticleSalesHistoryVC = [[ACArticleSalesHistoryVC alloc] init];
    }
    
    return _ArticleSalesHistoryVC;
}

-(ACDataExportVC*)DataExportVC {
    if ( _DataExportVC == nil ) {
        _DataExportVC = [[ACDataExportVC alloc] init];
    }
    
    return _DataExportVC;
}

-(ACCLimitListVC*)CLimitListVC {
    if ( _CLimitListVC == nil ) {
        _CLimitListVC = [[ACCLimitListVC alloc] init];
    }
    
    return _CLimitListVC;
}


-(ACDatabase*)DB {
    assert([NSThread isMainThread]);
    
    if ( !_DB ) {
        _DB = [[ACDatabase alloc] init];
    }
    
    return _DB;
}

-(void)BeforeLogin {
    [Common.OpQueue cancelAllOperations];
    Common.HelloData = nil;
}

-(void)onLogin:(ACRemoteActionResultLogin*)login_result {
    
    if ( ![self loginVC_Active] ) return;
    
    Common.LastLogin = [NSDate date];
    [Common.DB onLogin:login_result];
    
    [UIView transitionFromView:Common.window.rootViewController.view
                        toView:Common.navigationController.view
                      duration:0.65f
                       options: UIViewAnimationOptionTransitionFlipFromTop /*UIViewAnimationOptionTransitionCrossDissolve*/
     
     
                    completion:^(BOOL finished){
                        self.LoginVC.edPassword.text = @"";
                        
                        Common.window.rootViewController = Common.navigationController;
                        [Common.window makeKeyAndVisible];
                        
                        if ( _sideMenuVC == nil ) {
                            _sideMenuVC = [[ACSideMenuVC alloc] init];
                            _sideMenuVC.tableView.backgroundColor = [UIColor clearColor];
                            _sideMenuVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                        };
                        
                        MenuOptions options = MenuButtonEnabled|BackButtonEnabled;
                        
                        [MFSideMenuManager configureWithNavigationController:Common.navigationController
                                                          sideMenuController:_sideMenuVC
                                                                    menuSide:MenuLeftHandSide
                                                                     options:options];
                        
                        [_sideMenuVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                        
                    }];
    
    
    _exportTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onExportTimer:) userInfo:nil repeats:YES];
    
}

-(void)onExportTimer:(id)sender {
    [ACRemoteOperation doExport];
}

-(void)Logout {

    _LastLogin = nil;
    [_OpQueue cancelAllOperations];
    [_OpExportQueue cancelAllOperations];
    
    if ( _exportTimer ) {
        [_exportTimer invalidate];
        _exportTimer = nil;
    }

    
    self.LoginVC.edPassword.text = @"";
    [self.LoginVC moveToZeroPos:nil];
    
    [UIView transitionWithView:Common.window duration:0.5 options: UIViewAnimationOptionTransitionFlipFromBottom /*UIViewAnimationOptionTransitionCrossDissolve*/ animations:^{
        Common.window.rootViewController = self.LoginVC;
    } completion:nil];

}

-(void)CheckTimeout {
    if ( _LastLogin
        && [[NSDate date] timeIntervalSinceDate:_LastLogin] >= 600 ) {
        [self Logout];
    }
}

-(BOOL)loginVC_Active {
    
    return self.window.rootViewController == _LoginVC;
}

+(NSString*)statusStringWithDataExport:(DataExport*)de {
    if ( de ) {
        
        switch([de.status intValue]) {
            case QSTATUS_EDITING:
                return NSLocalizedString(@"W przygotowaniu", nil);
            case QSTATUS_WAITING:
            case QSTATUS_SENT:
            case QSTATUS_USERCONFIRMATION_WAITING:
            case QSTATUS_ASYNCREQUEST_CONFIRMED:
                return NSLocalizedString(@"Oczekiwanie", nil);
                break;
            case QSTATUS_WARNING:
                return NSLocalizedString(@"Wymaga akceptacji", nil);
                break;
            case QSTATUS_ERROR:
                return NSLocalizedString(@"Niepowodzenie", nil);
                break;
            case QSTATUS_DELETED:
                return NSLocalizedString(@"Usunięto", nil);
                break;
        }
    }
    
    return nil;
}

+(NSString*)statusStringWithDataExport:(DataExport*)de andStatusString:(NSString*)status {
        if ( de && status && status.length > 0) {
            switch([de.status intValue]) {
                case QSTATUS_EDITING:
                case QSTATUS_WAITING:
                case QSTATUS_SENT:
                case QSTATUS_USERCONFIRMATION_WAITING:
                case QSTATUS_ASYNCREQUEST_CONFIRMED:
                    return status == nil ? [ACERPCCommon statusStringWithDataExport:de] : [NSString stringWithFormat:@"%@ (%@)", [ACERPCCommon statusStringWithDataExport:de], status];
            }
            
            
        }
    
    return [ACERPCCommon statusStringWithDataExport:de];
}

+(NSString*)dateExportTitle:(DataExport*)de {
    if ( de ) {
        if ( de.order ) {
            if ( de.order.customer ) {
                return [NSString stringWithFormat:@"Zamówienie dla %@", de.order.customer.name];
            }
        } else if ( de.contractor ) {
            return [NSString stringWithFormat:@"Nowy Kontrahent %@", de.contractor.name];
        }
    }
    
    return @"";
}

-(BOOL)exportInProgress:(DataExport *)de {
    return  [de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WAITING]]
             || [de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_USERCONFIRMATION_WAITING]]
             || [de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_SENT]]
             || [de.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ASYNCREQUEST_CONFIRMED]];
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)onKeyboardShow:(NSNotification *)notif {
    _keyboardVisible = YES;
    _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if ( [self.navigationController.visibleViewController isKindOfClass:[ACUIDataVC class]] ) {
        [((ACUIDataVC*)self.navigationController.visibleViewController) onKeyboardShow:notif];
    }
};

- (void)onKeyboardHide:(NSNotification *)notif {
    _keyboardVisible = NO;
    
    if ( [self.navigationController.visibleViewController isKindOfClass:[ACUIDataVC class]] ) {
        [((ACUIDataVC*)self.navigationController.visibleViewController) onKeyboardHide:notif];
    }
};


- (void)onConnectionError:(NSNotification *)notif {
    
    if ( self.window.rootViewController == _LoginVC ) {
        [_LoginVC onConnectionError:notif];
    };
    self.Connected = NO;
};

- (void)onRemoteData:(NSNotification *)notif {
    self.Connected = YES;
};

- (void)onVersionError:(NSNotification *)notif {
    if ( self.window.rootViewController == _LoginVC ) {
        
        [_LoginVC onVersionError:notif];
        
    };
};

- (void)onRegisterResult:(NSNotification *)notif {
    ACRemoteAction *RA = [notif.userInfo valueForKey:@"RA"];
    if ( RA ) {
        ACRemoteActionResultHello *hello = RA.hello_result;
        if ( hello
            && hello.status.success == YES
            && [hello isKindOfClass:[ACRemoteActionResultHello class]] ) {
            _HelloData = hello;
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:self.HelloData.srv_instanceid] forKey:@"serverinstanceid_preference"];
            [self.DB updateServerData];
        }
    }
};

- (void)onRemoteSearchDone:(NSNotification *)notif {
    if ( _ContractorListVC
        && self.navigationController.visibleViewController == _ContractorListVC ) {
        
        [_ContractorListVC onRemoteSearchDone:notif];
        
    } else if ( _ContractorVC
               && self.navigationController.visibleViewController == _ContractorVC ) {
        
        [_ContractorVC onRecordDetailData:notif];
        
    }
}

- (void)onCustomerData:(NSNotification *)notif {
    if ( _ContractorListVC
        && self.navigationController.visibleViewController == _ContractorListVC ) {
        
        [_ContractorListVC onRecordDetailData:notif];
        
    } else if ( _ContractorVC
               && self.navigationController.visibleViewController == _ContractorVC ) {
        
        [_ContractorVC onRecordData:notif];
        
    }
}

- (void)onGetInvoiceListDone:(NSNotification *)notif {
    if ( _InvoiceListVC
        && self.navigationController.visibleViewController == _InvoiceListVC ) {
        [_InvoiceListVC onDetailDataLoadDone:notif];
    }
};

- (void)onGetInvoiceItemsDone:(NSNotification *)notif {
    if ( _ComDocVC
        && self.navigationController.visibleViewController == _ComDocVC) {
        [_ComDocVC onRecordDetailData:notif];
    }
};

- (void)onInvoiceData:(NSNotification *)notif {
    if ( _InvoiceListVC
        && self.navigationController.visibleViewController == _InvoiceListVC ) {
        [_InvoiceListVC onDetailDataItem:notif];
    }
}

- (void)onGetOrderListDone:(NSNotification *)notif {
    
    if ( _OrderListVC
        && self.navigationController.visibleViewController == _OrderListVC ) {
        [_OrderListVC onDetailDataLoadDone:notif];
    }
};

- (void)onGetOrderItemsDone:(NSNotification *)notif {
    if ( _ComDocVC
        && self.navigationController.visibleViewController == _ComDocVC
        && [_ComDocVC isOrder]) {
        [_ComDocVC onRecordDetailData:notif];
    }
};

- (void)onOrderData:(NSNotification *)notif {
    
    if ( _OrderListVC
        && self.navigationController.visibleViewController == _OrderListVC ) {
        [_OrderListVC onDetailDataItem:notif];
    }
    
    if ( _ComDocVC
        && self.navigationController.visibleViewController == _ComDocVC
        && [_ComDocVC isOrder] ) {
        [_ComDocVC onRecordData:notif];
    }
}

- (void)onGetPaymentListDone:(NSNotification *)notif {
    if ( _PaymentListVC
        && self.navigationController.visibleViewController == _PaymentListVC ) {
        [_PaymentListVC onGetListDoneDone:notif];
    }
}

- (void)onRemoteLoginResult:(NSNotification *)notif {
    if ( _LoginVC
        && self.window.rootViewController == _LoginVC ) {
        [_LoginVC onRemoteLoginResult:notif];
    }
};

- (void)onArticleSearchDone:(NSNotification *)notif {
    if ( _ArticleListVC
        && self.navigationController.visibleViewController == _ArticleListVC ) {
        
        [_ArticleListVC onRemoteSearchDone:notif];
    } else if ( _ArticleGlobalListVC
            && self.navigationController.visibleViewController == _ArticleGlobalListVC ) {
            
            [_ArticleGlobalListVC onRemoteSearchDone:notif];
    } else if ( _ArticleVC
               && self.navigationController.visibleViewController == _ArticleVC ) {
        [_ArticleVC onRecordDetailData:notif];
    } else if ( _ComDocItemVC
               && self.navigationController.visibleViewController == _ComDocItemVC ) {
        [_ComDocItemVC setSalesHistoryButtonState];
    }
}

- (void)onArticleSHItemDone:(NSNotification *)notif {
    
    if ( _ArticleSalesHistoryVC
        && self.navigationController.visibleViewController == _ArticleSalesHistoryVC ) {
        
        [_ArticleSalesHistoryVC onRemoteDataDone:notif];
    }
}

- (void)onArticleData:(NSNotification *)notif {
    
    if ( _ArticleVC
        && self.navigationController.visibleViewController == _ArticleVC ) {
        [_ArticleVC onRecordData:notif];
        
    } else if ( _ArticleListVC
        && self.navigationController.visibleViewController == _ArticleListVC ) {
        [_ArticleListVC onDetailDataItem:notif];
        
    } else if ( _ArticleGlobalListVC
               && self.navigationController.visibleViewController == _ArticleGlobalListVC ) {
        [_ArticleGlobalListVC onDetailDataItem:notif];
    };
}

- (void)onArticleSHItemData:(NSNotification *)notif {
    
    if ( _ArticleSalesHistoryVC
        && self.navigationController.visibleViewController == _ArticleSalesHistoryVC ) {
        
        [_ArticleSalesHistoryVC onRecordData:notif];

    };
}


- (void)onRemoteResultUnsuccess:(NSNotification *)notif {
    //int _Action = [[notif.userInfo valueForKey:@"action"] integerValue];
    ACRemoteActionResult *_result = [notif.userInfo valueForKey:@"result"];
    notif = nil;
    
    NSString *AlertMessage = [ACRemoteAction messageByResultCode:_result.status.code];
    
    
    switch(_result.status.code) {

        case RESULTCODE_ACCESSDENIED:
        case RESULTCODE_WAIT_FOR_REGISTER:
             if ( self.window.rootViewController != _LoginVC  ) {
                 [Common.DB clearUserPassword];
                 [self Logout];
             };
            break;
            
        case RESULTCODE_LOGIN_INCORRECT:
        case RESULTCODE_SERVICEUNAVAILABLE:
            if ( self.window.rootViewController != _LoginVC  ) {
                AlertMessage = nil;
                [Common.DB clearUserPassword];
                [self Logout];
            }
            break;
    }
    
    if ( AlertMessage ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:AlertMessage
                                                       delegate:self.window.rootViewController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

};


- (void)onDocumentPart:(NSNotification *)notif {
};

- (void)onGetDocumentDone:(NSNotification *)notif {
    if ( _ComDocPreviewVC
        && self.navigationController.visibleViewController == _ComDocPreviewVC ) {
        
        NSString *shortcut = [notif.userInfo stringValueForKey:@"Shortcut"];
        Invoice *i = [self.DB fetchInvoiceByShortcut:shortcut];
        if ( i ) {
            [self.DB.managedObjectContext refreshObject:i mergeChanges:YES];
           [_ComDocPreviewVC onGetDocumentDone:shortcut];
        };
    }
};

- (void)onRemoteAddDone:(NSNotification *)notif {
    
    if ( _ContractorVC
        && self.navigationController.visibleViewController == _ContractorVC ) {
        
        [_ContractorVC onRecordAddDone:notif];
        
    } else if ( _ComDocVC
        && self.navigationController.visibleViewController == _ComDocVC
        && [_ComDocVC isOrder] ) {
        
        [_ComDocVC onRecordAddDone:notif];
        
    } else if ( _ACDEWaitingQueue
            && self.navigationController.visibleViewController == _ACDEWaitingQueue ) {
            
        [_ACDEWaitingQueue loadList];
    } else if ( _DataExportVC
               && self.navigationController.visibleViewController == _DataExportVC ) {
        [_DataExportVC onRecordAddDone:notif];
        
    }

}

- (void)onRemoteAddError:(NSNotification *)notif {
    
    if ( _ACDEWaitingQueue
               && self.navigationController.visibleViewController == _ACDEWaitingQueue ) {
        
        [_ACDEWaitingQueue loadList];
    } else if ( _DataExportVC
               && self.navigationController.visibleViewController == _DataExportVC ) {
        [_DataExportVC onRecordAddError:notif];
        
    }
    
}

- (void)onPriceData:(NSNotification *)notif {
    
    if ( _ComDocVC
        && self.navigationController.visibleViewController == _ComDocVC ) {
        
        [_ComDocVC onPriceData:notif];
        
    };
    
}

- (void)onLimitData:(NSNotification *)notif {
    
    if ( _ContractorListVC
        && self.navigationController.visibleViewController == _ContractorListVC ) {
        
        [_ContractorListVC onDetailDataItem:notif];
        
    };
    
}

- (void)showContractorVC:(Contractor*)c {

    if ( c ) {
        [self.navigationController pushViewController:self.ContractorVC animated:YES];
        [self.ContractorVC showRecord:c];
    }
}

- (void)showContractorInvoiceListVC:(Contractor*)c {
    if ( c ) {
        [self.navigationController pushViewController:self.InvoiceListVC animated:YES];
        [self.InvoiceListVC showRecord:c];
    }
};

- (void)showContractorPaymentListVC:(Contractor*)c {
    if ( c ) {
        [self.navigationController pushViewController:self.PaymentListVC animated:YES];
        [self.PaymentListVC loadList:c];
    }
};

- (void)showComDocPreview:(id)record {
    if ( record ) {
    
        [self.navigationController pushViewController:self.ComDocPreviewVC animated:YES];
        [self.ComDocPreviewVC showDocument:record remoteEnabled:YES];
    }
}

- (void)showContractorOrderListVC:(Contractor*)c {
    [self.navigationController pushViewController:self.OrderListVC animated:YES];
    [self.OrderListVC showRecord:c];
}

- (void)showComDoc:(id)record {
    [self.navigationController pushViewController:self.ComDocVC animated:YES];
    [self.ComDocVC showRecord:record];
}

- (void)showComDocItem:(id)record{
    [self.navigationController pushViewController:self.ComDocItemVC animated:YES];
    [self.ComDocItemVC showRecord:record];
}

- (void)selectArticlesForDocument:(id)record {
    self.ArticleListVC.selectionMode = YES;
    self.ArticleListVC.ComDoc = record;
    [self.navigationController pushViewController:self.ArticleListVC animated:YES];
}


- (void)showArticle:(Article*)article {
    [self.navigationController pushViewController:self.ArticleVC animated:YES];
    [self.ArticleVC showRecord:article];
}

- (void)showArticleSalesHistory:(Article*)article {
    
    if ( self.HelloData.cap & SERVERCAP_ARTICLE_SALESHISTORY ) {
        
        [self.navigationController pushViewController:self.ArticleSalesHistoryVC animated:YES];
        [self.ArticleSalesHistoryVC showRecord:article];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Ten serwer nie pozwala na przeglądanie historii sprzedaży Skontaktuj się z Administratorem serwera.", nil) delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    

}

- (void)showArticleList {
    [self.navigationController pushViewController:self.ArticleGlobalListVC animated:YES];
}

- (void)showDataExportItem:(DataExport*)de {
    [self.navigationController pushViewController:self.DataExportVC animated:YES];
    [self.DataExportVC showRecord:de];
}

+(void)postNotification:(NSString*)n target:(id)target {
    NSArray *keys = [NSArray arrayWithObjects:@"NN", nil];
    NSArray *values = [NSArray arrayWithObjects:n, nil];
    [target performSelectorOnMainThread:@selector(postNotification:) withObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] waitUntilDone:NO];
}

- (void)showLimitsForContractor:(Contractor*)c {
    [self.navigationController pushViewController:self.CLimitListVC animated:YES];
    [self.CLimitListVC showRecord:c];
}

-(void)newOrderForCustomer:(Contractor *)c {
    
    _new_order_customer = c;
    
    if ( [self.DB eOrdersForContractor:c] ) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: [NSString stringWithFormat:@"%@ - %@", c.shortcut, NSLocalizedString(@"Ten kontrahent posiada już przynajmniej jedno przygotowywane zamówienie. Czy utworzyć kolejne ?", nil)] delegate: self cancelButtonTitle: NSLocalizedString(@"Nie", nil)  otherButtonTitles:NSLocalizedString(@"Tak", nil),nil];
        [alertView show];
        
    } else {
        [self alertView:nil clickedButtonAtIndex:1];
    }
    
}

-(void)newContractor {

    Contractor *c = [Common.DB newContractor];
    if ( c ) {
        [Common showContractorVC:c];
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( buttonIndex == 1 ) {
        
        Order *order = [Common.DB newOrderForCustomer:_new_order_customer];
        if ( order ) {
            [Common showComDoc:order];
        }
        
    }
}

@end

@implementation NSString (ERPC)

static const char *base64_chars =   
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789+/";


static char rstr[] = {
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  62,   0,   0,   0,  63,
    52,  53,  54,  55,  56,  57,  58,  59,  60,  61,   0,   0,   0,   0,   0,   0,
    0,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,
    15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,   0,   0,   0,   0,   0,
    0,  26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,   0,   0,   0,   0,   0};


- (NSString*) HMACWithSecret:(NSString*) secret
{
    CCHmacContext    ctx;
    const char       *key = [secret UTF8String];
    const char       *str = [self UTF8String];
    unsigned char    mac[CC_MD5_DIGEST_LENGTH];
    char             hexmac[2 * CC_MD5_DIGEST_LENGTH + 1];
    char             *p;
    
    CCHmacInit(&ctx, kCCHmacAlgMD5, key, strlen( key ));
    CCHmacUpdate(&ctx, str, strlen(str) );
    CCHmacFinal(&ctx, mac );
    
    p = hexmac;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
        snprintf( p, 3, "%02x", mac[ i ] );
        p += 2;
    }
    
    return [[NSString stringWithUTF8String:hexmac] uppercaseString];
}

+(NSString*) Base64encodeWithCString:(const char*)bytes_to_encode length:(unsigned long)in_len {
    
    NSMutableString *ret = [[NSMutableString alloc] init];

    
    if ( bytes_to_encode && in_len > 0 ) {
        
        
        int i = 0;
        int j = 0;
        unsigned char char_array_3[3];
        unsigned char char_array_4[4];
        
        while (in_len--) {
            char_array_3[i++] = *(bytes_to_encode++);
            if (i == 3) {
                char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
                char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
                char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
                char_array_4[3] = char_array_3[2] & 0x3f;
                
                for(i = 0; (i <4) ; i++)
                    [ret appendFormat:@"%c", base64_chars[char_array_4[i]]];
                i = 0;
            }
        }
        
        if (i) {
            for(j = i; j < 3; j++)
                char_array_3[j] = '\0';
            
            char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
            char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
            char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
            char_array_4[3] = char_array_3[2] & 0x3f;
            
            for (j = 0; (j < i + 1); j++)
                [ret appendFormat:@"%c", base64_chars[char_array_4[j]]];
            
            while((i++ < 3))
                [ret appendString:@"="];
            
        }
    };
    
    
    return ret;

}
-(NSString*) Base64encode {

    const char *bytes_to_encode = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned long in_len = bytes_to_encode == NULL ? 0 : strlen(bytes_to_encode);
    
    return [NSString Base64encodeWithCString:bytes_to_encode length:in_len];

};

+(NSString*) Base64encodeForUrlWithCString:(const char*)bytes_to_encode length:(int)in_len {
    return  [[NSString Base64encodeWithCString:bytes_to_encode length:in_len] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
};

-(NSString*) Base64encodeForUrl {
    return  [[self Base64encode] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
};

-(unsigned char*) Base64decode:(int*)OutLen  {
    
    *OutLen = 0;
    if ( self.length == 0 ) return NULL;
    
    char *input = malloc(self.length+1);
    
    if ( [self getCString:input maxLength:self.length+1 encoding:NSStringEncodingConversionAllowLossy] == NO ) {
        free(input);
        return NULL;
    }
    
    
    
    size_t i = 0;
    size_t l = self.length;
    
    unsigned char *output = malloc(self.length+1);
    int out_offset = 0;
    
    while (i < l)
    {
        while (i < l && (input[i] == 13 || input[i] == 10))
            i++;
        if (i < l)
        {
            char b1 = (char)((rstr[(int)input[i]] << 2 & 0xfc) + ((i+1<l)?(rstr[(int)input[i + 1]] >> 4 & 0x03):0));
            
            output[out_offset] = b1;
            out_offset++;
            
            if (i+2<l && input[i + 2] != '=')
            {
                char b2 = (char)((rstr[(int)input[i + 1]] << 4 & 0xf0) +
                                 (rstr[(int)input[i + 2]] >> 2 & 0x0f));
                output[out_offset] = b2;
                out_offset++;
            }
            if (i+3 <l && input[i + 3] != '=')
            {
                char b3 = (char)((rstr[(int)input[i + 2]] << 6 & 0xc0) +
                                 rstr[(int)input[i + 3]]);
                output[out_offset] = b3;
                out_offset++;
            }
            i += 4;
        }
    }
    
    free(input);
    
    if ( out_offset > 0 ) {
        *OutLen = out_offset;
        output[out_offset] = 0;
        out_offset++;
        output = realloc(output, out_offset);
    } else if (output) {
        free(output);
    }
    
    
    return (unsigned char*)output;
    
}

-(NSData*) Base64decode  {
    
    int size = 0;
    unsigned char *data = [self Base64decode:&size];
    NSData *result = nil;
    
    if (data) {
        result = [NSData dataWithBytesNoCopy:data length:size];
    };
    return result;
}

-(NSString*) firstChar {
    if ( self.length > 0 ) {
        return [[self substringToIndex:1] uppercaseString];
    }
    
    return @"";
}

-(NSString*)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


-(double)doubleValueWithLocalization {
    return [[self stringByReplacingOccurrencesOfString:[[NSLocale currentLocale] objectForKey: NSLocaleDecimalSeparator] withString:@"."] doubleValue];
}

@end


@implementation NSDictionary (ERPC)

-(NSString*) stringValueForKey:(NSString*)key {
    NSString *s = [self valueForKey:key];
    return s == nil || ![s isKindOfClass:[NSString class]] ? @"" : s;
}

-(int) intValueForKey:(NSString*)key {
    NSNumber *n = [self valueForKey:key];
    return n == nil || ![n isKindOfClass:[NSNumber class]] ? 0 : [n intValue];
};

-(double) doubleValueForKey:(NSString*)key {
    NSNumber *n = [self valueForKey:key];
    return n == nil || ![n isKindOfClass:[NSNumber class]] ? 0.00 : [n doubleValue];
};

-(double) floatValueForKey:(NSString*)key {
    NSNumber *n = [self valueForKey:key];
    return n == nil || ![n isKindOfClass:[NSNumber class]] ? 0.00 : [n floatValue];
};

-(NSNumber*) numberValueForKey:(NSString*)key {
    NSNumber *n = [self valueForKey:key];
    return n == nil || ![n isKindOfClass:[NSNumber class]] ? [NSNumber numberWithDouble:0.00] : n;
};

-(BOOL) boolValueForKey:(NSString*)key {
    NSNumber *n = [self valueForKey:key];
    return n && [n isKindOfClass:[NSNumber class]] && [n boolValue] == YES;
}

@end

@implementation NSNumber (ERPC)
-(double)addVatByRate:(NSString*)rate {
    
    return ( [self doubleValue] * [rate intValue] / 100 ) + [self doubleValue];

}

-(NSString*)moneyToString {
    
    return [[NSString stringWithFormat:@"%.2f", [self doubleValue]] stringByReplacingOccurrencesOfString:@"." withString:[[NSLocale currentLocale] objectForKey: NSLocaleDecimalSeparator]];
}
@end

@implementation UIButton (ERPC)

-(void)setTitle:(NSString*)title {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateDisabled];
    [self setTitle:title forState:UIControlStateSelected];
}

@end