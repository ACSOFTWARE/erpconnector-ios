/*
 ACSearchVC.h
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

@class ACSearchTableViewCell;
@interface ACSearchVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)onConnectionError:(NSNotification *)notif;
- (void)onRemoteSearchDone:(NSNotification *)notif;
- (void)onCustomerData:(NSNotification *)notif;

@property (weak, nonatomic) IBOutlet UITextField *searchField;
- (IBAction)searchEditingChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelConnectionError;
@property (strong, nonatomic) IBOutlet ACSearchTableViewCell *tableCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
- (IBAction)tableViewTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@end
