//
//  ACContractorListVC.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 15.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACContractorListVC.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "MFSideMenu.h"

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Ta funkcja nie jest obsługiwana przez serwer"
                                                   delegate:Common.window.rootViewController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}



@end
