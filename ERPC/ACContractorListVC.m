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

#import "ACContractorListVC.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "MFSideMenu.h"
#import "RemoteAction.h"

@interface ACContractorListVC ()

@end

@implementation ACContractorListVC {
    id last_record;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setBackgroundImageWithName:@"search_bg1.png"];
        [self initTableWithNamedNib:@"ACContractorTableViewCell"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addAddButtonWithSelector:@selector(addTouch:)];
};

-(NSFetchedResultsController*)list_frc {
    
    return [Common.DB fetchedContractorsWithText:[NSString stringWithFormat:@"*%@*", self.searchText]];
}

-(void)doRemoteSearchWithText:(NSString*)text {
    
    if ( self.requiredLen ) {
        [ACRemoteOperation customerSearch:self.searchText mtu:3];
    }
    
}

-(void)doOpenRecord:(id)record {
    
    last_record = record;
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Anuluj", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dane kontrahenta", nil), NSLocalizedString(@"Utwórz zamówienie", nil), nil];

    as.actionSheetStyle = UIActionSheetStyleAutomatic;
    as.backgroundColor = [UIColor whiteColor];
    [as showInView:self.view];

}

-(void)detailSelected:(int)idx record:(id)record {
   [Common showContractorVC:record];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        [Common showContractorVC:last_record];
    } else if ( buttonIndex == 1 ) {
        [Common newOrderForCustomer:last_record];
    }
}

- (void)addTouch:(id)sender {
    
    if ( Common.HelloData.cap & SERVERCAP_ADDCONTRACTOR ) {
        
        [Common newContractor];
    
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Ten serwer nie pozwala na dodawanie kontrahentów. Skontaktuj się z Administratorem serwera.", nil) delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    

}



@end
