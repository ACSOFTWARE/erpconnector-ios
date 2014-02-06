/*
 FavoritesVC.m
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

#import "FavoritesVC.h"
#import "ERPCCommon.h"
#import "Favorite.h"
#import "Contractor.h"
#import "Invoice.h"
#import "FavTableViewCell.h"

@interface ACFavoritesVC ()

@end

@implementation ACFavoritesVC {
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

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setTableCell:nil];
    [super viewDidUnload];
}

#pragma mark Table Support

-(NSFetchedResultsController*)frc {
    
    if ( !_frc ) {
        _frc = [Common.DB fetchedFavorites];
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
    
    ACFavTableViewCell *cell = (ACFavTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavTableViewCell"];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FavTableViewCell" owner:self options:nil];
        cell = self.tableCell;
		self.tableCell = nil;
    }
    
    Favorite *f = (Favorite *)[self.frc objectAtIndexPath:indexPath];
    
    if ( f.contractor ) {
        cell.lType.text = NSLocalizedString(@"Kontrahent", nil);
        cell.lCaption.text = f.contractor.name;
    } else if ( f.invoice ) {
        cell.lType.text = NSLocalizedString(@"Faktura VAT", nil);;
        cell.lCaption.text = f.invoice.number;
    } else {
        cell.lType.text = @"";
        cell.lCaption.text = @"";
    }
    
    cell.f = f;
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
@end
