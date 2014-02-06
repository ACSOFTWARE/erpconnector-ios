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
#import "RemoteAction.h"
#import "LoginVC.h"
#import "SearchVC.h"
#import "FavoritesVC.h"
#import "HistoryVC.h"
#import "ContractorVC.h"
#import "InfoVC.h"
#import "InvoiceListVC.h"
#import "InvoicePreviewVC.h"
#import "PaymentListVC.h"
#import "Invoice.h"

#include <CommonCrypto/CommonHMAC.h>
#include <Foundation/Foundation.h>

ACERPCCommon *Common = nil;

NSString *kConnectionErrorNotification = @"n01";
NSString *kLoginOperationNotification = @"n02";
NSString *kRegisterDeviceOperationNotification = @"n03";
NSString *kCustomerSearchDoneNotification = @"n04";
NSString *kCustomerDataNotification = @"n05";
NSString *kGetInvoiceListDoneNotification = @"n06";
NSString *kInvoiceDataNotification = @"n07";
NSString *kGetOutstandingPaymentsListDoneNotification = @"n08";
NSString *kRemoteResultUnsuccess = @"n9";
NSString *kDocumentPartNotification = @"n10";
NSString *kGetDocumentDoneNotification = @"n11";
NSString *kVersionErrorNotification = @"n12";

@implementation ACERPCCommon {
    NSString *_UDID;
    UINavigationController *_navigationController;
    ACLoginVC *_LoginVC;
    ACSearchVC *_SearchVC;
    ACFavoritesVC *_FavoritesVC;
    ACHistoryVC *_HistoryVC;
    ACContractorVC *_ContractorVC;
    ACInfoVC *_InfoVC;
    ACInvoiceListVC *_InvoiceListVC;
    ACInvoicePreviewVC *_InvoicePreviewVC;
    ACPaymentListVC *_PaymentListVC;
    ACDatabase *_DB;
}

@synthesize window = _window;
@synthesize Sign = _Sign;
@synthesize Login = _Login;
@synthesize Password = _Password;
@synthesize ServerAddress = _ServerAddress;
@synthesize ServerCap = _ServerCap;
@synthesize OpQueue = _OpQueue;
@synthesize HelloData = _HelloData;
@synthesize LastLogin = _LastLogin;

-(id) init {
    self = [super init];
    if ( self ) {
        _window = nil;
        _navigationController = nil;
        _navigationController = nil;
        _OpQueue = [[NSOperationQueue alloc] init];
        _InfoVC = nil;
        _SearchVC = nil;
        _HistoryVC = nil;
        _InvoiceListVC = nil;
        _InvoicePreviewVC = nil;
        _DB = nil;
        _HelloData = nil;
        _LastLogin = nil;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(defaultsChanged:)
                       name:NSUserDefaultsDidChangeNotification
                     object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionError:) name:kConnectionErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVersionError:) name:kVersionErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRegisterResult:) name:kRegisterDeviceOperationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomerData:) name:kCustomerDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteSearchDone:) name:kCustomerSearchDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteLoginResult:) name:kLoginOperationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteResultUnsuccess:) name:kRemoteResultUnsuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetInvoiceListDone:) name:kGetInvoiceListDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInvoiceData:) name:kInvoiceDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetPaymentListDone:) name:kGetOutstandingPaymentsListDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDocumentPart:) name:kDocumentPartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetDocumentDone:) name:kGetDocumentDoneNotification object:nil];
        
    }
    return self;
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
        _navigationController = [[UINavigationController alloc] initWithRootViewController:self.SearchVC];
        
        [_navigationController.navigationBar setBackgroundImage:[UIImage  imageNamed : @"nav_bg1" ] forBarMetrics:UIBarMetricsDefault];

        [_navigationController setDelegate:self];
    };
    return _navigationController;
    
};

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (  _InvoicePreviewVC
        && viewController != _InvoicePreviewVC ) {
        _InvoicePreviewVC = nil;
    } else if ( viewController == _SearchVC ) {
        [_SearchVC onRemoteSearchDone:nil];
    };
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( viewController == _HistoryVC ) {
        [_HistoryVC refresh];
    } else if ( viewController == _FavoritesVC ) {
        [_FavoritesVC refresh];
    }
}

-(ACLoginVC*)LoginVC {
    if ( _LoginVC == nil ) {
         _LoginVC = [[ACLoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    }
    return _LoginVC;
}

-(ACSearchVC*)SearchVC {
    if ( _SearchVC == nil ) {
        _SearchVC = [[ACSearchVC alloc] initWithNibName:@"SearchVC" bundle:nil];
    }
    return _SearchVC;
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
        _ContractorVC = [[ACContractorVC alloc] initWithNibName:@"ContractorVC" bundle:nil];
    }
    
    return _ContractorVC;
}

-(ACInfoVC*)InfoVC {
    if ( _InfoVC == nil ) {
        _InfoVC = [[ACInfoVC alloc] initWithNibName:@"InfoVC" bundle:nil];
    }

    return _InfoVC;
}

-(ACInvoiceListVC*)InvoiceListVC {
    if ( _InvoiceListVC == nil ) {
        _InvoiceListVC = [[ACInvoiceListVC alloc] initWithNibName:@"InvoiceListVC" bundle:nil];
    }
    
    return _InvoiceListVC;
}

-(ACInvoicePreviewVC*)InvoicePreviewVC {
    if ( _InvoicePreviewVC == nil ) {
        _InvoicePreviewVC = [[ACInvoicePreviewVC alloc] initWithNibName:@"InvoicePreviewVC" bundle:nil];
    }
    
    return _InvoicePreviewVC;
}

-(ACPaymentListVC*)PaymentListVC {
    if ( _PaymentListVC == nil ) {
        _PaymentListVC = [[ACPaymentListVC alloc] initWithNibName:@"PaymentListVC" bundle:nil];
    }
    
    return _PaymentListVC;
}

-(ACDatabase*)DB {
    assert([NSThread isMainThread]);
    
    if ( !_DB ) {
        _DB = [[ACDatabase alloc] init];
    }
    
    return _DB;
}

-(void)Logout {

    _LastLogin = nil;
    [_OpQueue cancelAllOperations];
    
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

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)onConnectionError:(NSNotification *)notif {
    if ( self.window.rootViewController == _LoginVC ) {
        
        [_LoginVC onConnectionError:notif];
        
    } else if ( _SearchVC
        && self.navigationController.visibleViewController == _SearchVC ) {
        
        [_SearchVC onRemoteSearchDone:notif];
        
    } else if ( _ContractorVC
               && self.navigationController.visibleViewController == _ContractorVC ) {
        
        [_ContractorVC onConnectionError:notif];
         
    } else if ( _InvoiceListVC
               && self.navigationController.visibleViewController == _InvoiceListVC ) {
        
        [_InvoiceListVC onConnectionError:notif];
    } else if ( _InvoicePreviewVC
               && self.navigationController.visibleViewController == _InvoicePreviewVC
               && ![_InvoicePreviewVC documentVisible] ) {
        [_InvoicePreviewVC documentErrorWithMessage:NSLocalizedString(@"Brak połączenia z serwerem", nil)];
    }
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
            && [hello isKindOfClass:[ACRemoteActionResultHello class]] ) {
            _HelloData = hello;
        }
    }
};

- (void)onRemoteSearchDone:(NSNotification *)notif {
    if ( _SearchVC
        && self.navigationController.visibleViewController == _SearchVC ) {
        
        [_SearchVC onRemoteSearchDone:notif];
        
    } else if ( _ContractorVC
               && self.navigationController.visibleViewController == _ContractorVC ) {
        
        [_ContractorVC onRemoteSearchDone:notif];
        
    }
}

- (void)onCustomerData:(NSNotification *)notif {
    if ( _SearchVC
        && self.navigationController.visibleViewController == _SearchVC ) {
        
        [_SearchVC onCustomerData:notif];
        
    } else if ( _ContractorVC
               && self.navigationController.visibleViewController == _ContractorVC ) {
        
        [_ContractorVC onCustomerData:notif];
        
    }
}

- (void)onGetInvoiceListDone:(NSNotification *)notif {
    if ( _InvoiceListVC
        && self.navigationController.visibleViewController == _InvoiceListVC ) {
        [_InvoiceListVC onGetListDoneDone:notif];
    }
};

- (void)onInvoiceData:(NSNotification *)notif {
    if ( _InvoiceListVC
        && self.navigationController.visibleViewController == _InvoiceListVC ) {
        [_InvoiceListVC onInvoiceData:notif];
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


- (void)onRemoteResultUnsuccess:(NSNotification *)notif {
    //int _Action = [[notif.userInfo valueForKey:@"action"] integerValue];
    ACRemoteActionResult *_result = [notif.userInfo valueForKey:@"result"];
    notif = nil;
    
    NSString *AlertMessage = nil;
    
    switch(_result.status.code) {
        case RESULTCODE_INTERNAL_SERVER_ERROR:
            AlertMessage = NSLocalizedString(@"Wystąpił wewnętrzny błąd serwera. Skontaktuj się z administratorem!", nil);
            break;
        case RESULTCODE_PARAM_ERROR:
            AlertMessage = NSLocalizedString(@"Błąd kompatybilności. Skontaktuj się z administratorem!", nil);
            break;
        case RESULTCODE_SERVICEUNAVAILABLE:
            if ( self.window.rootViewController == _LoginVC  ) {
              AlertMessage = NSLocalizedString(@"Usługa niedostępna. Skontaktuj się z administratorem!", nil);
            }
            break;
        case RESULTCODE_ACCESSDENIED:
             AlertMessage = NSLocalizedString(@"Brak dostępu! Skontaktuj się z administratorem.", nil);
             if ( self.window.rootViewController != _LoginVC  ) {
                 [self Logout];
             };
            break;
            
        case RESULTCODE_LOGIN_INCORRECT:
            if ( self.window.rootViewController == _LoginVC  ) {
              AlertMessage = NSLocalizedString(@"Błędny login lub hasło", nil);
            }
            break;
            
        case RESULTCODE_INSUFF_ACCESS_RIGHTS:
            AlertMessage = NSLocalizedString(@"Brak uprawnień", nil);
            break;
            
        case RESULTCODE_WAIT_FOR_REGISTER:
            AlertMessage = NSLocalizedString(@"Urządzenie oczekuje na rejestrację. Skontaktuj się z administratorem serwera.", nil);
            if ( self.window.rootViewController != _LoginVC  ) {
                [self Logout];
            };
            break;

    }
    
    if ( AlertMessage ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:AlertMessage
                                                       delegate:self.window.rootViewController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

};


- (void)onDocumentPart:(NSNotification *)notif {
    if ( _InvoicePreviewVC
        && self.navigationController.visibleViewController == _InvoicePreviewVC ) {
        [_InvoicePreviewVC onDocumentPart:[notif.userInfo stringValueForKey:@"Shortcut"] position:[notif.userInfo intValueForKey:@"Position"] size:[notif.userInfo intValueForKey:@"Size"] ];
    }
};

- (void)onGetDocumentDone:(NSNotification *)notif {
    if ( _InvoicePreviewVC
        && self.navigationController.visibleViewController == _InvoicePreviewVC ) {
        
        NSString *shortcut = [notif.userInfo stringValueForKey:@"Shortcut"];
        Invoice *i = [self.DB fetchInvoiceByShortcut:shortcut];
        if ( i ) {
            [self.DB.managedObjectContext refreshObject:i mergeChanges:YES];
           [_InvoicePreviewVC onGetDocumentDone:shortcut];
        };
    }
};

- (void)showContractorVC:(Contractor*)c {

    if ( c ) {
        [self.navigationController pushViewController:self.ContractorVC animated:YES];
        [self.ContractorVC showContractorData:c];
    }
}

- (void)showContractorInvoiceListVC:(Contractor*)c {
    if ( c ) {
        [self.navigationController pushViewController:self.InvoiceListVC animated:YES];
        [self.InvoiceListVC loadList:c];
    }
};

- (void)showContractorPaymentListVC:(Contractor*)c {
    if ( c ) {
        [self.navigationController pushViewController:self.PaymentListVC animated:YES];
        [self.PaymentListVC loadList:c];
    }
};

- (void)showInvoicePreview:(NSString*)shortcut {
    if ( shortcut ) {
        
       // QLPreviewController *previewController = [[QLPreviewController alloc] init];
       // previewController.dataSource = self;
       // previewController.delegate = self;
        
       // [self.navigationController pushViewController:previewController animated:YES];
        [self.navigationController pushViewController:self.InvoicePreviewVC animated:YES];
        [self.InvoicePreviewVC showDocument:shortcut remoteEnabled:YES];
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

-(NSString*) Base64encode {
    
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    const char *bytes_to_encode = [self cStringUsingEncoding:NSUTF8StringEncoding];
    int in_len = bytes_to_encode == NULL ? 0 : strlen(bytes_to_encode);
    
    if ( in_len > 0 ) {
        
        
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

@end


@implementation NSDictionary (ERPC)

-(NSString*) stringValueForKey:(NSString*)key {
    NSString *s = [self valueForKey:key];
    return s == nil || ![s isKindOfClass:[NSString class]] ? @"" : s;
}

-(int) intValueForKey:(NSString*)key {
    NSNumber *n = [self valueForKey:key];
    return n == nil || ![n isKindOfClass:[NSNumber class]] ? 0 : [n integerValue];
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
    return n && [n boolValue] == YES;
}

@end