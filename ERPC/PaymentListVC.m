/*
 PaymentListVC.m
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

#import "PaymentListVC.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "Contractor.h"
#import "PaymentTableViewCell.h"
#import "Payment.h"
#import "MFSideMenu.h"

@interface ACPaymentListVC ()

@end

@implementation ACPaymentListVC {
    NSString *customerShortcut;
    NSFetchedResultsController *_frc;
    NSDate *_now;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        customerShortcut = nil;
        _frc = nil;
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

- (void)viewDidUnload {
    [self setTableCell:nil];
    [self setLInfo:nil];
    [self setBtnRefresh:nil];
    [self setRefreshInd:nil];
    [self setTableView:nil];
    [self setLSumTotal:nil];
    [self setLSumTotalBefore:nil];
    [self setLSumTotalAfter:nil];
    [super viewDidUnload];
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

- (void)showSummary {
    
    self.lSumTotal.text = @"0.00 zł";
    self.lSumTotalBefore.text = @"0.00 zł";
    self.lSumTotalAfter.text = @"0.00 zł";
    
    if ( customerShortcut ) {
        Contractor *c = [Common.DB fetchContractorByShortcut:customerShortcut];
        if ( c )  {
            NSDictionary *sum = [Common.DB paymentSummaryForContractor:c];
            
            self.lSumTotal.text = [NSString stringWithFormat:@"%.2f zł", [sum doubleValueForKey:@"total"]];
            
            self.lSumTotalBefore.text = [NSString stringWithFormat:@"%.2f zł", [sum doubleValueForKey:@"before"]];
            
            double a = [sum doubleValueForKey:@"after"];
            self.lSumTotalAfter.textColor = a > 0 ? [UIColor colorWithHue:0.998 saturation:0.903 brightness:1.000 alpha:1.000] : [UIColor colorWithWhite:0.000 alpha:1.000];
            self.lSumTotalAfter.text = [NSString stringWithFormat:@"%.2f zł", a];
            
        }
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

    _frc = [Common.DB fetchedPaymentsForContractor:c];
    
    [self showSummary];
    [Common.DB paymentSummaryForContractor:c];
    [Common.DB performFetch:_frc];
    [self.tableView reloadData];
    
    [self showDate:c.payments_last_resp_date];
    [self refreshTouch:self.btnRefresh];
    
}

- (IBAction)refreshTouch:(id)sender {
    if ( customerShortcut ) {
        
        self.btnRefresh.hidden = YES;
        self.refreshInd.hidden = NO;
        
        [Common.OpQueue cancelAllOperations];
        [ACRemoteOperation outstandingPaymentsForCustomerWithShortcut:customerShortcut];
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
    
    ACPaymentTableViewCell *cell = (ACPaymentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PaymentTableViewCell"];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"PaymentTableViewCell" owner:self options:nil];
        cell = self.tableCell;
		self.tableCell = nil;
    }
    
    cell.lNumber.text = @"";
    cell.lDate.text = @"";
    cell.lDays.text = @"";
    cell.lRemain.text = @"";
    cell.lGross.text = @"";

    if ( _frc ) {
        Payment *p = (Payment *)[_frc objectAtIndexPath:indexPath];
        if ( p ) {
            cell.lNumber.text = p.number;
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            if ( !_now ) {
                _now = [NSDate date];
            }
            
            int t = [_now timeIntervalSinceDate:p.termdate]/86400;
            
            if ( [_now earlierDate:p.termdate] ) {
                t*=-1;
            }
            
            cell.lDays.text = [NSString stringWithFormat:@"%i %@", t, NSLocalizedString(@"dni", nil)];
            cell.lDays.textColor = t <= 0 ? [UIColor colorWithHue:0.998 saturation:0.903 brightness:1.000 alpha:1.000] : [UIColor colorWithHue:0.246 saturation:0.855 brightness:1.000 alpha:1.000];
            
            cell.lDate.text = [dateFormatter stringFromDate:p.dateofissue];
            cell.lRemain.text = [NSString stringWithFormat:@"%.2f zł", [p.remaining doubleValue]];
            cell.lGross.text = [NSString stringWithFormat:@"%.2f zł", [p.totalgross doubleValue]];
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
    _now = [NSDate date];
    
    [self showSummary];
    [Common.DB performFetch:_frc];
    [self.tableView reloadData];
    
    [self showDate:_now];
}
@end
