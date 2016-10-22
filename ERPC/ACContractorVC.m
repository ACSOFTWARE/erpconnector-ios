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
#import "ACUIDeleteBtn.h"
#import "ACUIExportBtn.h"
#import "MFSideMenu/MFSideMenu.h"
#import "ACDataExportVC.h"
#import "DataExport.h"

@interface ACContractorVC ()

@end

@implementation ACContractorVC {
    ACUIDataItem *di_name;
    ACUIDataItem *di_shortcut;
    ACUIDataItem *di_locked;
    ACUIMultiDataItem *di_address;
    
    ACUIDataItem *di_addr_country;
    ACUIDataItem *di_addr_region;
    ACUIDataItem *di_addr_postcode;
    ACUIDataItem *di_addr_city;
    ACUIDataItem *di_addr_street;
    ACUIDataItem *di_addr_houseno;
    
    ACUIDataItem *di_NIP;
    ACUIMultiDataItem *di_phone;
    ACUIDataItem *di_single_phone;
    ACUIMultiDataItem *di_email;
    ACUIDataItem *di_single_email;
    ACUIMultiDataItem *di_www;
    ACUIDataItem *di_single_www;
    ACUIDataItem *di_limit;
    ACUIDataItem *di_limit_credit;
    ACUIContractorButtons *btns;
    ACUIDataItem *di_state;
    
    ACUIDeleteBtn *btnDel;
    ACUIExportBtn *btnExport;
    
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
        
        di_name = [self.form CreateDataItem:@"nazwa"];
        
        di_locked = [self.form CreateDataItem:@""];
        di_locked.data = NSLocalizedString(@"Transakcje zablokowane", nil);
        di_locked.hidden = YES;
        di_locked.textColor = [UIColor redColor];
        di_address = [self.form CreateMultiDataItem:@"adres"];
        
        di_addr_country = [self.form CreateDataItem:@"kraj"];
        di_addr_region = [self.form CreateDataItem:@"region"];
        di_addr_postcode = [self.form CreateDataItem:@"kod pocztowy"];
        di_addr_city = [self.form CreateDataItem:@"miasto"];
        di_addr_street = [self.form CreateDataItem:@"ulica"];
        di_addr_houseno = [self.form CreateDataItem:@"nr"];
        
        di_NIP = [self.form CreateDataItem:@"NIP"];
        di_phone = [self.form CreateMultiDataItem:@"telefon"];
        di_phone.hideIfEmpty = YES;
        di_email = [self.form CreateMultiDataItem:@"e-mail"];
        di_email.hideIfEmpty = YES;
        di_www = [self.form CreateMultiDataItem:@"www"];
        di_www.hideIfEmpty = YES;
        di_limit = [self.form CreateDataItem:@"limit"];
        di_limit.hideIfEmpty = YES;
        
        di_limit_credit = [self.form CreateDataItem:@"limit kredytowy"];
        di_limit_credit.hideIfEmpty = YES;
        
        di_single_phone = [self.form CreateDataItem:@"telefon"];
        di_single_email = [self.form CreateDataItem:@"e-mail"];
        di_single_www = [self.form CreateDataItem:@"www"];
        
        di_state = [self.form CreateDataItem:@"stan"];
        
        btns = nil;
        btnDel = nil;
        
    }
    return self;
}


-(void)fetchRemoteDataByShortcut:(NSString*)shortcut RefreshTouch:(BOOL)rtouch {
    
    if ( self.contractor
         && shortcut != nil
         && shortcut.length > 0 ) {
        
        [ACRemoteOperation customerSearchOnlyByShortcut:shortcut];
        [ACRemoteOperation limitForContractor:shortcut];
    }
}

-(void)fetchRemoteDataWithRefreshTouch:(BOOL)rtouch {
    [self fetchRemoteDataByShortcut:self.contractor.shortcut RefreshTouch:rtouch];
}

-(id)fetchRecordByShortcut:(NSString*)shortcut {
    return [Common.DB fetchContractorByShortcut:shortcut];
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

- (BOOL)exportVCisPrevious {
    id v = nil;
    
    if ( Common.navigationController.viewControllers.count > 1 ) {
        v = [Common.navigationController.viewControllers objectAtIndex:Common.navigationController.viewControllers.count-2];
        if ( [v isKindOfClass:[ACDataExportVC class]]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)showDataExportDetails:(id)sender {
    if ( [self exportVCisPrevious] ) {
        [self backButtonPressed:sender];
    } else {
        if ( self.contractor.dataexport ) {
            [Common showDataExportItem:self.contractor.dataexport ];
        }
    }
    
}

-(DataExport*)dataexport {

    return self.contractor.dataexport;
}

-(void)fieldChanged:(id)field {
    if ( di_shortcut.readonly == NO ) {
        
        self.contractor.shortcut = di_shortcut.data;
        self.contractor.nip = di_NIP.data;
        
        self.contractor.name = di_name.data;
        self.contractor.country = di_addr_country.data;
        self.contractor.region = di_addr_region.data;
        self.contractor.postcode = di_addr_postcode.data;
        self.contractor.city = di_addr_city.data;
        self.contractor.street = di_addr_street.data;
        self.contractor.houseno = di_addr_houseno.data;
        self.contractor.tel1 = di_single_phone.data;
        self.contractor.email1 = di_single_email.data;
        self.contractor.www1 = di_single_www.data;
        
        [Common.DB save];
    };
}

-(void)onDataView {
    
    if ( btns ) {
        [self.form RemoveUIPart:btns];
        btns = nil;
    }
    
    if ( btnDel ) {
        [self.form RemoveUIPart:btnDel];
        btnDel = nil;
    }
    
    if ( btnExport ) {
        [self.form RemoveUIPart:btnExport];
        btnExport = nil;
    }

    if ( self.contractor )  {
        
        if ( self.contractor.dataexport ) {
            
            [di_addr_country setDictionaryOfType:DICTTYPE_CONTRACTOR_COUNTRY forContractor:nil];
            [ACRemoteOperation dictinaryOfType:DICTTYPE_CONTRACTOR_COUNTRY forContractor:@""];
            
            [di_addr_region setDictionaryOfType:DICTTYPE_CONTRACTOR_REGION forContractor:nil];
            [ACRemoteOperation dictinaryOfType:DICTTYPE_CONTRACTOR_REGION forContractor:@""];
            
            di_shortcut.hidden = YES;
            di_address.hidden = YES;
            di_phone.hidden = YES;
            di_email.hidden = YES;
            di_www.hidden = YES;
            di_limit.hidden = YES;
            di_limit_credit.hidden = YES;
           
            di_name.data = self.contractor.name;
            di_addr_country.data = self.contractor.country;
            di_addr_region.data = self.contractor.region;
            di_addr_postcode.data = self.contractor.postcode;
            di_addr_city.data = self.contractor.city;
            di_addr_street.data = self.contractor.street;
            di_addr_houseno.data = self.contractor.houseno;
            di_single_phone.data = self.contractor.tel1;
            di_single_email.data = self.contractor.email1;
            di_single_www.data = self.contractor.www1;
            di_state.hidden = NO;
            
            di_name.hidden = NO;
            di_addr_country.hidden = NO;
            di_addr_region.hidden = NO;
            di_addr_postcode.hidden = NO;
            di_addr_city.hidden = NO;
            di_addr_street.hidden = NO;
            di_addr_houseno.hidden = NO;
            di_single_phone.hidden =  NO;
            di_single_email.hidden = NO;
            di_single_www.hidden = NO;
            di_state.hidden = NO;
            
            di_shortcut.readonly = ![self.contractor.dataexport.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_EDITING]];
            di_NIP.readonly = di_shortcut.readonly;
            di_name.readonly = di_shortcut.readonly;
            di_addr_country.readonly = di_shortcut.readonly;
            di_addr_region.readonly = di_shortcut.readonly;
            di_addr_postcode.readonly = di_shortcut.readonly;
            di_addr_city.readonly = di_shortcut.readonly;
            di_addr_street.readonly = di_shortcut.readonly;
            di_addr_houseno.readonly = di_shortcut.readonly;
            di_single_phone.readonly = di_shortcut.readonly;
            di_single_www.readonly = di_shortcut.readonly;
            di_single_email.readonly = di_shortcut.readonly;
            
            di_state.actInidicator = [Common exportInProgress:self.contractor.dataexport];
            
            di_state.data = [ACERPCCommon statusStringWithDataExport:self.contractor.dataexport];
    
            
            if ( [self.contractor.dataexport.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_ERROR]] ) {
                [di_state addErrorButtonWithTarget:self touchAction:@selector(showDataExportDetails:)];
            } else if ( [self.contractor.dataexport.status isEqualToNumber:[NSNumber numberWithInt:QSTATUS_WARNING]] ) {
                [di_state addWarningButtonWithTarget:self touchAction:@selector(showDataExportDetails:)];
            }
            
            self.refreshPanelVisible = NO;
            self.form.Title = NSLocalizedString(@"Nowy kontrahent", nil);
            
            di_name.data = self.contractor.name;
            
            if ( self.contractor.dataexport ) {
                
                if ( btnExport == nil && !di_shortcut.readonly ) {
                    btnExport = [[ACUIExportBtn alloc] initWithNamedNib:@"ACUIExportBtn" form:self.form];
                    btnExport.topMargin = 20;
                    [btnExport.btnSend addTarget:self action:@selector(sendTouch:) forControlEvents:UIControlEventTouchDown];
                    [self.form AddUIPart:btnExport];
                }
                
                
                if ( btnDel == nil  && ![Common exportInProgress:self.contractor.dataexport] ) {

                        btnDel =  [ACUIDeleteBtn btnWithForm:self.form];
                        btnDel.topMargin = 20;
                        btnDel.btnDel.enabled = YES;
                        [btnDel addTargetForDeleteEvent:self action:@selector(doDelete:)];
                        [self.form AddUIPart:btnDel];
                }
                
            }

            
        } else {
            
            self.refreshPanelVisible = YES;
            self.form.Title = self.contractor.name;
            
            di_shortcut.hidden = NO;
            di_address.hidden = NO;
            di_phone.hidden = NO;
            di_email.hidden = NO;
            di_www.hidden = NO;
            di_limit.hidden = NO;
            di_limit_credit.hidden = NO;
            
            di_name.hidden = YES;
            di_addr_country.hidden = YES;
            di_addr_region.hidden = YES;
            di_addr_postcode.hidden = YES;
            di_addr_city.hidden = YES;
            di_addr_street.hidden = YES;
            di_addr_houseno.hidden = YES;
            di_single_phone.hidden = YES;
            di_single_email.hidden = YES;
            di_single_www.hidden = YES;
            di_state.hidden = YES;
            
            di_shortcut.readonly = YES;
            di_NIP.readonly = YES;
            
            [di_address setData:[[NSString stringWithFormat:@"%@ %@", self.contractor.street ? self.contractor.street : @"", self.contractor.houseno ? self.contractor.houseno : @""] trim] Level:0];
            
            [di_address setData:[[NSString stringWithFormat:@"%@ %@", self.contractor.postcode ? self.contractor.postcode : @"", self.contractor.city ? self.contractor.city : @""] trim] Level:1];
            
            [di_address setData:self.contractor.country Level:2];
            
            [self setDetailtButton:di_address touchAction:@selector(addressTouch:) ImageName:@"map.png"];
            
            
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
            
            if ( self.contractor.limit == nil
                 || [self.contractor.limit doubleValue] == 0 )
               di_limit_credit.data = @"";
            else
                [di_limit_credit setMoneyValue:[self.contractor.limit doubleValue]];
            
            btns = [[ACUIContractorButtons alloc] initWithNamedNib:@"ACUIContractorButtons" form:self.form];
            btns.topMargin = 20;
            [btns.btnInvoices addTarget:self action:@selector(invoicesTouch:) forControlEvents:UIControlEventTouchDown];
            [btns.btnPayments addTarget:self action:@selector(paymentsTouch:) forControlEvents:UIControlEventTouchDown];
            [btns.btnOrders addTarget:self action:@selector(ordersTouch:) forControlEvents:UIControlEventTouchDown];
            [self.form AddUIPart:btns];
            
            [self showFavBtn];
        }
        
        di_shortcut.data = self.contractor.shortcut;
        di_locked.hidden = ![self.contractor.trnlocked boolValue];
        di_NIP.data = self.contractor.nip;

        
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

- (IBAction)doDelete:(id)sender {
    if ( btnDel ) {
        [Common.DB removeContractor:self.contractor];
        [self backButtonPressed:sender];
    }
}

- (IBAction)sendTouch:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Czy na pewno chcesz przesłać dane tego Kontrahenta ?", nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Tak", nil)  otherButtonTitles:NSLocalizedString(@"Nie", nil),nil];
    [alertView show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        
        btnExport.btnSend.enabled = NO;
        btnExport.btnSend.hidden = YES;
        [Common.DB updateDataExport:self.contractor.dataexport withStatus:QSTATUS_WAITING];
        [self onRecordDetailData:nil];
    }
}


@end
