//
//  ACUISearchVC.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIDataListVC.h"
#import "ACUIPart.h"
#import "ACUITableSearchPanel.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "ACUITableViewCell.h"
#import "MFSideMenu.h"

@implementation ACUIDataListVC {
     ACUITableView *_tv;
     NSFetchedResultsController *_frc;
    ACUITableSearchPanel *_search;
    NSTimer *_searchTimer;
    UIImageView *_bg;
    NSMutableArray *_selections;
    BOOL _selectionMode;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topPanel:(BOOL)topp
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectionMode = NO;
        _tv = nil;
        _frc = nil;
        _bg = nil;
        _search = nil;
        self.form.LRMargin = 1;
        _selections = [[NSMutableArray alloc] init];
        
        if ( topp ) {
            _search = [[ACUITableSearchPanel alloc] initWithNamedNib:@"ACUITableSearchPanel" form:self.form];
            _search.delegate = self;
            [self.form AddUIPart:_search];
        }
        
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil topPanel:YES];
};

-(void)initTableWithNamedNib:(NSString*)cellnib {
    [self initTableWithNamedNib:cellnib andHeaderNib:nil];
}

-(void)initTableWithNamedNib:(NSString*)cellnib andHeaderNib:(NSString*)headernib {
    _tv = [self.form CreateTableViewWithMargin:0 headerNibName:headernib cellNibName:cellnib];
    _tv.dataSource = self;
    _tv.delegate = self;
    [_tv maxHeight];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    if ( _search == nil ) {
        [self loadList];
    }
    
    if ( self.selectionMode ) {
        [_selections removeAllObjects];
        [self onItemSelected];
        [_tv reloadDataWithResize:NO];
    }

}

-(void)dismissKeyboard {
    [_search.searchField endEditing:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int)rowHeight {
    return _tv ? _tv.rowHeight : 0;
}

-(void)setRowHeight:(int)rowHeight {
    if ( _tv ) {
        _tv.rowHeight = rowHeight;
    }
}

-(NSFetchedResultsController*)frc {
    
    if ( !_frc
        && ( self.requiredLen || _search == nil ) ) {

        if ([self respondsToSelector:@selector(list_frc)]) {
            _frc = [(ACUIDataListVC <ACUIDataListItemsSource> *)self list_frc];
        }
        
        if ( _frc ) {
            NSError *error = nil;
            [_frc performFetch:&error];
            if ( error ) {
                NSLog(@"%@", error.description);
            }
        }
    };
    
    return _frc;
}

-(void)searchFieldChanged:(ACUITableSearchPanel*)search_panel withText:(NSString*)text{
    
    if ( search_panel.requiredLen ) {
        
        if (  _tv.hidden) {
            _tv.hidden = NO;
            _bg.hidden = YES;
        }
        
        if ( _searchTimer ) {
            [_searchTimer invalidate];
        }
        
        _searchTimer = [NSTimer scheduledTimerWithTimeInterval:_searchTimer ? 1.5 : 0.1 target:self selector:@selector(remoteSearch:) userInfo:nil repeats:NO];
        
    } else {
        
        [Common.OpQueue cancelAllOperations];
        _tv.hidden = YES;
        _bg.hidden = NO;
    }
    
    [self loadList];
}

-(void)loadList {
    _frc = nil;
    [_tv reloadDataWithResize:NO];
}

-(NSString*)searchText {
    return _search ? _search.text : @"";
}

-(BOOL)requiredLen {
    return _search ? _search.requiredLen : 0;
}

-(int)minLen {
    return _search ? _search.minLen : 0;
}

-(void)setMinLen:(int)minLen {
    if ( _search )
      _search.minLen = minLen;
}

- (void)remoteSearch:(id)ui {
    if ( self.requiredLen )  {
        
        [Common.OpQueue cancelAllOperations];
        
        if ([self respondsToSelector:@selector(doRemoteSearchWithText:)]) {
            [(ACUIDataListVC <ACUIDataListItemsSource> *)self doRemoteSearchWithText:self.searchText];
        }
    }
}

- (void)onConnectionError:(NSNotification *)notif {
    [super onConnectionError:notif];
    if ( _search )
      _search.activityIndicatorVisible = NO;
}

- (void)onRemoteSearchDone:(NSNotification *)notif {
    if ( _search )
      _search.activityIndicatorVisible = NO;
    [self loadList];
}


-(void)setBackgroundImageWithName:(NSString*)name {
    if ( _bg ) {
        [_bg removeFromSuperview];
        _bg = nil;
    }
    
    _bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    CGRect frame = _bg.frame;
    frame.origin.y = self.view.frame.size.height-Common.navigationController.toolbar.frame.size.height-Common.navigationController.navigationBar.frame.origin.y-frame.size.height;
    frame.origin.x = self.view.frame.size.width - frame.size.width;
    _bg.frame = frame;
    [self.view addSubview:_bg];
}

-(void)recordSelected:(id)record cellSelected:(ACUITableViewCell*)cell {
    
    if ( _search
        && _search.searchField
        && [_search.searchField isFirstResponder] ) {
        
        [_search.searchField endEditing:YES];
        
    } else {
        if ( self.selectionMode ) {
            
            cell.record_selected = !cell.record_selected;
            
            if ( cell.record_selected ) {
                [self addRecordToSelection:record];
            } else {
                [self removeRecordFromSelection:record];
            }
            
            [self onItemSelected];
            
            if ([self respondsToSelector:@selector(onItemSelected:item:)]) {
                [(ACUIDataListVC <ACUIDataListItemsSource> *)self onItemSelected:cell.record_selected item:record];
            }
        } else {
            
            if ([self respondsToSelector:@selector(doOpenRecord:)]) {
                [(ACUIDataListVC <ACUIDataListItemsSource> *)self doOpenRecord:record];
            }
        }
    }
        
    

    
}

-(BOOL)recordIsSelected:(id)record {
    return [self isSeleceted:record] != NSNotFound;
}

-(void)setSelectionMode:(BOOL)selectionMode {
    if ( _selectionMode == selectionMode ) return;
    
    _selectionMode = selectionMode;
    _tv.selectMode = _selectionMode;
    
    if ( _frc ) {
        _frc = nil;
        [_tv reloadDataWithResize:NO];
    }
    
}

-(BOOL)selectionMode {
    return _selectionMode;
}

- (NSUInteger)isSeleceted:(id)record {
    
    return [_selections indexOfObject:record];
    /*
    for(NSUInteger a=0;a<_selections.count;a++) {
        if ( [shortcut isEqualToString:[_selections objectAtIndex:a]] ) {
            return a;
        }
    }
     return NSNotFound;
     */
    
    
}

- (void)addRecordToSelection:(id)record {
    
    if ( [self isSeleceted:record] == NSNotFound ) {
        [_selections addObject:record];
    }
    
}

- (void)removeRecordFromSelection:(id)record {
    
    NSUInteger idx = [self isSeleceted:record];
    
    if ( idx != NSNotFound ) {
        [_selections removeObjectAtIndex:idx];
    };
}

- (void)onItemSelected {
    if ( _selections.count > 0 ) {
        [self addDoneButtonWithSelector:@selector(selDoneTouch:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)selDoneTouch:(id)sender {
    
    if ([self respondsToSelector:@selector(onRecordChoice:)]) {
        
        if ( _selections.count ) {
            for(int a=0;a<_selections.count;a++) {
                [(ACUIDataListVC <ACUIDataListItemsSource> *)self onRecordChoice:[_selections objectAtIndex:a]];
            }
        }
    }

    [_selections removeAllObjects];
    [self backButtonPressed:sender];
    
}

- (void) backButtonPressed:(id)sender {
    
    if ( _selections.count > 0 ) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Wybrane towary zostaną pominięte. Czy chcesz kontynuować ?", nil) delegate: self cancelButtonTitle: NSLocalizedString(@"Tak", nil)  otherButtonTitles:NSLocalizedString(@"Nie", nil),nil];
        [alertView show];
        
        return;
    }
    [super backButtonPressed:sender];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) {
        [super backButtonPressed:alertView];
    }
}

-(void)onDetailDataItem:(NSNotification *)notif {
    [self loadList];
}

-(void)onDetailDataLoadDone:(NSNotification *)notif {
    if ( self.form.refreshPanel ) {
        self.form.refreshPanel.refreshBtnHidden = NO;
        
        if ( [self respondsToSelector:@selector(getDate)]) {
            self.form.refreshPanel.date = [(ACUIDataVC <ACUIFormDataSource> *)self getDate];
        }
    }
}

@end
