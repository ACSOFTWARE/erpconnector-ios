/*
 InvoiceListVC.m
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

#import "InvoiceListVC.h"
#import "InvoiceTableViewCell.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "Contractor.h"
#import "Invoice.h"
#import "MFSideMenu.h"

@interface ACInvoiceListVC ()

@end

@implementation ACInvoiceListVC {
    NSFetchedResultsController *_frc;
    NSString *customerShortcut;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _frc = nil;
        customerShortcut = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshInd setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self setupSideMenuBarButtonItem];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}
- (void)showDate:(NSDate*)date {
    
    if ( date ) {
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        self.lInfo.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Dane z dnia:", nil), [dateFormatter stringFromDate:date]];
        
        self.lInfo.hidden = NO;
    } else {
        self.lInfo.hidden = YES;
    }

}

- (void)loadList:(Contractor*)c {
    
    self.btnRefresh.hidden = NO;
    self.refreshInd.hidden = YES;
    
    if ( !c ) return;
    
    if ( !customerShortcut
        || ![customerShortcut isEqualToString:c.shortcut] ) {
        customerShortcut = c.shortcut;
        _frc = nil;
    }
    
    _frc = [Common.DB fetchedInvoicesForContractor:c];

    [Common.DB performFetch:_frc];
    [self.tableView reloadData];
    
    [self showDate:c.invoices_last_resp_date];
    [self refreshTouch:self.btnRefresh];
    

}

- (IBAction)refreshTouch:(id)sender {
    if ( customerShortcut ) {
        
        self.btnRefresh.hidden = YES;
        self.refreshInd.hidden = NO;
        
        Contractor *c = [Common.DB fetchContractorByShortcut:customerShortcut];
        NSDate *date = c && c.invoices_last_resp_date ? c.invoices_last_resp_date : nil;
        c = nil;
        
        [Common.OpQueue cancelAllOperations];
        [ACRemoteOperation invoicesForCustomerWithShortcut:customerShortcut mtu:3 fromDate:date];
    }
}

#pragma mark Table Support

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _frc ? [[_frc sections] count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if ( _frc ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_frc sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ACInvoiceTableViewCell *cell = (ACInvoiceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InvoiceTableViewCell"];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"InvoiceTableViewCell" owner:self options:nil];
        cell = self.tableCell;
		self.tableCell = nil;
    }
    
    cell.lNumber.text = @"";
    cell.lDate.text = @"";
    cell.lNet.text = @"";
    cell.lGross.text = @"";
    
    if ( _frc ) {
        Invoice *i = (Invoice *)[_frc objectAtIndexPath:indexPath];
        if ( i ) {
            cell.shortcut = i.shortcut;
            cell.lNumber.text = i.number;
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            cell.lDate.text = [dateFormatter stringFromDate:i.dateofissue];
            cell.lNet.text = [NSString stringWithFormat:@"%.2f zł", [i.totalnet doubleValue]];
            cell.lGross.text = [NSString stringWithFormat:@"%.2f zł", [i.totalgross doubleValue]];
        }
    }


    return cell;

}


- (void)onConnectionError:(NSNotification *)notif {
    self.btnRefresh.hidden = NO;
    self.refreshInd.hidden = YES;
}

- (void)onGetListDoneDone:(NSNotification *)notif {
    self.btnRefresh.hidden = NO;
    self.refreshInd.hidden = YES;
    Contractor *c = [Common.DB fetchContractorByShortcut:customerShortcut];
    if ( c ) {
        c.invoices_last_resp_date = [NSDate date];
        [Common.DB updateContractor:c];
        c = nil;
    }
    [self showDate:[NSDate date]];
}

- (void)onInvoiceData:(NSNotification *)notif {
    [Common.DB performFetch:_frc];
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setTableCell:nil];
    [self setTableView:nil];
    [self setBtnRefresh:nil];
    [self setRefreshInd:nil];
    [self setLInfo:nil];
    [super viewDidUnload];
}
@end
