/*
 ContractorVC.h
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

#import <UIKit/UIKit.h>

@class Contractor;
@interface ACContractorVC : UIViewController 

- (void)onConnectionError:(NSNotification *)notif;
- (void)onRemoteSearchDone:(NSNotification *)notif;
- (void)onCustomerData:(NSNotification *)notif;

-(void)showContractorData:(Contractor*)cdata;
- (IBAction)refreshTouch:(id)sender;
- (IBAction)invoicesTouch:(id)sender;
- (IBAction)paymentsTouch:(id)sender;
- (IBAction)favTouch:(id)sender;
@property UIButton *btnFav;
@property (weak, nonatomic) IBOutlet UILabel *lShortcut;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lStreet;
@property (weak, nonatomic) IBOutlet UILabel *lCity;
@property (weak, nonatomic) IBOutlet UILabel *lCountry;
@property (weak, nonatomic) IBOutlet UILabel *lNIP;
@property (weak, nonatomic) IBOutlet UIButton *btnInvoices;
@property (weak, nonatomic) IBOutlet UIButton *btnPayments;
@property (weak, nonatomic) IBOutlet UIButton *btnRefresh;
@property (weak, nonatomic) IBOutlet UILabel *lInfo;
@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshInd;
@property (weak, nonatomic) IBOutlet UIView *vShortcut;
@property (weak, nonatomic) IBOutlet UIView *vAddress;
@property (weak, nonatomic) IBOutlet UIView *vNip;
@property (weak, nonatomic) IBOutlet UIView *vPhone;
@property (weak, nonatomic) IBOutlet UIView *vEmail;
@property (weak, nonatomic) IBOutlet UIView *vWWW;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone1;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone2;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone3;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail1;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail2;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail3;
@property (weak, nonatomic) IBOutlet UIButton *btnWWW1;
@property (weak, nonatomic) IBOutlet UIButton *btnWWW2;
@property (weak, nonatomic) IBOutlet UIButton *btnWWW3;
- (IBAction)wwwTouch:(id)sender;
- (IBAction)emailTouch:(id)sender;
- (IBAction)phoneTouch:(id)sender;
@end
