/*
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

#import "ACContractorVC.h"
#import "BackgroundOperations.h"
#import "Contractor.h"
#import "ERPCCommon.h"
#import "ACUIContractorButtons.h"
#import "Limit.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import "RemoteAction.h"

@interface ACContractorVC ()

@end

@implementation ACContractorVC {
    ACUIDataItem *di_shortcut;
    ACUIDataItem *di_locked;
    ACUIMultiDataItem *di_address;
    ACUIDataItem *di_NIP;
    ACUIMultiDataItem *di_phone;
    ACUIMultiDataItem *di_email;
    ACUIMultiDataItem *di_www;
    ACUIDataItem *di_limit;
    
    UIActionSheet *webActionSheet;
    UIActionSheet *emailActionSheet;
    UIActionSheet *phoneActionSheet;
    UIActionSheet *addressActionSheet;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.refreshPanelVisible = YES;
        self.form.delegate = self;
        
        di_shortcut = [self.form CreateDataItem:@"symbol"];
        di_locked = [self.form CreateDataItem:@""];
        di_locked.data = NSLocalizedString(@"Transakcje zablokowane", nil);
        di_locked.hidden = YES;
        di_locked.textColor = [UIColor redColor];
        di_address = [self.form CreateMultiDataItem:@"adres"];
        di_NIP = [self.form CreateDataItem:@"NIP"];
        di_phone = [self.form CreateMultiDataItem:@"telefon"];
        di_phone.hideIfEmpty = YES;
        di_email = [self.form CreateMultiDataItem:@"e-mail"];
        di_email.hideIfEmpty = YES;
        di_www = [self.form CreateMultiDataItem:@"www"];
        di_www.hideIfEmpty = YES;
        di_limit = [self.form CreateDataItem:@"limit"];
        di_limit.hideIfEmpty = YES;
        
        ACUIContractorButtons *btns = [[ACUIContractorButtons alloc] initWithNamedNib:@"ACUIContractorButtons" form:self.form];
        btns.topMargin = 20;
        [btns.btnInvoices addTarget:self action:@selector(invoicesTouch:) forControlEvents:UIControlEventTouchDown];
        [btns.btnPayments addTarget:self action:@selector(paymentsTouch:) forControlEvents:UIControlEventTouchDown];
        [btns.btnOrders addTarget:self action:@selector(ordersTouch:) forControlEvents:UIControlEventTouchDown];
        [self.form AddUIPart:btns];
        
    }
    return self;
}


-(void)fetchRemoteDataByShortcut:(NSString*)shortcut RefreshTouch:(BOOL)rtouch {
    
    if ( self.contractor ) {
        [ACRemoteOperation customerSearch:shortcut mtu:3];
        [ACRemoteOperation limitForContractor:shortcut];
    }
}

-(void)fetchRemoteDataWithRefreshTouch:(BOOL)rtouch {
    [self fetchRemoteDataByShortcut:self.contractor.shortcut RefreshTouch:rtouch];
}

-(id)fetchRecordByShortcut:(NSString*)shortcut {
    return [Common.DB fetchContractorByShortcut:self.contractor.shortcut];
}

-(id)fetchData {
    return [Common.DB fetchContractor:self.contractor];
}

-(void)setDetailtButton:(ACUIMultiDataItem*)di touchAction:(SEL)action ImageName:(NSString*)img {
    if ( di.count > 0 ) {
        [di addDetailButtonWithImageName:img addTarget:self touchAction:action];
        [di setDataTouchTarget:self action:action];
    } else {
        [di removeDetailButton];
        [di setDataTouchTarget:nil action:nil];
    }
}

-(void)onDataView {

    if ( self.contractor )  {
        
        self.form.Title = self.contractor.name;
        di_shortcut.data = self.contractor.shortcut;
        
        di_locked.hidden = ![self.contractor.trnlocked boolValue];
        
        [di_address setData:[[NSString stringWithFormat:@"%@ %@", self.contractor.street ? self.contractor.street : @"", self.contractor.houseno ? self.contractor.houseno : @""] trim] Level:0];
        
        [di_address setData:[[NSString stringWithFormat:@"%@ %@", self.contractor.postcode ? self.contractor.postcode : @"", self.contractor.city ? self.contractor.city : @""] trim] Level:1];
        
        [di_address setData:self.contractor.country Level:2];
        
        [self setDetailtButton:di_address touchAction:@selector(addressTouch:) ImageName:@"map.png"];
        
        di_NIP.data = self.contractor.nip;
        
        [di_phone setData:self.contractor.tel1 Level:0];
        [di_phone setData:self.contractor.tel2 Level:1];
        [di_phone setData:self.contractor.tel3 Level:2];
        

        [self setDetailtButton:di_phone touchAction:@selector(phoneTouch:) ImageName:@"call.png"];
        
        [di_email setData:self.contractor.email1 Level:0];
        [di_email setData:self.contractor.email2 Level:1];
        [di_email setData:self.contractor.email3 Level:2];
        
        
        [self setDetailtButton:di_email touchAction:@selector(emailTouch:) ImageName:@"compose.png"];
        
        [di_www setData:self.contractor.www1 Level:0];
        [di_www setData:self.contractor.www2 Level:1];
        [di_www setData:self.contractor.www3 Level:2];
        
        
        [self setDetailtButton:di_www touchAction:@selector(wwwTouch:) ImageName:@"www.png"];
        
        Limit *l = [Common.DB contractor1stLimit:self.contractor];
        if ( l ) {
            if ( [l.unlimited boolValue] == YES ) {
                di_limit.data = NSLocalizedString(@"Nieograniczony", nil);
            } else {
                [di_limit setDoubleValue:[l.remain doubleValue] withSuffix:l.currency];
            }
          
            [di_limit addDetailButtonWithImageName:@"detail.png" addTarget:self touchAction:@selector(limitTouch:)];
            [di_limit setDataTouchTarget:self action:@selector(limitTouch:)];
            
        } else {
            [di_limit setDataTouchTarget:nil action:nil];
            [di_limit removeDetailButton];
            di_limit.data = @"";
        }
        
        [self showFavBtn];
        
    } else {
        di_shortcut.data = @"";
        di_address.data = @"";
        di_NIP.data = @"";
        di_phone.data = @"";
        di_email.data = @"";
        di_www.data = @"";
        di_limit.data = @"";
        di_locked.hidden = YES;
    }
}

-(Contractor*)contractor {
    return (Contractor*)self.record;
}

-(NSDate*)getDate {
    return self.contractor.uptodate;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if ( buttonIndex == actionSheet.cancelButtonIndex ) return;
    NSString *data = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ( !data || data.length < 1 ) return;
    
    if ( actionSheet == webActionSheet ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", data]]];
    } else if ( actionSheet == emailActionSheet ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", data]]];
    } else if ( actionSheet == phoneActionSheet ) {

        NSString *nr = @"";
        
        bool p = NO;
        char *cstr = malloc(data.length+1);
        [data getCString:cstr maxLength:data.length+1 encoding:NSStringEncodingConversionAllowLossy];
        
        for(int a=0;a<data.length;a++) {
            
            if ( ( cstr[a] >= '0'
                  && cstr[a] <= '9' )
                || ( a == 0
                    && cstr[a] == '+' )) {
                    if ( cstr[a] == '+' ) {
                        p=YES;
                    }
                    nr = [NSString stringWithFormat:@"%@%c",nr, cstr[a]];
                }
        }
        
        free(cstr);
        data = nil;
        
        if ( nr && nr.length > 0 ) {
            if ( !p && nr.length == 9 ) {
                nr = [NSString stringWithFormat:@"+48%@",nr];
                p = YES;
            }
            if ( p ) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", nr]]];
            }
        }
        
    } else if ( addressActionSheet == actionSheet ) {
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            
            NSDictionary *address = @{
                                      (NSString *)kABPersonAddressStreetKey: self.contractor.street ? self.contractor.street : @"",
                                      (NSString *)kABPersonAddressCityKey: self.contractor.city ? self.contractor.city : @"",
                                      (NSString *)kABPersonAddressCountryKey: self.contractor.country ? self.contractor.country : @"",
                                      (NSString *)kABPersonAddressZIPKey: self.contractor.postcode ? self.contractor.postcode : @""
                                      };
            
            [geocoder geocodeAddressDictionary:address
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             
                             CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                             MKPlacemark *placemark = [[MKPlacemark alloc]
                                                       initWithCoordinate:geocodedPlacemark.location.coordinate
                                                       addressDictionary:geocodedPlacemark.addressDictionary];
                             
                             MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                             [mapItem setName:geocodedPlacemark.name];
                             
                             
                             if ( buttonIndex == 0 ) {
                                 NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                                 MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                                 [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                             } else {
                                 [MKMapItem openMapsWithItems:@[mapItem] launchOptions:nil];
                             }
                             
                         }];
        }

    }
    
}


-(UIActionSheet *)ActionSheetWithMultiDataItem:(ACUIMultiDataItem*)di {
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for(int a=0;a<3;a++) {
        NSString *x = [di getDataWithLevel:a];
        if ( x && x.length > 0 ) {
            [as addButtonWithTitle:x];
        }
    }
    
    [as setCancelButtonIndex: [as addButtonWithTitle:NSLocalizedString(@"Anuluj", nil)]];
    
    as.actionSheetStyle = UIActionSheetStyleAutomatic;
    as.backgroundColor = [UIColor whiteColor];
    
    
    return as;
}


- (void)wwwTouch:(NSString*)url {
    
    webActionSheet = [self ActionSheetWithMultiDataItem:di_www];
    [webActionSheet showInView:self.view];
    
}

- (IBAction)emailTouch:(id)sender {
    
    emailActionSheet = [self ActionSheetWithMultiDataItem:di_email];
    [emailActionSheet showInView:self.view];
}

- (IBAction)phoneTouch:(id)sender {
    
    
    phoneActionSheet = [self ActionSheetWithMultiDataItem:di_phone];
    [phoneActionSheet showInView:self.view];

}

- (IBAction)ordersTouch:(id)sender {
    
    if ( Common.HelloData.cap & SERVERCAP_ORDERS
         && Common.HelloData.cap & SERVERCAP_ORDER_ITEMS ) {
        
        [Common showContractorOrderListVC:self.contractor];
        
    } else {
    
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Ten serwer nie pozwala na przeglądanie zamówień. Skontaktuj się z Administratorem serwera.", nil) delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (IBAction)invoicesTouch:(id)sender {
    
    if ( Common.HelloData.cap & SERVERCAP_INVOICES
        && Common.HelloData.cap & SERVERCAP_INVOICE_ITEMS ) {
        
    [Common showContractorInvoiceListVC:self.contractor];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Ten serwer nie pozwala na przeglądanie faktur. Skontaktuj się z Administratorem serwera.", nil) delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)paymentsTouch:(id)sender {
    
    if ( Common.HelloData.cap & SERVERCAP_OUTSTANDINGPAYMENTS ) {
        
       [Common showContractorPaymentListVC:self.contractor];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Ten serwer nie pozwala na przeglądanie płatności. Skontaktuj się z Administratorem serwera.", nil) delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)addressTouch:(id)sender {
    
    addressActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Anuluj", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Wyznacz trasę", nil), NSLocalizedString(@"Pokaż na mapie", nil), nil];
    
    
    
    addressActionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    addressActionSheet.backgroundColor = [UIColor whiteColor];
    [addressActionSheet showInView:self.view];
}

- (IBAction)limitTouch:(id)sender {
    [Common showLimitsForContractor:self.contractor];
}


@end
