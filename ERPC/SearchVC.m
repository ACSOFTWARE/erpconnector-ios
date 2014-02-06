/*
 ACSearchVC.m
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

#import "SearchVC.h"
#import "BackgroundOperations.h"
#import "SearchTableViewCell.h"
#import "ERPCCommon.h"
#import "Contractor.h"
#import "ContractorVC.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_SEARCH_TEXT_LEN   3

@interface ACSearchVC ()

@end

@implementation ACSearchVC {
    UIView *_aiView;
    UIActivityIndicatorView *_ai;
    UIImageView *_searchimg;
    NSTimer *_searchTimer;
    NSFetchedResultsController *_frc;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _aiView = nil;
        _ai = nil;
        _frc = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Common.navigationController.navigationBar.topItem.titleView = [[ UIImageView  alloc ] initWithImage: [UIImage  imageNamed : @"nav_logo.png" ]];
    
    _searchTimer = nil;
    
    _aiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    
    _ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_aiView addSubview:_ai];
    _aiView.hidden = YES;
    _ai.frame = CGRectMake(3, 0, 20, 20);

    _searchimg = [[ UIImageView  alloc ] initWithImage: [UIImage  imageNamed : @"search_black.png" ]];
    
    [self.searchField setLeftViewMode: UITextFieldViewModeAlways];
    
    self.searchField.layer.cornerRadius = 8;
    //self.searchField.borderStyle = UITextBorderStyleRoundedRect;//To change borders to rounded
    self.searchField.layer.borderWidth = 1.0f; //To hide the square corners
    self.searchField.layer.borderColor = [[UIColor grayColor] CGColor];
   
    self.searchField.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Min %i znaki", nil), MIN_SEARCH_TEXT_LEN];
    [self showConnectionError:NO];
    [self showActInd:NO];
    

}

- (void)viewDidUnload {
    [self setSearchField:nil];
    [self setLabelConnectionError:nil];
    [self setTableCell:nil];
    [self setTableView:nil];
    [self setSearchView:nil];
    [self setBgImage:nil];
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)tableViewTouched:(id)sender {
           [self.view endEditing:YES];
}


- (void)showActInd:(BOOL)show {
    
    if ( show ) {
        _aiView.hidden = NO;
        [self.searchField setLeftView:_aiView];
        [_ai startAnimating];
    } else {
        _aiView.hidden = YES;
        [_ai stopAnimating];
        [self.searchField setLeftView:_searchimg];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showConnectionError:(BOOL)show {
    
    CGRect f;
    
    f = self.searchField.frame;
    f.origin.y = 5;
    self.searchField.frame = f;
    
    f = self.searchView.frame;
    f.size.height = self.searchField.frame.size.height+10;
    self.searchView.frame = f;
    
    if ( show ) {
        f = self.labelConnectionError.frame;
        f.origin.y = self.searchField.frame.origin.y + self.searchField.frame.size.height;
        self.labelConnectionError.frame = f;
        f = self.searchView.frame;
        f.size.height = self.labelConnectionError.frame.origin.y + self.labelConnectionError.frame.size.height + 5;
        self.searchView.frame = f;
        self.labelConnectionError.hidden = NO;
    } else {
        self.labelConnectionError.hidden = YES;
    }
    
    f = self.tableView.frame;
    f.origin.y = self.searchView.frame.origin.y + self.searchView.frame.size.height;
    f.size.height = self.view.frame.size.height - f.origin.y;
    self.tableView.frame = f;
}

#pragma mark Table Support

-(NSFetchedResultsController*)frc {
    
    if ( !_frc ) {
        if ( self.searchField.text.length >= MIN_SEARCH_TEXT_LEN ) {
            _frc = [Common.DB fetchedContractorsWithText:self.searchField.text];
            NSError *error = nil;
            [_frc performFetch:&error];
            if ( error ) {
                NSLog(@"%@", error.description);
            }
        };
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
    
    ACSearchTableViewCell *cell = (ACSearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"SearchTableViewCell" owner:self options:nil];
        cell = self.tableCell;
		self.tableCell = nil;
    }
    
    Contractor *c = (Contractor *)[self.frc objectAtIndexPath:indexPath];
    cell.labelName.text = c.name;
    NSString *addr = @"";
    if ( c.street.length > 0) {
        addr = [[NSString stringWithFormat:@"ul. %@ %@", c.street, c.houseno] trim];
    }

    if ( c.postcode.length > 0 ) {
        if ( addr.length > 0 ) {
            addr = [NSString stringWithFormat:@"%@, %@", addr, c.postcode];
        } else {
            addr = c.postcode;
        }
    }
    
    addr = [[NSString stringWithFormat:@"%@ %@ %@", addr, c.city, c.country] trim];
    
    cell.labelAddress.text = addr;
    cell.c = c;
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        if ( self.frc ) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
            return [sectionInfo name];
        };
    return nil;
}
/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];


    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    [layer setBounds:headerView.bounds];
    [layer setColors:[NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil]];

    [headerView.layer insertSublayer:layer atIndex:0];
    
    return headerView;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
};

#pragma mark Search

- (void)remoteSearch:(id)ui {
    if ( self.searchField.text.length >= MIN_SEARCH_TEXT_LEN )  {
        
        [Common.OpQueue cancelAllOperations];
        [ACRemoteOperation customerSearch:self.searchField.text mtu:3];
    }
}

- (IBAction)searchEditingChanged:(id)sender {

    if ( self.searchField.text.length >= MIN_SEARCH_TEXT_LEN ) {
        
        if ( self.tableView.hidden) {
            self.tableView.hidden = NO;
            self.bgImage.hidden = YES;
        }
        
        if ( _searchTimer ) {
            [_searchTimer invalidate];
        }
        
        [self showActInd:YES];
        [self showConnectionError:NO];
        _searchTimer = [NSTimer scheduledTimerWithTimeInterval:_searchTimer ? 1.5 : 0.1 target:self selector:@selector(remoteSearch:) userInfo:nil repeats:NO];
    } else {
        
        [Common.OpQueue cancelAllOperations];
        
        [self showActInd:NO];
        self.tableView.hidden = YES;
        self.bgImage.hidden = NO;
    }
    
    _frc = nil;
    [self.tableView reloadData];
    
}

#pragma mark Notifications

- (void)onConnectionError:(NSNotification *)notif {
    [self showActInd:NO];
    [self showConnectionError:YES];
}

- (void)onRemoteSearchDone:(NSNotification *)notif {
    [self showActInd:NO];
}

- (void)onCustomerData:(NSNotification *)notif {
    _frc = nil;
    [self.tableView reloadData];
}


@end
