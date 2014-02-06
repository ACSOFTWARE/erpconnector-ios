/*
 ContractorVC.m
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

#import "ContractorVC.h"
#import "Contractor.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "MFSideMenu.h"

@interface ACContractorVC () {
}

@end

@implementation ACContractorVC

@synthesize btnFav = _btnFav;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    _btnFav = [self addFavButtonWithSelector:@selector(favTouch:)];
    
    [self.refreshInd setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLShortcut:nil];
    [self setLName:nil];
    [self setLStreet:nil];
    [self setLCity:nil];
    [self setLCountry:nil];
    [self setLNIP:nil];
    [self setBtnInvoices:nil];
    [self setBtnPayments:nil];
    [self setBtnRefresh:nil];
    [self setLInfo:nil];
    [self setSv:nil];
    [self setRefreshInd:nil];
    [self setVShortcut:nil];
    [self setVAddress:nil];
    [self setVNip:nil];
    [self setVPhone:nil];
    [self setVEmail:nil];
    [self setVWWW:nil];
    [self setBtnPhone1:nil];
    [self setBtnPhone2:nil];
    [self setBtnPhone3:nil];
    [self setBtnEmail1:nil];
    [self setBtnEmail2:nil];
    [self setBtnEmail3:nil];
    [self setBtnWWW1:nil];
    [self setBtnWWW2:nil];
    [self setBtnWWW3:nil];
    [super viewDidUnload];

}

- (NSUInteger)supportedInterfaceOrientations {
    return UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

-(void)setContact:(NSString *)txt c1:(UIButton *)C1 c2:(UIButton *)C2 c3:(UIButton *)C3 {
    if ( !txt || txt.length == 0) return;

    
    UIButton *c = nil;
    if ( !C1 || [C1 titleForState:UIControlStateNormal].length == 0 ) {
        c = C1;
    } else if ( !C2 || [C2 titleForState:UIControlStateNormal].length == 0  ) {
        c = C2;
    } else if ( !C3 || [C3 titleForState:UIControlStateNormal].length == 0  ) {
        c = C3;
    };
    
    if ( c )
        [c setTitle:[NSString stringWithString:txt] forState:UIControlStateNormal];
}

- (int)setCaptionLabel:(UILabel*)label dataLabel:(UILabel*)data pos:(int)p {
    CGRect f = label.frame;
    f.origin.y = p;
    f.origin.x = 8;
    label.frame = f;
    
    p+=6;
    
    f = data.frame;
    f.origin.x = 8;
    f.origin.y = p;
    data.frame = f;
    
    if ( !data.text || data.text.length == 0  ) {
        data.text = @"-";
    }
    
    return p+data.frame.size.height+5;
}

- (int)setCaptionView:(UIView*)cview dataLabel1:(UIView*)data1 dataLabel2:(UIView*)data2 dataLabel3:(UIView*)data3 pos:(int)p {
    
    CGRect f;
    float y = 0;
    float h = 0;
    
    
    if ( data1 ) {
        NSString *str = [data1 isKindOfClass:[UIButton class]] ? [(UIButton*)data1 titleForState:UIControlStateNormal] : ((UILabel*)data1).text;
        if ( str.length > 0 ) {
            data1.hidden = NO;
            f = data1.frame;
            f.origin.y = p;
            y = p;
            h = f.size.height;
            f.origin.x = 115;
            p+=f.size.height+2;
            data1.frame = f;
        } else {
            data1.hidden = YES;
        }
    }


    if ( data2 ) {
        NSString *str = [data2 isKindOfClass:[UIButton class]] ? [(UIButton*)data2 titleForState:UIControlStateNormal] : ((UILabel*)data2).text;
        
        if ( str.length > 0 ) {
            data2.hidden = NO;
            f = data2.frame;
            f.origin.y = p;
            if ( y == 0 ) y = p;
            h = f.origin.y - p + f.size.height;
            f.origin.x = 115;
            p+=f.size.height+2;
            data2.frame = f;
        } else {
            data2.hidden = YES;
        }
    }

    if ( data3 ) {
        NSString *str = [data3 isKindOfClass:[UIButton class]] ? [(UIButton*)data3 titleForState:UIControlStateNormal] : ((UILabel*)data3).text;
        
        if ( str.length > 0 ) {
            data3.hidden = NO;
            f = data3.frame;
            f.origin.y = p;
            if ( y == 0 ) y = p;
            h = f.origin.y - y + f.size.height;
            f.origin.x = 115;
            p+=f.size.height+2;
            data3.frame = f;
        } else {
            data3.hidden = YES;
        }
    }

    
    if ( data1
        && data1.hidden
        && ( !data2 || data2.hidden )
        && ( !data3 || data3.hidden ) ) {
        
        f = data1.frame;
        f.origin.y = p;
        y = p;
        h = f.size.height;
        f.origin.x = 115;
        p+=f.size.height+2;
        data1.frame = f;
        if ( [data3 isKindOfClass:[UIButton class]] ) {
            [(UIButton*)data1 setTitle:@"-" forState:UIControlStateNormal];
        } else {
            ((UILabel*)data3).text = @"";
        }

        data1.hidden = NO;
    }

    f = cview.frame;
    f.origin.y = y;
    f.origin.x = 9;
    f.size.height = h;
    cview.frame = f;
    
    return p+8;
};

-(void)showContractorData:(Contractor*)cdata {
    
    self.lShortcut.text = @"";
    self.lName.text = @"";
    self.lStreet.text = @"";
    self.lCity.text = @"";
    self.lCountry.text = @"";
    self.lNIP.text = @"";
    [self.btnPhone1 setTitle:@"" forState:UIControlStateNormal];
    [self.btnPhone2 setTitle:@"" forState:UIControlStateNormal];
    [self.btnPhone3 setTitle:@"" forState:UIControlStateNormal];
    [self.btnEmail1 setTitle:@"" forState:UIControlStateNormal];
    [self.btnEmail2 setTitle:@"" forState:UIControlStateNormal];
    [self.btnEmail3 setTitle:@"" forState:UIControlStateNormal];
    [self.btnWWW1 setTitle:@"" forState:UIControlStateNormal];
    [self.btnWWW2 setTitle:@"" forState:UIControlStateNormal];
    [self.btnWWW3 setTitle:@"" forState:UIControlStateNormal];
    
    self.lInfo.text = @"";
    
    self.btnRefresh.hidden = NO;
    self.refreshInd.hidden = YES;
    
    if ( cdata ) {
        
        [Common.DB updateRecentListWithContractor:cdata orInvoice:nil];
        
        if ( cdata.shortcut )
            self.lShortcut.text = [NSString stringWithString:cdata.shortcut];
        
        if ( cdata.name )
            self.lName.text = [NSString stringWithString:cdata.name];
        
        self.lStreet.text = [[NSString stringWithFormat:@"%@ %@", cdata.street ? cdata.street : @"", cdata.houseno ? cdata.houseno : @""] trim];
        self.lCity.text = [[NSString stringWithFormat:@"%@ %@", cdata.postcode ? cdata.postcode : @"", cdata.city ? cdata.city : @""] trim];
        
        if ( cdata.country )
            self.lCountry.text = [NSString stringWithString:cdata.country];
        
        if ( cdata.nip )
            self.lNIP.text = [NSString stringWithString:cdata.nip];
        
        [self setContact:cdata.tel1 c1:self.btnPhone1 c2:self.btnPhone2 c3:self.btnPhone3];
        [self setContact:cdata.tel2 c1:self.btnPhone1 c2:self.btnPhone2 c3:self.btnPhone3];
        [self setContact:cdata.tel3 c1:self.btnPhone1 c2:self.btnPhone2 c3:self.btnPhone3];
        
        [self setContact:cdata.email1 c1:self.btnEmail1 c2:self.btnEmail2 c3:self.btnEmail3];
        [self setContact:cdata.email2 c1:self.btnEmail1 c2:self.btnEmail2 c3:self.btnEmail3];
        [self setContact:cdata.email3 c1:self.btnEmail1 c2:self.btnEmail2 c3:self.btnEmail3];
        
        [self setContact:cdata.www1 c1:self.btnWWW1 c2:self.btnWWW2 c3:self.btnWWW3];
        [self setContact:cdata.www2 c1:self.btnWWW1 c2:self.btnWWW2 c3:self.btnWWW3];
        [self setContact:cdata.www3 c1:self.btnWWW1 c2:self.btnWWW2 c3:self.btnWWW3];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        self.lInfo.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Dane z dnia:", nil), [dateFormatter stringFromDate:cdata.updated]];
        
        self.btnFav.selected = [Common.DB fetchFavoriteItemForContractor:cdata orInvoice:nil] != nil;
        
    }
    
    float p = [self setCaptionView:self.vAddress dataLabel1:self.lStreet dataLabel2:self.lCity dataLabel3:self.lCountry pos:90];
    p = [self setCaptionView:self.vNip dataLabel1:self.lNIP dataLabel2:nil dataLabel3:nil pos:p];
    p = [self setCaptionView:self.vPhone dataLabel1:self.btnPhone1 dataLabel2:self.btnPhone2 dataLabel3:self.btnPhone3 pos:p];
    p = [self setCaptionView:self.vEmail dataLabel1:self.btnEmail1 dataLabel2:self.btnEmail2 dataLabel3:self.btnEmail3 pos:p];
    [self setCaptionView:self.vWWW dataLabel1:self.btnWWW1 dataLabel2:self.btnWWW2 dataLabel3:self.btnWWW3 pos:p];
    
    CGRect f = self.btnInvoices.frame;
    f.origin.y = self.view.frame.size.height - 120;
    if ( f.origin.y < self.vWWW.frame.origin.y+self.vWWW.frame.size.height+10 ) {
        f.origin.y = self.vWWW.frame.origin.y+self.vWWW.frame.size.height+10;
    }
    self.btnInvoices.frame = f;
    f = self.btnPayments.frame;
    f.origin.y =  self.btnInvoices.frame.origin.y;
    self.btnPayments.frame = f;
    
    
    self.sv.contentSize = CGSizeMake(self.view.frame.size.width, self.btnRefresh.frame.origin.y + self.btnRefresh.frame.size.height + 10);
}

- (IBAction)refreshTouch:(id)sender {
    self.btnRefresh.hidden = YES;
    self.refreshInd.hidden = NO;
    
    
    [Common.OpQueue cancelAllOperations];
    [ACRemoteOperation customerSearchOnlyByShortcut:self.lShortcut.text];
}

- (IBAction)invoicesTouch:(id)sender {
    
    [Common showContractorInvoiceListVC:[Common.DB fetchContractorByShortcut:self.lShortcut.text]];
}

- (IBAction)paymentsTouch:(id)sender {
        [Common showContractorPaymentListVC:[Common.DB fetchContractorByShortcut:self.lShortcut.text]];
}

- (IBAction)favTouch:(id)sender {
    
    if ( ![self.lShortcut.text isEqualToString:@""] ) {
        BOOL FAV = self.btnFav.selected;
        
        Contractor *c = [Common.DB fetchContractorByShortcut:self.lShortcut.text];
        if ( c ) {
            if ( FAV ) {
                [Common.DB removeFavoriteItem:c orInvoice:nil];
                FAV = NO;
            } else {
                [Common.DB addToFavorites:c orInvoice:nil];
                FAV = YES;
            }
        }
        
        self.btnFav.selected = FAV;
    }

}

- (void)onConnectionError:(NSNotification *)notif {
    self.btnRefresh.hidden = NO;
    self.refreshInd.hidden = YES;
}

- (void)onRemoteSearchDone:(NSNotification *)notif {
    self.btnRefresh.hidden = NO;
    self.refreshInd.hidden = YES;
}

- (void)onCustomerData:(NSNotification *)notif {
    Contractor *c = [Common.DB fetchContractorByShortcut:self.lShortcut.text];
    if ( c ) {
        [[Common.DB managedObjectContext] refreshObject:c mergeChanges:YES];
        [self showContractorData:c];
    }

}

- (IBAction)wwwTouch:(id)sender {
    if ( [sender isKindOfClass:[UIButton class]] ) {
        NSString *str = [[(UIButton*)sender titleForState:UIControlStateNormal] trim];
        if ( str && str.length > 0 ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", str]]];
        }
    }
}

- (IBAction)emailTouch:(id)sender {
    if ( [sender isKindOfClass:[UIButton class]] ) {
        NSString *str = [[(UIButton*)sender titleForState:UIControlStateNormal] trim];
        if ( str && str.length > 0 ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", str]]];
        }
    }
}

- (IBAction)phoneTouch:(id)sender {
    if ( [sender isKindOfClass:[UIButton class]] ) {
        NSString *str = [(UIButton*)sender titleForState:UIControlStateNormal];
        if ( str && str.length > 0 ) {
            NSString *nr = @"";
            
            bool p = NO;
            char *cstr = malloc(str.length+1);
            [str getCString:cstr maxLength:str.length+1 encoding:NSStringEncodingConversionAllowLossy];
            
            for(int a=0;a<str.length;a++) {

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
            str = nil;
            
            if ( nr && nr.length > 0 ) {
                if ( !p && nr.length == 9 ) {
                    nr = [NSString stringWithFormat:@"+48%@",nr];
                    p = YES;
                }
                if ( p ) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", nr]]];
                }
            }
        }

    }
}
@end
