/*
 HistoryVC.m
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

#import "HistoryVC.h"
#import "ERPCCommon.h"
#import "Contractor.h"
#import "Invoice.h"
#import "Recent.h"
#import "HistoryTableViewCell.h"

@interface ACHistoryVC ()

@end

@implementation ACHistoryVC {
        NSFetchedResultsController *_frc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _frc = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark Table Support

-(NSFetchedResultsController*)frc {
    
    if ( !_frc ) {
        _frc = [Common.DB fetchedHistory];
        NSError *error = nil;
        [_frc performFetch:&error];
        if ( error ) {
            NSLog(@"%@", error.description);
        }
    };
    
    return _frc;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.frc ? [[self.frc sections] count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if ( self.frc ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ACHistoryTableViewCell *cell = (ACHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HistoryTableViewCell"];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil];
        cell = self.tableCell;
		self.tableCell = nil;
    }
    
    Recent *r = (Recent *)[self.frc objectAtIndexPath:indexPath];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    cell.lDate.text = [dateFormatter stringFromDate:r.last_access];
    
    if ( r.contractor ) {
        cell.lType.text = NSLocalizedString(@"Kontrahent", nil);
        cell.lCaption.text = r.contractor.name;
    } else if ( r.invoice ) {
        cell.lType.text = NSLocalizedString(@"Faktura VAT", nil);
        cell.lCaption.text = r.invoice.number;
    } else {
        cell.lType.text = @"";
        cell.lCaption.text = @"";
    }

    cell.r = r;
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( self.frc ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
        return [sectionInfo name];
    };
    return nil;
}

-(void) refresh {
    if ( _frc ) {
        [Common.DB performFetch:_frc];
        [self.tableView reloadData];
    }
}

- (void)viewDidUnload {
    [self setTableCell:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
