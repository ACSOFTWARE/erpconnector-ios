/*
 PaymentListVC.h
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
@class ACPaymentTableViewCell;
@interface ACPaymentListVC : UIViewController

- (void)onGetListDoneDone:(NSNotification *)notif;
- (void)loadList:(Contractor*)c;

- (IBAction)refreshTouch:(id)sender;

@property (strong, nonatomic) IBOutlet ACPaymentTableViewCell *tableCell;
@property (weak, nonatomic) IBOutlet UILabel *lInfo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshInd;
@property (weak, nonatomic) IBOutlet UIButton *btnRefresh;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lSumTotal;
@property (weak, nonatomic) IBOutlet UILabel *lSumTotalBefore;
@property (weak, nonatomic) IBOutlet UILabel *lSumTotalAfter;

@end
